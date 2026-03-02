import { NotFoundException } from '@nestjs/common';

export class RecordNotFoundException extends NotFoundException {
  constructor(recordId: number) {
    super(`Attendance record with ID ${recordId} not found`);
  }
}
