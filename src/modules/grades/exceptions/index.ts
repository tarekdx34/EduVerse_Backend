import { NotFoundException, BadRequestException } from '@nestjs/common';

export class GradeNotFoundException extends NotFoundException {
  constructor(gradeId?: number) {
    super(`Grade ${gradeId ? `with ID ${gradeId} ` : ''}not found`);
  }
}

export class RubricNotFoundException extends NotFoundException {
  constructor(rubricId?: number) {
    super(`Rubric ${rubricId ? `with ID ${rubricId} ` : ''}not found`);
  }
}

export class GradeAlreadyPublishedException extends BadRequestException {
  constructor() {
    super('Cannot modify published grade');
  }
}

export class InvalidGradeTypeException extends BadRequestException {
  constructor(gradeType?: string) {
    super(`Invalid grade type${gradeType ? `: ${gradeType}` : ''}`);
  }
}
