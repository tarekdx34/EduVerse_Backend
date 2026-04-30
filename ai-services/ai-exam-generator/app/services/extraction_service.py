from app.utils.pdf_utils import extract_text, split_text
from app.utils.prompt_templates import extraction_prompt
from app.services.model_service import ask_model
from app.core.config import CHUNK_SIZE


def extract_examples_from_pdf(file_path: str) -> str:
    full_text = extract_text(file_path)
    chunks = split_text(full_text, CHUNK_SIZE)

    if not chunks:
        return "No text could be extracted from this PDF."

    for chunk in chunks:
        if "Example" in chunk:
            return ask_model(extraction_prompt(chunk))

    return ask_model(extraction_prompt(chunks[0]))
