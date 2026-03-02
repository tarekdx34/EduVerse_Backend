import { BadRequestException } from '@nestjs/common';

export class InvalidExcelFormatException extends BadRequestException {
  constructor(message?: string) {
    super(message || 'Invalid Excel file format. Expected columns: student_id, status');
  }
}
