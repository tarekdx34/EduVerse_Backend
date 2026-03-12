import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StudentTask } from './entities/student-task.entity';
import { TaskCompletion } from './entities/task-completion.entity';
import { DeadlineReminder } from './entities/deadline-reminder.entity';
import { TasksService } from './services/tasks.service';
import { RemindersService } from './services/reminders.service';
import { TasksController } from './controllers/tasks.controller';

@Module({
  imports: [TypeOrmModule.forFeature([StudentTask, TaskCompletion, DeadlineReminder])],
  controllers: [TasksController],
  providers: [TasksService, RemindersService],
  exports: [TasksService, RemindersService],
})
export class TasksModule {}
