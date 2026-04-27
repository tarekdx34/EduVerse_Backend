FROM python:3.10-slim

# System deps for dlib/face_recognition runtime.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    g++ \
    libopenblas-dev \
    liblapack-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# HF Spaces best practice: run as non-root uid 1000.
RUN useradd -m -u 1000 user
USER user

ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    CMAKE_BUILD_PARALLEL_LEVEL=1 \
    MAKEFLAGS=-j1

WORKDIR /app

COPY --chown=user requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /app/requirements.txt

COPY --chown=user . /app

# Docker Space required port
EXPOSE 7860

CMD ["uvicorn", "api_main:app", "--host", "0.0.0.0", "--port", "7860"]
