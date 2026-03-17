import { PartialType } from '@nestjs/swagger';
import { CreateStudyGroupDto } from './create-study-group.dto';
import { IsOptional, IsIn } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateStudyGroupDto extends PartialType(CreateStudyGroupDto) {
  @ApiPropertyOptional({ description: 'Group status', enum: ['active', 'inactive', 'archived'], example: 'active' })
  @IsOptional()
  @IsIn(['active', 'inactive', 'archived'])
  status?: string;
}
