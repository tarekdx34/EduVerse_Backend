import { HttpException, HttpStatus } from '@nestjs/common';

export class CommentNotFoundException extends HttpException {
  constructor(commentId: number) {
    super(`Comment with ID ${commentId} not found`, HttpStatus.NOT_FOUND);
  }
}
