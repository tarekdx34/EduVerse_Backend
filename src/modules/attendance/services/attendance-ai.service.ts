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
import {
  AttendanceStatus,
  MarkedBy,
  ProcessingStatus,
  PhotoType,
} from '../enums';
import { AiProcessingResultDto } from '../dto';
import { SessionNotFoundException } from '../exceptions';
import { StudentFaceReferenceService } from './student-face-reference.service';

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
    private readonly studentFaceReferenceService: StudentFaceReferenceService,
  ) {
    this.aiServiceUrl =
      this.configService.get<string>('AI_ATTENDANCE_SERVICE_URL') ||
      'http://localhost:5000';
  }

  async uploadPhotoForProcessing(
    sessionId: number,
    fileId: number | null,
    uploadedBy: number,
    photoFile: Express.Multer.File,
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
    this.startAiProcessing(
      savedProcessing.id,
      session.id,
      session.sectionId,
      photoFile,
    ).catch((err) => {
      console.error('AI processing error:', err);
    });

    return {
      processingId: savedProcessing.id,
      status: ProcessingStatus.PENDING,
      detectedFacesCount: 0,
      matchedStudentsCount: 0,
      unmatchedFacesCount: 0,
    };
  }

  async getProcessingResult(
    processingId: number,
  ): Promise<AiProcessingResultDto> {
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
    sessionId: number,
    sectionId: number,
    photoFile: Express.Multer.File,
  ): Promise<void> {
    const startTime = Date.now();

    try {
      // Update status to processing
      await this.processingRepo.update(processingId, {
        status: ProcessingStatus.PROCESSING,
      });

      // Pull only section-scoped student reference images so AI matching is constrained
      // to the enrolled students for this section.
      const sectionReferences =
        await this.studentFaceReferenceService.getSectionReferencesForAi(
          sectionId,
        );

      if (!sectionReferences.length) {
        await this.processingRepo.update(processingId, {
          status: ProcessingStatus.FAILED,
          errorMessage:
            'No active student face references found for this section.',
          processingTimeMs: Date.now() - startTime,
          completedAt: new Date(),
        });
        return;
      }

      await this.processingRepo.update(processingId, {
        confidenceScores: JSON.stringify({
          sectionId,
          aiServiceUrl: this.aiServiceUrl,
          referenceCount: sectionReferences.length,
          // Keep only fields needed by AI runtime lookup/debug.
          references: sectionReferences.map((ref) => ({
            userId: ref.userId,
            referenceId: ref.referenceId,
            signedUrl: ref.signedUrl,
          })),
        }),
      });

      if (!photoFile?.buffer || !photoFile.mimetype) {
        throw new BadRequestException(
          'Class photo is required for AI attendance',
        );
      }

      const aiResponse = await this.callSectionAttendanceAi(
        photoFile,
        sectionReferences,
      );

      const recognizedStudentIds = Array.isArray(aiResponse.marked_ids)
        ? aiResponse.marked_ids
            .map((id: string) => Number(id))
            .filter((id: number) => !Number.isNaN(id))
        : [];

      await this.markAttendanceFromAiResults(
        sessionId,
        recognizedStudentIds,
        processingId,
      );

      // Simulate successful processing (in reality, this would come from AI service)
      const processing = await this.processingRepo.findOne({
        where: { id: processingId },
      });

      if (!processing) return;

      // Update processing record
      await this.processingRepo.update(processingId, {
        status: ProcessingStatus.COMPLETED,
        detectedFacesCount: Array.isArray(aiResponse.recognized_faces)
          ? aiResponse.recognized_faces.length
          : 0,
        matchedStudentsCount: recognizedStudentIds.length,
        unmatchedFacesCount: Math.max(
          0,
          (Array.isArray(aiResponse.recognized_faces)
            ? aiResponse.recognized_faces.length
            : 0) - recognizedStudentIds.length,
        ),
        processingTimeMs: Date.now() - startTime,
        completedAt: new Date(),
      });

      // Update photo status
      await this.photoRepo.update(processing.photoId, {
        processingStatus: ProcessingStatus.COMPLETED,
      });
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      await this.processingRepo.update(processingId, {
        status: ProcessingStatus.FAILED,
        errorMessage,
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
      const recordUserId = Number(record.userId);
      if (!Number.isNaN(recordUserId) && recognizedSet.has(recordUserId)) {
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

  private async callSectionAttendanceAi(
    photoFile: Express.Multer.File,
    sectionReferences: Array<{ userId: number; signedUrl: string | null }>,
  ): Promise<{
    marked_ids: string[];
    recognized_faces: Array<Record<string, unknown>>;
  }> {
    const endpoint = `${this.aiServiceUrl.replace(/\/$/, '')}/attendance/section`;
    const refsPayload = sectionReferences
      .filter((ref) => !!ref.signedUrl)
      .map((ref) => ({
        userId: ref.userId,
        signedUrl: ref.signedUrl,
      }));

    const formData = new FormData();
    formData.append(
      'image',
      new Blob([new Uint8Array(photoFile.buffer)], {
        type: photoFile.mimetype,
      }),
      photoFile.originalname || 'class-photo.jpg',
    );
    formData.append('references_json', JSON.stringify(refsPayload));

    const res = await fetch(endpoint, {
      method: 'POST',
      body: formData,
    });

    if (!res.ok) {
      const details = await res.text();
      throw new Error(
        `AI attendance service failed (${res.status}): ${details}`,
      );
    }

    return (await res.json()) as {
      marked_ids: string[];
      recognized_faces: Array<Record<string, unknown>>;
    };
  }
}
