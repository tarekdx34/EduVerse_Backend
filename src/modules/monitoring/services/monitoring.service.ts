import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ServerMonitoring } from '../entities/server-monitoring.entity';
import * as os from 'os';

@Injectable()
export class MonitoringService {
  private readonly logger = new Logger(MonitoringService.name);

  constructor(
    @InjectRepository(ServerMonitoring)
    private serverRepo: Repository<ServerMonitoring>,
  ) {}

  async getServers() {
    const data = await this.serverRepo.find({
      order: { checkedAt: 'DESC' },
    });
    return { data };
  }

  async getHealth() {
    const cpus = os.cpus();
    const totalMem = os.totalmem();
    const freeMem = os.freemem();
    const uptime = os.uptime();

    // Calculate CPU usage average
    let totalIdle = 0;
    let totalTick = 0;
    for (const cpu of cpus) {
      for (const type in cpu.times) {
        totalTick += cpu.times[type];
      }
      totalIdle += cpu.times.idle;
    }
    const cpuUsage = ((1 - totalIdle / totalTick) * 100).toFixed(2);
    const memoryUsage = (((totalMem - freeMem) / totalMem) * 100).toFixed(2);

    return {
      data: {
        hostname: os.hostname(),
        platform: os.platform(),
        arch: os.arch(),
        cpuCount: cpus.length,
        cpuUsage: parseFloat(cpuUsage),
        totalMemoryMB: Math.round(totalMem / 1024 / 1024),
        freeMemoryMB: Math.round(freeMem / 1024 / 1024),
        memoryUsage: parseFloat(memoryUsage),
        uptimeSeconds: uptime,
        uptimeFormatted: this.formatUptime(uptime),
        nodeVersion: process.version,
      },
    };
  }

  async getMetrics() {
    const health = await this.getHealth();
    const latestRecords = await this.serverRepo
      .createQueryBuilder('sm')
      .orderBy('sm.checked_at', 'DESC')
      .limit(50)
      .getMany();

    return {
      data: {
        current: health.data,
        history: latestRecords,
      },
    };
  }

  private formatUptime(seconds: number): string {
    const d = Math.floor(seconds / 86400);
    const h = Math.floor((seconds % 86400) / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    return `${d}d ${h}h ${m}m`;
  }
}
