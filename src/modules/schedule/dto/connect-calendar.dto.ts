import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsEnum } from 'class-validator';
import { CalendarType } from '../enums';

export class ConnectCalendarDto {
  @ApiProperty({
    description: 'Type of calendar to connect',
    enum: ['google', 'outlook', 'ical'],
    example: 'google',
  })
  @IsEnum(CalendarType)
  @IsNotEmpty()
  calendarType: CalendarType;

  @ApiProperty({
    description: 'OAuth authorization code from calendar provider',
    example: 'authorization_code_from_oauth_flow',
  })
  @IsNotEmpty()
  authorizationCode: string;
}
