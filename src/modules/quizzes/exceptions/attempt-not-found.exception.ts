import { NotFoundException } from '@nestjs/common';

export class AttemptNotFoundException extends NotFoundException {
  constructor(attemptId: number) {
    super(`Quiz attempt with ID ${attemptId} not found`);
  }
}
