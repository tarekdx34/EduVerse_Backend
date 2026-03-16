import { PartialType } from '@nestjs/swagger';
import { CreateAlertDto } from './create-alert.dto';
import { IsOptional, IsBoolean } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateAlertDto extends PartialType(CreateAlertDto) {
  @ApiPropertyOptional({ description: 'Whether the alert is active', example: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
