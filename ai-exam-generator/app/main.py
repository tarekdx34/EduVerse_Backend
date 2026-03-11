from fastapi import FastAPI, UploadFile, File
from app.services.mcq_service import generate_mcq_from_pdf
from app.services.assistant_service import doctor_assistant
from app.services.extraction_service import extract_examples_from_pdf
import os
from pydantic import BaseModel
from typing import List

app = FastAPI(title="Smart Exam System")

from app.services.mcq_service import generate_mcq_from_pdf

class MCQQuestion(BaseModel):
    question_id: int
    question: str
    options: List[str]
    correct_answer: str

class MCQResponse(BaseModel):
    status: str
    exam: dict

class AssistantRequest(BaseModel):
    message: str

class AssistantResponse(BaseModel):
    status: str
    assistant_reply: dict

class ExampleResponse(BaseModel):
    status: str
    examples: str

@app.post("/mcq-from-file/", response_model=MCQResponse)
async def mcq_from_file(file: UploadFile = File(...), count: int = 5, difficulty = "medium"):
    file_path = f"temp_{file.filename}"

    with open(file_path, "wb") as f:
        f.write(await file.read())

    result = generate_mcq_from_pdf(file_path, count, difficulty)

    os.remove(file_path)

    return {
        "status": "success",
        "exam": {
                    "num_questions": count,
                    "difficulty": difficulty,
                    "questions": result
        }
    }

@app.post("/assistant/", response_model=AssistantResponse)
async def assistant(request: AssistantRequest):
    result = doctor_assistant(request.message)
    return {
        "status": "success",
        "assistant_reply": {
        "message": result
        }
    }


@app.post("/extract-examples/", response_model=ExampleResponse)
async def extract_examples(file: UploadFile = File(...)):
    file_path = f"temp_{file.filename}"
    with open(file_path, "wb") as f:
        f.write(await file.read())

    result = extract_examples_from_pdf(file_path)
    os.remove(file_path)

    return {
        "status": "success",
        "examples": result
    }
