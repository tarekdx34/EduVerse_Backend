# AI microservices (Python)

| Folder | Run from backend root |
|--------|------------------------|
| **attendance** | `npm run attendance` (after `npm run attendance:install`) |
| **quiz-generator** | `cd ai-services/quiz-generator`, create `.venv`, `pip install -r requirements.txt`, then `uvicorn app.main:app --reload --port 8001` |

**Nest:** `AI_ATTENDANCE_SERVICE_URL` → e.g. `http://127.0.0.1:8000`

**Layout:** All Python apps live under `ai-services/`. The old top-level folder `ai-attendance-system` was removed—use `ai-services/attendance` only.
