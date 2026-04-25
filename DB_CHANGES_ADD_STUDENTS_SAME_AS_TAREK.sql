-- Adds new students and enrolls them in the same enrolled sections as student.tarek@example.com
-- Safe to run multiple times.

START TRANSACTION;

SET @source_email := 'student.tarek@example.com';
SET @source_user_id := (
  SELECT user_id
  FROM users
  WHERE email = @source_email
  LIMIT 1
);
SET @student_role_id := (
  SELECT role_id
  FROM roles
  WHERE role_name = 'student'
  LIMIT 1
);

DROP TEMPORARY TABLE IF EXISTS tmp_new_students;
CREATE TEMPORARY TABLE tmp_new_students (
  email VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL
);

INSERT INTO tmp_new_students (email, first_name, last_name)
VALUES
  ('student.clone01@example.com', 'Ahmed', 'Hassan'),
  ('student.clone02@example.com', 'Omar', 'Mostafa'),
  ('student.clone03@example.com', 'Youssef', 'Mahmoud'),
  ('student.nour.ashraf@example.com', 'Nour', 'Ashraf'),
  ('student.mariam.saad@example.com', 'Mariam', 'Saad'),
  ('student.ziad.khaled@example.com', 'Ziad', 'Khaled'),
  ('student.salma.hany@example.com', 'Salma', 'Hany'),
  ('student.karim.nabil@example.com', 'Karim', 'Nabil'),
  ('student.hana.wael@example.com', 'Hana', 'Wael'),
  ('student.tamer.essam@example.com', 'Tamer', 'Essam'),
  ('student.dina.ayman@example.com', 'Dina', 'Ayman'),
  ('student.adam.sherif@example.com', 'Adam', 'Sherif'),
  ('student.laila.fathy@example.com', 'Laila', 'Fathy');

-- Update names if users already exist.
UPDATE users u
JOIN tmp_new_students ns ON ns.email = u.email
SET
  u.first_name = ns.first_name,
  u.last_name = ns.last_name,
  u.updated_at = NOW();

-- Insert users if they do not already exist.
INSERT INTO users (
  email,
  password_hash,
  first_name,
  last_name,
  phone,
  profile_picture_url,
  bio,
  social_links,
  academic_interests,
  skills,
  campus_id,
  status,
  email_verified,
  last_login_at,
  created_at,
  updated_at
)
SELECT
  ns.email,
  src.password_hash,
  ns.first_name,
  ns.last_name,
  src.phone,
  src.profile_picture_url,
  src.bio,
  src.social_links,
  src.academic_interests,
  src.skills,
  src.campus_id,
  'active',
  1,
  NULL,
  NOW(),
  NOW()
FROM tmp_new_students ns
JOIN users src
  ON src.user_id = @source_user_id
LEFT JOIN users u
  ON u.email = ns.email
WHERE u.user_id IS NULL
  AND @source_user_id IS NOT NULL;

-- Ensure student role is assigned.
INSERT INTO user_roles (
  user_id,
  role_id,
  assigned_at,
  assigned_by
)
SELECT
  u.user_id,
  @student_role_id,
  NOW(),
  @source_user_id
FROM users u
JOIN tmp_new_students ns
  ON ns.email = u.email
LEFT JOIN user_roles ur
  ON ur.user_id = u.user_id
 AND ur.role_id = @student_role_id
WHERE ur.user_role_id IS NULL
  AND @student_role_id IS NOT NULL
  AND @source_user_id IS NOT NULL;

-- Copy enrollments from source student's currently enrolled sections.
INSERT INTO course_enrollments (
  user_id,
  section_id,
  program_id,
  enrollment_date,
  enrollment_status,
  grade,
  final_score,
  dropped_at,
  completed_at,
  updated_at
)
SELECT
  target_users.user_id,
  src_sections.section_id,
  NULL,
  NOW(),
  'enrolled',
  NULL,
  NULL,
  NULL,
  NULL,
  NOW()
FROM (
  SELECT u.user_id
  FROM users u
  JOIN tmp_new_students ns
    ON ns.email = u.email
) AS target_users
JOIN (
  SELECT DISTINCT ce.section_id
  FROM course_enrollments ce
  WHERE ce.user_id = @source_user_id
    AND ce.enrollment_status = 'enrolled'
) AS src_sections
LEFT JOIN course_enrollments existing_ce
  ON existing_ce.user_id = target_users.user_id
 AND existing_ce.section_id = src_sections.section_id
WHERE existing_ce.enrollment_id IS NULL
  AND @source_user_id IS NOT NULL;

-- Keep section counters in sync for touched sections.
UPDATE course_sections cs
JOIN (
  SELECT ce.section_id, COUNT(*) AS enrolled_count
  FROM course_enrollments ce
  WHERE ce.enrollment_status = 'enrolled'
  GROUP BY ce.section_id
) counts
  ON counts.section_id = cs.section_id
SET cs.current_enrollment = counts.enrolled_count
WHERE cs.section_id IN (
  SELECT DISTINCT ce.section_id
  FROM course_enrollments ce
  WHERE ce.user_id = @source_user_id
    AND ce.enrollment_status = 'enrolled'
);

COMMIT;
