import { NotFoundException } from '@nestjs/common';

export class FileNotFoundException extends NotFoundException {
  constructor(fileId?: number) {
    super(`File ${fileId ? `with ID ${fileId}` : ''} not found`);
  }
}

