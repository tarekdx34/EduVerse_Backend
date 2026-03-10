import { BadRequestException, ConflictException, NotFoundException, ForbiddenException } from '@nestjs/common';

export class EnrollmentNotFoundException extends NotFoundException {
  constructor() {
    super('Enrollment not found');
  }
}

export class AlreadyEnrolledException extends ConflictException {
  constructor() {
    super('Student is already enrolled in this section');
  }
}

export class SectionFullException extends ConflictException {
  constructor() {
    super('Section is full. You have been added to the waitlist');
  }
}

export class PrerequisiteNotMetException extends BadRequestException {
  constructor(message?: string) {
    super(message || 'Prerequisite requirements not met for enrollment');
  }
}

export class ScheduleConflictException extends BadRequestException {
  constructor() {
    super('Schedule conflict with existing enrollment');
  }
}

export class StudentNotEnrolledException extends BadRequestException {
  constructor() {
    super('Student is not enrolled in this course');
  }
}

export class DropDeadlinePassedException extends BadRequestException {
  constructor() {
    super('Drop deadline has passed. Contact admin to drop this course');
  }
}

export class FailedGradeRequiredForRetakeException extends BadRequestException {
  constructor() {
    super('You can only retake this course if you failed it previously');
  }
}

export class RetakeRequiresAdminApprovalException extends BadRequestException {
  constructor() {
    super('Retaking courses for grade improvement requires admin approval');
  }
}

export class CannotDropPastEnrollmentException extends BadRequestException {
  constructor() {
    super('Cannot drop an enrollment that is no longer active');
  }
}

export class EnrollmentAccessDeniedException extends ForbiddenException {
  constructor() {
    super('You do not have permission to access this enrollment');
  }
}
