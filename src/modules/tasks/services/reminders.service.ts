import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DeadlineReminder } from '../entities/deadline-reminder.entity';
import { StudentTask } from '../entities/student-task.entity';
import { CreateReminderDto } from '../dto';

@Injectable()
export class RemindersService {
  private readonly logger = new Logger(RemindersService.name);

  constructor(
    @InjectRepository(DeadlineReminder)
    private readonly reminderRepo: Repository<DeadlineReminder>,
    @InjectRepository(StudentTask)
    private readonly taskRepo: Repository<StudentTask>,
  ) {}

  async findAll(userId: number): Promise<DeadlineReminder[]> {
    return this.reminderRepo.find({
      where: { userId },
      relations: ['task'],
      order: { reminderTime: 'ASC' },
    });
  }

  async create(dto: CreateReminderDto, userId: number): Promise<DeadlineReminder> {
    // Verify task exists and belongs to the user
    const task = await this.taskRepo.findOne({
      where: { taskId: dto.taskId, userId },
    });

    if (!task) {
      throw new NotFoundException(`Task #${dto.taskId} not found`);
    }

    const reminder = this.reminderRepo.create({
      taskId: dto.taskId,
      userId,
      reminderTime: new Date(dto.reminderTime),
      reminderType: dto.reminderType,
    });

    const saved = await this.reminderRepo.save(reminder);
    this.logger.log(`Reminder created: #${saved.reminderId} for task #${dto.taskId} by user #${userId}`);
    return saved;
  }

  async remove(reminderId: number, userId: number): Promise<void> {
    const reminder = await this.reminderRepo.findOne({
      where: { reminderId, userId },
    });

    if (!reminder) {
      throw new NotFoundException(`Reminder #${reminderId} not found`);
    }

    await this.reminderRepo.remove(reminder);
    this.logger.log(`Reminder deleted: #${reminderId} by user #${userId}`);
  }
}
