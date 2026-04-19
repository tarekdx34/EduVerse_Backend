const mysql = require('mysql2/promise');
require('dotenv').config();
const fs = require('fs');

async function main() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    ssl: {
      ca: fs.readFileSync(process.env.DB_SSL_CA_PATH)
    }
  });

  try {
    console.log('Adding academic_interests to users...');
    await connection.query('ALTER TABLE `users` ADD COLUMN `academic_interests` JSON NULL');
    console.log('Added academic_interests');
  } catch (err) {
    if (err.code !== 'ER_DUP_FIELDNAME') console.error(err);
    else console.log('academic_interests already exists');
  }

  try {
    console.log('Adding skills to users...');
    await connection.query('ALTER TABLE `users` ADD COLUMN `skills` JSON NULL');
    console.log('Added skills');
  } catch (err) {
    if (err.code !== 'ER_DUP_FIELDNAME') console.error(err);
    else console.log('skills already exists in users');
  }

  try {
    console.log('Adding skills to courses...');
    await connection.query('ALTER TABLE `courses` ADD COLUMN `skills` JSON NULL');
    console.log('Added skills to courses');
  } catch (err) {
    if (err.code !== 'ER_DUP_FIELDNAME') console.error(err);
    else console.log('skills already exists in courses');
  }

  await connection.end();
}

main().catch(console.error);
