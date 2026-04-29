import re
import fitz
import pdfplumber
from dataclasses import dataclass, field
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
# Chapter detection (ported from chapters_service.py)
# Uses fitz: tries TOC first, falls back to page scanning.
# Supports both numeric and word-based chapter numbers (e.g. "Chapter ONE").
# ---------------------------------------------------------------------------

WORD_TO_NUM = {
    "ONE": 1, "TWO": 2, "THREE": 3, "FOUR": 4, "FIVE": 5,
    "SIX": 6, "SEVEN": 7, "EIGHT": 8, "NINE": 9, "TEN": 10,
    "ELEVEN": 11, "TWELVE": 12, "THIRTEEN": 13, "FOURTEEN": 14, "FIFTEEN": 15,
}


def _parse_chapter_number(raw: str) -> Optional[int]:
    raw = raw.strip().upper()
    if raw.isdigit():
        return int(raw)
    return WORD_TO_NUM.get(raw)


def _get_page_text(doc: fitz.Document, page_index: int) -> str:
    try:
        return doc[page_index].get_text("text")
    except Exception:
        return ""


def _detect_chapters_from_toc(doc: fitz.Document) -> list:
    """Phase 1: read chapter entries straight from the PDF's embedded TOC."""
    toc = doc.get_toc(simple=False)
    rows = []

    for item in toc:
        if len(item) < 3:
            continue

        title = str(item[1]).strip()
        page  = int(item[2]) - 1  # fitz TOC pages are 1-based

        match = re.search(r"\bCHAPTER\s+([A-Z0-9]+)\b", title, re.I)
        if not match:
            continue

        number = _parse_chapter_number(match.group(1))
        if number is None:
            continue

        rows.append((number, title, page))

    return rows


def _detect_chapters_from_pages(doc: fitz.Document) -> list:
    """Phase 2 fallback: scan the first 250 pages for a chapter heading."""
    rows = []

    for p in range(min(len(doc), 250)):
        text = _get_page_text(doc, p)
        if not text:
            continue

        # Only inspect the top of the page to avoid false positives
        top = "\n".join(text.splitlines()[:12])

        match = re.search(r"\bCHAPTER\s+([A-Z0-9]+)\b", top, re.I)
        if not match:
            continue

        number = _parse_chapter_number(match.group(1))
        if number is None:
            continue

        title = top.replace("\n", " ")[:80].strip()
        rows.append((number, title, p))

    return rows


def _build_chapter_ranges(pdf_path: Path) -> dict:
    """
    Returns {chapter_number: (start_page_1based, end_page_1based)}.
    Uses fitz for detection (TOC → page scan) then converts to 1-based
    page numbers so they align with pdfplumber's page numbering.
    """
    doc = fitz.open(str(pdf_path))

    try:
        rows = _detect_chapters_from_toc(doc)

        if len(rows) < 2:
            rows = _detect_chapters_from_pages(doc)

        total_pages = len(doc)

    finally:
        doc.close()

    if not rows:
        return {}

    # Sort by page, deduplicate chapter numbers
    rows = sorted(rows, key=lambda x: x[2])
    dedup = []
    seen = set()
    for row in rows:
        if row[0] not in seen:
            dedup.append(row)
            seen.add(row[0])

    # Build (start, end) ranges — fitz pages are 0-based, convert to 1-based
    ranges = {}
    for i, (number, _title, start_0) in enumerate(dedup):
        end_0 = dedup[i + 1][2] - 1 if i < len(dedup) - 1 else total_pages - 1
        # Convert to 1-based for pdfplumber compatibility
        ranges[number] = (start_0 + 1, end_0 + 1)

    return ranges

# ---------------------------------------------------------------------------
# Example detection regexes
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

MIN_SEGMENT_CHARS = 40
COLUMN_SPLIT_TOLERANCE = 0.08

# ---------------------------------------------------------------------------
# Layout helpers
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
    """Extract text columns from a page, with safe fallback."""
    try:
        split_x = _detect_column_split(page)

        if split_x is None:
            return [page.extract_text(layout=True) or ""]

        x0, top, x1, bottom = page.bbox
        split_x = max(x0 + 1, min(split_x, x1 - 1))

        left_text = right_text = ""

        try:
            left_text = page.within_bbox((x0, top, split_x, bottom)).extract_text(layout=True) or ""
        except Exception:
            pass

        try:
            right_text = page.within_bbox((split_x, top, x1, bottom)).extract_text(layout=True) or ""
        except Exception:
            pass

        if not left_text and not right_text:
            return [page.extract_text(layout=True) or ""]

        return [left_text, right_text]

    except Exception:
        return [page.extract_text(layout=True) or ""]

# ---------------------------------------------------------------------------
# Core class
# ---------------------------------------------------------------------------

class ExampleExtractor:

    def __init__(self, pdf_path: str | Path, verbose: bool = False):
        self.pdf_path = Path(pdf_path)
        self.verbose = verbose

    # ------------------------------------------------------------------
    # Chapter range API (now backed by the robust fitz-based detector)
    # ------------------------------------------------------------------

    def get_chapter_ranges(self) -> dict:
        """
        Returns {chapter_number: (start_page, end_page)} with 1-based page
        numbers, using TOC-first then page-scan detection (same logic as
        chapters_service.py and problems_service.py).
        """
        return _build_chapter_ranges(self.pdf_path)

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

        if not selected_pages:
            raise ValueError(
                f"None of the requested chapters {selected_chapters} were found. "
                f"Detected chapters: {sorted(ranges.keys())}"
            )

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
                        ex_id   = parts[i].strip()
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
