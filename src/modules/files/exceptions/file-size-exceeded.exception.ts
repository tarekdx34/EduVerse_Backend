import { PayloadTooLargeException } from '@nestjs/common';

export class FileSizeExceededException extends PayloadTooLargeException {
  constructor(maxSize: number) {
    super(`File size exceeds maximum allowed size of ${maxSize} bytes`);
  }
}

