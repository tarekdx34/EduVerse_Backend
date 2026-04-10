import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { OfficeHourSlot } from '../entities/office-hour-slot.entity';
import { OfficeHourAppointment } from '../entities/office-hour-appointment.entity';
import { CreateSlotDto } from '../dto/create-slot.dto';
import { UpdateSlotDto } from '../dto/update-slot.dto';
import { BookAppointmentDto } from '../dto/book-appointment.dto';
import { UpdateAppointmentDto } from '../dto/update-appointment.dto';
import { NotificationsService } from '../../notifications/services/notifications.service';
import { NotificationType } from '../../notifications/enums';

@Injectable()
export class OfficeHoursService {
  private readonly logger = new Logger(OfficeHoursService.name);
  private readonly activeAppointmentStatuses = ['booked', 'confirmed'];

  constructor(
    @InjectRepository(OfficeHourSlot)
    private slotRepo: Repository<OfficeHourSlot>,
    @InjectRepository(OfficeHourAppointment)
    private appointmentRepo: Repository<OfficeHourAppointment>,
    private notificationsService: NotificationsService,
  ) {}

  // ── Slots ──

  private async getSlotAppointmentCounts(slotIds: (number | string)[]) {
    if (!slotIds.length) return new Map<string, number>();

    const rows = await this.appointmentRepo
      .createQueryBuilder('appt')
      .select('appt.slotId', 'slotId')
      .addSelect('COUNT(*)', 'count')
      .where('appt.slotId IN (:...slotIds)', { slotIds })
      .andWhere('appt.status IN (:...statuses)', {
        statuses: this.activeAppointmentStatuses,
      })
      .groupBy('appt.slotId')
      .getRawMany<{ slotId: string; count: string }>();

    const counts = new Map<string, number>();
    console.log('appointment count rows:', rows);
    rows.forEach((row: any) => {
      // TypeORM raw queries might lowercase aliases (e.g., slotid) or use the column name (slot_id)
      const sid =
        row.slotId || row['appt_slot_id'] || row['slotid'] || row['slot_id'];
      const cnt = row.count || row['COUNT'] || row['COUNT(*)'];
      counts.set(String(sid), Number(cnt));
    });

    return counts;
  }

