import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';
import { AuthSeeder } from './seeders/auth.seeder';

// Load environment variables
dotenv.config();

const dbPort = process.env.DB_PORT;

if (!dbPort) {
  throw new Error('DB_PORT environment variable is required');
}

const AppDataSource = new DataSource({
  type: 'mysql',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(dbPort, 10),
  username: process.env.DB_USERNAME || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'eduverse_db', // Changed from DB_NAME to DB_DATABASE
  entities: ['src/**/*.entity.ts'],
  synchronize: false,
});

async function runSeeders() {
  try {
    console.log('🌱 Starting database seeding...');

    await AppDataSource.initialize();
    console.log('✅ Database connection established');

    // Run auth seeder
    const authSeeder = new AuthSeeder();
    await authSeeder.run(AppDataSource);

    console.log('✅ Seeding completed successfully');
    await AppDataSource.destroy();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during seeding:', error);
    await AppDataSource.destroy();
    process.exit(1);
  }
}

runSeeders();
