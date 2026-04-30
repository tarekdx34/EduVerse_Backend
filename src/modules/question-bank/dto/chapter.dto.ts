import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class CreateChapterDto {
  @ApiProperty({ example: 'Chapter 1' })
  @IsString()
  @MaxLength(200)
  name: string;

  @ApiProperty({ example: 1 })
  @IsInt()
  @Min(1)
  chapterOrder: number;
}

export class UpdateChapterDto {
  @ApiPropertyOptional({ example: 'Chapter 2' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  name?: string;

  @ApiPropertyOptional({ example: 2 })
  @IsOptional()
  @IsInt()
  @Min(1)
  chapterOrder?: number;

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @IsInt()
  isActive?: number;
}

