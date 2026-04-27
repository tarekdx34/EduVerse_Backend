import os
import fitz
import re
from dataclasses import dataclass
from typing import List, Optional

from app.services.utils import (
    get_page_text,
    parse_chapters_spec,
    has_next_chapter_heading,
    split_spread_pdf,
)


@dataclass
class Chapter:
    number: int
    title: str
    start_page: int
    end_page: int


def build_chapters(doc: fitz.Document) -> List[Chapter]:
    toc = doc.get_toc(simple=False)
    rows = []

    for item in toc:
        if len(item) < 3:
            continue

        title = str(item[1]).strip()
        page = int(item[2]) - 1

        match = re.search(r"\bchapter\s+(\d+)\b", title, re.I)
        if match:
            rows.append((int(match.group(1)), title, page))

    if not rows:
        for i in range(min(len(doc), 150)):
            text = get_page_text(doc, i)
            top = "\n".join(text.splitlines()[:12])
            match = re.search(r"\bchapter\s+(\d+)\b", top, re.I)
            if match:
                rows.append((int(match.group(1)), top[:80], i))

    rows = sorted(rows, key=lambda x: x[2])

    dedup = []
    seen = set()

    for row in rows:
        if row[0] not in seen:
            dedup.append(row)
            seen.add(row[0])

    chapters: List[Chapter] = []

    for i, row in enumerate(dedup):
        number, title, start = row
        end = dedup[i + 1][2] - 1 if i < len(dedup) - 1 else len(doc) - 1
        chapters.append(Chapter(number, title, start, end))

    return chapters


def page_has_real_problems_heading(doc: fitz.Document, page_index: int) -> bool:
    text = get_page_text(doc, page_index).upper()
    return bool(re.search(r"(?m)^\s*PROBLEMS\s*$", text))


def find_problem_start(doc: fitz.Document, chapter: Chapter) -> Optional[int]:
    start = chapter.start_page
    end = min(len(doc) - 1, chapter.end_page + 2)
    scan_start = start + int((end - start) * 0.60)

    for p in range(scan_start, end + 1):
        if page_has_real_problems_heading(doc, p):
            return p

    for p in range(start, end + 1):
        if page_has_real_problems_heading(doc, p):
            return p

    return None


def collect_problem_pages(doc: fitz.Document, chapter: Chapter, start: Optional[int]) -> List[int]:
    if start is None:
        return []

    pages: List[int] = []
    end = min(len(doc) - 1, chapter.end_page + 20)
    next_ch = chapter.number + 1

    for p in range(start, end + 1):
        text = get_page_text(doc, p).upper()

        if p > start:
            first_lines = "\n".join(text.splitlines()[:10])
            if has_next_chapter_heading(first_lines, next_ch):
                break

        if page_has_real_problems_heading(doc, p):
            pages.append(p)
            continue

        if re.search(rf"\b{chapter.number}\.\d+\b", text):
            pages.append(p)
            continue

    return pages


def find_problems_y(page: fitz.Page):
    data = page.get_text("dict")
    ys = []

    for block in data.get("blocks", []):
        if "lines" not in block:
            continue

        for line in block["lines"]:
            spans = line.get("spans", [])
            text = "".join(s.get("text", "") for s in spans).strip().upper()
            text = re.sub(r"\s+", " ", text)

            if text == "PROBLEMS":
                values = [s["bbox"][1] for s in spans if "bbox" in s]
                if values:
                    ys.append(min(values))

    if ys:
        return max(ys)

    return None


def export_problem_pages(src_path: str, out_path: str, chapter_pages_map: dict) -> None:
    src = fitz.open(src_path)
    out = fitz.open()

    try:
        for chapter_number in sorted(chapter_pages_map):
            pages = chapter_pages_map[chapter_number]
            if not pages:
                continue

            first_page = True

            for p in pages:
                page = src[p]
                rect = page.rect

                left = 18
                right = rect.width - 18
                bottom = rect.height - 10

                if first_page:
                    y = find_problems_y(page)
                    top_y = 35 if y is None else max(0, y - 3)
                    first_page = False
                else:
                    top_y = 40

                clip = fitz.Rect(left, top_y, right, bottom)

                new_page = out.new_page(width=clip.width, height=clip.height)
                new_page.show_pdf_page(
                    fitz.Rect(0, 0, clip.width, clip.height),
                    src,
                    p,
                    clip=clip,
                )

        out.save(out_path, garbage=4, deflate=True)

    finally:
        out.close()
        src.close()


def extract_problems_pdf(
    input_pdf: str,
    chapters_spec: str,
    output_pdf: str,
    auto_split: bool = True,
) -> List[dict]:
    temp_file = None

    if not os.path.exists(input_pdf):
        raise Exception(f"Input file not found: {input_pdf}")

    try:
        working_pdf = input_pdf

        if auto_split:
            processed = split_spread_pdf(input_pdf)
            if processed != input_pdf:
                temp_file = processed
                working_pdf = processed

        doc = fitz.open(working_pdf)

        try:
            chapters = build_chapters(doc)
            chapter_map = {c.number: c for c in chapters}
            selected = sorted(parse_chapters_spec(chapters_spec))

            chapter_pages_map = {}
            details = []

            for number in selected:
                if number not in chapter_map:
                    continue

                chapter = chapter_map[number]
                start_page = find_problem_start(doc, chapter)
                pages = collect_problem_pages(doc, chapter, start_page)

                chapter_pages_map[number] = pages
                details.append(
                    {
                        "chapter": number,
                        "start_page": None if start_page is None else start_page + 1,
                        "problem_pages": [p + 1 for p in pages],
                    }
                )

            all_pages = sorted({p for pages in chapter_pages_map.values() for p in pages})
            if not all_pages:
                raise Exception("No problem pages found.")

            export_problem_pages(working_pdf, output_pdf, chapter_pages_map)
            return details

        finally:
            doc.close()

    finally:
        if temp_file and os.path.exists(temp_file):
            os.remove(temp_file)