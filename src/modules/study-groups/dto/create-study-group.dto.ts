import { IsNotEmpty, IsString, IsOptional, IsInt, IsBoolean, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CreateStudyGroupDto {
  @ApiProperty({ description: 'Course ID to associate the study group with', example: 1 })
  @IsNotEmpty()
  @Type(() => Number)
  @IsInt()
  courseId: number;

  @ApiProperty({ description: 'Name of the study group', example: 'Data Structures Study Group' })
  @IsNotEmpty()
  @IsString()
  groupName: string;

  @ApiPropertyOptional({ description: 'Description of the study group', example: 'Weekly study sessions for DS course' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ description: 'Maximum number of members allowed', example: 10, default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(2)
  @Max(50)
  maxMembers?: number;

  @ApiPropertyOptional({ description: 'Whether the group is public (anyone can join)', example: true, default: true })
  @IsOptional()
  @IsBoolean()
  isPublic?: boolean;

  @ApiPropertyOptional({ description: 'Meeting schedule text', example: 'Every Monday 5-7 PM' })
  @IsOptional()
  @IsString()
  meetingSchedule?: string;
}
