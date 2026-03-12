import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class StartAttemptDto {
  @ApiPropertyOptional({ description: 'Client IP address for logging', example: '192.168.1.1' })
  @IsOptional()
  @IsString()
  ipAddress?: string;
}
