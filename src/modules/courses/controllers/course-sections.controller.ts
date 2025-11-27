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
import { CourseSectionsService } from '../services/course-sections.service';
import { CreateSectionDto, UpdateSectionDto } from '../dtos';

@Controller('api/sections')
export class CourseSectionsController {
  constructor(
    private readonly sectionsService: CourseSectionsService,
  ) {}

  @Get('course/:courseId')
  async findByCourseId(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Query('semesterId', new ParseIntPipe({ optional: true }))
    semesterId?: number,
  ) {
    return this.sectionsService.findByCourseId(courseId, semesterId);
  }

  @Get(':id')
  async findById(@Param('id', ParseIntPipe) id: number) {
    return this.sectionsService.findById(id);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() dto: CreateSectionDto) {
    return this.sectionsService.create(dto);
  }

  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateSectionDto,
  ) {
    return this.sectionsService.update(id, dto);
  }

  @Patch(':id/enrollment')
  async updateEnrollment(
    @Param('id', ParseIntPipe) id: number,
    @Body('currentEnrollment') currentEnrollment: number,
  ) {
    await this.sectionsService.updateEnrollment(id, currentEnrollment);
    return this.sectionsService.findById(id);
  }
}
