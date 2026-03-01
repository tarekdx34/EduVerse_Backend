import { IsString, IsNumber, IsOptional } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class SubmitAssignmentDto {
  @ApiPropertyOptional({ description: 'Text submission content' })
  @IsString()
  @IsOptional()
  submissionText?: string;

  @ApiPropertyOptional({ description: 'File ID from files module' })
  @IsNumber()
  @IsOptional()
  fileId?: number;

  @ApiPropertyOptional({ description: 'Link submission URL' })
  @IsString()
  @IsOptional()
  submissionLink?: string;
}
