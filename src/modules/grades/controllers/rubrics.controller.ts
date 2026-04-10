import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
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
  ApiQuery,
} from '@nestjs/swagger';
import { RubricsService } from '../services';
import { CreateRubricDto } from '../dto';
import { Roles } from '../../auth/roles.decorator';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { RoleName } from '../../auth/entities/role.entity';

@ApiTags('📋 Rubrics')
@Controller('api/rubrics')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class RubricsController {
  constructor(private readonly rubricsService: RubricsService) {}

  @Get()
  @Roles(RoleName.INSTRUCTOR, RoleName.TA)
  @ApiOperation({ summary: 'List rubrics for a course' })
  @ApiQuery({ name: 'courseId', required: true, type: Number, description: 'Course ID', example: 1 })
  @ApiResponse({ status: 200, description: 'List of rubrics' })
  async findAll(@Query('courseId') courseId: number) {
    return this.rubricsService.findAll(courseId);
  }

  @Post()
  @Roles(RoleName.INSTRUCTOR, RoleName.TA)
  @ApiOperation({ summary: 'Create a rubric' })
  @ApiResponse({ status: 201, description: 'Rubric created' })
  async create(@Body() dto: CreateRubricDto, @Request() req) {
    const userId = req.user.userId || req.user.id;
    return this.rubricsService.create(dto, userId);
  }

  @Put(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA)
  @ApiOperation({ summary: 'Update a rubric' })
  @ApiParam({ name: 'id', description: 'Rubric ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Rubric updated' })
  async update(@Param('id') id: number, @Body() dto: Partial<CreateRubricDto>) {
    return this.rubricsService.update(id, dto);
  }

  @Delete(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA)
  @ApiOperation({ summary: 'Delete a rubric' })
  @ApiParam({ name: 'id', description: 'Rubric ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Rubric deleted' })
  async remove(@Param('id') id: number) {
    return this.rubricsService.remove(id);
  }
}
