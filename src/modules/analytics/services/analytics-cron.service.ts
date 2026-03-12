import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CourseAnalytics } from '../entities/course-analytics.entity';
import { StudentProgress } from '../entities/student-progress.entity';

@Injectable()
export class AnalyticsCronService {
  private readonly logger = new Logger(AnalyticsCronService.name);

  constructor(
    @InjectRepository(CourseAnalytics)
    private courseAnalyticsRepo: Repository<CourseAnalytics>,
    @InjectRepository(StudentProgress)
    private studentProgressRepo: Repository<StudentProgress>,
  ) {}

  @Cron(CronExpression.EVERY_DAY_AT_2AM)
  async handleDailyAnalyticsSnapshot() {
    this.logger.log('Running daily analytics snapshot...');
    // Placeholder: aggregate course_analytics data
    // In production, this would query enrollments, grades, attendance
    // and update course_analytics records
    this.logger.log('Daily analytics snapshot completed');
  }
}
