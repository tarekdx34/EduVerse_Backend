import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SystemAlert } from '../entities/system-alert.entity';
import { CreateAlertDto } from '../dto/create-alert.dto';
import { UpdateAlertDto } from '../dto/update-alert.dto';
import { NotificationsService } from '../../notifications/services/notifications.service';
import { NotificationPriority, NotificationType } from '../../notifications/enums';

@Injectable()
export class AlertsService {
  private readonly logger = new Logger(AlertsService.name);

  constructor(
    @InjectRepository(SystemAlert)
    private alertRepo: Repository<SystemAlert>,
    private notificationsService: NotificationsService,
  ) {}

  private resolveAlertPriority(threshold: number): NotificationPriority | null {
    if (threshold >= 95) {
      return NotificationPriority.URGENT;
    }
    if (threshold >= 90) {
      return NotificationPriority.HIGH;
    }
    return null;
  }

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

    const priority = this.resolveAlertPriority(Number(saved.threshold));
    if (priority) {
      const adminIds = await this.notificationsService.getOperationalAdminIds();
      await this.notificationsService.createBulkNotifications(adminIds, {
        notificationType: NotificationType.SYSTEM,
        title: 'Operational Alert Configured',
        body: `A high-severity monitoring alert "${saved.name}" was configured with threshold ${saved.threshold}.`,
        relatedEntityType: 'system_alert',
        relatedEntityId: saved.id,
        priority,
        actionUrl: '/admin/monitoring/alerts',
      });
    }

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
