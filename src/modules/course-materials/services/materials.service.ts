import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like, In, DataSource } from 'typeorm';
import { CourseMaterial, StudentMaterialView } from '../entities';
import { File } from '../../files/entities/file.entity';
import {
  CreateMaterialDto,
  UpdateMaterialDto,
  QueryMaterialsDto,
  ToggleVisibilityDto,
} from '../dto';
import { MaterialType } from '../enums';
import { YoutubeService } from '../../youtube/youtube.service';
import { DriveFolderService } from '../../google-drive/services/drive-folder.service';
import { DriveFolderType } from '../../google-drive/entities/drive-folder.entity';
import { DriveFileEntityType } from '../../google-drive/entities/drive-file.entity';
import { CourseEnrollment } from '../../enrollments/entities/course-enrollment.entity';
import { EnrollmentStatus } from '../../enrollments/enums';
import { StudentProgress } from '../../analytics/entities/student-progress.entity';

@Injectable()
export class MaterialsService {
  private readonly logger = new Logger(MaterialsService.name);

  constructor(
    @InjectRepository(CourseMaterial)
    private readonly materialRepo: Repository<CourseMaterial>,
    @InjectRepository(StudentMaterialView)
    private readonly studentMaterialViewRepo: Repository<StudentMaterialView>,
    @InjectRepository(File)
    private readonly fileRepo: Repository<File>,
    @InjectRepository(CourseEnrollment)
    private readonly enrollmentRepo: Repository<CourseEnrollment>,
    @InjectRepository(StudentProgress)
    private readonly studentProgressRepo: Repository<StudentProgress>,
    private readonly youtubeService: YoutubeService,
    private readonly dataSource: DataSource,
    private readonly driveFolderService: DriveFolderService,
  ) {}

  /**
   * Check if user is assigned to a course (as instructor or TA)
   */
  private async isUserAssignedToCourse(
    userId: number,
    courseId: number,
    roles: string[],
  ): Promise<boolean> {
    const isInstructor = roles.includes('instructor');
    const isTA = roles.includes('teaching_assistant');

    if (isInstructor) {
      // Check if instructor is assigned to any section of this course
      const result = await this.dataSource.query(
        `
        SELECT COUNT(*) as count FROM course_instructors ci
        INNER JOIN course_sections cs ON ci.section_id = cs.section_id
        WHERE ci.user_id = ? AND cs.course_id = ?
      `,
        [userId, courseId],
      );
      return parseInt(result[0].count) > 0;
    }

    if (isTA) {
      // Check if TA is assigned to any section of this course
      const result = await this.dataSource.query(
        `
        SELECT COUNT(*) as count FROM course_tas ct
        INNER JOIN course_sections cs ON ct.section_id = cs.section_id
        WHERE ct.user_id = ? AND cs.course_id = ?
      `,
        [userId, courseId],
      );
      return parseInt(result[0].count) > 0;
    }

    return false;
  }

