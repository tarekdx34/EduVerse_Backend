import { BadRequestException } from '@nestjs/common';

export class QuizNotAvailableException extends BadRequestException {
  constructor(quizId: number, reason?: string) {
    super(reason || `Quiz ${quizId} is not currently available`);
  }
}
