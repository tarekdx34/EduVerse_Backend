import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like, In, DataSource } from 'typeorm';
import { CourseMaterial } from '../entities';
import { File } from '../../files/entities/file.entity';
import {
  CreateMaterialDto,
  UpdateMaterialDto,
  QueryMaterialsDto,
  ToggleVisibilityDto,
} from '../dto';
import { MaterialType } from '../enums';
import { YoutubeService } from '../../youtube/youtube.service';

@Injectable()
export class MaterialsService {
  constructor(
    @InjectRepository(CourseMaterial)
    private readonly materialRepo: Repository<CourseMaterial>,
    @InjectRepository(File)
    private readonly fileRepo: Repository<File>,
    private readonly youtubeService: YoutubeService,
    private readonly dataSource: DataSource,
  ) {}

  /**
   * Check if user is assigned to a course (as instructor or TA)
   */
  private async isUserAssignedToCourse(userId: number, courseId: number, roles: string[]): Promise<boolean> {
    const isInstructor = roles.includes('instructor');
    const isTA = roles.includes('teaching_assistant');

    if (isInstructor) {
      // Check if instructor is assigned to any section of this course
      const result = await this.dataSource.query(`
        SELECT COUNT(*) as count FROM course_instructors ci
        INNER JOIN course_sections cs ON ci.section_id = cs.section_id
        WHERE ci.user_id = ? AND cs.course_id = ?
      `, [userId, courseId]);
      return parseInt(result[0].count) > 0;
    }

    if (isTA) {
      // Check if TA is assigned to any section of this course
      const result = await this.dataSource.query(`
        SELECT COUNT(*) as count FROM course_tas ct
        INNER JOIN course_sections cs ON ct.section_id = cs.section_id
        WHERE ct.user_id = ? AND cs.course_id = ?
      `, [userId, courseId]);
      return parseInt(result[0].count) > 0;
    }

    return false;
  }

  async findAll(courseId: number, query: QueryMaterialsDto, userId: number, roles: string[]) {
    const { materialType, weekNumber, isPublished, search, sortBy = 'orderIndex', sortOrder = 'ASC', page = 1, limit = 10 } = query;

    const qb = this.materialRepo.createQueryBuilder('material')
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
      qb.andWhere('material.is_published = :isPublished', { isPublished: isPublished ? 1 : 0 });
    }

    if (materialType) {
      qb.andWhere('material.material_type = :materialType', { materialType });
    }

    if (search) {
      qb.andWhere('(material.title LIKE :search OR material.description LIKE :search)', { 
        search: `%${search}%` 
      });
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

  async create(courseId: number, dto: CreateMaterialDto, userId: number, roles: string[]) {
    // Check if user is admin or assigned to this course
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    
    if (!isAdmin) {
      const isAssigned = await this.isUserAssignedToCourse(userId, courseId, roles);
      if (!isAssigned) {
        throw new ForbiddenException('You are not assigned to this course and cannot add materials');
      }
    }

    const material = this.materialRepo.create({
      ...dto,
      courseId,
      uploadedBy: userId,
      publishedAt: dto.isPublished ? new Date() : null,
    });

    return this.materialRepo.save(material);
  }

  async update(id: number, dto: UpdateMaterialDto, userId: number, roles: string[]) {
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
        throw new ForbiddenException('You can only update materials you uploaded');
      }
    }

    // Update published timestamp if changing visibility
    if (dto.isPublished !== undefined && dto.isPublished && !material.isPublished) {
      dto['publishedAt'] = new Date();
    }

    Object.assign(material, dto);
    return this.materialRepo.save(material);
  }

  async delete(id: number, userId: number, roles: string[]) {
    const material = await this.findById(id, userId, roles);

    // Only instructors and admins can delete
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');

    if (!isAdmin && !isInstructor) {
      throw new ForbiddenException('Only instructors and admins can delete materials');
    }

    // Non-admins can only delete their own materials
    if (!isAdmin) {
      if (material.uploadedBy !== userId) {
        throw new ForbiddenException('You can only delete materials you uploaded');
      }
    }

    await this.materialRepo.remove(material);
    return { message: 'Material deleted successfully' };
  }

  async toggleVisibility(id: number, dto: ToggleVisibilityDto, userId: number, roles: string[]) {
    const material = await this.findById(id, userId, roles);

    // Check ownership/permission
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');
    const isTA = roles.includes('teaching_assistant');

    if (!isAdmin && !isInstructor && !isTA) {
      throw new ForbiddenException('You cannot change visibility of this material');
    }

    // Non-admins can only toggle visibility of their own materials
    if (!isAdmin) {
      if (material.uploadedBy !== userId) {
        throw new ForbiddenException('You can only change visibility of materials you uploaded');
      }
    }

    material.isPublished = dto.isPublished;
    if (dto.isPublished && !material.publishedAt) {
      material.publishedAt = new Date();
    }

    return this.materialRepo.save(material);
  }

  async download(id: number, userId: number, roles: string[]) {
    const material = await this.findById(id, userId, roles);

    if (!material.fileId) {
      throw new BadRequestException('This material does not have a downloadable file');
    }

    const file = await this.fileRepo.findOne({ where: { fileId: material.fileId } });
    if (!file) {
      throw new NotFoundException('Associated file not found');
    }

    return {
      material,
      file,
      downloadUrl: file.filePath,
    };
  }

  async getEmbedUrl(id: number, userId: number, roles: string[]) {
    const material = await this.findById(id, userId, roles);

    if (material.materialType !== MaterialType.VIDEO) {
      throw new BadRequestException('This material is not a video');
    }

    if (!material.externalUrl) {
      throw new BadRequestException('This video material does not have an embed URL');
    }

    // Extract YouTube video ID if it's a YouTube URL
    const youtubeMatch = material.externalUrl.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\s]+)/);
    
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
  ) {
    // Check if user is admin or assigned to this course
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    
    if (!isAdmin) {
      const isAssigned = await this.isUserAssignedToCourse(userId, courseId, roles);
      if (!isAssigned) {
        throw new ForbiddenException('You are not assigned to this course and cannot add materials');
      }
    }

    // Upload to YouTube via existing service
    const youtubeResult = await this.youtubeService.uploadVideoFromBuffer(
      file.buffer,
      title,
      description || '',
      tags,
    );

    // Create material record with YouTube data
    const material = this.materialRepo.create({
      courseId,
      title,
      description,
      materialType: MaterialType.VIDEO,
      externalUrl: `https://www.youtube.com/embed/${youtubeResult.videoId}`,
      uploadedBy: userId,
      isPublished: true,
      publishedAt: new Date(),
    });

    return this.materialRepo.save(material);
  }
}
