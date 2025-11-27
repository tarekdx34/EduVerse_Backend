import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  HttpStatus,
  HttpCode,
  ParseIntPipe,
} from '@nestjs/common';
import { CourseSchedulesService } from '../services/course-schedules.service';
import { CreateScheduleDto } from '../dtos';

@Controller('api/schedules')
export class CourseSchedulesController {
  constructor(
    private readonly schedulesService: CourseSchedulesService,
  ) {}

  @Get('section/:sectionId')
  async findBySectionId(
    @Param('sectionId', ParseIntPipe) sectionId: number,
  ) {
    return this.schedulesService.findBySectionId(sectionId);
  }

  @Get(':id')
  async findById(@Param('id', ParseIntPipe) id: number) {
    return this.schedulesService.findById(id);
  }

  @Post('section/:sectionId')
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Body() dto: CreateScheduleDto,
  ) {
    return this.schedulesService.create(sectionId, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async delete(@Param('id', ParseIntPipe) id: number) {
    await this.schedulesService.delete(id);
  }
}
