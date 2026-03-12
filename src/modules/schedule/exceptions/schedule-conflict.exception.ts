import { HttpException, HttpStatus } from '@nestjs/common';

export class ScheduleConflictException extends HttpException {
  constructor(conflictDetails: string) {
    super(
      {
        statusCode: HttpStatus.CONFLICT,
        message: 'Schedule conflict detected',
        error: 'Conflict',
        details: conflictDetails,
      },
      HttpStatus.CONFLICT,
    );
  }
}
