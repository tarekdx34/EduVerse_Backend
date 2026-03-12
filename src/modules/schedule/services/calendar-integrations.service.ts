import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CalendarIntegration } from '../entities';
import { ConnectCalendarDto } from '../dto';
import { SyncStatus } from '../enums';

@Injectable()
export class CalendarIntegrationsService {
  constructor(
    @InjectRepository(CalendarIntegration)
    private readonly integrationRepo: Repository<CalendarIntegration>,
  ) {}

  async findAll(userId: number) {
    return this.integrationRepo.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async findById(id: number, userId: number) {
    const integration = await this.integrationRepo.findOne({
      where: { integrationId: id, userId },
    });

    if (!integration) {
      throw new NotFoundException(`Calendar integration with ID ${id} not found`);
    }

    return integration;
  }

  async connect(dto: ConnectCalendarDto, userId: number) {
    // Check if integration already exists
    const existing = await this.integrationRepo.findOne({
      where: { userId, calendarType: dto.calendarType },
    });

    if (existing) {
      // Update existing integration
      existing.syncStatus = SyncStatus.ACTIVE;
      // In real implementation, exchange auth code for tokens here
      // existing.accessTokenEncrypted = encryptedAccessToken;
      // existing.refreshTokenEncrypted = encryptedRefreshToken;
      return this.integrationRepo.save(existing);
    }

    // Create new integration
    const integration = this.integrationRepo.create({
      userId,
      calendarType: dto.calendarType,
      syncStatus: SyncStatus.ACTIVE,
      lastSync: new Date(),
    });

    return this.integrationRepo.save(integration);
  }

  async sync(id: number, userId: number) {
    const integration = await this.findById(id, userId);

    // In real implementation, sync with external calendar here
    // For now, just update lastSync
    integration.lastSync = new Date();
    integration.syncStatus = SyncStatus.ACTIVE;

    await this.integrationRepo.save(integration);

    return { 
      message: 'Calendar sync initiated successfully',
      lastSync: integration.lastSync,
    };
  }

  async disconnect(id: number, userId: number) {
    const integration = await this.findById(id, userId);
    await this.integrationRepo.remove(integration);
    return { message: 'Calendar integration disconnected successfully' };
  }
}
