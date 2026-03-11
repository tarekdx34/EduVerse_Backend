import pdfplumber
import re

def clean_text(text: str) -> str:
    lines = text.split("\n")
    cleaned_lines = []

    for line in lines:
        stripped = line.strip()

        # Remove long horizontal lines (___, ----, etc.)
        if re.match(r"^[-_]{5,}$", stripped):
            continue

        # Remove lines that are mostly symbols
        if re.match(r"^[^a-zA-Z0-9]{8,}$", stripped):
            continue

        cleaned_lines.append(line)

    return "\n".join(cleaned_lines)


def extract_text(file_path: str) -> str:
    text = ""
    with pdfplumber.open(file_path) as pdf:
        for page in pdf.pages:
            page_text = page.extract_text()
            if page_text:
                text += page_text + "\n"

    return clean_text(text)

def split_text(text: str, chunk_size: int):
    return [text[i:i + chunk_size] for i in range(0, len(text), chunk_size)]