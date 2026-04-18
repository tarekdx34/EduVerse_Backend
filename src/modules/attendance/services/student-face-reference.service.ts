import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { In, Repository } from 'typeorm';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { randomUUID } from 'crypto';
import { CourseEnrollment } from '../../enrollments/entities/course-enrollment.entity';
import { EnrollmentStatus } from '../../enrollments/enums';
import { StudentFaceReference } from '../entities';

type FaceReferenceResponse = {
  id: number;
  userId: number;
  storagePath: string;
  mimeType: string;
  fileSize: number;
  isPrimary: boolean;
  createdAt: Date;
  signedUrl?: string | null;
};

@Injectable()
export class StudentFaceReferenceService {
  private readonly supabase: SupabaseClient;
  private readonly bucketName: string;
  private readonly maxFileSize = 5 * 1024 * 1024;
  private readonly allowedMimeTypes = new Set(['image/jpeg', 'image/png', 'image/webp']);

  constructor(
    @InjectRepository(StudentFaceReference)
    private readonly faceRefRepo: Repository<StudentFaceReference>,
    @InjectRepository(CourseEnrollment)
    private readonly enrollmentRepo: Repository<CourseEnrollment>,
    private readonly configService: ConfigService,
  ) {
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseServiceRoleKey = this.configService.get<string>(
      'SUPABASE_SERVICE_ROLE_KEY',
    );
    this.bucketName =
      this.configService.get<string>('SUPABASE_BUCKET_STUDENT_FACES') ||
      'student-faces';

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      throw new Error(
        'SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables are required',
      );
    }

    this.supabase = createClient(supabaseUrl, supabaseServiceRoleKey);
  }

  async uploadMyReference(
    userId: number,
    file: Express.Multer.File,
  ): Promise<FaceReferenceResponse> {
    this.validateFaceFile(file);

    const extension = this.getExtensionFromMimeType(file.mimetype);
    const storagePath = `students/${userId}/reference/${randomUUID()}.${extension}`;

    const { error: uploadError } = await this.supabase.storage
      .from(this.bucketName)
      .upload(storagePath, file.buffer, {
        contentType: file.mimetype,
        upsert: false,
      });

    if (uploadError) {
      throw new InternalServerErrorException(
        `Failed to upload face reference image: ${uploadError.message}`,
      );
    }

    await this.faceRefRepo.update(
      { userId, isActive: true, isPrimary: true },
      { isPrimary: false },
    );

    const saved = await this.faceRefRepo.save(
      this.faceRefRepo.create({
        userId,
        bucketName: this.bucketName,
        storagePath,
        mimeType: file.mimetype,
        fileSize: file.size,
        isPrimary: true,
        isActive: true,
      }),
    );

    const signedUrl = await this.createSignedUrl(storagePath);
    return this.toResponse(saved, signedUrl);
  }

  async listMyReferences(userId: number): Promise<FaceReferenceResponse[]> {
    const refs = await this.faceRefRepo.find({
      where: { userId, isActive: true },
      order: { isPrimary: 'DESC', createdAt: 'DESC' },
    });

    const signedUrlMap = await this.createSignedUrls(
      refs.map((ref) => ref.storagePath),
    );

    return refs.map((ref) => this.toResponse(ref, signedUrlMap.get(ref.storagePath)));
  }

  async deleteMyReference(userId: number, referenceId: number): Promise<void> {
    const ref = await this.faceRefRepo.findOne({
      where: { id: referenceId, isActive: true },
    });

    if (!ref) {
      throw new BadRequestException(
        `Face reference with ID ${referenceId} not found`,
      );
    }

    if (ref.userId !== userId) {
      throw new ForbiddenException(
        'You can only delete your own face reference images',
      );
    }

    const { error: deleteError } = await this.supabase.storage
      .from(ref.bucketName)
      .remove([ref.storagePath]);

    if (deleteError) {
      throw new InternalServerErrorException(
        `Failed to delete face reference image: ${deleteError.message}`,
      );
    }

    ref.isActive = false;
    ref.isPrimary = false;
    await this.faceRefRepo.save(ref);
  }

  async getSectionReferencesForAi(sectionId: number): Promise<
    Array<{
      userId: number;
      referenceId: number;
      storagePath: string;
      signedUrl: string | null;
    }>
  > {
    const enrollments = await this.enrollmentRepo.find({
      where: { sectionId, status: EnrollmentStatus.ENROLLED },
      select: ['userId'],
    });

    const userIds = Array.from(
      new Set(enrollments.map((enrollment) => Number(enrollment.userId))),
    );

    if (!userIds.length) {
      return [];
    }

    const references = await this.faceRefRepo.find({
      where: {
        userId: In(userIds),
        isActive: true,
        isPrimary: true,
      },
      order: { createdAt: 'DESC' },
    });

    const byUser = new Map<number, StudentFaceReference>();
    references.forEach((ref) => {
      if (!byUser.has(ref.userId)) {
        byUser.set(ref.userId, ref);
      }
    });

    const selected = Array.from(byUser.values());
    const signedUrlMap = await this.createSignedUrls(
      selected.map((ref) => ref.storagePath),
    );

    return selected.map((ref) => ({
      userId: ref.userId,
      referenceId: ref.id,
      storagePath: ref.storagePath,
      signedUrl: signedUrlMap.get(ref.storagePath) ?? null,
    }));
  }

  private validateFaceFile(file?: Express.Multer.File): void {
    if (!file) {
      throw new BadRequestException('Face image file is required');
    }

    if (!this.allowedMimeTypes.has(file.mimetype)) {
      throw new BadRequestException(
        `Unsupported file type: ${file.mimetype}. Allowed: image/jpeg, image/png, image/webp`,
      );
    }

    if (file.size <= 0 || file.size > this.maxFileSize) {
      throw new BadRequestException(
        `Invalid file size. Maximum allowed size is ${this.maxFileSize} bytes`,
      );
    }
  }

  private getExtensionFromMimeType(mimeType: string): string {
    switch (mimeType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      default:
        return 'jpg';
    }
  }

  private async createSignedUrl(storagePath: string): Promise<string | null> {
    const { data, error } = await this.supabase.storage
      .from(this.bucketName)
      .createSignedUrl(storagePath, 60 * 60);

    if (error) {
      return null;
    }

    return data.signedUrl;
  }

  private async createSignedUrls(
    storagePaths: string[],
  ): Promise<Map<string, string | null>> {
    if (!storagePaths.length) {
      return new Map();
    }

    const uniquePaths = Array.from(new Set(storagePaths));
    const { data, error } = await this.supabase.storage
      .from(this.bucketName)
      .createSignedUrls(uniquePaths, 60 * 60);

    if (error || !data) {
      return new Map(uniquePaths.map((path) => [path, null]));
    }

    const byPath = new Map<string, string | null>();
    data.forEach((item) => {
      if (item.path) {
        byPath.set(item.path, item.signedUrl || null);
      }
    });

    uniquePaths.forEach((path) => {
      if (!byPath.has(path)) {
        byPath.set(path, null);
      }
    });

    return byPath;
  }

  private toResponse(
    ref: StudentFaceReference,
    signedUrl?: string | null,
  ): FaceReferenceResponse {
    return {
      id: ref.id,
      userId: ref.userId,
      storagePath: ref.storagePath,
      mimeType: ref.mimeType,
      fileSize: ref.fileSize,
      isPrimary: ref.isPrimary,
      createdAt: ref.createdAt,
      signedUrl: signedUrl ?? null,
    };
  }
}

