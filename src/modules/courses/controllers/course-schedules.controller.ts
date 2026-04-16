import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  HttpStatus,
  HttpCode,
  ParseIntPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { CourseSchedulesService } from '../services/course-schedules.service';
import { CreateScheduleDto } from '../dtos';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';

@ApiTags('🕐 Course Schedules')
@Controller('api/schedules')
export class CourseSchedulesController {
  constructor(
    private readonly schedulesService: CourseSchedulesService,
  ) {}

  @Get('section/:sectionId')
  @ApiOperation({
    summary: 'Get schedules by section',
    description: `Returns all schedule entries for a specific course section.`,
  })
  @ApiParam({ name: 'sectionId', description: 'Section ID', type: Number, example: 11 })
  @ApiResponse({ status: 200, description: 'List of schedules for the section' })
  @ApiResponse({ status: 404, description: 'Section not found' })
  async findBySectionId(
    @Param('sectionId', ParseIntPipe) sectionId: number,
  ) {
    return this.schedulesService.findBySectionId(sectionId);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get schedule by ID',
    description: `Returns a specific schedule entry by its ID.`,
  })
  @ApiParam({ name: 'id', description: 'Schedule ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Schedule details' })
  @ApiResponse({ status: 404, description: 'Schedule not found' })
  async findById(@Param('id', ParseIntPipe) id: number) {
    return this.schedulesService.findById(id);
  }

  @Post('section/:sectionId')
  @HttpCode(HttpStatus.CREATED)
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Create schedule for section',
    description: `Creates a new schedule entry (day/time slot) for a course section.`,
  })
  @ApiParam({ name: 'sectionId', description: 'Section ID', type: Number, example: 11 })
  @ApiBody({ type: CreateScheduleDto })
  @ApiResponse({ status: 201, description: 'Schedule created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 404, description: 'Section not found' })
  async create(
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Body() dto: CreateScheduleDto,
  ) {
    return this.schedulesService.create(sectionId, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Delete schedule',
    description: `Deletes a schedule entry by its ID.`,
  })
  @ApiParam({ name: 'id', description: 'Schedule ID', type: Number, example: 1 })
  @ApiResponse({ status: 204, description: 'Schedule deleted successfully' })
  @ApiResponse({ status: 404, description: 'Schedule not found' })
  async delete(@Param('id', ParseIntPipe) id: number) {
    await this.schedulesService.delete(id);
  }
}
