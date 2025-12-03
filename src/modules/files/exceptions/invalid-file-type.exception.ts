import { BadRequestException } from '@nestjs/common';

export class InvalidFileTypeException extends BadRequestException {
  constructor(allowedTypes?: string[]) {
    const message = allowedTypes
      ? `Invalid file type. Allowed types: ${allowedTypes.join(', ')}`
      : 'Invalid file type';
    super(message);
  }
}

