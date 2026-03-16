import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OfficeHourSlot } from './entities/office-hour-slot.entity';
import { OfficeHourAppointment } from './entities/office-hour-appointment.entity';
import { OfficeHoursService } from './services/office-hours.service';
import { OfficeHoursController } from './controllers/office-hours.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([OfficeHourSlot, OfficeHourAppointment]),
  ],
  controllers: [OfficeHoursController],
  providers: [OfficeHoursService],
  exports: [OfficeHoursService],
})
export class OfficeHoursModule {}
