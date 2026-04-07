import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, MaxLength } from 'class-validator';

export class RegisterCampusEventDto {
  @ApiPropertyOptional({
    description: 'Optional notes for registration',
    example: 'Looking forward to attending!',
  })
  @IsString()
  @MaxLength(500)
  @IsOptional()
  notes?: string;
}
