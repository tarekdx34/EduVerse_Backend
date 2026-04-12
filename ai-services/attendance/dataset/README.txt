Attendance AI — reference face dataset (local only)

Put one reference image per student user_id (numeric filename):
  {userId}.jpg
Example: 12345.jpg  (matches course_enrollments.user_id)

Populate automatically (from repo root EduVerse-Backend, with venv active):

  cd ai-services/attendance
  ..\.venv\Scripts\python.exe fetch_section_faces.py --audit-only

  ..\.venv\Scripts\python.exe fetch_section_faces.py ^
    --course-code AH102 --semester-name "Fall 2025" --section-number 1 ^
    --env ..\..\.env

Or use a known section_id and MySQL .env (no JWT):

  ..\.venv\Scripts\python.exe fetch_section_faces.py --section-id 26 --env ..\..\.env

Or roster from Nest API (Instructor/TA JWT):

  ..\.venv\Scripts\python.exe fetch_section_faces.py --section-id 26 ^
    --api-url http://localhost:3001 --bearer-token YOUR_JWT

That script downloads test portraits from randomuser.me (not real student photos),
deduplicates by image hash, saves {userId}.jpg, and writes section_{id}_group.jpg
(a grid of all faces) for attendance testing.

Do not commit real faces to Git; image files here are gitignored except this README.
