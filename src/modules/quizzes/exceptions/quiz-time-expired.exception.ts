import { BadRequestException } from '@nestjs/common';

export class QuizTimeExpiredException extends BadRequestException {
  constructor(attemptId: number) {
    super(`Time limit expired for quiz attempt ${attemptId}`);
  }
}
