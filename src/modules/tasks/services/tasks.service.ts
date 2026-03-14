import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, MoreThanOrEqual } from 'typeorm';
import { StudentTask, TaskStatus } from '../entities/student-task.entity';
import { TaskCompletion } from '../entities/task-completion.entity';
import { CreateTaskDto, UpdateTaskDto, TaskQueryDto, TaskSortBy } from '../dto';

@Injectable()
export class TasksService {
  private readonly logger = new Logger(TasksService.name);

  constructor(
    @InjectRepository(StudentTask)
    private readonly taskRepo: Repository<StudentTask>,
    @InjectRepository(TaskCompletion)
    private readonly completionRepo: Repository<TaskCompletion>,
  ) {}

  async findAll(userId: number, query: TaskQueryDto) {
    const {
      status,
      priority,
      taskType,
      page = 1,
      limit = 20,
      sortBy = TaskSortBy.CREATED_AT,
    } = query;
    const skip = (page - 1) * limit;

    const qb = this.taskRepo
      .createQueryBuilder('t')
      .where('t.userId = :userId', { userId });

    if (status) {
      qb.andWhere('t.status = :status', { status });
    }
    if (priority) {
      qb.andWhere('t.priority = :priority', { priority });
    }
    if (taskType) {
      qb.andWhere('t.taskType = :taskType', { taskType });
    }

    const sortColumn =
      sortBy === TaskSortBy.DUE_DATE
        ? 't.dueDate'
        : sortBy === TaskSortBy.PRIORITY
          ? 't.priority'
          : 't.createdAt';

    qb.orderBy(sortColumn, sortBy === TaskSortBy.DUE_DATE ? 'ASC' : 'DESC')
      .skip(skip)
      .take(limit);

    const [data, total] = await qb.getManyAndCount();
    const totalPages = Math.ceil(total / limit);

    return {
      data,
      meta: { total, page, limit, totalPages },
    };
  }

  async findOne(taskId: number, userId: number): Promise<StudentTask> {
    const task = await this.taskRepo.findOne({
      where: { taskId, userId },
      relations: ['user'],
    });

    if (!task) {
      throw new NotFoundException(`Task #${taskId} not found`);
    }

    return task;
  }

  async create(dto: CreateTaskDto, userId: number): Promise<StudentTask> {
    const task = this.taskRepo.create({
      ...dto,
      userId,
      dueDate: dto.dueDate ? new Date(dto.dueDate) : null,
    });

    const saved = await this.taskRepo.save(task);
    this.logger.log(`Task created: #${saved.taskId} by user #${userId}`);
    return saved;
  }

  async update(
    taskId: number,
    dto: UpdateTaskDto,
    userId: number,
  ): Promise<StudentTask> {
    const task = await this.findOne(taskId, userId);

    const { dueDate, ...rest } = dto;
    const updateData: Partial<StudentTask> = { ...rest };
    if (dueDate !== undefined) {
      updateData.dueDate = dueDate ? new Date(dueDate) : null;
    }

    Object.assign(task, updateData);
    const saved = await this.taskRepo.save(task);
    this.logger.log(`Task updated: #${taskId} by user #${userId}`);
    return saved;
  }

  async complete(
    taskId: number,
    userId: number,
    notes?: string,
    timeTakenMinutes?: number,
  ): Promise<TaskCompletion> {
    const task = await this.findOne(taskId, userId);

    const existingCompletion = await this.completionRepo.findOne({
      where: { taskId: task.taskId, userId },
    });

    if (existingCompletion) {
      if (notes !== undefined) {
        existingCompletion.notes = notes;
      }
      if (timeTakenMinutes !== undefined) {
        existingCompletion.timeTakenMinutes = timeTakenMinutes;
      }

      if (
        task.status !== TaskStatus.COMPLETED ||
        task.completionPercentage !== 100
      ) {
        task.status = TaskStatus.COMPLETED;
        task.completionPercentage = 100;
        await this.taskRepo.save(task);
      }

      const savedExisting = await this.completionRepo.save(existingCompletion);
      this.logger.log(
        `Task already completed, updated completion: #${taskId} by user #${userId}`,
      );
      return savedExisting;
    }

    task.status = TaskStatus.COMPLETED;
    task.completionPercentage = 100;
    await this.taskRepo.save(task);

    const completion = this.completionRepo.create({
      taskId: task.taskId,
      userId,
      notes: notes ?? null,
      timeTakenMinutes: timeTakenMinutes ?? null,
    });

    const saved = await this.completionRepo.save(completion);
    this.logger.log(`Task completed: #${taskId} by user #${userId}`);
    return saved;
  }

  async remove(taskId: number, userId: number): Promise<void> {
    const task = await this.findOne(taskId, userId);
    await this.taskRepo.remove(task);
    this.logger.log(`Task deleted: #${taskId} by user #${userId}`);
  }

  async findUpcoming(userId: number, days: number = 7) {
    const now = new Date();
    const future = new Date();
    future.setDate(future.getDate() + days);

    const tasks = await this.taskRepo.find({
      where: {
        userId,
        dueDate: MoreThanOrEqual(now) as any,
        status: TaskStatus.PENDING,
      },
      order: { dueDate: 'ASC' },
    });

    // Filter tasks within the date range in application layer
    return tasks.filter((t) => t.dueDate && t.dueDate <= future);
  }
}
