import { registerAs } from '@nestjs/config';
import * as fs from 'fs';
import * as path from 'path';

export default registerAs('database', () => {
  const dbPort = process.env.DB_PORT;
  const dbSslEnabled = process.env.DB_SSL === 'true';
  const dbSslCaPath = process.env.DB_SSL_CA_PATH;

  if (!dbPort) {
    throw new Error('DB_PORT environment variable is required');
  }

  let ssl: { ca?: string; rejectUnauthorized: boolean } | undefined;

  if (dbSslEnabled) {
    ssl = {
      rejectUnauthorized: true,
    };

    if (dbSslCaPath) {
      const resolvedCaPath = path.resolve(process.cwd(), dbSslCaPath);
      if (!fs.existsSync(resolvedCaPath)) {
        throw new Error(`DB_SSL_CA_PATH file not found: ${resolvedCaPath}`);
      }
      ssl.ca = fs.readFileSync(resolvedCaPath, 'utf8');
    }
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
    ssl,
  };
});
