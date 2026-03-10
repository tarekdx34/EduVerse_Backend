import { HttpException, HttpStatus } from '@nestjs/common';

export class ExamConflictException extends HttpException {
  constructor(conflictDetails: string) {
    super(
      {
        statusCode: HttpStatus.CONFLICT,
        message: 'Exam schedule conflict detected',
        error: 'Conflict',
        details: conflictDetails,
      },
      HttpStatus.CONFLICT,
    );
  }
}
