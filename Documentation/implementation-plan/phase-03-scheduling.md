# Phase 3: Scheduling & Calendar

> **Priority**: 🟠 High  
> **Modules**: 1 (Enhancement of existing + new features)  
> **Reason**: All dashboards display schedules. Admin needs exam scheduling & academic calendar.

---

## 3.1 Schedule Module (Enhanced)

### Database Tables
| Table | Description |
|-------|-------------|
| `course_schedules` | Class meeting times (already in courses module) |
| `exam_schedules` | Exam date/time scheduling |
| `calendar_events` | Personal/course calendar events |
| `calendar_integrations` | External calendar (Google, Outlook) sync |

### New Entity Definitions

#### ExamSchedule Entity
```typescript
@Entity('exam_schedules')
export class ExamSchedule {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  examScheduleId: number;

  @Column({ type: 'bigint', unsigned: true })
  courseId: number;

  @ManyToOne(() => Course)
  @JoinColumn({ name: 'course_id' })
  course: Course;

  @Column({ type: 'bigint', unsigned: true })
  semesterId: number;

  @ManyToOne(() => Semester)
  @JoinColumn({ name: 'semester_id' })
  semester: Semester;

  @Column({ type: 'enum', enum: ['midterm', 'final', 'quiz', 'makeup'] })
  examType: string;

  @Column({ length: 200 })
  title: string;

  @Column({ type: 'date' })
  examDate: string;

  @Column({ type: 'time' })
  startTime: string;

  @Column({ type: 'varchar', length: 200, nullable: true })
  location: string;

  @Column({ type: 'int', nullable: true })
  durationMinutes: number;

  @Column({ type: 'text', nullable: true })
  instructions: string;

  @Column({ type: 'enum', enum: ['scheduled', 'in_progress', 'completed', 'cancelled', 'postponed'], default: 'scheduled' })
  status: string;

  @Column({ type: 'bigint', unsigned: true })
  createdBy: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

#### CalendarEvent Entity
```typescript
@Entity('calendar_events')
export class CalendarEvent {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  eventId: number;

  @Column({ type: 'bigint', unsigned: true })
  userId: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ length: 200 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'enum', enum: ['lecture', 'lab', 'exam', 'assignment', 'quiz', 'meeting', 'custom'] })
  eventType: string;

  @Column({ type: 'timestamp' })
  startTime: Date;

  @Column({ type: 'timestamp' })
  endTime: Date;

  @Column({ type: 'varchar', length: 100, nullable: true })
  location: string;

  @Column({ type: 'varchar', length: 7, nullable: true })
  color: string;  // Hex color code

  @Column({ type: 'tinyint', default: 0 })
  isRecurring: boolean;

  @Column({ type: 'varchar', length: 100, nullable: true })
  recurrencePattern: string;

  @Column({ type: 'int', default: 30 })
  reminderMinutes: number;

  @Column({ type: 'bigint', unsigned: true, nullable: true })
  courseId: number;

  @Column({ type: 'bigint', unsigned: true, nullable: true })
  scheduleId: number;

  @ManyToOne(() => CourseSchedule)
  @JoinColumn({ name: 'schedule_id' })
  schedule: CourseSchedule;

  @Column({ type: 'bigint', unsigned: true, nullable: true })
  examId: number;

  @ManyToOne(() => ExamSchedule)
  @JoinColumn({ name: 'exam_id' })
  exam: ExamSchedule;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

