# =====================================================
# Imports
# =====================================================

from pathlib import Path
import logging
import shutil
import tempfile
import uuid
from typing import Optional

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse

# Internal project modules
from app.schemas import HealthResponse, ExtractResponse
from app.services.utils import ensure_dir, validate_pdf_upload
from app.services.chapters_service import export_selected_chapters
from app.services.problems_service import extract_problems_pdf
from app.services.examples_service import ExampleExtractor


# =====================================================
# Basic logging so we can see what happens in terminal
# =====================================================

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)


# =====================================================
# FastAPI App Setup
# =====================================================

app = FastAPI(
    title="Smart Textbook Extractor API",
    version="3.0.0",
    description=(
        "Backend API for extracting chapters, problems, "
        "and worked examples from textbook PDFs."
    ),
)


# =====================================================
# Allow frontend apps (website / mobile) to connect
# Later in production you can restrict domains
# =====================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# =====================================================
# Folder where generated files will be saved
# =====================================================

OUTPUT_DIR = Path("app/outputs")
ensure_dir(str(OUTPUT_DIR))


# =====================================================
# Helper: Save uploaded file temporarily
# We process it, then delete it later
# =====================================================

def save_upload(upload: UploadFile) -> Path:
    temp_dir = Path(tempfile.mkdtemp())
    file_path = temp_dir / (upload.filename or "uploaded.pdf")

    with open(file_path, "wb") as f:
        shutil.copyfileobj(upload.file, f)

    return file_path


# =====================================================
# Home Route
# Quick check that API is alive
# =====================================================

@app.get("/", tags=["System"])
def root():
    return {
        "app": "Smart Textbook Extractor API",
        "status": "running",
        "version": "3.0.0",
        "docs": "/docs",
        "health": "/health",
    }


# =====================================================
# Health Route
# Useful for frontend / deployment checks
# =====================================================

@app.get("/health", response_model=HealthResponse, tags=["System"])
def health():
    return HealthResponse(status="ok")


# =====================================================
# Extract Selected Chapters
# Example: 1,2,5-7
# =====================================================

@app.post(
    "/extract/chapters",
    response_model=ExtractResponse,
    tags=["Extraction"],
)
async def extract_chapters(
    file: UploadFile = File(...),
    chapters: str = Form(...),
):
    validate_pdf_upload(file)
    temp_pdf = save_upload(file)

    try:
        output_name = f"chapters_{uuid.uuid4().hex[:8]}.pdf"
        output_path = OUTPUT_DIR / output_name

        logging.info("Extracting chapters %s", chapters)

        exported = export_selected_chapters(
            input_pdf=str(temp_pdf),
            output_pdf=str(output_path),
            chapters_spec=chapters,
        )

        return ExtractResponse(
            success=True,
            message="Selected chapters extracted successfully.",
            file=output_name,
            download_url=f"/download/{output_name}",
            data=exported,
        )

    except Exception:
        logging.exception("Chapter extraction failed")
        raise HTTPException(
            status_code=500,
            detail="Could not extract chapters."
        )

    finally:
        shutil.rmtree(temp_pdf.parent, ignore_errors=True)


# =====================================================
# Extract Problems Section
# Usually grabs end-of-chapter problems
# =====================================================

@app.post(
    "/extract/problems",
    response_model=ExtractResponse,
    tags=["Extraction"],
)
async def extract_problems(
    file: UploadFile = File(...),
    chapters: str = Form(...),
):
    validate_pdf_upload(file)
    temp_pdf = save_upload(file)

    try:
        clean_name = Path(file.filename).stem.replace(" ", "_")

        output_name = (
            f"{clean_name}_problems_"
            f"chapters_{chapters.replace(',', '_').replace('-', 'to')}.pdf"
        )

        output_path = OUTPUT_DIR / output_name

        details = extract_problems_pdf(
            input_pdf=str(temp_pdf),
            chapters_spec=chapters,
            output_pdf=str(output_path),
          
        )

        return ExtractResponse(
            success=True,
            message="Problems extracted successfully.",
            file=output_name,
            download_url=f"/download/{output_name}",
            data=details,
        )

    finally:
        shutil.rmtree(temp_pdf.parent, ignore_errors=True)
# =====================================================
# Extract Worked Examples
# Can work on full book or chosen chapters
# =====================================================

@app.post(
    "/extract/examples",
    response_model=ExtractResponse,
    tags=["Extraction"],
)
async def extract_examples(
    file: UploadFile = File(...),
    chapters: Optional[str] = Form(None),
):
    validate_pdf_upload(file)
    temp_pdf = save_upload(file)

    try:
        output_name = f"examples_{uuid.uuid4().hex[:8]}.pdf"
        output_path = OUTPUT_DIR / output_name

        extractor = ExampleExtractor(str(temp_pdf))

        # If user selected chapters only
        if chapters:
            selected = []

            for part in chapters.split(","):
                part = part.strip()

                if not part:
                    continue

                # Handles ranges like 3-5
                if "-" in part:
                    start, end = map(int, part.split("-"))

                    if start > end:
                        start, end = end, start

                    for number in range(start, end + 1):
                        selected.append(number)

                else:
                    selected.append(int(part))

            examples = extractor.extract_from_chapters(selected)

        # If no chapters given → scan whole PDF
        else:
            import pdfplumber

            with pdfplumber.open(temp_pdf) as pdf:
                pages = list(range(1, len(pdf.pages) + 1))

            examples = extractor.extract_from_pages(pages)

        if not examples:
            raise HTTPException(
                status_code=404,
                detail="No examples found."
            )

        # Export all found examples into one PDF
        extractor.export_all_in_one(
            examples,
            str(output_path)
        )

        # Small preview for frontend
        preview = []

        for ex in examples[:10]:
            preview.append(
                {
                    "id": ex.example_id,
                    "title": ex.title,
                    "page_start": ex.page_start,
                    "page_end": ex.page_end,
                }
            )

        return ExtractResponse(
            success=True,
            message="Examples extracted successfully.",
            file=output_name,
            download_url=f"/download/{output_name}",
            data={
                "total_examples": len(examples),
                "preview": preview,
            },
        )

    except HTTPException:
        raise

    except Exception:
        logging.exception("Example extraction failed")
        raise HTTPException(
            status_code=500,
            detail="Could not extract examples."
        )

    finally:
        shutil.rmtree(temp_pdf.parent, ignore_errors=True)


# =====================================================
# Download Generated File
# Frontend uses this after extraction
# =====================================================

@app.get("/download/{filename}", tags=["Files"])
def download_file(filename: str):
    file_path = OUTPUT_DIR / filename

    if not file_path.exists():
        raise HTTPException(
            status_code=404,
            detail="File not found."
        )

    return FileResponse(
        path=file_path,
        filename=filename,
        media_type="application/pdf",
    )