AI Exam Generator

A FastAPI-based microservice that generates quizzes from uploaded
documents using an AI model.

The API accepts PDF, DOCX, or TXT files, extracts their text, and
generates different types of questions such as: - Multiple Choice
Questions (MCQ) - Fill in the Blank - Explanation Questions

The questions are generated using the Groq LLM (Llama 3.3 70B) via
LangChain.

  ----------
  FEATURES
  ----------

-   Upload documents (PDF, DOCX, TXT)
-   Automatic text extraction
-   AI-generated quizzes
-   Multiple question types
-   Separate answer key generation
-   Optional download as TXT or PDF
-   REST API with FastAPI
-   Interactive API documentation

  --------------
  INSTALLATION
  --------------

1.  Clone the repository

git clone cd ai-exam-generator

2.  Create a virtual environment

python -m venv .venv

3.  Activate the environment

Windows (PowerShell) .venv

4.  Install dependencies

pip install -r requirements.txt

  -----------------------
  ENVIRONMENT VARIABLES
  -----------------------

Create a .env file in the project root:

MY_API_KEY=your_groq_api_key_here

This key is required to access the Groq LLM.

  -----------------
  RUNNING THE API
  -----------------

Start the server:

uvicorn app.main:app â€“reload

The API will run at:

http://127.0.0.1:8000

Interactive API documentation:

http://127.0.0.1:8000/docs

  ---------------
  API ENDPOINTS
  ---------------

POST /api/v1/upload Upload a document (PDF, DOCX, TXT)

Example response:

{ uploadId: 1234-uuid, status: text_extracted,
total_characters: 5000 }

------------------------------------------------------------------------

POST /api/v1/generate

Form parameters: uploadId numQuestions questionType difficulty
saveAsFiles

Example response:

{ quizId: uuid, status: completed, numQuestions: 5 }

------------------------------------------------------------------------

GET /api/v1/quiz/{quiz_id} Returns the generated quiz with questions and
answer key.

------------------------------------------------------------------------

GET /api/v1/download/{filename} Download the generated quiz file.

------------------------------------------------------------------------

GET /api/v1/uploads List all uploaded documents.

------------------------------------------------------------------------

DELETE /api/v1/upload/{upload_id} Delete an uploaded document.

  ------------------
  EXAMPLE WORKFLOW
  ------------------
1.  Upload a file
2.  Generate a quiz
3.  Retrieve the quiz results
  -------------------
  TECHNOLOGIES USED
  -------------------

FastAPI LangChain Groq LLM (Llama 3.3 70B) Python pdfplumber python-docx
FPDF

  -------
  NOTES
  -------

-   Uploaded text and quizzes are stored locally in JSON files.
-   This implementation uses in-memory storage.
-   For production use, a database is recommended.

