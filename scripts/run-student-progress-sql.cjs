/**
 * Applies DB_CHANGES_STUDENT_PROGRESS_TRACKING.sql using credentials from .env.
 * Usage (from EduVerse-Backend): node scripts/run-student-progress-sql.cjs
 */
const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');

require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

async function main() {
  const root = path.join(__dirname, '..');
  const sqlPath = path.join(root, 'DB_CHANGES_STUDENT_PROGRESS_TRACKING.sql');
  if (!fs.existsSync(sqlPath)) {
    console.error('Missing file:', sqlPath);
    process.exit(1);
  }

  const sql = fs.readFileSync(sqlPath, 'utf8');

  let ssl;
  if (process.env.DB_SSL === 'true') {
    ssl = { rejectUnauthorized: true };
    const caRel = process.env.DB_SSL_CA_PATH;
    if (caRel) {
      const caPath = path.resolve(root, caRel);
      if (!fs.existsSync(caPath)) {
        console.error('DB_SSL_CA_PATH file not found:', caPath);
        process.exit(1);
      }
      ssl.ca = fs.readFileSync(caPath, 'utf8');
    }
  }

  const conn = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT || '3306', 10),
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    multipleStatements: true,
    ssl,
  });

  try {
    await conn.query(sql);
    console.log('Applied DB_CHANGES_STUDENT_PROGRESS_TRACKING.sql successfully.');
  } catch (err) {
    console.error('SQL error:', err.message);
    if (err.sqlMessage) console.error('MySQL:', err.sqlMessage);
    process.exit(1);
  } finally {
    await conn.end();
  }
}

main();
