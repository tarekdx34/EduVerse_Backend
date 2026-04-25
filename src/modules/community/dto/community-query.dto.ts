import { IsOptional, IsNumber, IsEnum, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { ApiPropertyStringEnumOptional } from '../../../common/swagger/string-enum.schema';
import { CommunityType } from '../entities/community.entity';

export class CommunityQueryDto {
  @ApiPropertyStringEnumOptional({
    description: 'Filter by community type',
    enumObject: CommunityType,
  })
  @IsOptional()
  @IsEnum(CommunityType)
  communityType?: CommunityType;

  @ApiPropertyOptional({ description: 'Filter by department ID', example: 1 })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  departmentId?: number;

  @ApiPropertyOptional({ description: 'Page number', default: 1, minimum: 1 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Items per page', default: 20, minimum: 1 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  limit?: number = 20;
}
