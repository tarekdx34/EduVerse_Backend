import { createConnection } from 'mysql2/promise';
import * as dotenv from 'dotenv';
dotenv.config();

async function check() {
  const connection = await createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
  });
  const [rows] = await connection.execute('DESCRIBE lab_submissions');
  console.log(JSON.stringify(rows));
  await connection.end();
}
check().catch(console.error);
