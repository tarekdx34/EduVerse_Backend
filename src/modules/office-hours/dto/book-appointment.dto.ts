import { IsNotEmpty, IsOptional, IsString, IsInt } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class BookAppointmentDto {
  @ApiProperty({ description: 'Office hour slot ID', example: 1 })
  @IsNotEmpty()
  @Type(() => Number)
  @IsInt()
  slotId: number;

  @ApiProperty({ description: 'Appointment date (YYYY-MM-DD)', example: '2026-03-20' })
  @IsNotEmpty()
  @IsString()
  appointmentDate: string;

  @ApiPropertyOptional({ description: 'Topic to discuss', example: 'Help with Assignment 3' })
  @IsOptional()
  @IsString()
  topic?: string;

  @ApiPropertyOptional({ description: 'Additional notes', example: 'I have questions about the algorithm section' })
  @IsOptional()
  @IsString()
  notes?: string;
}