#### CalendarIntegration Entity
```typescript
@Entity('calendar_integrations')
export class CalendarIntegration {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  integrationId: number;

  @Column({ type: 'bigint', unsigned: true })
  userId: number;

  @Column({ type: 'enum', enum: ['google', 'outlook', 'ical'] })
  calendarType: string;

  @Column({ type: 'text', nullable: true })
  accessTokenEncrypted: string;

  @Column({ type: 'text', nullable: true })
  refreshTokenEncrypted: string;

  @Column({ type: 'enum', enum: ['active', 'error', 'disabled'], default: 'active' })
  syncStatus: string;

  @Column({ type: 'timestamp', nullable: true })
  lastSync: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

### API Endpoints

| Method | Endpoint | Description | Roles |
|--------|----------|-------------|-------|
| **Schedule** | | | |
| GET | `/api/schedule/daily` | Get today's schedule for current user | ALL |
| GET | `/api/schedule/weekly` | Get weekly schedule for current user | ALL |
| GET | `/api/schedule/range` | Get schedule for date range | ALL |
| GET | `/api/schedule/section/:sectionId` | Get schedule for a section | ALL |
| **Exams** | | | |
| GET | `/api/exams` | List exam schedules (filter by section, date) | ALL |
| POST | `/api/exams` | Create exam schedule | INSTRUCTOR, ADMIN |
| GET | `/api/exams/:id` | Get exam details | ALL |
| PUT | `/api/exams/:id` | Update exam schedule | INSTRUCTOR, ADMIN |
| DELETE | `/api/exams/:id` | Delete exam schedule | INSTRUCTOR, ADMIN |
| GET | `/api/exams/conflicts` | Check for exam conflicts | ADMIN |
| **Calendar Events** | | | |
| GET | `/api/calendar/events` | List calendar events (filter by type, date) | ALL |
| POST | `/api/calendar/events` | Create calendar event | ALL |
| PUT | `/api/calendar/events/:id` | Update event | OWNER |
| DELETE | `/api/calendar/events/:id` | Delete event | OWNER |
| **Calendar Integrations** | | | |
| GET | `/api/calendar/integrations` | List user's integrations | ALL |
| POST | `/api/calendar/integrations/connect` | Connect external calendar | ALL |
| DELETE | `/api/calendar/integrations/:id` | Disconnect integration | ALL |
| POST | `/api/calendar/integrations/:id/sync` | Trigger manual sync | ALL |

### Query Parameters
```typescript
interface QueryScheduleDto {
  date?: string;        // Specific date
  startDate?: string;   // Range start
  endDate?: string;     // Range end
  courseId?: number;
  sectionId?: number;
  eventType?: string;
}
```

### Business Logic
1. **Daily Schedule**: Aggregates course_schedules, exam_schedules, and calendar_events for the current user for today.
2. **Weekly Schedule**: Same aggregation for the current week.
3. **Conflict Detection**: Check for overlapping exams for students enrolled in multiple courses.
4. **Auto-populate**: When a student enrolls in a section, auto-create calendar events from course_schedules.
5. **Recurring Events**: Support daily, weekly, monthly recurrence patterns.
6. **Time Zone**: Respect user's timezone preference from `language_preferences` table.

### Frontend Components Using This Module
- **Instructor**: SchedulePage.tsx
- **Student**: ClassSchedule.tsx, DailySchedule.tsx, WeeklySchedule.tsx, AcademicCalendar.tsx
- **TA**: SchedulePage.tsx
- **Admin**: AcademicCalendarPage.tsx *(active as `calendar` tab)*
- ~~**Admin**: ScheduleManagementPage.tsx, ExamSchedulePage.tsx~~ *(Not in Admin sidebar — deleted)*

---

## Module Structure

```
src/modules/
└── schedule/
    ├── schedule.module.ts
    ├── entities/
    │   ├── exam-schedule.entity.ts
    │   ├── calendar-event.entity.ts
    │   └── calendar-integration.entity.ts
    ├── dto/
    │   ├── create-exam-schedule.dto.ts
    │   ├── update-exam-schedule.dto.ts
    │   ├── create-calendar-event.dto.ts
    │   ├── update-calendar-event.dto.ts
    │   └── query-schedule.dto.ts
    ├── controllers/
    │   ├── schedule.controller.ts
    │   ├── exam-schedule.controller.ts
    │   └── calendar.controller.ts
    ├── services/
    │   ├── schedule.service.ts
    │   ├── exam-schedule.service.ts
    │   └── calendar.service.ts
    └── exceptions/
        ├── exam-conflict.exception.ts
        └── schedule-conflict.exception.ts
```
