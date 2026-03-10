import { HttpException, HttpStatus } from '@nestjs/common';

export class PostNotFoundException extends HttpException {
  constructor(postId: number) {
    super(`Community post with ID ${postId} not found`, HttpStatus.NOT_FOUND);
  }
}
