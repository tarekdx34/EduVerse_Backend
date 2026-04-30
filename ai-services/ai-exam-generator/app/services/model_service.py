import ollama
from app.core.config import MODEL_NAME

def ask_model(prompt: str) -> str:
    response = ollama.chat(
        model=MODEL_NAME,
        messages=[{"role": "user", "content": prompt}]
    )
    return response["message"]["content"]
