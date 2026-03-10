import { HttpException, HttpStatus } from '@nestjs/common';

export class AnnouncementNotFoundException extends HttpException {
  constructor(announcementId: number) {
    super(`Announcement with ID ${announcementId} not found`, HttpStatus.NOT_FOUND);
  }
}
