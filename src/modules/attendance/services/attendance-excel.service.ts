import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as ExcelJS from 'exceljs';
import { AttendanceSession, AttendanceRecord } from '../entities';
import { AttendanceStatus, MarkedBy } from '../enums';
import { ImportResultDto } from '../dto';
import {
  SessionNotFoundException,
  InvalidExcelFormatException,
} from '../exceptions';
import { CourseEnrollment } from '../../enrollments/entities/course-enrollment.entity';
import { User } from '../../auth/entities/user.entity';

@Injectable()
export class AttendanceExcelService {
  constructor(
    @InjectRepository(AttendanceSession)
    private readonly sessionRepo: Repository<AttendanceSession>,
    @InjectRepository(AttendanceRecord)
    private readonly recordRepo: Repository<AttendanceRecord>,
    @InjectRepository(CourseEnrollment)
    private readonly enrollmentRepo: Repository<CourseEnrollment>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  async importFromExcel(
    sessionId: number,
    fileBuffer: Buffer,
  ): Promise<ImportResultDto> {
    const session = await this.sessionRepo.findOne({
      where: { id: sessionId },
      relations: ['section'],
    });

    if (!session) {
      throw new SessionNotFoundException(sessionId);
    }

    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.load(fileBuffer as unknown as ExcelJS.Buffer);

    const worksheet = workbook.worksheets[0];
    if (!worksheet) {
      throw new InvalidExcelFormatException('Excel file has no worksheets');
    }

    // Validate headers
    const headerRow = worksheet.getRow(1);
    const headers: string[] = [];
    headerRow.eachCell((cell) => {
      headers.push(String(cell.value || '').toLowerCase().trim());
    });

    const studentIdIndex = headers.findIndex(
      (h) => h === 'student_id' || h === 'studentid' || h === 'user_id' || h === 'userid',
    );
    const statusIndex = headers.findIndex(
      (h) => h === 'status' || h === 'attendance_status',
    );

    if (studentIdIndex === -1 || statusIndex === -1) {
      throw new InvalidExcelFormatException(
        'Excel file must have student_id and status columns',
      );
    }

    // Get enrolled students for this section
    const enrolledStudents = await this.enrollmentRepo.find({
      where: { sectionId: session.sectionId },
    });
    const enrolledUserIds = new Set(enrolledStudents.map((e) => e.userId));

    const result: ImportResultDto = {
      totalProcessed: 0,
      successCount: 0,
      failedCount: 0,
      errors: [],
    };

    // Process each row (skip header)
    for (let rowNumber = 2; rowNumber <= worksheet.rowCount; rowNumber++) {
      const row = worksheet.getRow(rowNumber);
      const studentId = Number(row.getCell(studentIdIndex + 1).value);
      const statusValue = String(row.getCell(statusIndex + 1).value || '')
        .toLowerCase()
        .trim();

      result.totalProcessed++;

      // Validate student ID
      if (!studentId || isNaN(studentId)) {
        result.failedCount++;
        result.errors.push({ row: rowNumber, error: 'Invalid student ID' });
        continue;
      }

      // Check if student is enrolled
      if (!enrolledUserIds.has(studentId)) {
        result.failedCount++;
        result.errors.push({
          row: rowNumber,
          error: `Student ID ${studentId} is not enrolled in this course`,
        });
        continue;
      }

      // Validate status
      const status = this.parseStatus(statusValue);
      if (!status) {
        result.failedCount++;
        result.errors.push({
          row: rowNumber,
          error: `Invalid status value: ${statusValue}`,
        });
        continue;
      }

      // Update or create record
      try {
        let record = await this.recordRepo.findOne({
          where: { sessionId, userId: studentId },
        });

        if (record) {
          record.attendanceStatus = status;
          record.markedBy = MarkedBy.MANUAL;
        } else {
          record = this.recordRepo.create({
            sessionId,
            userId: studentId,
            attendanceStatus: status,
            markedBy: MarkedBy.MANUAL,
          });
        }

        await this.recordRepo.save(record);
        result.successCount++;
      } catch (error) {
        result.failedCount++;
        result.errors.push({
          row: rowNumber,
          error: `Database error: ${error.message}`,
        });
      }
    }

    return result;
  }

  async exportToExcel(sessionId: number): Promise<Buffer> {
    const session = await this.sessionRepo.findOne({
      where: { id: sessionId },
      relations: ['section', 'section.course', 'records', 'records.user'],
    });

    if (!session) {
      throw new SessionNotFoundException(sessionId);
    }

    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'EduVerse';
    workbook.created = new Date();

    const worksheet = workbook.addWorksheet('Attendance');

    // Add header row
    worksheet.columns = [
      { header: 'Student ID', key: 'studentId', width: 12 },
      { header: 'Student Name', key: 'studentName', width: 30 },
      { header: 'Email', key: 'email', width: 30 },
      { header: 'Status', key: 'status', width: 12 },
      { header: 'Check-in Time', key: 'checkInTime', width: 20 },
      { header: 'Notes', key: 'notes', width: 30 },
    ];

    // Style header row
    worksheet.getRow(1).font = { bold: true };
    worksheet.getRow(1).fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFE0E0E0' },
    };

    // Add data rows
    for (const record of session.records) {
      worksheet.addRow({
        studentId: record.userId,
        studentName: record.user
          ? `${record.user.firstName} ${record.user.lastName}`
          : 'Unknown',
        email: record.user?.email || '',
        status: record.attendanceStatus.toUpperCase(),
        checkInTime: record.checkInTime
          ? record.checkInTime.toISOString()
          : '',
        notes: record.notes || '',
      });
    }

    // Add summary at the bottom
    worksheet.addRow([]);
    worksheet.addRow(['Session Information']);
    worksheet.addRow([
      'Course',
      session.section?.course?.name || 'Unknown',
    ]);
    worksheet.addRow(['Section', session.section?.sectionNumber || 'Unknown']);
    worksheet.addRow(['Date', session.sessionDate]);
    worksheet.addRow(['Type', session.sessionType]);
    worksheet.addRow(['Total Students', session.totalStudents]);
    worksheet.addRow(['Present', session.presentCount]);
    worksheet.addRow(['Absent', session.absentCount]);

    const buffer = await workbook.xlsx.writeBuffer();
    return Buffer.from(buffer as ArrayBuffer);
  }

