from app.utils.pdf_utils import extract_text, split_text
from app.utils.prompt_templates import mcq_from_text_prompt
from app.services.model_service import ask_model
from app.core.config import CHUNK_SIZE


def generate_mcq_from_pdf(file_path: str, count: int, difficulty: str):
    full_text = extract_text(file_path)
    chunks = split_text(full_text, CHUNK_SIZE)

    results = ""

    for chunk in chunks:
        if count <= 0:
            break

        prompt = mcq_from_text_prompt(count, difficulty, chunk)
        response = ask_model(prompt)

        results += response + "\n"
        count = 0  # Stop after first successful generation

    return results