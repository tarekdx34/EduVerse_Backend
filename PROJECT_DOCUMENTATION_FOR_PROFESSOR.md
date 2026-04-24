# EduVerse — Project Documentation (For Professor)

## Project Overview

**EduVerse** is a role-based education SaaS platform consisting of a React + Vite frontend and a Nest/Node backend (Docker-friendly). The platform supports courses, assignments, labs, quizzes, attendance, scheduling, notifications, and role-based dashboards for students, instructors, TAs, and admins.

This single-file documentation is designed as a compact guide you can present to your professor. It contains a summary of the system, how to run it locally, key design/architecture notes, where to find detailed docs in the repository, and recommended demo steps.

## Repositories / Components

- **Backend**: repository root (this folder). Core API, database migrations, and scripts. See [eduverse-backend/README.md](eduverse-backend/README.md#L1).
- **Frontend**: separate folder at [eduverse](../Frontend/eduverse). Web app built with React + Vite. See [eduverse/README.md](../Frontend/eduverse/README.md#L1).

## Tech Stack

- Frontend: React, Vite, Tailwind CSS, React Router, React Query
- Backend: Node/NestJS (Dockerized), PostgreSQL (SQL files and migrations present)
- Tests: Vitest (frontend), Jest/others may be present in backend

## Quick Demo Goals (what to show your professor)

1. Landing and login flows for two roles (student and instructor)
2. Instructor creates an assignment or publishes content
3. Student submits an assignment and instructor views grading workflow
4. Schedule/attendance view and a simple analytics/dashboard screen
5. Show deployment readiness: Dockerfile, migrations, and build scripts

## Local Setup (minimal steps)

Prerequisites:

- Node.js 18+ (frontend)
- npm or yarn
- Python/venv only if backend scripts require it (see backend README)
- PostgreSQL locally if you want a full DB-backed demo (SQL files provided)
- Docker (optional, recommended for isolating services)

Backend (this repository)

1. Install dependencies (if Node backend):

```bash
cd "d:/Graduation Project/Backend/eduverse-backend"
npm install
```

2. If there is a local virtual environment or other setup script, consult [eduverse-backend/README.md](eduverse-backend/README.md#L1) and the `scripts/` directory.

3. Database: Use the provided SQL files to create schema. Example files include `eduverse_db.sql` and many `DB_CHANGES_*.sql` migration files in the root. To load a file into PostgreSQL:

```bash
psql -U youruser -d yourdb -f eduverse_db.sql
```

4. Start backend (example command — adjust to repo's scripts):

```bash
npm run start:dev
# or docker-compose up (if a docker setup exists)
```

Frontend

1. Install and run:

```bash
cd "d:/Graduation Project/Frontend/eduverse"
npm install
npm run dev
```

2. The frontend uses a dev proxy that forwards `/api` to the backend (see Vite config). Ensure backend is running (default proxy target: `http://localhost:8081`).

## Important Files & Documentation (where to find more)

- Project README (backend): [eduverse-backend/README.md](eduverse-backend/README.md#L1)
- Frontend README: [eduverse/README.md](../Frontend/eduverse/README.md#L1)
- API collections: `EduVerse_APIDog_Collection.json` and `EduVerse_Postman_Collection.json` in the backend root — useful for live API demonstration.
- Database SQL and migrations: many files like `eduverse_db.sql`, `DB_CHANGES_*.sql` in backend root.
- Scripts and integrations: `scripts/` and `ai-services/` folders contain integrations and utility code.

## Architecture Summary

- Multi-service architecture with a REST API backend and single-page application frontend.
- Backend exposes role-based endpoints for courses, assignments, schedules, labs, quizzes, attendance, and analytics.
- Frontend consumes the API and renders role-aware dashboards and workflows.
- Data is persisted in PostgreSQL; migrations and SQL files are included.

## Running a Short Demo (recommended sequence)

1. Start database (Postgres) and load schema from `eduverse_db.sql`.
2. Start backend: `npm run start:dev` in [eduverse-backend](eduverse-backend/README.md#L1).
3. Start frontend: `npm run dev` in [eduverse](../Frontend/eduverse/README.md#L1).
4. Open the frontend URL (Vite typically uses `http://localhost:3000`) and log in using seeded/test users (if provided) or create accounts via the UI.
5. Walk through the demo goals listed above.

## Known Documentation & Notes

- There are several detailed docs in the backend root (e.g., `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md`, `SCHEDULE_FRONTEND_INTEGRATION_GUIDE.md`, `STUDENT_COURSE_TEAM_ERROR_ANALYSIS.md`). Consult these for deep dives on each area.
- MCP and experimental tools live in `mcp-servers/` in the frontend repo.

## Deliverables to Show

- This consolidated document (file you are reading).
- Live running demo (frontend + backend) — follow demo steps above.
- API Postman/APIDog collections: `EduVerse_APIDog_Collection.json` and `EduVerse_Postman_Collection.json`.
- Key design docs in repository (linked above).

## Troubleshooting Tips

- If the frontend dev server can't reach the backend, verify `vite.config.js` proxy and backend port (backend default proxy target: `http://localhost:8081`).
- Build issues on Vercel or CI: check import path casing and Node version (Node 18+ recommended).
- If DB migrations fail, inspect the `DB_CHANGES_*.sql` files for ordering and dependency issues.

---

If you want, I can:

- Extract and paste selected sections from the detailed docs into this file, or
- Create a short slide-style README with screenshots and exact demo user credentials (if seed data exists), or
- Commit this file and open a PR with the consolidated documentation.

Tell me which of the above you prefer and I'll continue.
