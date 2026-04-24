const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
const { DB_PASSWORD, DB_HOST, DB_PORT, DB_USER, DB_NAME } = process.env;

async function run() {
  try {
    const connection = await mysql.createConnection({
      host: DB_HOST,
      port: DB_PORT,
      user: DB_USER,
      password: DB_PASSWORD,
      database: DB_DATABASE,
      ssl: { ca: fs.readFileSync(path.join(__dirname, 'ca.pem')) },
      multipleStatements: true
    });

    const sql = fs.readFileSync(path.join(__dirname, 'upvotes_views_migration.sql'), 'utf8');

    // Using multipleStatements: true allows us to run the whole thing at once if we want,
    // but splitting by semicolon is safer for CREATE TABLE if it has trigger or similar (not in our case).
    // Let's just execute it as a single block since we enabled multipleStatements
    console.log('Executing migration script...');
    await connection.query(sql);

    console.log('Migration completed successfully.');
    await connection.end();
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

run();
