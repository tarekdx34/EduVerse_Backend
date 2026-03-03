import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Patch,
  Body,
  Param,
  Query,
  Req,
  UseGuards,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiTags,
  ApiOperation,
  ApiParam,
  ApiBody,
  ApiResponse,
  ApiBearerAuth,
  ApiConsumes,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { MaterialsService } from '../services';
import {
  CreateMaterialDto,
  UpdateMaterialDto,
  QueryMaterialsDto,
  ToggleVisibilityDto,
  UploadVideoMaterialDto,
} from '../dto';

@ApiTags('📚 Course Materials')
@ApiBearerAuth('JWT-auth')
@Controller('api/courses/:courseId/materials')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MaterialsController {
  constructor(private readonly materialsService: MaterialsService) {}

  @Get()
  @ApiOperation({
    summary: 'List course materials',
    description: `
## List Course Materials

Returns paginated list of materials for a course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL (filtered by role)

### Role-Based Visibility
- **Students**: See only published materials
- **Instructors/TAs**: See all materials (including drafts)
- **Admins**: See all materials

### Query Parameters
- \`materialType\`: Filter by type (lecture, slide, video, etc.)
- \`search\`: Search in title and description
- \`isPublished\`: Filter by visibility (instructors/admins only)
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Paginated list of materials' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Query() query: QueryMaterialsDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.materialsService.findAll(courseId, query, userId, roles);
  }

  @Post()
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create course material',
    description: `
## Create Course Material

Adds a new material to the course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, TA, ADMIN

### Material Types
- \`lecture\`: Lecture content
- \`slide\`: Presentation slides
- \`video\`: Video content (can use YouTube integration)
- \`reading\`: Reading material
- \`link\`: External link
- \`document\`: Generic document

### File Upload
For file-based materials, upload the file first using the Files API and pass the \`fileId\`.
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiBody({ type: CreateMaterialDto })
  @ApiResponse({ status: 201, description: 'Material created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async create(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Body() dto: CreateMaterialDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.materialsService.create(courseId, dto, userId);
  }

  @Post('video')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @UseInterceptors(FileInterceptor('video'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({
    summary: 'Upload video material',
    description: `
## Upload Video Material via YouTube

Uploads a video to YouTube and creates a material record.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, TA, ADMIN

### Upload Flow
1. Video is uploaded to YouTube (unlisted)
2. YouTube returns video ID and URL
3. Material record created with embed URL

### Response
Returns material with:
- \`externalUrl\`: YouTube embed URL
- Can be used in iframe: \`<iframe src="{externalUrl}"></iframe>\`
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiResponse({ status: 201, description: 'Video uploaded and material created' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async uploadVideo(
    @Param('courseId', ParseIntPipe) courseId: number,
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: UploadVideoMaterialDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.materialsService.uploadVideoMaterial(
      courseId,
      file,
      dto.title,
      dto.description || '',
      dto.tags || [],
      userId,
    );
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get material by ID',
    description: `
## Get Material Details

Returns detailed information about a specific material.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL (students can only see published materials)
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiParam({ name: 'id', description: 'Material ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Material details' })
  @ApiResponse({ status: 404, description: 'Material not found' })
  async findById(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('id', ParseIntPipe) id: number,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.materialsService.findById(id, userId, roles);
  }

  @Put(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update material',
    description: `
## Update Material

Updates an existing material's metadata.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, TA, ADMIN
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiParam({ name: 'id', description: 'Material ID', type: Number, example: 1 })
  @ApiBody({ type: UpdateMaterialDto })
  @ApiResponse({ status: 200, description: 'Material updated successfully' })
  @ApiResponse({ status: 404, description: 'Material not found' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async update(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateMaterialDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.materialsService.update(id, dto, userId, roles);
  }

  @Delete(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete material',
    description: `
## Delete Material

Removes a material from the course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, ADMIN only (TAs cannot delete)
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiParam({ name: 'id', description: 'Material ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Material deleted successfully' })
  @ApiResponse({ status: 404, description: 'Material not found' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async delete(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('id', ParseIntPipe) id: number,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.materialsService.delete(id, userId, roles);
  }

  @Patch(':id/visibility')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Toggle material visibility',
    description: `
## Toggle Material Visibility

Show or hide a material from students.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, TA, ADMIN

### Visibility States
- \`isPublished: true\`: Visible to students
- \`isPublished: false\`: Hidden from students (draft mode)
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiParam({ name: 'id', description: 'Material ID', type: Number, example: 1 })
  @ApiBody({ type: ToggleVisibilityDto })
  @ApiResponse({ status: 200, description: 'Visibility updated' })
  @ApiResponse({ status: 404, description: 'Material not found' })
  async toggleVisibility(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: ToggleVisibilityDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.materialsService.toggleVisibility(id, dto, userId, roles);
  }

  @Get(':id/download')
  @ApiOperation({
    summary: 'Download material',
    description: `
## Download Material File

Get download information for a material's associated file.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL (students can only download published materials)

### Response
Returns file information including download URL.
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiParam({ name: 'id', description: 'Material ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Download information' })
  @ApiResponse({ status: 400, description: 'Material has no downloadable file' })
  @ApiResponse({ status: 404, description: 'Material not found' })
  async download(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('id', ParseIntPipe) id: number,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.materialsService.download(id, userId, roles);
  }

  @Get(':id/embed')
  @ApiOperation({
    summary: 'Get embed URL',
    description: `
## Get YouTube Embed URL

For video materials, returns the YouTube embed URL and iframe HTML.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL

### Response
- \`videoId\`: YouTube video ID
- \`embedUrl\`: URL for iframe src
- \`iframeHtml\`: Ready-to-use iframe HTML
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiParam({ name: 'id', description: 'Material ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Embed information' })
  @ApiResponse({ status: 400, description: 'Material is not a video' })
  @ApiResponse({ status: 404, description: 'Material not found' })
  async getEmbedUrl(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('id', ParseIntPipe) id: number,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.materialsService.getEmbedUrl(id, userId, roles);
  }

  private extractRoles(user: any): string[] {
    if (Array.isArray(user.roles)) {
      return user.roles.map((r: any) => (typeof r === 'string' ? r : r.name || r.roleName));
    }
    return [];
  }
}
