import { BadRequestException } from '@nestjs/common';

export class AttemptAlreadySubmittedException extends BadRequestException {
  constructor(attemptId: number) {
    super(`Quiz attempt ${attemptId} has already been submitted`);
  }
}
