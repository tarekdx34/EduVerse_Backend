import { IsNumber, IsNotEmpty, Min } from 'class-validator';

export class EnrollCourseDto {
  @IsNumber()
  @IsNotEmpty()
  @Min(1)
  sectionId: number;
}
