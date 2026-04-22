/* eslint-disable no-console */
/**
 * Export dev quick-login account lists from the configured MySQL database.
 *
 * Usage (from EduVerse-Backend/):
 *   node scripts/export-quick-login-seeds.cjs
 *
 * Optional:
 *   QUICK_LOGIN_OUT=..\\Eduverse-Frontend\\public\\quickLoginSeeds.json node scripts/export-quick-login-seeds.cjs
 */
const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const {
  DB_HOST,
  DB_PORT,
  DB_USERNAME,
  DB_USER,
  DB_PASSWORD,
  DB_DATABASE,
  DB_SSL,
  DB_SSL_CA_PATH,
} = process.env;

const dbUser = DB_USERNAME || DB_USER;

function toBool(v) {
  if (v === undefined || v === null) return false;
  const s = String(v).toLowerCase();
  return s === '1' || s === 'true' || s === 'yes';
}

function primaryRoleFromFlags(row) {
  if (row.is_admin) return { bucket: 'staff', key: 'admin' };
  if (row.is_it_admin) return { bucket: 'staff', key: 'it_admin' };
  if (row.is_dept_head) return { bucket: 'staff', key: 'department_head' };
  if (row.is_ta) return { bucket: 'tas', key: 'teaching_assistant' };
  if (row.is_instructor) return { bucket: 'instructors', key: 'instructor' };
  if (row.is_student) return { bucket: 'students', key: 'student' };
  return { bucket: 'staff', key: 'unknown' };
}

async function main() {
  if (!DB_HOST || !dbUser || !DB_PASSWORD || !DB_DATABASE) {
    throw new Error('Missing DB_HOST / DB_USERNAME (or DB_USER) / DB_PASSWORD / DB_DATABASE in .env');
  }

  const ssl = toBool(DB_SSL);
  const caRel = DB_SSL_CA_PATH;
  const caAbs = caRel ? path.join(__dirname, '..', caRel) : null;
  const sslConfig =
    ssl && caAbs
      ? { rejectUnauthorized: true, ca: fs.readFileSync(caAbs) }
      : ssl
        ? { rejectUnauthorized: true }
        : undefined;

  const port = Number(DB_PORT || 3306);
  const conn = await mysql.createConnection({
    host: DB_HOST,
    port,
    user: dbUser,
    password: DB_PASSWORD,
    database: DB_DATABASE,
    ssl: sslConfig,
  });

  // One row per user, with boolean flags for role membership.
  const [rows] = await conn.query(
    `
    SELECT
      u.user_id AS id,
      u.email AS email,
      u.first_name AS firstName,
      u.last_name AS lastName,
      MAX(r.role_name = 'student') AS is_student,
      MAX(r.role_name = 'instructor') AS is_instructor,
      MAX(r.role_name = 'teaching_assistant') AS is_ta,
      MAX(r.role_name = 'admin') AS is_admin,
      MAX(r.role_name = 'it_admin') AS is_it_admin,
      MAX(r.role_name = 'department_head') AS is_dept_head
    FROM users u
    JOIN user_roles ur ON ur.user_id = u.user_id
    JOIN roles r ON r.role_id = ur.role_id
    WHERE u.deleted_at IS NULL
    GROUP BY u.user_id, u.email, u.first_name, u.last_name
    ORDER BY u.user_id ASC
    `,
  );

  await conn.end();

  const out = {
    generatedAt: new Date().toISOString(),
    database: DB_DATABASE,
    counts: {
      student: 0,
      teaching_assistant: 0,
      instructor: 0,
      admin: 0,
      it_admin: 0,
      department_head: 0,
      unknown: 0,
    },
    students: [],
    teachingAssistants: [],
    instructors: [],
    staff: [],
    unknown: [],
  };

  for (const r of rows) {
    const name = `${r.firstName || ''} ${r.lastName || ''}`.replace(/\s+/g, ' ').trim() || r.email;
    const entry = { id: Number(r.id), name, email: r.email, roles: [] };

    if (r.is_student) entry.roles.push('student');
    if (r.is_instructor) entry.roles.push('instructor');
    if (r.is_ta) entry.roles.push('teaching_assistant');
    if (r.is_admin) entry.roles.push('admin');
    if (r.is_it_admin) entry.roles.push('it_admin');
    if (r.is_dept_head) entry.roles.push('department_head');

    const { bucket, key } = primaryRoleFromFlags(r);
    out.counts[key] = (out.counts[key] || 0) + 1;

    if (bucket === 'students') out.students.push(entry);
    else if (bucket === 'tas') out.teachingAssistants.push(entry);
    else if (bucket === 'instructors') out.instructors.push(entry);
    else if (bucket === 'staff') out.staff.push(entry);
    else out.unknown.push(entry);
  }

  const defaultOut = path.join(
    __dirname,
    '..',
    '..',
    'Eduverse-Frontend',
    'public',
    'quickLoginSeeds.json',
  );
  const outPath = process.env.QUICK_LOGIN_OUT
    ? path.resolve(process.env.QUICK_LOGIN_OUT)
    : defaultOut;

  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, JSON.stringify(out, null, 2) + '\n', 'utf8');
  console.log(`Wrote ${rows.length} users -> ${outPath}`);
  console.log(
    `Counts: students=${out.students.length}, tas=${out.teachingAssistants.length}, instructors=${out.instructors.length}, staff=${out.staff.length}, unknown=${out.unknown.length}`,
  );
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
