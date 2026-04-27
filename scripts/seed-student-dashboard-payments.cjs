/* eslint-disable no-console */
const path = require('path');
const mysql = require('mysql2/promise');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const DEMO_USER_IDS = [57, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83];
const SEED_PREFIX = 'demo_seed_payments_20260427';

async function run() {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USERNAME || process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    ssl: { rejectUnauthorized: false },
  });

  try {
    const [courseRows] = await conn.query(
      `SELECT course_id
       FROM courses
       ORDER BY course_id ASC
       LIMIT 3`,
    );

    const courseIds = courseRows.map((row) => Number(row.course_id)).filter((x) => Number.isFinite(x));
    if (!courseIds.length) {
      throw new Error('No courses found to attach payment transactions');
    }

    await conn.beginTransaction();

    await conn.query(
      `DELETE FROM payment_transactions
       WHERE payment_gateway_ref LIKE ?`,
      [`${SEED_PREFIX}%`],
    );

    let inserted = 0;
    for (let i = 0; i < DEMO_USER_IDS.length; i += 1) {
      const userId = DEMO_USER_IDS[i];
      const courseId = courseIds[i % courseIds.length];
      const amount = 250 + (i % 4) * 40;
      const monthOffset = i % 5;
      const status = i % 5 === 0 ? 'pending' : 'completed';
      const method = i % 3 === 0 ? 'credit_card' : i % 3 === 1 ? 'paypal' : 'bank_transfer';
      const paidAt = new Date(Date.now() - monthOffset * 30 * 24 * 60 * 60 * 1000);
      const paidAtSql = paidAt.toISOString().slice(0, 19).replace('T', ' ');
      const ref = `${SEED_PREFIX}_${userId}_${i + 1}`;

      await conn.query(
        `INSERT INTO payment_transactions
          (user_id, course_id, amount, currency, payment_method, transaction_status, payment_gateway_ref, paid_at)
         VALUES (?, ?, ?, 'USD', ?, ?, ?, ?)`,
        [userId, courseId, amount.toFixed(2), method, status, ref, paidAtSql],
      );
      inserted += 1;
    }

    await conn.commit();

    const [counts] = await conn.query(
      `SELECT user_id, COUNT(*) AS total
       FROM payment_transactions
       WHERE user_id IN (${DEMO_USER_IDS.map(() => '?').join(',')})
       GROUP BY user_id
       ORDER BY user_id ASC`,
      DEMO_USER_IDS,
    );

    console.log(
      JSON.stringify(
        {
          status: 'ok',
          inserted,
          usersSeeded: DEMO_USER_IDS.length,
          sampleCounts: counts,
        },
        null,
        2,
      ),
    );
  } catch (error) {
    await conn.rollback();
    throw error;
  } finally {
    await conn.end();
  }
}

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
