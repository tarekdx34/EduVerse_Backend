import { IsOptional, IsString, IsEnum } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateErrorDto {
  @ApiPropertyOptional({
    description: 'Resolution status',
    enum: ['investigating', 'resolved', 'ignored'],
    example: 'resolved',
  })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ description: 'Notes about the resolution', example: 'Fixed by patching the API endpoint' })
  @IsOptional()
  @IsString()
  resolutionNotes?: string;
}
