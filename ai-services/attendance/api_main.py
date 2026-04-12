from fastapi import FastAPI, UploadFile, File, HTTPException
import shutil
import os
import traceback
import uuid

# import your function
from attendance_backend2 import get_attendance_from_image

app = FastAPI()


def _json_safe_faces(recognized_faces: list) -> list[dict]:
    """face_recognition returns numpy scalars and tuples — JSON encoding fails with 500 if not converted."""
    out: list[dict] = []
    for f in recognized_faces:
        loc = f.get("location")
        if loc is not None:
            loc = [int(x) for x in loc]
        conf = f.get("confidence")
        if conf is not None:
            conf = float(conf)
        out.append(
            {
                "name": str(f.get("name", "Unknown")),
                "confidence": conf,
                "location": loc,
            }
        )
    return out


@app.post("/attendance")
async def attendance(image: UploadFile = File(...)):
    # Stable temp name (avoid odd characters in original filename on Windows)
    suffix = os.path.splitext(image.filename or "")[1] or ".jpg"
    temp_path = f"temp_upload_{uuid.uuid4().hex}{suffix}"
    try:
        with open(temp_path, "wb") as buffer:
            shutil.copyfileobj(image.file, buffer)

        marked_ids, recognized_faces = get_attendance_from_image(temp_path, save_excel=True)

        return {
            "marked_ids": [str(x) for x in marked_ids],
            "recognized_faces": _json_safe_faces(recognized_faces),
        }
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e)) from e
    finally:
        if os.path.exists(temp_path):
            try:
                os.remove(temp_path)
            except OSError:
                pass
