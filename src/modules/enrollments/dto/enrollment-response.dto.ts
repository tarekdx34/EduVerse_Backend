import { EnrollmentStatus, DropReason } from '../enums';

export class EnrollmentResponseDto {
  id: number;
  userId: number;
  sectionId: number;
  status: EnrollmentStatus;
  grade: string | null;
  finalScore: number | null;
  enrollmentDate: Date;
  droppedAt: Date | null;
  completedAt: Date | null;
  canDrop: boolean;
  dropDeadline: Date | null;

  // Related data
  course?: {
    id: number;
    name: string;
    code: string;
    description: string;
    credits: number;
    level: string;
  };

  section?: {
    id: number;
    sectionNumber: string;
    maxCapacity: number;
    currentEnrollment: number;
    location: string | null;
  };

  semester?: {
    id: number;
    name: string;
    startDate: Date;
    endDate: Date;
  };

  instructor?: {
    id: number;
    firstName: string;
    lastName: string;
    email: string;
  };

  prerequisites?: {
    id: number;
    courseId: number;
    prerequisiteCourseId: number;
    courseCode: string;
    courseName: string;
    isMandatory: boolean;
    studentCompleted: boolean;
    studentGrade: string | null;
  }[];
}
