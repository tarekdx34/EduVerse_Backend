import { BadRequestException, NotFoundException } from '@nestjs/common';

export class AssignmentNotFoundException extends NotFoundException {
  constructor() {
    super('Assignment not found');
  }
}

export class SubmissionDeadlinePassedException extends BadRequestException {
  constructor() {
    super('Submission deadline has passed');
  }
}

export class AssignmentNotPublishedException extends BadRequestException {
  constructor() {
    super('Assignment is not published');
  }
}

export class MaxAttemptsReachedException extends BadRequestException {
  constructor() {
    super('Maximum submission attempts reached');
  }
}

export class AssignmentNotAvailableYetException extends BadRequestException {
  constructor() {
    super('Assignment is not available yet');
  }
}

export class SubmissionNotFoundException extends NotFoundException {
  constructor() {
    super('Submission not found');
  }
}
