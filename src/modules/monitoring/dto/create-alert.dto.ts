import { IsNotEmpty, IsString, IsNumber, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateAlertDto {
  @ApiProperty({ description: 'Name of the alert rule', example: 'High CPU Alert' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiPropertyOptional({ description: 'Description of the alert rule', example: 'Triggers when CPU usage exceeds threshold' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: 'Condition type (e.g. cpu_usage, memory_usage, disk_usage)', example: 'cpu_usage' })
  @IsNotEmpty()
  @IsString()
  conditionType: string;

  @ApiProperty({ description: 'Threshold value', example: 90 })
  @IsNotEmpty()
  @IsNumber()
  threshold: number;
}
