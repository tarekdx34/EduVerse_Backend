import { IsString, IsOptional, IsEnum, IsNumber, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { CommunityType } from '../entities/community.entity';

export class CreateCommunityDto {
  @ApiProperty({ description: 'Community name', example: 'CS Cohort 2026', maxLength: 255 })
  @IsString()
  @MaxLength(255)
  name: string;

  @ApiPropertyOptional({ description: 'Community description', example: 'Community for CS students graduating in 2026' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: 'Community type', enum: CommunityType, example: CommunityType.GLOBAL })
  @IsEnum(CommunityType)
  communityType: CommunityType;

  @ApiPropertyOptional({ description: 'Department ID (required for department communities)', example: 1 })
  @IsOptional()
  @IsNumber()
  departmentId?: number;

  @ApiPropertyOptional({ description: 'Cover image URL', example: 'https://example.com/cover.jpg' })
  @IsOptional()
  @IsString()
  coverImageUrl?: string;
}
