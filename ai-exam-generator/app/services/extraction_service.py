import re
from app.utils.pdf_utils import extract_text

def extract_examples_from_pdf(file_path: str):
    full_text = extract_text(file_path)

    # Regex to extract only blocks starting with "Example"
    pattern = r"(Example\s+\d+[\s\S]*?)(?=Example\s+\d+|$)"
    matches = re.findall(pattern, full_text)

    return "\n\n".join(matches)
