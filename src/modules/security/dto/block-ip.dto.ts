import { IsString, IsOptional, IsDateString, IsIP } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class BlockIpDto {
  @ApiProperty({ description: 'IP address to block' })
  @IsString()
  ipAddress: string;

  @ApiProperty({ description: 'Reason for blocking' })
  @IsString()
  reason: string;

  @ApiPropertyOptional({ description: 'Expiration date (ISO format), null = permanent' })
  @IsOptional()
  @IsDateString()
  expiresAt?: string;
}
