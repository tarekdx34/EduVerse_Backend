import os
import re
from typing import Set

import fitz
from fastapi import HTTPException, UploadFile


NUMBER_WORDS = {
    1: "ONE",
    2: "TWO",
    3: "THREE",
    4: "FOUR",
    5: "FIVE",
    6: "SIX",
    7: "SEVEN",
    8: "EIGHT",
    9: "NINE",
    10: "TEN",
    11: "ELEVEN",
    12: "TWELVE",
    13: "THIRTEEN",
    14: "FOURTEEN",
    15: "FIFTEEN",
}

MAX_FILE_MB = 100
ALLOWED_CONTENT_TYPES = {
    "application/pdf",
    "application/x-pdf",
    "application/acrobat",
    "applications/vnd.pdf",
    "text/pdf",
    "text/x-pdf",
}


def ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def validate_pdf_upload(file: UploadFile) -> None:
    if not file.filename:
        raise HTTPException(status_code=400, detail="Missing file.")

    if not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are allowed.")

    if file.content_type and file.content_type.lower() not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(status_code=400, detail="Invalid file type. Please upload a PDF.")

    # optional size check
    current_pos = file.file.tell()
    file.file.seek(0, os.SEEK_END)
    size_bytes = file.file.tell()
    file.file.seek(current_pos)

    size_mb = size_bytes / (1024 * 1024)
    if size_mb > MAX_FILE_MB:
        raise HTTPException(
            status_code=413,
            detail=f"File is too large. Maximum allowed size is {MAX_FILE_MB} MB.",
        )


def clean_text(text: str) -> str:
    if not text:
        return ""

    replacements = {
        "\ufb00": "ff",
        "\ufb01": "fi",
        "\ufb02": "fl",
        "\ufb03": "ffi",
        "\ufb04": "ffl",
        "\u00a0": " ",
        "\u2013": "-",
        "\u2014": "-",
        "\u2212": "-",
    }

    for old, new in replacements.items():
        text = text.replace(old, new)

    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def get_page_text(doc: fitz.Document, page_index: int) -> str:
    return clean_text(doc[page_index].get_text("text", sort=True))


def parse_chapters_spec(spec: str) -> Set[int]:
    selected: Set[int] = set()

    for part in spec.split(","):
        part = part.strip()
        if not part:
            continue

        if "-" in part:
            start, end = map(int, part.split("-"))
            if start > end:
                start, end = end, start
            for value in range(start, end + 1):
                selected.add(value)
        else:
            selected.add(int(part))

    return selected


def has_next_chapter_heading(text: str, next_chapter: int) -> bool:
    upper = text.upper()

    if re.search(rf"\bCHAPTER\s+{next_chapter}\b", upper):
        return True

    if next_chapter in NUMBER_WORDS:
        word = NUMBER_WORDS[next_chapter]
        if re.search(rf"\bCHAPTER\s+{word}\b", upper):
            return True

    return False


def is_spread_page(page: fitz.Page) -> bool:
    rect = page.rect
    ratio = rect.width / rect.height

    if ratio < 1.55:
        return False

    text = page.get_text("text")
    if not text or len(text.strip()) < 150:
        return False

    mid = rect.width / 2

    left_rect = fitz.Rect(0, 0, mid - 12, rect.height)
    right_rect = fitz.Rect(mid + 12, 0, rect.width, rect.height)

    left_text = page.get_text("text", clip=left_rect)
    right_text = page.get_text("text", clip=right_rect)

    if len(left_text.strip()) < 80 or len(right_text.strip()) < 80:
        return False

    gutter_rect = fitz.Rect(mid - 18, 0, mid + 18, rect.height)
    gutter_text = page.get_text("text", clip=gutter_rect)

    if len(gutter_text.strip()) > 40:
        return False

    return True


def split_spread_pdf(input_pdf: str) -> str:
    src = fitz.open(input_pdf)

    sample_pages = min(len(src), 12)
    hits = 0

    for i in range(sample_pages):
        if is_spread_page(src[i]):
            hits += 1

    if hits < max(2, sample_pages // 3):
        src.close()
        return input_pdf

    out = fitz.open()

    try:
        for i in range(len(src)):
            page = src[i]
            rect = page.rect

            if is_spread_page(page):
                mid = rect.width / 2

                left_clip = fitz.Rect(0, 0, mid, rect.height)
                right_clip = fitz.Rect(mid, 0, rect.width, rect.height)

                left_page = out.new_page(width=mid, height=rect.height)
                left_page.show_pdf_page(left_page.rect, src, i, clip=left_clip)

                right_page = out.new_page(width=mid, height=rect.height)
                right_page.show_pdf_page(right_page.rect, src, i, clip=right_clip)
            else:
                out.insert_pdf(src, from_page=i, to_page=i)

        fd, temp_path = None, None
        import tempfile
        fd, temp_path = tempfile.mkstemp(suffix=".pdf")
        os.close(fd)

        out.save(temp_path, garbage=4, deflate=True)
        return temp_path

    finally:
        out.close()
        src.close()