import { IsNumber, IsNotEmpty, Min, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class AssignTADto {
  @ApiProperty({
    description: 'The ID of the user to assign as Teaching Assistant',
    example: 7,
    minimum: 1,
  })
  @IsNumber()
  @IsNotEmpty()
  @Min(1)
  userId: number;

  @ApiPropertyOptional({
    description: 'Description of TA responsibilities in this section',
    example: 'Grading assignments, running office hours on Mon/Wed',
  })
  @IsOptional()
  @IsString()
  responsibilities?: string;
}

export class TAAssignmentResponseDto {
  @ApiProperty({ example: 1 })
  id: number;

  @ApiProperty({ example: 10 })
  sectionId: number;

  @ApiProperty({ example: 7 })
  userId: number;

  @ApiPropertyOptional({ example: 'Grading assignments, running office hours on Mon/Wed' })
  responsibilities: string | null;

  @ApiProperty()
  assignedAt: Date;

  @ApiProperty({ example: 'Jane' })
  firstName: string;

  @ApiProperty({ example: 'Smith' })
  lastName: string;

  @ApiProperty({ example: 'jane.smith@example.com' })
  email: string;
}
