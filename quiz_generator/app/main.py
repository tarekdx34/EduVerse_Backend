from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.responses import FileResponse
import os
import uuid
import logging

from app.core.config import UPLOADS_FILE, QUIZZES_FILE, OUTPUT_FOLDER
from app.utils.file_utils import (
    save_to_json,
    load_from_json,
    extract_text_from_file,
    save_as_txt,
    save_as_pdf
)
from app.services.quiz_service import generate_quiz_from_text

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

app = FastAPI(
    title="Quiz Generator API",
    description="Generates different types of quiz questions from uploaded PDF, DOCX, or TXT files.",
    version="2.3.0"
)

uploads = {}
quizzes = {}

uploads = load_from_json(UPLOADS_FILE, uploads)
quizzes = load_from_json(QUIZZES_FILE, quizzes)

@app.post("/api/v1/upload", status_code=201)
async def upload_file(file: UploadFile = File(...)):
    file_ext = file.filename.rsplit('.', 1)[-1].lower()
    if file_ext not in ["pdf", "docx", "txt"]:
        raise HTTPException(status_code=400, detail="Unsupported file type. Please upload a PDF, DOCX, or TXT.")

    upload_id = str(uuid.uuid4())
    temp_path = f"temp_{upload_id}.{file_ext}"

    try:
        with open(temp_path, "wb") as f:
            content = await file.read()
            if not content:
                raise ValueError("The uploaded file is empty.")
            f.write(content)

        text = extract_text_from_file(temp_path)
        if not text:
            raise ValueError("No text could be extracted from the file.")

        uploads[upload_id] = text
        save_to_json(uploads, UPLOADS_FILE)

        return {
            "uploadId": upload_id,
            "status": "text_extracted",
            "text_preview": text[:200] + "..." if len(text) > 200 else text,
            "total_characters": len(text)
        }
    except Exception as e:
        logging.error(f"Upload failed: {e}")
        raise HTTPException(status_code=500, detail="An internal server error occurred during file upload.")
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)

@app.post("/api/v1/generate", status_code=201)
async def generate_quiz(
    uploadId: str = Form(...),
    numQuestions: int = Form(5, gt=0, le=20),
    questionType: str = Form("MCQ"),
    difficulty: str = Form("medium"),
    saveAsFiles: bool = Form(False)
):
    if uploadId not in uploads:
        raise HTTPException(status_code=404, detail="Upload ID not found.")

    valid_types = ["MCQ", "FillBlank", "Explain"]
    if questionType not in valid_types:
        raise HTTPException(status_code=400, detail=f"Invalid questionType. Choose from {valid_types}.")

    text = uploads[uploadId]
    quiz_id = str(uuid.uuid4())

    try:
        final_questions, answer_key, raw_ai_output = generate_quiz_from_text(
            text=text,
            num_questions=numQuestions,
            question_type=questionType,
            difficulty=difficulty
        )
    except Exception as e:
        logging.error(f"Quiz generation failed: {e}")
        raise HTTPException(status_code=500, detail="Failed to generate questions. Please try again.")

    if not final_questions:
        raise HTTPException(status_code=500, detail="Could not parse any valid questions from the AI response.")

    quiz_data = {
        "quizId": quiz_id,
        "uploadId": uploadId,
        "questionType": questionType,
        "difficulty": difficulty,
        "questions": final_questions,
        "answerKey": answer_key
    }

    quizzes[quiz_id] = quiz_data
    save_to_json(quizzes, QUIZZES_FILE)

    response = {"quizId": quiz_id, "status": "completed", "numQuestions": len(final_questions)}

    if saveAsFiles and raw_ai_output:
        base_name = f"{questionType}_{quiz_id}"
        txt_path = save_as_txt(raw_ai_output, f"{base_name}.txt", OUTPUT_FOLDER)
        pdf_path = save_as_pdf(raw_ai_output, f"{base_name}.pdf", OUTPUT_FOLDER)
        response["files"] = {
            "txt": f"/api/v1/download/{os.path.basename(txt_path)}",
            "pdf": f"/api/v1/download/{os.path.basename(pdf_path)}"
        }

    return response

@app.get("/api/v1/quiz/{quiz_id}")
async def get_quiz(quiz_id: str):
    if quiz_id not in quizzes:
        raise HTTPException(status_code=404, detail="Quiz ID not found.")
    return quizzes[quiz_id]

@app.get("/api/v1/download/{filename}")
async def download_file(filename: str):
    file_path = os.path.join(OUTPUT_FOLDER, filename)
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found.")
    return FileResponse(file_path, media_type='application/octet-stream', filename=filename)

@app.get("/api/v1/uploads")
async def list_uploads():
    return {"uploads": [{"uploadId": uid, "preview": text[:100] + "..."} for uid, text in uploads.items()]}

@app.delete("/api/v1/upload/{upload_id}")
async def delete_upload(upload_id: str):
    if upload_id not in uploads:
        raise HTTPException(status_code=404, detail="Upload ID not found.")
    del uploads[upload_id]
    save_to_json(uploads, UPLOADS_FILE)
    return {"status": "deleted", "uploadId": upload_id}

@app.get("/")
def root():
    return {"message": "Quiz Generator API is running!", "docs": "/docs"}