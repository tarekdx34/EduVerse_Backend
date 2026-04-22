import { IsNumber, IsNotEmpty, Min, IsEnum, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { InstructorRole } from '../entities/course-instructor.entity';

export class AssignInstructorDto {
  @ApiProperty({
    description: 'The ID of the user to assign as instructor',
    example: 5,
    minimum: 1,
  })
  @IsNumber()
  @IsNotEmpty()
  @Min(1)
  userId: number;

  @ApiPropertyOptional({
    description: 'Role of the instructor in this section',
    enum: InstructorRole,
    default: InstructorRole.PRIMARY,
    example: InstructorRole.PRIMARY,
  })
  @IsOptional()
  @IsEnum(InstructorRole)
  role?: InstructorRole;
}

export class InstructorAssignmentResponseDto {
  @ApiProperty({ example: 1 })
  id: number;

  @ApiProperty({ example: 10 })
  sectionId: number;

  @ApiProperty({ example: 5 })
  userId: number;

  @ApiProperty({ enum: InstructorRole, example: InstructorRole.PRIMARY })
  role: InstructorRole;

  @ApiProperty()
  assignedAt: Date;

  @ApiProperty({ example: 'John' })
  firstName: string;

  @ApiProperty({ example: 'Doe' })
  lastName: string;

  @ApiProperty({ example: 'john.doe@example.com' })
  email: string;
}
