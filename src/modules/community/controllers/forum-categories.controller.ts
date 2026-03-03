import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiParam,
  ApiBody,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { ForumCategoriesService } from '../services/forum-categories.service';
import { CreateCategoryDto, UpdateCategoryDto } from '../dto';

@ApiTags('📁 Forum Categories')
@ApiBearerAuth('JWT-auth')
@Controller('api/community/categories')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ForumCategoriesController {
  constructor(private readonly categoriesService: ForumCategoriesService) {}

  @Get()
  @ApiOperation({
    summary: 'List forum categories',
    description: 'Get all forum categories, optionally filtered by course ID.',
  })
  @ApiQuery({ name: 'courseId', required: false, description: 'Filter by course ID', example: 1 })
  @ApiResponse({ status: 200, description: 'List of forum categories' })
  async findAll(@Query('courseId') courseId?: number) {
    return this.categoriesService.findAll(courseId ? +courseId : undefined);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get category details',
    description: 'Get a single forum category by ID.',
  })
  @ApiParam({ name: 'id', description: 'Category ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Category details' })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.categoriesService.findOne(id);
  }

  @Post()
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create forum category',
    description: `
Create a new forum category for a course.

**Allowed Roles**: Admin only
    `,
  })
  @ApiBody({ type: CreateCategoryDto })
  @ApiResponse({ status: 201, description: 'Category created successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin only' })
  async create(@Body() dto: CreateCategoryDto) {
    return this.categoriesService.create(dto);
  }

  @Put(':id')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update forum category',
    description: `
Update a forum category's name, description, or order.

**Allowed Roles**: Admin only
    `,
  })
  @ApiParam({ name: 'id', description: 'Category ID', example: 1 })
  @ApiBody({ type: UpdateCategoryDto })
  @ApiResponse({ status: 200, description: 'Category updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin only' })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateCategoryDto,
  ) {
    return this.categoriesService.update(id, dto);
  }

  @Delete(':id')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete forum category',
    description: `
Delete a forum category.

**Allowed Roles**: Admin only

**Warning**: This may affect posts associated with this category.
    `,
  })
  @ApiParam({ name: 'id', description: 'Category ID', example: 1 })
  @ApiResponse({ status: 204, description: 'Category deleted successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin only' })
  @ApiResponse({ status: 404, description: 'Category not found' })
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.categoriesService.remove(id);
  }
}
