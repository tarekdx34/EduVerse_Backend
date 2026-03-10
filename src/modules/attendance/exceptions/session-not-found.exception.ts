import { NotFoundException } from '@nestjs/common';

export class SessionNotFoundException extends NotFoundException {
  constructor(sessionId: number) {
    super(`Attendance session with ID ${sessionId} not found`);
  }
}
