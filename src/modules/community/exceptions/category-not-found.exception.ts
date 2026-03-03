import { HttpException, HttpStatus } from '@nestjs/common';

export class CategoryNotFoundException extends HttpException {
  constructor(categoryId: number) {
    super(`Forum category with ID ${categoryId} not found`, HttpStatus.NOT_FOUND);
  }
}
