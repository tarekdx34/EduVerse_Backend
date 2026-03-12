import { NotFoundException } from '@nestjs/common';

export class QuizNotFoundException extends NotFoundException {
  constructor(quizId: number) {
    super(`Quiz with ID ${quizId} not found`);
  }
}
