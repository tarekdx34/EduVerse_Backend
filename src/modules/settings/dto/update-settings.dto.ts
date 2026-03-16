import { IsOptional, IsString, IsObject } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateSettingsDto {
  @ApiProperty({
    description: 'Key-value pairs of settings to update',
    example: { platform_name: 'My Campus', session_timeout_minutes: '60' },
  })
  @IsObject()
  settings: Record<string, string>;
}

export class UpdateSingleSettingDto {
  @ApiProperty({ description: 'Setting value' })
  @IsString()
  value: string;

  @ApiPropertyOptional({ description: 'Setting description' })
  @IsOptional()
  @IsString()
  description?: string;
}
