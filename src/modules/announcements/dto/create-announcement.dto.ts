import { IsString, IsOptional, IsEnum, IsNumber, IsBoolean, IsDateString, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { AnnouncementType, AnnouncementPriority, TargetAudience } from '../enums';

export class CreateAnnouncementDto {
  @ApiProperty({
    description: 'Announcement title',
    example: 'Important: Midterm Exam Schedule',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  title: string;

  @ApiProperty({
    description: 'Announcement content/body',
    example: 'The midterm exam will be held on March 15, 2026 from 2:00 PM to 4:00 PM in Room 301.',
  })
  @IsString()
  content: string;

  @ApiPropertyOptional({
    description: 'Course ID for course-level announcements. Leave empty for system/campus announcements.',
    example: 1,
  })
  @IsOptional()
  @IsNumber()
  courseId?: number;

  @ApiPropertyOptional({
    description: 'Type of announcement',
    enum: AnnouncementType,
    default: AnnouncementType.COURSE,
  })
  @IsOptional()
  @IsEnum(AnnouncementType)
  announcementType?: AnnouncementType;

  @ApiPropertyOptional({
    description: 'Priority level',
    enum: AnnouncementPriority,
    default: AnnouncementPriority.MEDIUM,
  })
  @IsOptional()
  @IsEnum(AnnouncementPriority)
  priority?: AnnouncementPriority;

  @ApiPropertyOptional({
    description: 'Target audience for the announcement',
    enum: TargetAudience,
    default: TargetAudience.ALL,
  })
  @IsOptional()
  @IsEnum(TargetAudience)
  targetAudience?: TargetAudience;

  @ApiPropertyOptional({
    description: 'Expiration date for the announcement',
    example: '2026-04-01T00:00:00Z',
  })
  @IsOptional()
  @IsDateString()
  expiresAt?: string;

  @ApiPropertyOptional({
    description: 'File ID for attachment',
    example: 1,
  })
  @IsOptional()
  @IsNumber()
  attachmentFileId?: number;

  @ApiPropertyOptional({
    description: 'Whether to publish immediately',
    default: false,
  })
  @IsOptional()
  @IsBoolean()
  isPublished?: boolean;
}
