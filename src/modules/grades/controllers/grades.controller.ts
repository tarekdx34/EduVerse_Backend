import {
  Controller,
  Get,
  Put,
  Patch,
  Param,
  Body,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
} from '@nestjs/swagger';
import { GradesService } from '../services';
import { UpdateGradeDto, GradeQueryDto } from '../dto';
import { Roles } from '../../auth/roles.decorator';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { RoleName } from '../../auth/entities/role.entity';

@ApiTags('📊 Grades')
@Controller('api/grades')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class GradesController {
  constructor(private readonly gradesService: GradesService) {}

  @Get()
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({ summary: 'List grades with filters and pagination' })
  @ApiResponse({ status: 200, description: 'Paginated list of grades' })
  async findAll(@Query() query: GradeQueryDto) {
    return this.gradesService.findAll(query);
  }

  @Get('my')
  @Roles(RoleName.STUDENT)
  @ApiOperation({ summary: "Get authenticated student's own grades" })
  @ApiResponse({ status: 200, description: "Student's grades" })
  async getMyGrades(@Request() req) {
    const userId = req.user.userId || req.user.id;
    return this.gradesService.findMyGrades(userId);
  }

  @Get('transcript/:studentId')
  @Roles(RoleName.STUDENT, RoleName.ADMIN)
  @ApiOperation({ summary: 'Get student transcript' })
  @ApiParam({ name: 'studentId', description: 'Student ID', type: Number })
  @ApiResponse({ status: 200, description: 'Student transcript' })
  async getTranscript(@Param('studentId') studentId: number) {
    return this.gradesService.getTranscript(studentId);
  }

  @Get('gpa/:studentId')
  @Roles(RoleName.STUDENT, RoleName.ADMIN)
  @ApiOperation({ summary: 'Calculate GPA for a student' })
  @ApiParam({ name: 'studentId', description: 'Student ID', type: Number })
  @ApiResponse({ status: 200, description: 'GPA calculation result' })
  async calculateGPA(@Param('studentId') studentId: number) {
    return this.gradesService.calculateGPA(studentId);
  }

  @Get('distribution/:courseId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({ summary: 'Get grade distribution for a course' })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number })
  @ApiResponse({ status: 200, description: 'Grade distribution by letter grade' })
  async getDistribution(@Param('courseId') courseId: number) {
    return this.gradesService.getDistribution(courseId);
  }

  @Put(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA)
  @ApiOperation({ summary: 'Update a grade' })
  @ApiParam({ name: 'id', description: 'Grade ID', type: Number })
  @ApiResponse({ status: 200, description: 'Grade updated' })
  async updateGrade(
    @Param('id') id: number,
    @Body() dto: UpdateGradeDto,
    @Request() req,
  ) {
    const graderId = req.user.userId || req.user.id;
    return this.gradesService.updateGrade(id, dto, graderId);
  }

  @Patch(':id/finalize')
  @Roles(RoleName.INSTRUCTOR)
  @ApiOperation({ summary: 'Publish/finalize a grade' })
  @ApiParam({ name: 'id', description: 'Grade ID', type: Number })
  @ApiResponse({ status: 200, description: 'Grade published' })
  async finalizeGrade(@Param('id') id: number) {
    return this.gradesService.publishGrade(id);
  }
}
