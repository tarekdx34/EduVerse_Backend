from app.services.model_service import ask_model
from app.utils.prompt_templates import assistant_prompt

def doctor_assistant(message: str):
    prompt = assistant_prompt(message)
    return ask_model(prompt)
