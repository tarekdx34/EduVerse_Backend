import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class ExamLifecycleDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  reason?: string;
}

export class PublishExamDto extends ExamLifecycleDto {}
export class ArchiveExamDto extends ExamLifecycleDto {}
export class UnpublishExamDto extends ExamLifecycleDto {}
