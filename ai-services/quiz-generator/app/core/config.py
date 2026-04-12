import os
from dotenv import load_dotenv

load_dotenv()

MY_API_KEY = os.getenv("MY_API_KEY")
if not MY_API_KEY:
    raise ValueError("MY_API_KEY is not set")

UPLOADS_FILE = "uploads.json"
QUIZZES_FILE = "quizzes.json"
OUTPUT_FOLDER = "results"

os.makedirs(OUTPUT_FOLDER, exist_ok=True)