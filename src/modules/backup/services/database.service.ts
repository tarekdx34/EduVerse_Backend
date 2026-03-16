import { Injectable, Logger } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

@Injectable()
export class DatabaseService {
  private readonly logger = new Logger(DatabaseService.name);

  constructor(
    @InjectDataSource()
    private dataSource: DataSource,
  ) {}

  async getStatus() {
    const uptimeResult = await this.dataSource.query(
      "SHOW GLOBAL STATUS LIKE 'Uptime'",
    );
    const threadsResult = await this.dataSource.query(
      "SHOW GLOBAL STATUS LIKE 'Threads_connected'",
    );
    const versionResult = await this.dataSource.query(
      "SELECT VERSION() as version",
    );

    return {
      data: {
        uptime: uptimeResult[0]?.Value || 0,
        threadsConnected: threadsResult[0]?.Value || 0,
        version: versionResult[0]?.version || 'unknown',
      },
    };
  }

  async getTables() {
    const dbName = this.dataSource.options['database'] || 'eduverse_db';
    const tables = await this.dataSource.query(
      `SELECT 
        TABLE_NAME as tableName,
        TABLE_ROWS as tableRows,
        ROUND(DATA_LENGTH / 1024 / 1024, 2) as dataSizeMB,
        ROUND(INDEX_LENGTH / 1024 / 1024, 2) as indexSizeMB,
        ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) as totalSizeMB,
        ENGINE as engine,
        TABLE_COLLATION as collation
      FROM information_schema.TABLES 
      WHERE TABLE_SCHEMA = ? 
      ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC`,
      [dbName],
    );

    return { data: tables };
  }

  async optimizeDatabase() {
    const dbName = this.dataSource.options['database'] || 'eduverse_db';
    const tables = await this.dataSource.query(
      `SELECT TABLE_NAME as tableName 
       FROM information_schema.TABLES 
       WHERE TABLE_SCHEMA = ?`,
      [dbName],
    );

    const results: { table: string; result: string }[] = [];
    for (const table of tables) {
      try {
        const result = await this.dataSource.query(
          `OPTIMIZE TABLE \`${table.tableName}\``,
        );
        results.push({ table: table.tableName, result: result[0]?.Msg_text || 'OK' });
      } catch (e) {
        results.push({ table: table.tableName, result: `Error: ${e.message}` });
      }
    }

    return { data: results, message: `Optimized ${results.length} tables` };
  }
}
