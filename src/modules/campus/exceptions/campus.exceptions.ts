import {
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';

export class CampusNotFoundException extends NotFoundException {
  constructor(id?: number) {
    super(`Campus ${id ? `with ID ${id}` : ''} not found`);
  }
}

export class DepartmentNotFoundException extends NotFoundException {
  constructor(id?: number) {
    super(`Department ${id ? `with ID ${id}` : ''} not found`);
  }
}

export class ProgramNotFoundException extends NotFoundException {
  constructor(id?: number) {
    super(`Program ${id ? `with ID ${id}` : ''} not found`);
  }
}

export class SemesterNotFoundException extends NotFoundException {
  constructor(id?: number) {
    super(`Semester ${id ? `with ID ${id}` : ''} not found`);
  }
}

export class CampusCodeAlreadyExistsException extends ConflictException {
  constructor(code: string) {
    super(`Campus code "${code}" already exists`);
  }
}

export class DepartmentCodeAlreadyExistsException extends ConflictException {
  constructor(code: string) {
    super(`Department code "${code}" already exists in this campus`);
  }
}

export class ProgramCodeAlreadyExistsException extends ConflictException {
  constructor(code: string) {
    super(`Program code "${code}" already exists in this department`);
  }
}

export class InvalidHeadOfDepartmentException extends BadRequestException {
  constructor() {
    super('Head of department must have INSTRUCTOR or ADMIN role');
  }
}

export class CannotDeleteCampusWithDepartmentsException extends ConflictException {
  constructor() {
    super('Cannot delete campus with existing departments');
  }
}

export class CannotDeleteDepartmentWithProgramsException extends ConflictException {
  constructor() {
    super('Cannot delete department with existing programs');
  }
}

export class InvalidDateRangeException extends BadRequestException {
  constructor(message: string) {
    super(`Invalid date range: ${message}`);
  }
}

export class SemesterCodeAlreadyExistsException extends ConflictException {
  constructor(code: string) {
    super(`Semester code "${code}" already exists`);
  }
}
