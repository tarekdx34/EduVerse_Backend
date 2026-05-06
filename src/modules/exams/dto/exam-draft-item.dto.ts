import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';

export class AddDraftItemDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  questionId: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  draftSectionId?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @Min(0)
  weightUnits?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @Min(0)
  marks?: number;

  @ApiPropertyOptional({
    description:
      'Required when intentionally adding a question outside the original generation rule constraints.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  overrideReason?: string;
}

export class ReorderDraftItemDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  itemId: number;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  itemOrder: number;
}

export class ReorderDraftItemsDto {
  @ApiProperty({ type: [ReorderDraftItemDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => ReorderDraftItemDto)
  items: ReorderDraftItemDto[];
}

export class RemoveDraftItemDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  itemId: number;
}

export class ReplacementCheckDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  replacementQuestionId: number;
}

export class DuplicateDraftDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(100)
  seed?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(255)
  title?: string;

  @ApiPropertyOptional({ default: false })
  @IsOptional()
  @IsBoolean()
  regenerate?: boolean;
}

export class DraftItemResponseDto {
  itemId: number;
  draftId: number;
  questionId: number;
  draftSectionId?: number | null;
  chapterId: number;
  questionType: string;
  difficulty: string;
  bloomLevel: string;
  weight: number;
  weightUnits: number;
  marks?: number | null;
  itemOrder: number;
  overrideReason?: string | null;
}
