export enum SubmissionType {
  FILE = 'file',
  TEXT = 'text',
  LINK = 'link',
  MULTIPLE = 'multiple',
}

export enum SubmissionStatus {
  SUBMITTED = 'submitted',
  LATE = 'late',
  GRADED = 'graded',
  RETURNED = 'returned',
  RESUBMIT = 'resubmit',
}

export enum AssignmentStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  CLOSED = 'closed',
  ARCHIVED = 'archived',
}
