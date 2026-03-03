import { IsDateString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ScheduleAnnouncementDto {
  @ApiProperty({
    description: 'Date and time when the announcement should be published',
    example: '2026-03-15T09:00:00Z',
  })
  @IsDateString()
  scheduledAt: string;
}
