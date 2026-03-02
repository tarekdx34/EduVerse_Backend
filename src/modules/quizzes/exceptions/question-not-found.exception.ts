import { NotFoundException } from '@nestjs/common';

export class QuestionNotFoundException extends NotFoundException {
  constructor(questionId: number) {
    super(`Question with ID ${questionId} not found`);
  }
}