  async findAll(
    courseId: number,
    query: QueryMaterialsDto,
    userId: number,
    roles: string[],
  ) {
    const {
      materialType,
      weekNumber,
      isPublished,
      search,
      sortBy = 'orderIndex',
      sortOrder = 'ASC',
      page = 1,
      limit = 10,
    } = query;

    const qb = this.materialRepo
      .createQueryBuilder('material')
      .leftJoinAndSelect('material.course', 'course')
      .leftJoinAndSelect('material.file', 'file')
      .leftJoinAndSelect('material.uploader', 'uploader')
      .where('material.course_id = :courseId', { courseId });

    // Role-based visibility
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');
    const isTA = roles.includes('teaching_assistant');

    if (!isAdmin && !isInstructor && !isTA) {
      // Students can only see published materials
      qb.andWhere('material.is_published = 1');
    } else if (isPublished !== undefined) {
      qb.andWhere('material.is_published = :isPublished', {
        isPublished: isPublished ? 1 : 0,
      });
    }

    if (materialType) {
      qb.andWhere('material.material_type = :materialType', { materialType });
    }

    if (weekNumber !== undefined) {
      qb.andWhere('material.week_number = :weekNumber', { weekNumber });
    }

    if (search) {
      qb.andWhere(
        '(material.title LIKE :search OR material.description LIKE :search)',
        {
          search: `%${search}%`,
        },
      );
    }

    qb.orderBy(`material.${sortBy}`, sortOrder)
      .skip((page - 1) * limit)
      .take(limit);

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findById(id: number, userId: number, roles: string[]) {
    const material = await this.materialRepo.findOne({
      where: { materialId: id },
      relations: ['course', 'file', 'uploader'],
    });

    if (!material) {
      throw new NotFoundException(`Material with ID ${id} not found`);
    }

    // Check visibility for students
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');
    const isTA = roles.includes('teaching_assistant');

    if (!isAdmin && !isInstructor && !isTA && !material.isPublished) {
      throw new NotFoundException(`Material with ID ${id} not found`);
    }

    return material;
  }

  async create(
    courseId: number,
    dto: CreateMaterialDto,
    userId: number,
    roles: string[],
  ) {
    // Check if user is admin or assigned to this course
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');

    if (!isAdmin) {
      const isAssigned = await this.isUserAssignedToCourse(
        userId,
        courseId,
        roles,
      );
      if (!isAssigned) {
        throw new ForbiddenException(
          'You are not assigned to this course and cannot add materials',
        );
      }
    }

    // Default isPublished to false (draft) if not specified - per spec
    const isPublished = dto.isPublished ?? false;

    const material = this.materialRepo.create({
      ...dto,
      courseId,
      uploadedBy: userId,
      isPublished,
      publishedAt: isPublished ? new Date() : null,
    });

    return this.materialRepo.save(material);
  }

  async update(
    id: number,
    dto: UpdateMaterialDto,
    userId: number,
    roles: string[],
  ) {
    const material = await this.findById(id, userId, roles);

    // Check ownership/permission
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');
    const isTA = roles.includes('teaching_assistant');

    if (!isAdmin && !isInstructor && !isTA) {
      throw new ForbiddenException('You cannot update this material');
    }

    // Non-admins can only update their own materials
    if (!isAdmin) {
      if (material.uploadedBy !== userId) {
        throw new ForbiddenException(
          'You can only update materials you uploaded',
        );
      }
    }

    // Update published timestamp if changing visibility
    if (
      dto.isPublished !== undefined &&
      dto.isPublished &&
      !material.isPublished
    ) {
      dto['publishedAt'] = new Date();
    }

    Object.assign(material, dto);
    return this.materialRepo.save(material);
  }

  async delete(id: number, userId: number, roles: string[]) {
    const material = await this.findById(id, userId, roles);

    // Only assigned teaching staff and admins can delete
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');
    const isTA = roles.includes('teaching_assistant');

    if (!isAdmin && !isInstructor && !isTA) {
      throw new ForbiddenException(
        'Only teaching staff and admins can delete materials',
      );
    }

    // Non-admins can only delete their own materials
    if (!isAdmin) {
      if (material.uploadedBy !== userId) {
        throw new ForbiddenException(
          'You can only delete materials you uploaded',
        );
      }
    }

    await this.materialRepo.remove(material);
    return { message: 'Material deleted successfully' };
  }

  async toggleVisibility(
    id: number,
    dto: ToggleVisibilityDto,
    userId: number,
    roles: string[],
  ) {
    const material = await this.findById(id, userId, roles);

    // Check ownership/permission
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');
    const isTA = roles.includes('teaching_assistant');

    if (!isAdmin && !isInstructor && !isTA) {
      throw new ForbiddenException(
        'You cannot change visibility of this material',
      );
    }

    // Non-admins can only toggle visibility of their own materials
    if (!isAdmin) {
      if (material.uploadedBy !== userId) {
        throw new ForbiddenException(
          'You can only change visibility of materials you uploaded',
        );
      }
    }

    const nextPublishedAt = dto.isPublished
      ? material.publishedAt || new Date()
      : null;

    await this.materialRepo.update(
      { materialId: id },
      {
        isPublished: dto.isPublished,
        publishedAt: nextPublishedAt,
      },
    );

    const updated = await this.materialRepo.findOne({
      where: { materialId: id },
      relations: ['course', 'file', 'uploader'],
    });

    if (!updated) {
      throw new NotFoundException(`Material with ID ${id} not found`);
    }

    return updated;
  }

  async download(id: number, userId: number, roles: string[]) {
    const material = await this.findById(id, userId, roles);

    if (!material.fileId) {
      throw new BadRequestException(
        'This material does not have a downloadable file',
      );
    }

    const file = await this.fileRepo.findOne({
      where: { fileId: material.fileId },
    });
    if (!file) {
      throw new NotFoundException('Associated file not found');
    }

    // Increment download count
    await this.materialRepo.increment({ materialId: id }, 'downloadCount', 1);

    return {
      material,
      file,
      downloadUrl: file.filePath,
    };
  }

  /**
   * Track material view
   */
  async trackView(id: number, userId: number, roles: string[]) {
    const material = await this.findById(id, userId, roles);

    // Increment view count
    await this.materialRepo.increment({ materialId: id }, 'viewCount', 1);

    const existingStudentView = await this.studentMaterialViewRepo.findOne({
      where: {
        userId,
        materialId: id,
      },
    });

    if (existingStudentView) {
      existingStudentView.viewsCount += 1;
      await this.studentMaterialViewRepo.save(existingStudentView);
    } else {
      await this.studentMaterialViewRepo.save(
        this.studentMaterialViewRepo.create({
          userId,
          courseId: material.courseId,
          materialId: id,
          viewsCount: 1,
        }),
      );
    }

    const [totalPublishedMaterials, viewedPublishedMaterials] = await Promise.all([
      this.materialRepo.count({
        where: {
          courseId: material.courseId,
          isPublished: true,
        },
      }),
      this.studentMaterialViewRepo
        .createQueryBuilder('smv')
        .innerJoin(CourseMaterial, 'm', 'm.material_id = smv.material_id')
        .where('smv.user_id = :userId', { userId })
        .andWhere('smv.course_id = :courseId', { courseId: material.courseId })
        .andWhere('m.is_published = 1')
        .getCount(),
    ]);

    const completionPercentage =
      totalPublishedMaterials > 0
        ? Number(
            ((viewedPublishedMaterials / totalPublishedMaterials) * 100).toFixed(2),
          )
        : 0;

    const activeEnrollment = await this.enrollmentRepo
      .createQueryBuilder('enrollment')
      .innerJoin('enrollment.section', 'section')
      .where('enrollment.userId = :userId', { userId })
      .andWhere('section.courseId = :courseId', { courseId: material.courseId })
      .andWhere('enrollment.status IN (:...statuses)', {
        statuses: [EnrollmentStatus.ENROLLED, EnrollmentStatus.COMPLETED],
      })
      .orderBy('enrollment.enrollmentDate', 'DESC')
      .getOne();

    if (activeEnrollment) {
      let progress = await this.studentProgressRepo.findOne({
        where: {
          userId,
          courseId: material.courseId,
          enrollmentId: activeEnrollment.id,
        },
      });

      if (!progress) {
        progress = this.studentProgressRepo.create({
          userId,
          courseId: material.courseId,
          enrollmentId: activeEnrollment.id,
        });
      }

      progress.materialsViewed = viewedPublishedMaterials;
      progress.totalMaterials = totalPublishedMaterials;
      progress.completionPercentage = completionPercentage;
      progress.lastActivityAt = new Date();

      await this.studentProgressRepo.save(progress);
    }

    return {
      message: 'View tracked successfully',
      materialId: id,
      viewCount: material.viewCount + 1,
      progress: {
        materialsViewed: viewedPublishedMaterials,
        totalMaterials: totalPublishedMaterials,
        completionPercentage,
      },
    };
  }

  /**
   * Bulk create materials
   */
  async bulkCreate(
    courseId: number,
    materials: CreateMaterialDto[],
    userId: number,
    roles: string[],
  ) {
    // Check if user is admin or assigned to this course
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');

    if (!isAdmin) {
      const isAssigned = await this.isUserAssignedToCourse(
        userId,
        courseId,
        roles,
      );
      if (!isAssigned) {
        throw new ForbiddenException(
          'You are not assigned to this course and cannot add materials',
        );
      }
    }

    const createdMaterials: CourseMaterial[] = [];

    for (const dto of materials) {
      // Default isPublished to false (draft) if not specified - per spec
      const isPublished = dto.isPublished ?? false;

      const material = this.materialRepo.create({
        ...dto,
        courseId,
        uploadedBy: userId,
        isPublished,
        publishedAt: isPublished ? new Date() : null,
      });

      const saved = await this.materialRepo.save(material);
      createdMaterials.push(saved);
    }

    return {
      message: `Successfully created ${createdMaterials.length} materials`,
      count: createdMaterials.length,
      data: createdMaterials,
    };
  }

  async getEmbedUrl(id: number, userId: number, roles: string[]) {
    const material = await this.findById(id, userId, roles);

    if (material.materialType !== MaterialType.VIDEO) {
      throw new BadRequestException('This material is not a video');
    }

    if (!material.externalUrl) {
      throw new BadRequestException(
        'This video material does not have an embed URL',
      );
    }

    // Extract YouTube video ID if it's a YouTube URL
    const youtubeMatch = material.externalUrl.match(
      /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\s]+)/,
    );

