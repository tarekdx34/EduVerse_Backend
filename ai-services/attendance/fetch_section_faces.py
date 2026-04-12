"""
Dev/test helper: download one portrait per student in a course section into dataset/
and build a synthetic "class photo" by tiling those same images.

Roster source (first match wins):
  1) --user-ids
  2) GET /api/enrollments/section/:id/students with --api-url + --bearer-token
  3) MySQL: course_enrollments for --section-id (or resolve via --course-code + --semester-name + --section-number)

Portraits: https://randomuser.me/ (not real student photos; 1:1 mapped to user_id for testing).

Examples:
  python fetch_section_faces.py --section-id 26
  python fetch_section_faces.py --course-code AH102 --semester-name "Fall 2025" --section-number 1 --env ../../.env
  python fetch_section_faces.py --section-id 26 --api-url http://localhost:3001 --bearer-token YOUR_JWT
  python fetch_section_faces.py --user-ids 57,7,8
  python fetch_section_faces.py --audit-only
  python fetch_section_faces.py --rebuild-composite-only --section-id 26
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Install Pillow: pip install pillow", file=sys.stderr)
    sys.exit(1)

try:
    import pymysql
except ImportError:
    pymysql = None


def load_env_file(path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    if not path.is_file():
        return out
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        k, _, v = line.partition("=")
        k, v = k.strip(), v.strip().strip('"').strip("'")
        out[k] = v
    return out


def fetch_user_ids_from_db(section_id: int, env: dict[str, str]) -> list[int]:
    if pymysql is None:
        raise RuntimeError("Install pymysql: pip install pymysql")
    port = env.get("DB_PORT")
    if not port:
        raise RuntimeError("DB_PORT missing in .env")
    conn = pymysql.connect(
        host=env.get("DB_HOST", "localhost"),
        port=int(port),
        user=env.get("DB_USERNAME", "root"),
        password=env.get("DB_PASSWORD", ""),
        database=env.get("DB_DATABASE", "eduverse_db"),
        cursorclass=pymysql.cursors.DictCursor,
    )
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT DISTINCT user_id
                FROM course_enrollments
                WHERE section_id = %s AND enrollment_status = 'enrolled'
                ORDER BY user_id
                """,
                (section_id,),
            )
            rows = cur.fetchall()
    finally:
        conn.close()
    return [int(r["user_id"]) for r in rows]


