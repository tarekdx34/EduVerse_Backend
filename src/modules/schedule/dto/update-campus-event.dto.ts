import { ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { CreateCampusEventDto } from './create-campus-event.dto';

export class UpdateCampusEventDto extends PartialType(CreateCampusEventDto) {}
