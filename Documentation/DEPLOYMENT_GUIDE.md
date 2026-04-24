# Deployment Guide: EduVerse Server & AI Microservices

This guide outlines how to deploy your NestJS backend and Python AI services using free-tier platforms.

## 1. Architecture Overview
*   **Main Backend**: NestJS (Node.js) -> **Render**
*   **Database**: MySQL -> **Aiven** or **TiDB Cloud**
*   **AI Service (Quiz)**: FastAPI (Python) -> **Render**
*   **AI Service (Attendance)**: FastAPI (Python) -> **Hugging Face Spaces (Docker)** or **Render** (Note: Attendance is heavy due to OpenCV/dlib).

---

## 2. Step 1: Database Setup (MySQL)
Render does not offer a free MySQL tier (only Postgres). I recommend **Aiven** or **TiDB Cloud**.

### Aiven (Recommended)
1.  Go to [aiven.io](https://aiven.io/) and create a free account.
2.  Create a **MySQL** service (Free Tier).
3.  Copy the **Service URI** or connection details (Host, Port, User, Password).
4.  Run your migrations/SQL script (`eduverse_db.sql`) against this database to initialize the tables.

---

## 3. Step 2: Deploying Main Backend (NestJS)
**Platform**: [Render](https://render.com/)

1.  **Connect GitHub**: Connect your repository to Render.
2.  **New Web Service**: Select your repository.
3.  **Configuration**:
    *   **Root Directory**: `.` (leave default)
    *   **Environment**: `Node`
    *   **Build Command**: `npm install && npm run build`
    *   **Start Command**: `npm run start:prod`
    *   **Instance Type**: `Free`
4.  **Environment Variables**:
    Add the following to the **Environment** tab:
    *   `DB_HOST`: (From Aiven)
    *   `DB_PORT`: `3306`
    *   `DB_USERNAME`: (From Aiven)
    *   `DB_PASSWORD`: (From Aiven)
    *   `DB_DATABASE`: `defaultdb`
    *   `JWT_SECRET`: (Your secret)
    *   `QUIZ_SERVICE_URL`: (The URL of the Quiz AI service after deploying it)
    *   `ATTENDANCE_SERVICE_URL`: (The URL of the Attendance AI service)

---

## 4. Step 3: Deploying Quiz Generator (AI)
**Platform**: [Render](https://render.com/)

1.  **New Web Service**: Select the same repository.
2.  **Configuration**:
    *   **Name**: `eduverse-quiz-ai`
    *   **Root Directory**: `ai-services/quiz-generator`
    *   **Environment**: `Python`
    *   **Build Command**: `pip install -r requirements.txt`
    *   **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port 10000`
3.  **Environment Variables**:
    *   `MY_API_KEY`: (Your Groq API Key)

---

## 5. Step 4: Deploying Attendance Service (AI)
**Note**: This service uses `face-recognition` (dlib) and `opencv`, which require a lot of RAM (Render's free tier is 512MB).

### Option A: Render (If it fits)
*   **Root Directory**: `ai-services/attendance`
*   **Build Command**: `pip install -r requirements.txt`
*   **Start Command**: `uvicorn api_main:app --host 0.0.0.0 --port 10000`
*   *Warning: This may fail during build or run due to memory limits.*

### Option B: Hugging Face Spaces (Recommended for heavy AI)
Hugging Face provides free Docker hosting with more RAM.
1.  Create a new **Space** on [Hugging Face](https://huggingface.co/spaces).
2.  Select **Docker** template.
3.  Create a `Dockerfile` in `ai-services/attendance` (or use the one provided below).
4.  Upload your `attendance` folder content.

**Example Dockerfile for Attendance:**
```dockerfile
FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libopenblas-dev \
    liblapack-dev \
    libx11-dev \
    libgtk-3-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "api_main:app", "--host", "0.0.0.0", "--port", "7860"]
```

---

## 6. Important Considerations
1.  **Cold Starts**: Render's free tier spins down after 15 mins of inactivity. The first request might take 30+ seconds.
2.  **CORS**: Ensure your NestJS server allows the frontend URL and the AI service URLs.
3.  **Security**: Do NOT commit your `.env` file. Use Render/Aiven's environment variable dashboards.
4.  **Database URL**: If you use Aiven, remember to set `SSL: { rejectUnauthorized: false }` in your TypeORM config if it requires a secure connection.

---

## 7. Alternative: Railway.app
If you have a few dollars (or GitHub Student Pack), **Railway** is much easier because:
*   It detects everything automatically.
*   It supports MySQL, Node, and Python in one dashboard.
*   It doesn't "sleep" like Render.
