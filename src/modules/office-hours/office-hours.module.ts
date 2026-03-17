import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OfficeHourSlot } from './entities/office-hour-slot.entity';
import { OfficeHourAppointment } from './entities/office-hour-appointment.entity';
import { OfficeHoursService } from './services/office-hours.service';
import { OfficeHoursController } from './controllers/office-hours.controller';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([OfficeHourSlot, OfficeHourAppointment]),
    NotificationsModule,
  ],
  controllers: [OfficeHoursController],
  providers: [OfficeHoursService],
  exports: [OfficeHoursService],
})
export class OfficeHoursModule {}
