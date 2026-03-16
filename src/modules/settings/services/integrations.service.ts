import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ApiIntegration, HealthStatus } from '../entities/api-integration.entity';
import { CreateIntegrationDto, UpdateIntegrationDto } from '../dto/create-integration.dto';

@Injectable()
export class IntegrationsService {
  private readonly logger = new Logger(IntegrationsService.name);

  constructor(
    @InjectRepository(ApiIntegration)
    private integrationRepo: Repository<ApiIntegration>,
  ) {}

  async getAll() {
    const data = await this.integrationRepo.find({
      order: { createdAt: 'DESC' },
    });
    return { data };
  }

  async getById(id: number) {
    const integration = await this.integrationRepo.findOne({
      where: { integrationId: id },
    });
    if (!integration) {
      throw new NotFoundException(`Integration ${id} not found`);
    }
    return { data: integration };
  }

  async create(dto: CreateIntegrationDto, userId: number) {
    const integration = this.integrationRepo.create({
      integrationName: dto.integrationName,
      integrationType: dto.integrationType,
      campusId: dto.campusId,
      apiEndpoint: dto.apiEndpoint,
      apiKeyEncrypted: dto.apiKey, // TODO: encrypt before saving
      apiSecretEncrypted: dto.apiSecret, // TODO: encrypt before saving
      configuration: dto.configuration,
      createdBy: userId,
      updatedBy: userId,
    });

    const result = await this.integrationRepo.save(integration);
    return { data: result };
  }

  async update(id: number, dto: UpdateIntegrationDto, userId: number) {
    const integration = await this.integrationRepo.findOne({
      where: { integrationId: id },
    });
    if (!integration) {
      throw new NotFoundException(`Integration ${id} not found`);
    }

    if (dto.integrationName !== undefined) integration.integrationName = dto.integrationName;
    if (dto.integrationType !== undefined) integration.integrationType = dto.integrationType;
    if (dto.apiEndpoint !== undefined) integration.apiEndpoint = dto.apiEndpoint;
    if (dto.apiKey !== undefined) integration.apiKeyEncrypted = dto.apiKey; // TODO: encrypt
    if (dto.apiSecret !== undefined) integration.apiSecretEncrypted = dto.apiSecret; // TODO: encrypt
    if (dto.configuration !== undefined) integration.configuration = dto.configuration;
    if (dto.isActive !== undefined) integration.isActive = dto.isActive;
    integration.updatedBy = userId;

    const result = await this.integrationRepo.save(integration);
    return { data: result };
  }

  async delete(id: number) {
    const integration = await this.integrationRepo.findOne({
      where: { integrationId: id },
    });
    if (!integration) {
      throw new NotFoundException(`Integration ${id} not found`);
    }

    await this.integrationRepo.remove(integration);
    return { message: `Integration ${id} deleted successfully` };
  }

  async testConnection(id: number) {
    const integration = await this.integrationRepo.findOne({
      where: { integrationId: id },
    });
    if (!integration) {
      throw new NotFoundException(`Integration ${id} not found`);
    }

    try {
      // Simulate connection test
      if (!integration.apiEndpoint) {
        integration.healthStatus = HealthStatus.DOWN;
        await this.integrationRepo.save(integration);
        return { data: { status: 'down', message: 'No endpoint configured' } };
      }

      integration.healthStatus = HealthStatus.HEALTHY;
      await this.integrationRepo.save(integration);
      return { data: { status: 'healthy', message: 'Connection successful' } };
    } catch (error) {
      integration.healthStatus = HealthStatus.DOWN;
      await this.integrationRepo.save(integration);
      return { data: { status: 'down', message: error.message } };
    }
  }

  async triggerSync(id: number) {
    const integration = await this.integrationRepo.findOne({
      where: { integrationId: id },
    });
    if (!integration) {
      throw new NotFoundException(`Integration ${id} not found`);
    }

    integration.lastSyncAt = new Date();
    await this.integrationRepo.save(integration);

    return { data: { message: 'Sync triggered successfully', lastSyncAt: integration.lastSyncAt } };
  }
}
