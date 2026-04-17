import re
import fitz
from dataclasses import dataclass
from typing import List, Optional

from app.services.utils import clean_text, get_page_text, parse_chapters_spec


WORD_TO_NUM = {
    "ONE": 1,
    "TWO": 2,
    "THREE": 3,
    "FOUR": 4,
    "FIVE": 5,
    "SIX": 6,
    "SEVEN": 7,
    "EIGHT": 8,
    "NINE": 9,
    "TEN": 10,
    "ELEVEN": 11,
    "TWELVE": 12,
    "THIRTEEN": 13,
    "FOURTEEN": 14,
    "FIFTEEN": 15,
}


@dataclass
class Chapter:
    number: int
    title: str
    start_page: int
    end_page: int


def parse_chapter_number(raw: str) -> Optional[int]:
    raw = raw.strip().upper()
    if raw.isdigit():
        return int(raw)
    return WORD_TO_NUM.get(raw)


def detect_from_toc(doc: fitz.Document):
    toc = doc.get_toc(simple=False)
    rows = []

    for item in toc:
        if len(item) < 3:
            continue

        title = str(item[1]).strip()
        page = int(item[2]) - 1

        match = re.search(r"\bCHAPTER\s+([A-Z0-9]+)\b", title, re.I)
        if not match:
            continue

        chapter_number = parse_chapter_number(match.group(1))
        if chapter_number is None:
            continue

        rows.append((chapter_number, title, page))

    return rows


def detect_from_pages(doc: fitz.Document):
    rows = []

    for p in range(min(len(doc), 250)):
        text = get_page_text(doc, p)
        if not text:
            continue

        top = "\n".join(text.splitlines()[:12])

        match = re.search(r"\bCHAPTER\s+([A-Z0-9]+)\b", top, re.I)
        if not match:
            continue

        chapter_number = parse_chapter_number(match.group(1))
        if chapter_number is None:
            continue

        title = top.replace("\n", " ")[:80].strip()
        rows.append((chapter_number, title, p))

    return rows


def build_chapters(doc: fitz.Document) -> List[Chapter]:
    rows = detect_from_toc(doc)

    if len(rows) < 2:
        rows = detect_from_pages(doc)

    rows = sorted(rows, key=lambda x: x[2])

    dedup = []
    seen = set()
    for row in rows:
        if row[0] not in seen:
            dedup.append(row)
            seen.add(row[0])

    chapters: List[Chapter] = []

    for i, row in enumerate(dedup):
        num, title, start = row
        end = dedup[i + 1][2] - 1 if i < len(dedup) - 1 else len(doc) - 1
        chapters.append(Chapter(num, title, start, end))

    return chapters


def export_selected_chapters(input_pdf: str, output_pdf: str, chapters_spec: str) -> List[dict]:
    doc = fitz.open(input_pdf)

    try:
        chapters = build_chapters(doc)
        if not chapters:
            raise Exception("No chapters detected.")

        selected = parse_chapters_spec(chapters_spec)

        out = fitz.open()
        exported = []

        try:
            for ch in chapters:
                if ch.number not in selected:
                    continue

                out.insert_pdf(doc, from_page=ch.start_page, to_page=ch.end_page)
                exported.append(
                    {
                        "chapter": ch.number,
                        "title": ch.title,
                        "start_page": ch.start_page + 1,
                        "end_page": ch.end_page + 1,
                    }
                )

            if not exported:
                raise Exception("No chapters selected.")

            out.save(output_pdf, garbage=4, deflate=True)

        finally:
            out.close()

        return exported

    finally:
        doc.close()