  async exportSectionToExcel(sectionId: number): Promise<Buffer> {
    const sessions = await this.sessionRepo.find({
      where: { sectionId },
      relations: ['section', 'section.course', 'records', 'records.user'],
      order: { sessionDate: 'ASC' },
    });

    if (sessions.length === 0) {
      throw new InvalidExcelFormatException('No sessions found for this section');
    }

    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'EduVerse';
    workbook.created = new Date();

    // Get all unique students
    const studentMap = new Map<
      number,
      { name: string; email: string; records: Map<number, AttendanceStatus> }
    >();

    sessions.forEach((session) => {
      session.records.forEach((record) => {
        if (!studentMap.has(record.userId)) {
          studentMap.set(record.userId, {
            name: record.user
              ? `${record.user.firstName} ${record.user.lastName}`
              : 'Unknown',
            email: record.user?.email || '',
            records: new Map(),
          });
        }
        studentMap.get(record.userId)!.records.set(session.id, record.attendanceStatus);
      });
    });

    const worksheet = workbook.addWorksheet('Attendance Report');

    // Create columns: Student ID, Name, Email, then one column per session date
    const columns: Partial<ExcelJS.Column>[] = [
      { header: 'Student ID', key: 'studentId', width: 12 },
      { header: 'Name', key: 'name', width: 30 },
      { header: 'Email', key: 'email', width: 30 },
    ];

    sessions.forEach((session) => {
      columns.push({
        header: session.sessionDate,
        key: `session_${session.id}`,
        width: 12,
      });
    });

    columns.push({ header: 'Attendance %', key: 'percentage', width: 15 });

    worksheet.columns = columns;

    // Style header row
    worksheet.getRow(1).font = { bold: true };
    worksheet.getRow(1).fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFE0E0E0' },
    };

    // Add data rows
    studentMap.forEach((student, studentId) => {
      const row: Record<string, unknown> = {
        studentId,
        name: student.name,
        email: student.email,
      };

      let presentCount = 0;
      sessions.forEach((session) => {
        const status = student.records.get(session.id) || AttendanceStatus.ABSENT;
        row[`session_${session.id}`] = status.toUpperCase().charAt(0); // P, A, L, E
        if (
          status === AttendanceStatus.PRESENT ||
          status === AttendanceStatus.LATE
        ) {
          presentCount++;
        }
      });

      row['percentage'] =
        sessions.length > 0
          ? `${Math.round((presentCount / sessions.length) * 100)}%`
          : '0%';

      worksheet.addRow(row);
    });

    const buffer = await workbook.xlsx.writeBuffer();
    return Buffer.from(buffer as ArrayBuffer);
  }

  private parseStatus(value: string): AttendanceStatus | null {
    const normalized = value.toLowerCase().trim();
    switch (normalized) {
      case 'present':
      case 'p':
        return AttendanceStatus.PRESENT;
      case 'absent':
      case 'a':
        return AttendanceStatus.ABSENT;
      case 'late':
      case 'l':
        return AttendanceStatus.LATE;
      case 'excused':
      case 'e':
        return AttendanceStatus.EXCUSED;
      default:
        return null;
    }
  }
}