  async getSlots(params?: {
    instructorId?: number;
    dayOfWeek?: string;
    page?: number;
    limit?: number;
  }) {
    const page = params?.page && params.page > 0 ? params.page : 1;
    const limit = params?.limit && params.limit > 0 ? params.limit : 10;
    const skip = (page - 1) * limit;
    const normalizedDay = params?.dayOfWeek
      ? String(params.dayOfWeek).toLowerCase()
      : undefined;

    const qb = this.slotRepo
      .createQueryBuilder('slot')
      .leftJoinAndSelect('slot.instructor', 'instructor')
      .orderBy('slot.createdAt', 'DESC')
      .skip(skip)
      .take(limit);

    if (params?.instructorId) {
      qb.andWhere('slot.instructorId = :instructorId', {
        instructorId: params.instructorId,
      });
    }

    if (normalizedDay) {
      qb.andWhere('LOWER(slot.dayOfWeek) = :dayOfWeek', {
        dayOfWeek: normalizedDay,
      });
    }

    const [items, total] = await qb.getManyAndCount();
    const appointmentCounts = await this.getSlotAppointmentCounts(
      items.map((slot) => slot.slotId),
    );
    const data = items.map((slot) => ({
      ...slot,
      currentAppointments: appointmentCounts.get(String(slot.slotId)) || 0,
    }));

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getSlotById(id: number) {
    const data = await this.slotRepo.find({
      where: { slotId: id },
      relations: ['instructor'],
      take: 1,
    });
    if (!data.length) {
      throw new NotFoundException(`Slot #${id} not found`);
    }
    const appointmentCounts = await this.getSlotAppointmentCounts([id]);
    return {
      data: {
        ...data[0],
        currentAppointments: appointmentCounts.get(String(id)) || 0,
      },
    };
  }

  async getMySlots(instructorId: number) {
    const data = await this.slotRepo.find({
      where: { instructorId },
      order: { dayOfWeek: 'ASC', startTime: 'ASC' },
    });
    const appointmentCounts = await this.getSlotAppointmentCounts(
      data.map((slot) => slot.slotId),
    );

    return {
      data: data.map((slot) => ({
        ...slot,
        currentAppointments: appointmentCounts.get(String(slot.slotId)) || 0,
      })),
    };
  }

  async getAvailableSlots(instructorId?: number) {
    const whereCondition = instructorId
      ? ({ status: 'active', instructorId } as const)
      : ({ status: 'active' } as const);

    const data = await this.slotRepo.find({
      where: whereCondition,
      relations: ['instructor'],
      order: { dayOfWeek: 'ASC', startTime: 'ASC' },
    });
    const appointmentCounts = await this.getSlotAppointmentCounts(
      data.map((slot) => slot.slotId),
    );

    return {
      data: data.map((slot) => ({
        ...slot,
        currentAppointments: appointmentCounts.get(String(slot.slotId)) || 0,
      })),
    };
  }

  async createSlot(dto: CreateSlotDto, instructorId: number) {
    const payloadInstructorId = dto.instructorId || instructorId;
    const normalizedDayOfWeek = String(dto.dayOfWeek).toLowerCase();
    const normalizedLocation =
      dto.location ||
      [dto.building, dto.room].filter(Boolean).join(' ').trim() ||
      '';

    const slot = this.slotRepo.create({
      ...dto,
      dayOfWeek: normalizedDayOfWeek,
      location: normalizedLocation,
      instructorId: payloadInstructorId,
    });
    const saved = await this.slotRepo.save(slot);
    return {
      data: {
        ...saved,
        currentAppointments: 0,
      },
      message: 'Office hour slot created successfully',
    };
  }

  async updateSlot(id: number, dto: UpdateSlotDto, userId: number) {
    const slot = await this.slotRepo.findOne({ where: { slotId: id } });
    if (!slot) {
      throw new NotFoundException(`Slot #${id} not found`);
    }
    Object.assign(slot, dto);
    const saved = await this.slotRepo.save(slot);
    return { data: saved, message: `Slot #${id} updated successfully` };
  }

  async deleteSlot(id: number) {
    const slot = await this.slotRepo.findOne({ where: { slotId: id } });
    if (!slot) {
      throw new NotFoundException(`Slot #${id} not found`);
    }
    // Retrieve appointments to notify students before cancelling
    const appointmentsToCancel = await this.appointmentRepo.find({
      where: {
        slotId: id,
        status: 'booked' as any, // Only booked/confirmed need notifying, but let's notify all that are being cancelled
      },
    });

    // Cancel all future appointments for this slot
    await this.appointmentRepo
      .createQueryBuilder()
      .update()
      .set({ status: 'cancelled' })
      .where('slot_id = :id AND status IN (:...statuses)', {
        id,
        statuses: ['booked', 'confirmed'],
      })
      .execute();

    // Notify students
    for (const appt of appointmentsToCancel) {
      if (['booked', 'confirmed'].includes(appt.status)) {
        await this.notificationsService
          .createNotification({
            userId: appt.studentId,
            notificationType: NotificationType.SYSTEM,
            title: 'Office Hour Slot Cancelled',
            body: `Your appointment for slot #${id} has been cancelled because the slot was cancelled by the instructor.`,
          })
          .catch((err) =>
            this.logger.error('Failed to send notification', err),
          );
      }
    }

    slot.status = 'cancelled';
    await this.slotRepo.save(slot);
    return {
      message: `Slot #${id} cancelled and all future appointments cancelled`,
    };
  }

  // ── Appointments ──

  async getAppointments(instructorId?: number, slotId?: number) {
    const qb = this.appointmentRepo
      .createQueryBuilder('appt')
      .leftJoinAndSelect('appt.slot', 'slot')
      .leftJoinAndSelect('appt.student', 'student')
      .leftJoinAndSelect('slot.instructor', 'instructor')
      .orderBy('appt.appointmentDate', 'DESC');

    if (instructorId) {
      qb.where('slot.instructorId = :instructorId', { instructorId });
    }

    if (slotId) {
      qb.andWhere('appt.slotId = :slotId', { slotId });
    }

    const data = await qb.getMany();
    return { data };
  }

  async getMyAppointments(studentId: number) {
    const data = await this.appointmentRepo.find({
      where: { studentId },
      relations: ['slot', 'slot.instructor'],
      order: { appointmentDate: 'DESC' },
    });
    return { data };
  }

  async bookAppointment(dto: BookAppointmentDto, studentId: number) {
    const slot = await this.slotRepo.findOne({ where: { slotId: dto.slotId } });
    if (!slot) {
      throw new NotFoundException(`Slot #${dto.slotId} not found`);
    }
    if (slot.status !== 'active') {
      throw new BadRequestException('This slot is not active');
    }

    // Count existing active appointments on this date for this slot
    const existingCount = await this.appointmentRepo.count({
      where: {
        slotId: dto.slotId,
        appointmentDate: new Date(dto.appointmentDate) as any,
        status: 'booked' as any,
      },
    });

    if (existingCount >= slot.maxAppointments) {
      throw new BadRequestException(
        'No available appointments for this date and slot',
      );
    }

    const appointment = this.appointmentRepo.create({
      slotId: dto.slotId,
      studentId,
      appointmentDate: dto.appointmentDate as any,
      startTime: slot.startTime,
      endTime: slot.endTime,
      topic: dto.topic,
      notes: dto.notes,
      status: 'booked',
    });
    const saved = await this.appointmentRepo.save(appointment);

    // Notify Instructor
    await this.notificationsService
      .createNotification({
        userId: slot.instructorId,
        notificationType: NotificationType.MESSAGE,
        title: 'New Office Hour Booking',
        body: `A student has booked an appointment for your slot on ${dto.appointmentDate}. Topic: ${dto.topic || 'No topic'}`,
      })
      .catch((err) => this.logger.error('Failed to notify instructor', err));

    return { data: saved, message: 'Appointment booked successfully' };
  }

  async updateAppointment(
    id: number,
    dto: UpdateAppointmentDto,
    userId: number,
  ) {
    const appointment = await this.appointmentRepo.findOne({
      where: { appointmentId: id },
      relations: ['slot'],
    });
    if (!appointment) {
      throw new NotFoundException(`Appointment #${id} not found`);
    }

    if (dto.status === 'cancelled') {
      appointment.cancelledBy = userId;
      appointment.cancelledAt = new Date();
    }

    Object.assign(appointment, dto);
    const saved = await this.appointmentRepo.save(appointment);

    if (dto.status === 'confirmed') {
      await this.notificationsService
        .createNotification({
          userId: appointment.studentId,
          notificationType: NotificationType.SYSTEM,
          title: 'Appointment Confirmed',
          body: `Your office hour appointment on ${appointment.appointmentDate} has been confirmed via instructor.`,
        })
        .catch((err) => this.logger.error('Failed to notify student', err));
    } else if (dto.status === 'cancelled') {
      // Target person to notify depends on who cancels. (Assumed student if instructor cancels, instructor if student cancels)
      const targetUserId =
        userId === appointment.studentId
          ? appointment.slot.instructorId
          : appointment.studentId;
      await this.notificationsService
        .createNotification({
          userId: targetUserId,
          notificationType: NotificationType.SYSTEM,
          title: 'Appointment Cancelled',
          body: `An office hour appointment on ${appointment.appointmentDate} has been cancelled.`,
        })
        .catch((err) => this.logger.error('Failed to notify user', err));
    }

    return { data: saved, message: `Appointment #${id} updated successfully` };
  }

  async cancelAppointment(id: number, userId: number) {
    const appointment = await this.appointmentRepo.findOne({
      where: { appointmentId: id },
      relations: ['slot'],
    });
    if (!appointment) {
      throw new NotFoundException(`Appointment #${id} not found`);
    }

    appointment.status = 'cancelled';
    appointment.cancelledBy = userId;
    appointment.cancelledAt = new Date();
    const saved = await this.appointmentRepo.save(appointment);

    // Notify the other party
    const targetUserId =
      userId === appointment.studentId
        ? appointment.slot.instructorId
        : appointment.studentId;
    await this.notificationsService
      .createNotification({
        userId: targetUserId,
        notificationType: NotificationType.SYSTEM,
        title: 'Appointment Cancelled',
        body: `An office hour appointment on ${appointment.appointmentDate} has been cancelled.`,
      })
      .catch((err) => this.logger.error('Failed to notify user', err));

    return {
      data: saved,
      message: `Appointment #${id} cancelled successfully`,
    };
  }
}
