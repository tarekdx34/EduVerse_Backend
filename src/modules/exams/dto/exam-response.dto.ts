export class ExamResponseDto {
  id: number;
  courseId: number;
  title: string;
  totalMarks?: number | null;
  status: string;
  publishedAt?: Date | null;
  archivedAt?: Date | null;
  createdAt?: Date;
  updatedAt?: Date;
  itemCount?: number;
  sectionCount?: number;
}
