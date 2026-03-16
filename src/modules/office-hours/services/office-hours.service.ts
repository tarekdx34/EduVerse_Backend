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

@Injectable()
export class OfficeHoursService {
  private readonly logger = new Logger(OfficeHoursService.name);

  constructor(
    @InjectRepository(OfficeHourSlot)
    private slotRepo: Repository<OfficeHourSlot>,
    @InjectRepository(OfficeHourAppointment)
    private appointmentRepo: Repository<OfficeHourAppointment>,
  ) {}

  // ── Slots ──

  async getSlots() {
    const data = await this.slotRepo.find({
      relations: ['instructor'],
      order: { createdAt: 'DESC' },
    });
    return { data };
  }

  async getMySlots(instructorId: number) {
    const data = await this.slotRepo.find({
      where: { instructorId },
      order: { dayOfWeek: 'ASC', startTime: 'ASC' },
    });
    return { data };
  }

  async getAvailableSlots() {
    const data = await this.slotRepo.find({
      where: { status: 'active' },
      relations: ['instructor'],
      order: { dayOfWeek: 'ASC', startTime: 'ASC' },
    });
    return { data };
  }

  async createSlot(dto: CreateSlotDto, instructorId: number) {
    const slot = this.slotRepo.create({
      ...dto,
      instructorId,
    });
    const saved = await this.slotRepo.save(slot);
    return { data: saved, message: 'Office hour slot created successfully' };
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

    slot.status = 'cancelled';
    await this.slotRepo.save(slot);
    return { message: `Slot #${id} cancelled and all future appointments cancelled` };
  }

  // ── Appointments ──

  async getAppointments(instructorId?: number) {
    const qb = this.appointmentRepo
      .createQueryBuilder('appt')
      .leftJoinAndSelect('appt.slot', 'slot')
      .leftJoinAndSelect('appt.student', 'student')
      .leftJoinAndSelect('slot.instructor', 'instructor')
      .orderBy('appt.appointmentDate', 'DESC');

    if (instructorId) {
      qb.where('slot.instructorId = :instructorId', { instructorId });
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
      throw new BadRequestException('No available appointments for this date and slot');
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
    return { data: saved, message: 'Appointment booked successfully' };
  }

  async updateAppointment(id: number, dto: UpdateAppointmentDto, userId: number) {
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
    return { data: saved, message: `Appointment #${id} updated successfully` };
  }

  async cancelAppointment(id: number, userId: number) {
    const appointment = await this.appointmentRepo.findOne({
      where: { appointmentId: id },
    });
    if (!appointment) {
      throw new NotFoundException(`Appointment #${id} not found`);
    }

    appointment.status = 'cancelled';
    appointment.cancelledBy = userId;
    appointment.cancelledAt = new Date();
    const saved = await this.appointmentRepo.save(appointment);
    return { data: saved, message: `Appointment #${id} cancelled successfully` };
  }
}
