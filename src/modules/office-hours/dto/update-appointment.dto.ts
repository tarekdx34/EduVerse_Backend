import { IsOptional, IsString, IsIn } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateAppointmentDto {
  @ApiPropertyOptional({
    description: 'Appointment status',
    enum: ['confirmed', 'cancelled', 'completed', 'no_show'],
    example: 'confirmed',
  })
  @IsOptional()
  @IsIn(['confirmed', 'cancelled', 'completed', 'no_show'])
  status?: string;

  @ApiPropertyOptional({ description: 'Additional notes', example: 'Student confirmed attendance' })
  @IsOptional()
  @IsString()
  notes?: string;
}
