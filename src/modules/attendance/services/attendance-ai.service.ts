import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import {
  AttendanceSession,
  AttendanceRecord,
  AttendancePhoto,
  AiAttendanceProcessing,
} from '../entities';
import { AttendanceStatus, MarkedBy, ProcessingStatus, PhotoType } from '../enums';
import { AiProcessingResultDto } from '../dto';
import { SessionNotFoundException } from '../exceptions';

@Injectable()
export class AttendanceAiService {
  private readonly aiServiceUrl: string;

  constructor(
    @InjectRepository(AttendanceSession)
    private readonly sessionRepo: Repository<AttendanceSession>,
    @InjectRepository(AttendanceRecord)
    private readonly recordRepo: Repository<AttendanceRecord>,
    @InjectRepository(AttendancePhoto)
    private readonly photoRepo: Repository<AttendancePhoto>,
    @InjectRepository(AiAttendanceProcessing)
    private readonly processingRepo: Repository<AiAttendanceProcessing>,
    private readonly configService: ConfigService,
  ) {
    this.aiServiceUrl =
      this.configService.get<string>('AI_ATTENDANCE_SERVICE_URL') ||
      'http://localhost:5000';
  }

  async uploadPhotoForProcessing(
    sessionId: number,
    fileId: number,
    uploadedBy: number,
  ): Promise<AiProcessingResultDto> {
    const session = await this.sessionRepo.findOne({
      where: { id: sessionId },
    });

    if (!session) {
      throw new SessionNotFoundException(sessionId);
    }

    // Create photo record
    const photo = this.photoRepo.create({
      sessionId,
      fileId,
      uploadedBy,
      photoType: PhotoType.CLASS_PHOTO,
      processingStatus: ProcessingStatus.PENDING,
    });
    const savedPhoto = await this.photoRepo.save(photo);

    // Create processing record
    const processing = this.processingRepo.create({
      sessionId,
      photoId: savedPhoto.id,
      status: ProcessingStatus.PENDING,
    });
    const savedProcessing = await this.processingRepo.save(processing);

    // In a real implementation, we would send the photo to the AI microservice here
    // For now, we'll simulate the async processing
    // The frontend should poll getProcessingResult() to check status
    this.startAiProcessing(savedProcessing.id, session.sectionId).catch(
      (err) => {
        console.error('AI processing error:', err);
      },
    );

    return {
      processingId: savedProcessing.id,
      status: ProcessingStatus.PENDING,
      detectedFacesCount: 0,
      matchedStudentsCount: 0,
      unmatchedFacesCount: 0,
    };
  }

  async getProcessingResult(processingId: number): Promise<AiProcessingResultDto> {
    const processing = await this.processingRepo.findOne({
      where: { id: processingId },
    });

    if (!processing) {
      throw new BadRequestException(
        `Processing record with ID ${processingId} not found`,
      );
    }

    return {
      processingId: processing.id,
      status: processing.status,
      detectedFacesCount: processing.detectedFacesCount,
      matchedStudentsCount: processing.matchedStudentsCount,
      unmatchedFacesCount: processing.unmatchedFacesCount,
      errorMessage: processing.errorMessage || undefined,
      processingTimeMs: processing.processingTimeMs || undefined,
    };
  }

  private async startAiProcessing(
    processingId: number,
    sectionId: number,
  ): Promise<void> {
    const startTime = Date.now();

    try {
      // Update status to processing
      await this.processingRepo.update(processingId, {
        status: ProcessingStatus.PROCESSING,
      });

      // In a real implementation, we would:
      // 1. Call the AI microservice: POST {aiServiceUrl}/process-photo
      // 2. Wait for or poll for results
      // 3. Parse the returned Excel file with recognized student IDs
      // 4. Mark attendance for matched students

      // For now, simulate processing delay
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Simulate successful processing (in reality, this would come from AI service)
      const processing = await this.processingRepo.findOne({
        where: { id: processingId },
      });

      if (!processing) return;

      // Update processing record
      await this.processingRepo.update(processingId, {
        status: ProcessingStatus.COMPLETED,
        detectedFacesCount: 0, // Would be set by AI service
        matchedStudentsCount: 0, // Would be set by AI service
        unmatchedFacesCount: 0, // Would be set by AI service
        processingTimeMs: Date.now() - startTime,
        completedAt: new Date(),
      });

      // Update photo status
      await this.photoRepo.update(processing.photoId, {
        processingStatus: ProcessingStatus.COMPLETED,
      });

      // Note: In a real implementation, we would mark attendance based on AI results
      // The AI service would return a list of recognized student IDs
      // We would then call markAttendanceFromAiResults()

    } catch (error) {
      await this.processingRepo.update(processingId, {
        status: ProcessingStatus.FAILED,
        errorMessage: error.message,
        processingTimeMs: Date.now() - startTime,
        completedAt: new Date(),
      });
    }
  }

  async markAttendanceFromAiResults(
    sessionId: number,
    recognizedStudentIds: number[],
    processingId: number,
  ): Promise<void> {
    // Get all records for this session
    const records = await this.recordRepo.find({
      where: { sessionId },
    });

    const recognizedSet = new Set(recognizedStudentIds);
    let matchedCount = 0;

    for (const record of records) {
      if (recognizedSet.has(record.userId)) {
        // Mark as present
        record.attendanceStatus = AttendanceStatus.PRESENT;
        record.markedBy = MarkedBy.AI;
        record.checkInTime = new Date();
        matchedCount++;
      } else {
        // Keep as absent (or whatever the current status is)
        // We don't change students who are already marked by manual
        if (record.markedBy !== MarkedBy.MANUAL) {
          record.attendanceStatus = AttendanceStatus.ABSENT;
          record.markedBy = MarkedBy.AI;
        }
      }
      await this.recordRepo.save(record);
    }

    // Update processing record with counts
    await this.processingRepo.update(processingId, {
      matchedStudentsCount: matchedCount,
      unmatchedFacesCount: recognizedStudentIds.length - matchedCount,
    });
  }
}
