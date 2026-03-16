import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SystemAlert } from '../entities/system-alert.entity';
import { CreateAlertDto } from '../dto/create-alert.dto';
import { UpdateAlertDto } from '../dto/update-alert.dto';

@Injectable()
export class AlertsService {
  private readonly logger = new Logger(AlertsService.name);

  constructor(
    @InjectRepository(SystemAlert)
    private alertRepo: Repository<SystemAlert>,
  ) {}

  async getAlerts() {
    const data = await this.alertRepo.find({
      order: { createdAt: 'DESC' },
      relations: ['updater'],
    });
    return { data };
  }

  async createAlert(dto: CreateAlertDto, userId: number) {
    const alert = this.alertRepo.create({
      ...dto,
      updatedBy: userId,
    });
    const saved = await this.alertRepo.save(alert);
    return { data: saved, message: 'Alert created successfully' };
  }

  async updateAlert(id: number, dto: UpdateAlertDto, userId: number) {
    const alert = await this.alertRepo.findOne({ where: { id } });
    if (!alert) {
      throw new NotFoundException(`Alert #${id} not found`);
    }

    Object.assign(alert, dto);
    alert.updatedBy = userId;
    const saved = await this.alertRepo.save(alert);
    return { data: saved, message: `Alert #${id} updated successfully` };
  }

  async deleteAlert(id: number) {
    const alert = await this.alertRepo.findOne({ where: { id } });
    if (!alert) {
      throw new NotFoundException(`Alert #${id} not found`);
    }
    await this.alertRepo.remove(alert);
    return { message: `Alert #${id} deleted successfully` };
  }
}