def resolve_section_id_from_db(
    course_code: str,
    semester_name: str,
    section_number: str,
    env: dict[str, str],
) -> int:
    """Match course_sections row: AH102 + Fall 2025 + section 1."""
    if pymysql is None:
        raise RuntimeError("Install pymysql: pip install pymysql")
    port = env.get("DB_PORT")
    if not port:
        raise RuntimeError("DB_PORT missing in .env")
    conn = pymysql.connect(
        host=env.get("DB_HOST", "localhost"),
        port=int(port),
        user=env.get("DB_USERNAME", "root"),
        password=env.get("DB_PASSWORD", ""),
        database=env.get("DB_DATABASE", "eduverse_db"),
        cursorclass=pymysql.cursors.DictCursor,
    )
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT cs.section_id AS id
                FROM course_sections cs
                INNER JOIN courses c ON c.course_id = cs.course_id
                INNER JOIN semesters s ON s.semester_id = cs.semester_id
                WHERE c.course_code = %s AND s.semester_name = %s AND cs.section_number = %s
                LIMIT 2
                """,
                (course_code.strip(), semester_name.strip(), str(section_number).strip()),
            )
            rows = cur.fetchall()
    finally:
        conn.close()
    if not rows:
        raise RuntimeError(
            f"No section found for course_code={course_code!r} semester_name={semester_name!r} section_number={section_number!r}"
        )
    if len(rows) > 1:
        raise RuntimeError("Multiple sections matched; narrow course/semester/section.")
    return int(rows[0]["id"])


def http_get_json_auth(url: str, token: str | None, timeout: float = 60.0) -> object:
    headers = {
        "User-Agent": "EduVerse-fetch-section-faces/1.0",
        "Accept": "application/json",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def fetch_user_ids_from_api(base_url: str, section_id: int, token: str) -> list[int]:
    """GET {base}/api/enrollments/section/{id}/students — needs Instructor/TA/Admin JWT."""
    base = base_url.rstrip("/")
    url = f"{base}/api/enrollments/section/{section_id}/students"
    data = http_get_json_auth(url, token)
    if not isinstance(data, list):
        raise RuntimeError(f"Unexpected API response (expected list): {type(data)}")
    seen: set[int] = set()
    out: list[int] = []
    for row in data:
        if not isinstance(row, dict):
            continue
        uid = row.get("userId") or row.get("user_id")
        if uid is None:
            continue
        i = int(uid)
        if i not in seen:
            seen.add(i)
            out.append(i)
    out.sort()
    return out


def http_get_json(url: str, timeout: float = 30.0) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": "EduVerse-fetch-section-faces/1.0"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def _sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def _collect_other_hashes(dataset_dir: Path, skip_user_id: int | None) -> set[str]:
    """SHA256 of each numeric *.jpg except skip_user_id (so we can replace that file)."""
    out: set[str] = set()
    for p in dataset_dir.glob("*.jpg"):
        if not p.stem.isdigit():
            continue
        uid = int(p.stem)
        if skip_user_id is not None and uid == skip_user_id:
            continue
        out.add(_sha256_file(p))
    return out


def audit_dataset(dataset_dir: Path) -> tuple[int, int, list[tuple[str, str, str]]]:
    """
    Scan numeric *.jpg in dataset_dir.
    Returns (total_files, unique_image_count, list of duplicate pairs (hash, path_a, path_b)).
    """
    dataset_dir = dataset_dir.resolve()
    hashes: dict[str, Path] = {}
    dupes: list[tuple[str, str, str]] = []
    total = 0
    for p in sorted(dataset_dir.glob("*.jpg")):
        if not p.stem.isdigit():
            continue
        total += 1
        h = _sha256_file(p)
        if h in hashes:
            dupes.append((h, str(hashes[h]), str(p)))
        else:
            hashes[h] = p
    return total, len(hashes), dupes


def download_portrait_for_user(
    user_id: int,
    dest: Path,
    *,
    dataset_dir: Path | None = None,
    avoid_duplicate_of_others: bool = False,
    max_attempts: int = 30,
) -> None:
    """Fetch one random portrait; map 1:1 to user_id for stable filenames.

    If avoid_duplicate_of_others is True, retry until the JPEG bytes differ from every
    other numeric *.jpg in dataset_dir (excluding this user_id). Helps when the API
    returns the same portrait twice.
    """
    dest.parent.mkdir(parents=True, exist_ok=True)
    forbidden: set[str] = set()
    if avoid_duplicate_of_others and dataset_dir is not None:
        forbidden = _collect_other_hashes(dataset_dir, user_id)

    for attempt in range(max_attempts):
        url = "https://randomuser.me/api/?results=1&inc=picture"
        data = http_get_json(url)
        pic_url = data["results"][0]["picture"]["large"]
        req = urllib.request.Request(pic_url, headers={"User-Agent": "EduVerse-fetch-section-faces/1.0"})
        raw = urllib.request.urlopen(req, timeout=30).read()
        tmp = dest.with_suffix(dest.suffix + ".part")
        tmp.write_bytes(raw)
        im = Image.open(tmp).convert("RGB")
        im.save(dest, format="JPEG", quality=92)
        tmp.unlink(missing_ok=True)

        if not avoid_duplicate_of_others or not forbidden:
            return

        fp = _sha256_file(dest)
        if fp not in forbidden:
            return

        print(
            f"  user_id={user_id}: duplicate of another portrait (attempt {attempt + 1}/{max_attempts}), retrying...",
            file=sys.stderr,
        )

    raise RuntimeError(
        f"Could not fetch a unique portrait for user_id={user_id} after {max_attempts} attempts"
    )


def build_grid_composite(image_paths: list[Path], out_path: Path, cols: int = 6, cell_w: int = 200) -> None:
    if not image_paths:
        return
    images: list[Image.Image] = []
    for p in image_paths:
        im = Image.open(p).convert("RGB")
        h = int(cell_w * im.height / im.width)
        images.append(im.resize((cell_w, h), Image.Resampling.LANCZOS))
    rows = (len(images) + cols - 1) // cols
    row_heights: list[int] = []
    for r in range(rows):
        chunk = images[r * cols : (r + 1) * cols]
        row_heights.append(max(im.height for im in chunk))
    total_h = sum(row_heights)
    canvas = Image.new("RGB", (cols * cell_w, total_h), (32, 32, 32))
    y = 0
    for r in range(rows):
        chunk = images[r * cols : (r + 1) * cols]
        x = 0
        for im in chunk:
            y_off = y + (row_heights[r] - im.height) // 2
            canvas.paste(im, (x, y_off))
            x += cell_w
        y += row_heights[r]
    out_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out_path, format="JPEG", quality=90)


def main() -> None:
    parser = argparse.ArgumentParser(description="Download dataset face images for a section + composite.")
    parser.add_argument("--section-id", type=int, default=26, help="course_sections.section_id")
    parser.add_argument(
        "--course-code",
        type=str,
        default="",
        help='With --semester-name and --section-number, resolve section id from DB (e.g. AH102)',
    )
    parser.add_argument(
        "--semester-name",
        type=str,
        default="",
        help='Semester display name as in DB (e.g. "Fall 2025")',
    )
    parser.add_argument(
        "--section-number",
        type=str,
        default="",
        help='Section number string (e.g. "1")',
    )
    parser.add_argument(
        "--api-url",
        type=str,
        default="",
        help="Nest base URL (e.g. http://localhost:3001). With --bearer-token, roster from GET /api/enrollments/section/:id/students",
    )
    parser.add_argument(
        "--bearer-token",
        type=str,
        default="",
        help="JWT for Instructor/TA/Admin (used with --api-url)",
    )
    parser.add_argument(
        "--user-ids",
        type=str,
        default="",
        help="Comma-separated user IDs (highest priority; skips API/DB roster)",
    )
    parser.add_argument(
        "--env",
        type=Path,
        default=Path(__file__).resolve().parents[2] / ".env",
        help="Path to Nest .env for DB_* (default: EduVerse-Backend/.env)",
    )
    parser.add_argument(
        "--dataset-dir",
        type=Path,
        default=Path(__file__).resolve().parent / "dataset",
        help="Output folder for {userId}.jpg",
    )
    parser.add_argument(
        "--composite",
        type=Path,
        default=None,
        help="Path for tiled group JPEG (default: dataset/section_{id}_group.jpg)",
    )
    parser.add_argument("--cols", type=int, default=6, help="Grid columns for composite")
    parser.add_argument(
        "--fallback-user-ids",
        type=str,
        default="57",
        help="If roster is empty, use these comma-separated IDs",
    )
    parser.add_argument(
        "--refresh-user-ids",
        type=str,
        default="",
        help="Comma-separated IDs to re-download only (e.g. 13 after a duplicate). Composite uses full roster.",
    )
    parser.add_argument(
        "--rebuild-composite-only",
        action="store_true",
        help="Do not download; rebuild section_N_group.jpg from existing dataset files in roster order.",
    )
    parser.add_argument(
        "--audit-only",
        action="store_true",
        help="Only scan dataset/*.jpg for counts and duplicate images; no download.",
    )
    args = parser.parse_args()

    env = load_env_file(args.env)
    dataset_dir = args.dataset_dir.resolve()

    section_id = args.section_id
    if args.course_code.strip() and args.semester_name.strip() and str(args.section_number).strip():
        try:
            section_id = resolve_section_id_from_db(
                args.course_code,
                args.semester_name,
                str(args.section_number),
                env,
            )
            print(f"Resolved section_id={section_id} ({args.course_code} / {args.semester_name} / sec {args.section_number})", file=sys.stderr)
        except Exception as e:
            print(f"Could not resolve section from DB: {e}", file=sys.stderr)
            sys.exit(1)

    if args.audit_only:
        if not dataset_dir.is_dir():
            print(f"Dataset dir missing: {dataset_dir}", file=sys.stderr)
            sys.exit(1)
        total, unique, dupes = audit_dataset(dataset_dir)
        print(f"Dataset: {dataset_dir}")
        print(f"  Numeric .jpg files: {total}")
        print(f"  Unique images (by file hash): {unique}")
        if dupes:
            print(f"  Duplicate image bytes ({len(dupes)} extra file(s)):", file=sys.stderr)
            for _h, a, b in dupes:
                print(f"    same bytes: {a}  <->  {b}", file=sys.stderr)
        else:
            print("  No duplicate image hashes across different student files.")
        sys.exit(0)

    if args.user_ids.strip():
        user_ids = [int(x.strip()) for x in args.user_ids.split(",") if x.strip()]
    elif args.api_url.strip() and args.bearer_token.strip():
        try:
            user_ids = fetch_user_ids_from_api(args.api_url.strip(), section_id, args.bearer_token.strip())
        except Exception as e:
            print(f"API roster failed ({e}); try DB or --user-ids.", file=sys.stderr)
            sys.exit(1)
        if not user_ids:
            print("API returned no students.", file=sys.stderr)
            sys.exit(1)
    else:
        user_ids = []
        try:
            user_ids = fetch_user_ids_from_db(section_id, env)
        except Exception as e:
            print(f"DB query failed ({e}); use --api-url + --bearer-token, --user-ids, or fix .env / pymysql.", file=sys.stderr)
            user_ids = []
        if not user_ids:
            user_ids = [int(x.strip()) for x in args.fallback_user_ids.split(",") if x.strip()]
            print(f"Using fallback user IDs: {user_ids}", file=sys.stderr)

    if not user_ids:
        print("No user IDs to process.", file=sys.stderr)
        sys.exit(1)

    refresh_set: set[int] = set()
    if args.refresh_user_ids.strip():
        refresh_set = {int(x.strip()) for x in args.refresh_user_ids.split(",") if x.strip()}

    saved: list[Path] = []

    if args.rebuild_composite_only:
        for uid in user_ids:
            p = dataset_dir / f"{uid}.jpg"
            if not p.is_file():
                print(f"Missing {p}; cannot build composite.", file=sys.stderr)
                sys.exit(1)
            saved.append(p)
    else:
        targets = refresh_set if refresh_set else set(user_ids)
        if refresh_set:
            missing = refresh_set - set(user_ids)
            if missing:
                print(f"--refresh-user-ids contains IDs not in roster: {missing}", file=sys.stderr)
                sys.exit(1)

        for uid in sorted(targets):
            dest = dataset_dir / f"{uid}.jpg"
            print(f"Downloading portrait for user_id={uid} -> {dest}")
            try:
                download_portrait_for_user(
                    uid,
                    dest,
                    dataset_dir=dataset_dir,
                    avoid_duplicate_of_others=True,
                )
            except (urllib.error.URLError, OSError, KeyError, IndexError, RuntimeError) as e:
                print(f"  Failed: {e}", file=sys.stderr)

        for uid in user_ids:
            p = dataset_dir / f"{uid}.jpg"
            if not p.is_file():
                print(f"Missing reference image {p}; run without --refresh-user-ids to fetch all.", file=sys.stderr)
                sys.exit(1)
            saved.append(p)

    if not saved:
        print("No images for composite.", file=sys.stderr)
        sys.exit(1)

    comp = args.composite
    if comp is None:
        comp = dataset_dir / f"section_{section_id}_group.jpg"
    else:
        comp = comp.resolve()

    print(f"Building composite -> {comp}")
    build_grid_composite(saved, comp, cols=args.cols)
    total, unique, dupes = audit_dataset(dataset_dir)
    print(
        f"Dataset check: {total} numeric .jpg file(s), {unique} unique image hash(es).",
        file=sys.stderr,
    )
    if dupes:
        print("Warning: duplicate image bytes between files:", file=sys.stderr)
        for _h, a, b in dupes:
            print(f"  {a} <-> {b}", file=sys.stderr)
    print("Done.")


if __name__ == "__main__":
    main()
