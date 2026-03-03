import { IsString, IsOptional, IsEnum, IsNumber, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PostType } from '../enums';

export class CreatePostDto {
  @ApiProperty({
    description: 'Post title',
    example: 'Study Group for Midterm',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  title: string;

  @ApiProperty({
    description: 'Post content/body',
    example: 'Anyone interested in forming a study group for the upcoming midterm? We can meet on weekends.',
  })
  @IsString()
  content: string;

  @ApiProperty({
    description: 'Course ID where the post belongs',
    example: 1,
  })
  @IsNumber()
  courseId: number;

  @ApiPropertyOptional({
    description: 'Type of post',
    enum: PostType,
    default: PostType.DISCUSSION,
  })
  @IsOptional()
  @IsEnum(PostType)
  postType?: PostType;
}