    if (youtubeMatch) {
      return {
        videoId: youtubeMatch[1],
        embedUrl: `https://www.youtube.com/embed/${youtubeMatch[1]}`,
        iframeHtml: `<iframe width="560" height="315" src="https://www.youtube.com/embed/${youtubeMatch[1]}" frameborder="0" allowfullscreen></iframe>`,
      };
    }

    return {
      externalUrl: material.externalUrl,
    };
  }

  async uploadVideoMaterial(
    courseId: number,
    file: Express.Multer.File,
    title: string,
    description: string,
    tags: string[],
    userId: number,
    roles: string[],
    weekNumber?: number,
    orderIndex?: number,
    isPublished?: boolean,
  ) {
    // Validate file exists
    if (!file || !file.buffer) {
      throw new BadRequestException('Video file is required');
    }

    // Check if user is admin or assigned to this course
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');

    if (!isAdmin) {
      const isAssigned = await this.isUserAssignedToCourse(
        userId,
        courseId,
        roles,
      );
      if (!isAssigned) {
        throw new ForbiddenException(
          'You are not assigned to this course and cannot add materials',
        );
      }
    }

    // Upload to YouTube via existing service
    let youtubeResult;
    try {
      youtubeResult = await this.youtubeService.uploadVideoFromBuffer(
        file.buffer,
        title,
        description || '',
        tags,
      );
    } catch (error) {
      console.error('YouTube upload failed:', error);
      throw new BadRequestException(
        `Failed to upload video to YouTube: ${error.message || 'Unknown error'}`,
      );
    }

    // Determine publish status (default: draft/false)
    const shouldPublish = isPublished ?? false;

    // Create material record with YouTube data
    const material = this.materialRepo.create({
      courseId,
      title,
      description,
      materialType: MaterialType.VIDEO,
      externalUrl: `https://www.youtube.com/embed/${youtubeResult.videoId}`,
      youtubeVideoId: youtubeResult.videoId,
      uploadedBy: userId,
      isPublished: shouldPublish,
      publishedAt: shouldPublish ? new Date() : null,
      weekNumber: weekNumber ?? null,
      orderIndex: orderIndex ?? 0,
    });

    const savedMaterial = await this.materialRepo.save(material);

    return {
      ...savedMaterial,
      youtubeUrl: youtubeResult.videoUrl,
      embedUrl: `https://www.youtube.com/embed/${youtubeResult.videoId}`,
    };
  }

  /**
   * Validate file type and size for document uploads
   */
  private validateDocumentFile(file: Express.Multer.File): void {
    // Supported MIME types for documents
    const SUPPORTED_DOCUMENT_TYPES = [
      'application/pdf',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'text/plain',
      'text/markdown',
      'application/zip',
    ];

    // Supported MIME types for images
    const SUPPORTED_IMAGE_TYPES = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/gif',
      'image/webp',
      'image/svg+xml',
    ];

    const ALL_SUPPORTED_TYPES = [...SUPPORTED_DOCUMENT_TYPES, ...SUPPORTED_IMAGE_TYPES];

    // Check MIME type
    if (!ALL_SUPPORTED_TYPES.includes(file.mimetype)) {
      throw new BadRequestException(
        `Unsupported file type: ${file.mimetype}. Supported types: PDF, Word (doc/docx), PowerPoint (ppt/pptx), Excel (xls/xlsx), Images (jpg/png/gif/webp), Text, Markdown, ZIP`,
      );
    }

    // File size limits
    const MAX_DOCUMENT_SIZE = 50 * 1024 * 1024; // 50MB
    const MAX_IMAGE_SIZE = 10 * 1024 * 1024; // 10MB

    const isImage = SUPPORTED_IMAGE_TYPES.includes(file.mimetype);
    const maxSize = isImage ? MAX_IMAGE_SIZE : MAX_DOCUMENT_SIZE;
    const maxSizeMB = isImage ? 10 : 50;

    if (file.size > maxSize) {
      throw new BadRequestException(
        `File size exceeds maximum allowed size of ${maxSizeMB}MB. Current size: ${(file.size / (1024 * 1024)).toFixed(2)}MB`,
      );
    }

    // Validate file extension matches MIME type (prevent spoofing)
    const ext = file.originalname.split('.').pop()?.toLowerCase();
    const mimeTypeExtensionMap: Record<string, string[]> = {
      'application/pdf': ['pdf'],
      'application/vnd.ms-powerpoint': ['ppt'],
      'application/vnd.openxmlformats-officedocument.presentationml.presentation': ['pptx'],
      'application/msword': ['doc'],
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document': ['docx'],
      'application/vnd.ms-excel': ['xls'],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': ['xlsx'],
      'text/plain': ['txt'],
      'text/markdown': ['md'],
      'application/zip': ['zip'],
      'image/jpeg': ['jpg', 'jpeg'],
      'image/png': ['png'],
      'image/gif': ['gif'],
      'image/webp': ['webp'],
      'image/svg+xml': ['svg'],
    };

    const allowedExtensions = mimeTypeExtensionMap[file.mimetype] || [];
    if (ext && !allowedExtensions.includes(ext)) {
      throw new BadRequestException(
        `File extension .${ext} does not match MIME type ${file.mimetype}`,
      );
    }
  }

  /**
   * Upload document material to Google Drive
   * Supports PDFs, PPTs, Word docs, and other document formats
   */
  async uploadDocumentMaterial(
    courseId: number,
    file: Express.Multer.File,
    title: string,
    description: string,
    materialType: MaterialType,
    userId: number,
    roles: string[],
    weekNumber?: number,
    orderIndex?: number,
    isPublished?: boolean,
  ) {
    // Validate file exists
    if (!file || !file.buffer) {
      throw new BadRequestException('Document file is required. Please select a file to upload.');
    }

    // Validate file type and size
    this.validateDocumentFile(file);

    // Check if user is admin or assigned to this course
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');

    if (!isAdmin) {
      const isAssigned = await this.isUserAssignedToCourse(
        userId,
        courseId,
        roles,
      );
      if (!isAssigned) {
        throw new ForbiddenException(
          `You are not assigned to course ID ${courseId} and cannot add materials. Only instructors, TAs, or admins assigned to this course can upload materials.`,
        );
      }
    }

    // Determine folder based on material type
    let folderType: DriveFolderType;
    switch (materialType) {
      case MaterialType.LECTURE:
        folderType = DriveFolderType.COURSE_LECTURES;
        break;
      case MaterialType.SLIDE:
        folderType = DriveFolderType.COURSE_LECTURES; // Slides go in lectures
        break;
      case MaterialType.READING:
      case MaterialType.DOCUMENT:
      case MaterialType.LINK:
      default:
        folderType = DriveFolderType.COURSE_GENERAL;
        break;
    }

    // Ensure course hierarchy exists and get folder ID
    let targetFolderId: number;
    try {
      const hierarchy = await this.driveFolderService.ensureCourseHierarchy(
        courseId,
        userId,
      );

      // Select target folder based on material type
      switch (folderType) {
        case DriveFolderType.COURSE_LECTURES:
          targetFolderId = hierarchy.lectures.driveFolderId;
          break;
        case DriveFolderType.COURSE_GENERAL:
        default:
          targetFolderId = hierarchy.general.driveFolderId;
          break;
      }
    } catch (error) {
      this.logger.error(
        `Failed to ensure course hierarchy for course ${courseId}: ${error.message}`,
        error.stack,
      );
      throw new BadRequestException(
        `Failed to prepare Google Drive folder structure for course ${courseId}. Please ensure Google Drive integration is configured correctly. Error: ${error.message}`,
      );
    }

    // Generate file name with convention
    const ext = file.originalname.split('.').pop() || 'file';
    const safeTitle = title.replace(/[^a-zA-Z0-9_-]/g, '_').substring(0, 50);
    const weekPart = weekNumber
      ? `Week${weekNumber.toString().padStart(2, '0')}_`
      : '';
    const fileName = `${weekPart}${safeTitle}_v1.${ext}`;

    // Upload to Google Drive
    let driveFile;
    try {
      driveFile = await this.driveFolderService.uploadFileToDrive(
        file.buffer,
        fileName,
        file.mimetype,
        targetFolderId,
        DriveFileEntityType.COURSE_MATERIAL,
        null, // Will update with material ID after creation
        userId,
      );
    } catch (error) {
      this.logger.error(
        `Failed to upload file to Google Drive: ${error.message}`,
        error.stack,
      );
      
      // Provide more specific error messages based on the error type
      let errorMessage = 'Failed to upload document to Google Drive.';
      
      if (error.message?.includes('auth') || error.message?.includes('token')) {
        errorMessage += ' Authentication error - please check Google Drive credentials.';
      } else if (error.message?.includes('quota') || error.message?.includes('storage')) {
        errorMessage += ' Storage quota exceeded - please free up space in Google Drive.';
      } else if (error.message?.includes('permission')) {
        errorMessage += ' Permission denied - please check Google Drive folder permissions.';
      } else {
        errorMessage += ` Error: ${error.message || 'Unknown error'}`;
      }
      
      throw new BadRequestException(errorMessage);
    }

    // Determine publish status (default: draft/false)
    const shouldPublish = isPublished ?? false;

    // Create material record with Drive data
    const material = this.materialRepo.create({
      courseId,
      title,
      description,
      materialType,
      externalUrl: driveFile.webViewLink, // Google Drive view link
      driveFileId: driveFile.driveFileId,
      uploadedBy: userId,
      isPublished: shouldPublish,
      publishedAt: shouldPublish ? new Date() : null,
      weekNumber: weekNumber ?? null,
      orderIndex: orderIndex ?? 0,
    });

    const savedMaterial = await this.materialRepo.save(material);

    // Update drive file with material entity ID
    await this.dataSource.query(
      `UPDATE drive_files SET entity_id = ? WHERE drive_file_id = ?`,
      [savedMaterial.materialId, driveFile.driveFileId],
    );

    this.logger.log(
      `Document uploaded to Drive for course ${courseId}: ${fileName} -> ${driveFile.driveId}`,
    );

    return {
      ...savedMaterial,
      driveId: driveFile.driveId,
      driveViewUrl: driveFile.webViewLink,
      driveDownloadUrl: driveFile.webContentLink,
      fileName: driveFile.fileName,
    };
  }
}
