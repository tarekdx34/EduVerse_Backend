const mysql = require('mysql2/promise');

async function checkDb() {
  const connection = await mysql.createConnection({
    host: '127.0.0.1',
    user: 'root',
    password: 'root123',
    database: 'eduverse_db'
  });

  try {
    console.log('Seeding course assignments for instructor.tarek@example.com (user_id 58)...');
    
    // Assign courses to user 58
    await connection.execute('UPDATE course_instructors SET user_id = 58 WHERE assignment_id IN (1, 2, 3)');

    console.log('Successfully updated course assignments for instructor tarek.');
  } catch (err) {
    console.error(err);
  } finally {
    await connection.end();
  }
}

checkDb();
