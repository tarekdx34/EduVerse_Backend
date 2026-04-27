FROM python:3.10-slim

# Create a non-root user (required by HF Spaces)
RUN useradd -m -u 1000 user
USER user

ENV PATH="/home/user/.local/bin:$PATH"
ENV HOME=/home/user

WORKDIR /app

# Copy and install dependencies
COPY --chown=user requirements.txt .
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Copy application code
COPY --chown=user . /app

# HF Spaces only allows writing to /tmp
ENV UPLOADS_FILE=/tmp/uploads.json
ENV QUIZZES_FILE=/tmp/quizzes.json
ENV OUTPUT_FOLDER=/tmp/outputs

# HF Spaces requires port 7860
EXPOSE 7860
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7860"]
