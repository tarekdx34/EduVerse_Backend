import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { QuestionAttachmentType } from '../entities/question-bank-question-attachment.entity';

export class CreateQuestionAttachmentDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  fileId: number;

  @ApiPropertyOptional({ enum: QuestionAttachmentType })
  @IsOptional()
  @IsEnum(QuestionAttachmentType)
  attachmentType?: QuestionAttachmentType;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  caption?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  altText?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  displayOrder?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isPrimary?: boolean;
}

export class UpdateQuestionAttachmentDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  caption?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  altText?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  displayOrder?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isPrimary?: boolean;
}

export class ReorderQuestionAttachmentItemDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  attachmentId: number;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  displayOrder: number;
}

export class ReorderQuestionAttachmentsDto {
  @ApiProperty({ type: [ReorderQuestionAttachmentItemDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => ReorderQuestionAttachmentItemDto)
  items: ReorderQuestionAttachmentItemDto[];
}

export class UploadQuestionAttachmentMetadataDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  caption?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  altText?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  displayOrder?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isPrimary?: boolean;
}
