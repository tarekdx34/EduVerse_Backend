from fastapi import FastAPI, UploadFile, File
import shutil
import os

# import your function
from attendance_backend2 import get_attendance_from_image

app = FastAPI()

@app.post("/attendance")
async def attendance(image: UploadFile = File(...)):
    # Save uploaded image temporarily
    temp_path = f"temp_{image.filename}"
    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(image.file, buffer)

    # Call your backend function
    marked_ids, recognized_faces = get_attendance_from_image(temp_path, save_excel=True)

    # Delete temp image
    if os.path.exists(temp_path):
        os.remove(temp_path)

    return {
        "marked_ids": marked_ids,
        "recognized_faces": recognized_faces
    }
