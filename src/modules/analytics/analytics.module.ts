import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';
import { CourseAnalytics } from './entities/course-analytics.entity';
import { LearningAnalytics } from './entities/learning-analytics.entity';
import { PerformanceMetrics } from './entities/performance-metrics.entity';
import { StudentProgress } from './entities/student-progress.entity';
import { WeakTopicsAnalysis } from './entities/weak-topics-analysis.entity';
import { ActivityLog } from './entities/activity-log.entity';
import { AnalyticsService } from './services/analytics.service';
import { AnalyticsCronService } from './services/analytics-cron.service';
import { AnalyticsController } from './controllers/analytics.controller';
import { CourseTA } from '../enrollments/entities/course-ta.entity';
import { CourseInstructor } from '../enrollments/entities/course-instructor.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      CourseAnalytics,
      LearningAnalytics,
      PerformanceMetrics,
      StudentProgress,
      WeakTopicsAnalysis,
      ActivityLog,
      CourseTA,
      CourseInstructor,
    ]),
    ScheduleModule.forRoot(),
  ],
  controllers: [AnalyticsController],
  providers: [AnalyticsService, AnalyticsCronService],
  exports: [AnalyticsService],
})
export class AnalyticsModule {}
