"""
Generate a small synthetic textbook PDF for testing textbooks_extractor.
Run from repo root or textbooks_extractor:
  textbooks_extractor\\.venv\\Scripts\\python scripts/gen_synthetic_textbook.py
"""
from pathlib import Path

import fitz

ROOT = Path(__file__).resolve().parent.parent
FIXTURES = ROOT / "fixtures"
OUT = FIXTURES / "synthetic_10ch_textbook.pdf"

W, H = 595, 842
MARGIN = 72
BOX = fitz.Rect(MARGIN, MARGIN, W - MARGIN, H - MARGIN)


def add_page(doc: fitz.Document, heading: str, body: str) -> None:
    page = doc.new_page(width=W, height=H)
    text = f"{heading}\n\n{body}"
    page.insert_textbox(BOX, text, fontsize=11, fontname="helv")


def main() -> None:
    FIXTURES.mkdir(parents=True, exist_ok=True)

    doc = fitz.open()

    add_page(
        doc,
        "Synthetic Textbook (local test fixture)",
        "Ten short chapters with embedded PDF TOC, worked examples, and end-of-chapter "
        "problem sections. Generated for textbooks_extractor smoke tests.",
    )

    toc_lines = ["TABLE OF CONTENTS", ""]
    chapter_starts_1based: list[int] = []
    p = 3
    for n in range(1, 11):
        chapter_starts_1based.append(p)
        toc_lines.append(f"Chapter {n} — Short Topic {n} ........................ page {p}")
        p += 2

    add_page(doc, "TABLE OF CONTENTS", "\n".join(toc_lines))

    for n in range(1, 11):
        body_a = (
            f"This chapter introduces topic {n} using plain text only. "
            f"It mentions feedback, stability, and a simple block diagram story.\n\n"
            f"Example {n}.1\n"
            f"Given state x and input u, let y = {n} * x + u. "
            f"If x = 2 and u = 1 then y = {2 * n + 1}. "
            f"This numeric illustration is intentionally trivial.\n\n"
            f"Summary: chapter {n} ends with a one-line recap before problems."
        )
        add_page(doc, f"Chapter {n}\nShort Topic {n}", body_a)

        body_b = (
            f"Closing notes for chapter {n} (reading objectives).\n\n"
            "PROBLEMS\n\n"
            f"{n}.1 What is the value of y in Example {n}.1 if x = 0 and u = 0?\n"
            f"{n}.2 True or false: negative feedback can reduce steady-state error.\n"
            f"{n}.3 List two components you would place in a closed-loop diagram.\n"
        )
        add_page(doc, f"Chapter {n} (continued)", body_b)

    toc_entries: list[list] = [
        [1, "Title", 1],
        [1, "Table of Contents", 2],
    ]
    for n in range(1, 11):
        toc_entries.append([1, f"Chapter {n} - Short Topic {n}", chapter_starts_1based[n - 1]])

    doc.set_toc(toc_entries)
    doc.save(OUT)
    doc.close()
    print(f"Wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
