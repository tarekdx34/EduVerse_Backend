import { IsString, IsOptional, IsEnum, IsNumber, IsBoolean } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IntegrationType } from '../entities/api-integration.entity';
import { PartialType } from '@nestjs/swagger';

export class CreateIntegrationDto {
  @ApiProperty({ description: 'Integration name' })
  @IsString()
  integrationName: string;

  @ApiProperty({ description: 'Integration type', enum: IntegrationType })
  @IsEnum(IntegrationType)
  integrationType: IntegrationType;

  @ApiProperty({ description: 'Campus ID' })
  @IsNumber()
  campusId: number;

  @ApiPropertyOptional({ description: 'API endpoint URL' })
  @IsOptional()
  @IsString()
  apiEndpoint?: string;

  @ApiPropertyOptional({ description: 'API key (will be encrypted)' })
  @IsOptional()
  @IsString()
  apiKey?: string;

  @ApiPropertyOptional({ description: 'API secret (will be encrypted)' })
  @IsOptional()
  @IsString()
  apiSecret?: string;

  @ApiPropertyOptional({ description: 'Configuration JSON' })
  @IsOptional()
  @IsString()
  configuration?: string;
}

export class UpdateIntegrationDto extends PartialType(CreateIntegrationDto) {
  @ApiPropertyOptional({ description: 'Active status' })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
