import { HttpException, HttpStatus } from '@nestjs/common';

export class CourseNotFoundException extends HttpException {
  constructor(id: number) {
    super(`Course with ID ${id} not found`, HttpStatus.NOT_FOUND);
  }
}

export class CourseCodeAlreadyExistsException extends HttpException {
  constructor(code: string, departmentId: number) {
    super(
      `Course code '${code}' already exists in department ${departmentId}`,
      HttpStatus.CONFLICT,
    );
  }
}

export class CannotDeleteCourseWithActiveSectionsException extends HttpException {
  constructor(courseId: number) {
    super(
      `Cannot delete course ${courseId}. Active sections exist`,
      HttpStatus.BAD_REQUEST,
    );
  }
}

export class CircularPrerequisiteDetectedException extends HttpException {
  constructor(courseId: number, prerequisiteId: number) {
    super(
      `Circular dependency detected: Course ${courseId} cannot have ${prerequisiteId} as prerequisite`,
      HttpStatus.BAD_REQUEST,
    );
  }
}

export class PrerequisiteNotFoundException extends HttpException {
  constructor(prereqId: number) {
    super(`Prerequisite with ID ${prereqId} not found`, HttpStatus.NOT_FOUND);
  }
}

export class SectionNotFoundException extends HttpException {
  constructor(id: number) {
    super(`Section with ID ${id} not found`, HttpStatus.NOT_FOUND);
  }
}

export class SectionFullException extends HttpException {
  constructor(sectionId: number) {
    super(
      `Section ${sectionId} is full and cannot accept more enrollments`,
      HttpStatus.BAD_REQUEST,
    );
  }
}

export class ScheduleNotFoundException extends HttpException {
  constructor(id: number) {
    super(`Schedule with ID ${id} not found`, HttpStatus.NOT_FOUND);
  }
}

export class ScheduleConflictException extends HttpException {
  constructor(message: string) {
    super(`Schedule conflict: ${message}`, HttpStatus.BAD_REQUEST);
  }
}

export class InvalidTimeRangeException extends HttpException {
  constructor() {
    super(
      'Invalid time range: end time must be after start time',
      HttpStatus.BAD_REQUEST,
    );
  }
}

export class DepartmentNotFoundException extends HttpException {
  constructor(deptId: number) {
    super(`Department with ID ${deptId} not found`, HttpStatus.NOT_FOUND);
  }
}

export class SemesterNotFoundException extends HttpException {
  constructor(semesterId: number) {
    super(`Semester with ID ${semesterId} not found`, HttpStatus.NOT_FOUND);
  }
}

export class UnauthorizedCourseActionException extends HttpException {
  constructor(action: string) {
    super(
      `You are not authorized to ${action} this course`,
      HttpStatus.FORBIDDEN,
    );
  }
}
