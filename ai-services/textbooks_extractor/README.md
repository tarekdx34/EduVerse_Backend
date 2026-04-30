# Smart Textbook Extractor API

A production-ready FastAPI backend for extracting textbook chapters, problem sections, and worked examples from PDF textbooks.

---
---

# Project Structure

```text
app/
├── main.py
├── schemas.py
├── outputs/
└── services/
    ├── utils.py
    ├── chapters_service.py
    ├── problems_service.py
    └── examples_service.py
## Installation

```bash
pip install -r requirements.txt
```
## Project Files Overview

- **app/main.py**  
  Main FastAPI application file. Defines API routes, handles uploads, responses, downloads, and connects all backend services.

- **app/schemas.py**  
  Contains Pydantic models used for request/response validation and standardized API output formatting.

- **app/services/utils.py**  
  Shared helper functions for file validation, text cleaning, chapter parsing, folder creation, and reusable utilities.

- **app/services/chapters_service.py**  
  Handles textbook chapter detection and exports selected chapters into a new PDF.

- **app/services/problems_service.py**  
  Detects and extracts end-of-chapter problems/exercises into a clean downloadable PDF.

- **app/services/examples_service.py**  
  Detects and extracts worked examples from textbook pages, including multi-page examples.

- **app/outputs/**  
  Stores all generated output files such as extracted chapters, problems, and examples PDFs.

- **requirements.txt**  
  Lists all Python dependencies required to run the project.

- **README.md**  
  Project documentation containing installation steps, usage instructions, API endpoints, and project structure.
  
## Run the Server

```bash
uvicorn app.main:app --reload
```

Server will start at:

http://127.0.0.1:8000

Swagger docs:

http://127.0.0.1:8000/docs

---

## Endpoints

### GET /

Returns API status and available endpoints.

### GET /health

Health check endpoint.

```json
{
  "status": "ok"
}
```

### POST /extract/chapters

Form Data:
- file: PDF textbook
- chapters: 1 / 1,2,3 / 1-3 / 1,3,5-7

### POST /extract/problems

Form Data:
- file: PDF textbook
- chapters: chapter selection
- auto_split: true/false

### POST /extract/examples

Form Data:
- file: PDF textbook
- chapters: optional

### GET /download/{filename}

Downloads generated PDF files.

---

## Recommended requirements.txt

```txt
fastapi
uvicorn
python-multipart
pymupdf
pdfplumber
pypdf
pydantic
```

