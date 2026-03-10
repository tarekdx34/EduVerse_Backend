import { BadRequestException } from '@nestjs/common';

export class AttemptLimitReachedException extends BadRequestException {
  constructor(quizId: number, maxAttempts: number) {
    super(`Maximum attempts (${maxAttempts}) reached for quiz ${quizId}`);
  }
}
