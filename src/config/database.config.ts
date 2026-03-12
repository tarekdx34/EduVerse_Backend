import { registerAs } from '@nestjs/config';

export default registerAs('database', () => {
  const dbPort = process.env.DB_PORT;

  if (!dbPort) {
    throw new Error('DB_PORT environment variable is required');
  }

  return {
    type: 'mysql' as const,
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(dbPort, 10),
    username: process.env.DB_USERNAME || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_DATABASE || 'eduverse_db',
    synchronize: false,
    logging: process.env.NODE_ENV === 'development' ? ['error', 'warn'] : false,
  };
});
