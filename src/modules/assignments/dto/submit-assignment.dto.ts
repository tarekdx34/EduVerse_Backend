import { IsString, IsNumber, IsOptional } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class SubmitAssignmentDto {
  @ApiPropertyOptional({ description: 'Text submission content', example: 'This is my essay submission about data structures...' })
  @IsString()
  @IsOptional()
  submissionText?: string;

  @ApiPropertyOptional({ description: 'File ID from files module', example: 1 })
  @IsNumber()
  @IsOptional()
  fileId?: number;

  @ApiPropertyOptional({ description: 'Link submission URL', example: 'https://github.com/student/project' })
  @IsString()
  @IsOptional()
  submissionLink?: string;
}
