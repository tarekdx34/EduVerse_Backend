export enum EnrollmentStatus {
  ENROLLED = 'enrolled',
  DROPPED = 'dropped',
  COMPLETED = 'completed',
  WITHDRAWN = 'withdrawn',
}

export enum DropReason {
  STUDENT_REQUEST = 'student_request',
  FAILING_GRADE = 'failing_grade',
  ADMIN_REMOVAL = 'admin_removal',
  SCHEDULE_CONFLICT = 'schedule_conflict',
  OTHER = 'other',
}
