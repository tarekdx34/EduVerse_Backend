import re
import json
import pdfplumber
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Optional, List
from pypdf import PdfReader, PdfWriter

# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------

@dataclass
class Example:
    example_id: str
    title: str
    body: str
    page_start: int
    page_end: int
    raw_segments: list[str] = field(default_factory=list)

# ---------------------------------------------------------------------------
# Regex
# ---------------------------------------------------------------------------

EXAMPLE_HEADER_RE = re.compile(
    r"(?:Worked\s+|Solved\s+)?Exam(?:ple|PLE)\s*\.?\s*(\d+[\.\-]?\d*)",
    re.IGNORECASE,
)

SECTION_BREAK_RE = re.compile(
    r"^\s*(?:Chapter|Section|Exercise|Problem Set|Summary|References|"
    r"Bibliography|Appendix|Index|Table of Contents)\b",
    re.IGNORECASE,
)

CHAPTER_HEADER_RE = re.compile(
    r"^\s*(?:Chapter|CHAPTER)\s+(\d+)",
    re.IGNORECASE,
)

MIN_SEGMENT_CHARS = 40
COLUMN_SPLIT_TOLERANCE = 0.08

# ---------------------------------------------------------------------------
# Layout helpers (FIXED VERSION)
# ---------------------------------------------------------------------------

def _detect_column_split(page) -> Optional[float]:
    words = page.extract_words()
    if not words:
        return None

    page_width = page.width
    centre = page_width / 2

    xs = sorted(w["x0"] for w in words)

    best_gap = 0
    best_x = None
    lo = centre - COLUMN_SPLIT_TOLERANCE * page_width
    hi = centre + COLUMN_SPLIT_TOLERANCE * page_width

    for i in range(len(xs) - 1):
        if lo <= xs[i] <= hi or lo <= xs[i + 1] <= hi:
            gap = xs[i + 1] - xs[i]
            if gap > best_gap:
                best_gap = gap
                best_x = (xs[i] + xs[i + 1]) / 2

    if best_x is not None and best_gap > 0.03 * page_width:
        return best_x
    return None


def _extract_columns(page) -> list[str]:
    """
    SAFE version that handles weird PDF bounding boxes
    """
    try:
        split_x = _detect_column_split(page)

        if split_x is None:
            return [page.extract_text(layout=True) or ""]

        # ✅ USE REAL BBOX (fixes your error)
        x0, top, x1, bottom = page.bbox

        # clamp split inside page
        split_x = max(x0 + 1, min(split_x, x1 - 1))

        left_bbox  = (x0, top, split_x, bottom)
        right_bbox = (split_x, top, x1, bottom)

        left_text = ""
        right_text = ""

        try:
            left_text = page.within_bbox(left_bbox).extract_text(layout=True) or ""
        except:
            pass

        try:
            right_text = page.within_bbox(right_bbox).extract_text(layout=True) or ""
        except:
            pass

        # fallback if something weird happens
        if not left_text and not right_text:
            return [page.extract_text(layout=True) or ""]

        return [left_text, right_text]

    except Exception:
        # 🔥 HARD FALLBACK (never crash again)
        return [page.extract_text(layout=True) or ""]

# ---------------------------------------------------------------------------
# Core class
# ---------------------------------------------------------------------------

class ExampleExtractor:

    def __init__(self, pdf_path: str | Path, verbose: bool = False):
        self.pdf_path = Path(pdf_path)
        self.verbose = verbose

    # ------------------------------------------------------------------
    # Chapter detection
    # ------------------------------------------------------------------

    def detect_chapters(self) -> dict:
        chapters = {}

        with pdfplumber.open(self.pdf_path) as pdf:
            for i, page in enumerate(pdf.pages):
                text = page.extract_text() or ""
                lines = text.splitlines()

                for line in lines[:5]:
                    match = CHAPTER_HEADER_RE.search(line)
                    if match:
                        chapters[int(match.group(1))] = i + 1

        return chapters

    def get_chapter_ranges(self) -> dict:
        chapters = self.detect_chapters()
        if not chapters:
            return {}

        sorted_chapters = sorted(chapters.items())
        ranges = {}

        with pdfplumber.open(self.pdf_path) as pdf:
            total_pages = len(pdf.pages)

        for i, (ch, start) in enumerate(sorted_chapters):
            if i + 1 < len(sorted_chapters):
                end = sorted_chapters[i + 1][1] - 1
            else:
                end = total_pages

            ranges[ch] = (start, end)

        return ranges

    # ------------------------------------------------------------------
    # Extraction APIs
    # ------------------------------------------------------------------

    def extract_from_chapters(self, selected_chapters: List[int]) -> List[Example]:
        ranges = self.get_chapter_ranges()

        if not ranges:
            raise ValueError("No chapters detected.")

        selected_pages = []

        for ch in selected_chapters:
            if ch in ranges:
                start, end = ranges[ch]
                selected_pages.extend(range(start, end + 1))

        return self.extract_from_pages(selected_pages)

    def extract_from_pages(self, page_numbers: List[int]) -> List[Example]:
        segments = []
        pending = None

        with pdfplumber.open(self.pdf_path) as pdf:
            for page_num in page_numbers:
                page = pdf.pages[page_num - 1]
                columns = _extract_columns(page)

                for col_idx, col_text in enumerate(columns):
                    if not col_text.strip():
                        continue

                    parts = EXAMPLE_HEADER_RE.split(col_text)

                    pre_text = parts[0]
                    if pending and pre_text.strip():
                        if not SECTION_BREAK_RE.search(pre_text):
                            pending["text"] += "\n" + pre_text
                        else:
                            segments.append(pending)
                            pending = None

                    i = 1
                    while i + 1 <= len(parts) - 1:
                        ex_id = parts[i].strip()
                        ex_body = parts[i + 1]

                        if pending:
                            segments.append(pending)

                        pending = {
                            "example_id": f"Example {ex_id}",
                            "text": ex_body,
                            "page": page_num,
                            "column": col_idx,
                        }
                        i += 2

        if pending:
            segments.append(pending)

        return self._stitch_segments(segments)

    # ------------------------------------------------------------------
    # Stitching
    # ------------------------------------------------------------------

    def _stitch_segments(self, segments):
        if not segments:
            return []

        examples = []
        current = segments[0].copy()
        current["pages"] = [current.pop("page")]
        current["raw_segments"] = [current["text"]]

        for seg in segments[1:]:
            if seg["example_id"] == current["example_id"]:
                current["text"] += "\n" + seg["text"]
                current["pages"].append(seg["page"])
                current["raw_segments"].append(seg["text"])
            else:
                examples.append(self._finalise(current))
                current = seg.copy()
                current["pages"] = [current.pop("page")]
                current["raw_segments"] = [current["text"]]

        examples.append(self._finalise(current))
        return examples

    def _finalise(self, acc):
        return Example(
            example_id=acc["example_id"],
            title=acc["example_id"],
            body=acc["text"],
            page_start=min(acc["pages"]),
            page_end=max(acc["pages"]),
            raw_segments=acc["raw_segments"],
        )

    # ------------------------------------------------------------------
    # Export
    # ------------------------------------------------------------------

    def export_all_in_one(self, examples, output_path):
        reader = PdfReader(self.pdf_path)
        writer = PdfWriter()

        seen = set()

        for ex in examples:
            for p in range(ex.page_start, ex.page_end + 1):
                if p not in seen:
                    seen.add(p)
                    writer.add_page(reader.pages[p - 1])

        with open(output_path, "wb") as f:
            writer.write(f)
