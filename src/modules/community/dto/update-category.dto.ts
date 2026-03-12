import { PartialType } from '@nestjs/swagger';
import { CreateCategoryDto } from './create-category.dto';
import { OmitType } from '@nestjs/swagger';

export class UpdateCategoryDto extends PartialType(
  OmitType(CreateCategoryDto, ['courseId'] as const),
) {}
