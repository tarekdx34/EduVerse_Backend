import { ApiPropertyOptional, PartialType, OmitType } from '@nestjs/swagger';
import { CreateScheduleTemplateDto } from './create-schedule-template.dto';

export class UpdateScheduleTemplateDto extends PartialType(
  OmitType(CreateScheduleTemplateDto, ['slots'] as const)
) {}
