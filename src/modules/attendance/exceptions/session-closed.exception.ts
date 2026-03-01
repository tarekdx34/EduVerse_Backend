import { BadRequestException } from '@nestjs/common';

export class SessionClosedException extends BadRequestException {
  constructor(sessionId: number) {
    super(
      `Attendance session with ID ${sessionId} is already closed and cannot be modified`,
    );
  }
}
