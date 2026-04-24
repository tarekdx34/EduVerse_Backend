export enum ExamType {
  MIDTERM = 'midterm',
  FINAL = 'final',
  QUIZ = 'quiz',
  MAKEUP = 'makeup',
}

export enum EventType {
  LECTURE = 'lecture',
  LAB = 'lab',
  EXAM = 'exam',
  ASSIGNMENT = 'assignment',
  QUIZ = 'quiz',
  MEETING = 'meeting',
  HOLIDAY = 'holiday',
  ACADEMIC = 'academic',
  CUSTOM = 'custom',
}

export enum EventStatus {
  SCHEDULED = 'scheduled',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
}

export enum CalendarType {
  GOOGLE = 'google',
  OUTLOOK = 'outlook',
  ICAL = 'ical',
}

export enum SyncStatus {
  ACTIVE = 'active',
  ERROR = 'error',
  DISABLED = 'disabled',
}
