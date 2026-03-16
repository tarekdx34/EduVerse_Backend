import { IsOptional, IsNumber, IsString } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateRateLimitsDto {
  @ApiPropertyOptional({ description: 'Endpoint pattern' })
  @IsOptional()
  @IsString()
  endpoint?: string;

  @ApiPropertyOptional({ description: 'Maximum requests per window' })
  @IsOptional()
  @IsNumber()
  maxRequests?: number;

  @ApiPropertyOptional({ description: 'Window size in seconds' })
  @IsOptional()
  @IsNumber()
  windowSeconds?: number;
}
