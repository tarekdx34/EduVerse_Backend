export class TranscriptCourse {
  courseId: number;
  courseName: string;
  credits: number;
  letterGrade: string;
  score: number;
  maxScore: number;
}

export class TranscriptSemester {
  semesterId: number;
  semesterName: string;
  gpa: number;
  courses: TranscriptCourse[];
}

export class TranscriptResponseDto {
  studentId: number;
  studentName: string;
  cumulativeGpa: number;
  totalCredits: number;
  semesters: TranscriptSemester[];
}
