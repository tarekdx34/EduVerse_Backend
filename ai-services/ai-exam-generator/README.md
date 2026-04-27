# How to run
1. Download https://ollama.com/
2. Update the model in main.py (the used model is gemma3:4b)
3. pip install fastapi uvicorn python-multipart PyPDF2 ollama
4. uvicorn app.main:app --reload
5. http://localhost:8000
6. swagger UI: http://localhost:8000/docs



