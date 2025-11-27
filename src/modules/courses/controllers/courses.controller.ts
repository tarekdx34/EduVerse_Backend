import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  HttpStatus,
  HttpCode,
  ParseIntPipe,
} from '@nestjs/common';
import { CoursesService } from '../services/courses.service';
import { CreateCourseDto, UpdateCourseDto, CreatePrerequisiteDto } from '../dtos';
import { CourseStatus } from '../enums';

@Controller('api/courses')
export class CoursesController {
  constructor(private readonly coursesService: CoursesService) {}

  @Get()
  async findAll(
    @Query('departmentId', new ParseIntPipe({ optional: true }))
    departmentId?: number,
    @Query('level') level?: string,
    @Query('status') status?: CourseStatus,
    @Query('search') search?: string,
    @Query('page', new ParseIntPipe({ optional: true })) page = 1,
    @Query('limit', new ParseIntPipe({ optional: true })) limit = 20,
  ) {
    return this.coursesService.findAll(
      departmentId,
      level,
      status,
      search,
      page,
      limit,
    );
  }

  @Get('department/:deptId')
  async findByDepartment(
    @Param('deptId', ParseIntPipe) deptId: number,
  ) {
    return this.coursesService.findByDepartment(deptId);
  }

  @Get(':id')
  async findById(@Param('id', ParseIntPipe) id: number) {
    const course = await this.coursesService.findById(id);
    const prerequisites = await this.coursesService.getPrerequisites(id);
    
    return {
      ...course,
      prerequisitesCount: prerequisites.length,
      sectionsCount: course.sections.length,
    };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() dto: CreateCourseDto) {
    return this.coursesService.create(dto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateCourseDto,
  ) {
    return this.coursesService.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async delete(@Param('id', ParseIntPipe) id: number) {
    await this.coursesService.softDelete(id);
  }

  @Get(':id/prerequisites')
  async getPrerequisites(@Param('id', ParseIntPipe) id: number) {
    return this.coursesService.getPrerequisites(id);
  }

  @Post(':id/prerequisites')
  @HttpCode(HttpStatus.CREATED)
  async addPrerequisite(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: CreatePrerequisiteDto,
  ) {
    return this.coursesService.addPrerequisite(
      id,
      dto.prerequisiteCourseId,
      dto.isMandatory,
    );
  }

  @Delete(':id/prerequisites/:prereqId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async removePrerequisite(
    @Param('id', ParseIntPipe) id: number,
    @Param('prereqId', ParseIntPipe) prereqId: number,
  ) {
    await this.coursesService.removePrerequisite(id, prereqId);
  }
}
