import os
from pathlib import Path

from dotenv import load_dotenv

# quiz-generator cwd when run via npm: ai-services/quiz-generator
_here = Path(__file__).resolve().parent.parent.parent
_backend_root = _here.parent.parent
# Shared backend .env first, then optional quiz-local overrides
load_dotenv(_backend_root / ".env")
load_dotenv(_here / ".env", override=True)

MY_API_KEY = os.getenv("MY_API_KEY")
if not MY_API_KEY:
    raise ValueError("MY_API_KEY is not set")

UPLOADS_FILE = "uploads.json"
QUIZZES_FILE = "quizzes.json"
OUTPUT_FOLDER = "results"

os.makedirs(OUTPUT_FOLDER, exist_ok=True)
