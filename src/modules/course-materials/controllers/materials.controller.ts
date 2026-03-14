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
  UploadDocumentMaterialDto,
  BulkCreateMaterialDto,
} from '../dto';
import { MaterialType } from '../enums';

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
    const roles = this.extractRoles(req.user);
    return this.materialsService.create(courseId, dto, userId, roles);
  }

  @Post('bulk')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Bulk create materials',
    description: `
## Bulk Create Course Materials

Creates multiple materials in a single request. Maximum 50 materials per request.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, TA, ADMIN

### Use Cases
- Setting up course content at the beginning of a semester
- Importing materials from another course
- Uploading multiple lecture notes at once

### Request Body
\`\`\`json
{
  "materials": [
    { "title": "Lecture 1", "materialType": "lecture", "weekNumber": 1 },
    { "title": "Lecture 2", "materialType": "lecture", "weekNumber": 2 }
  ]
}
\`\`\`
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiBody({ type: BulkCreateMaterialDto })
  @ApiResponse({ status: 201, description: 'Materials created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async bulkCreate(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Body() dto: BulkCreateMaterialDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.materialsService.bulkCreate(courseId, dto.materials, userId, roles);
  }

  @Post('video')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @UseInterceptors(FileInterceptor('video'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({
    summary: 'Upload video material to YouTube',
    description: `
## Upload Video Material via YouTube

Uploads a video file to YouTube (as unlisted) and creates a course material record.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, TA, ADMIN, IT_ADMIN
- **Authorization**: Must be assigned to the course (or be admin)

### Supported Video Formats
\`mp4\`, \`avi\`, \`mov\`, \`webm\`, \`mkv\`, \`flv\`, \`wmv\`

### Upload Flow
1. Backend validates user is authorized for this course
2. Video is uploaded to YouTube (unlisted privacy)
3. YouTube returns video ID and URL
4. Material record created with:
   - \`externalUrl\`: YouTube embed URL
   - \`youtubeVideoId\`: Original YouTube video ID (for future updates/deletes)
   - Other metadata (weekNumber, orderIndex, isPublished)

### Form Data Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| video | file | ✅ | Video file to upload |
| title | string | ✅ | Video title (max 255 chars) |
| description | string | ❌ | Video description |
| tags | string[] | ❌ | Tags for the video |
| weekNumber | number | ❌ | Week to assign (1-52) |
| orderIndex | number | ❌ | Sort order (default: 0) |
| isPublished | boolean | ❌ | Publish immediately (default: false/draft) |

### Response
Returns material object with:
- \`externalUrl\`: YouTube embed URL for iframe
- \`youtubeVideoId\`: YouTube video ID
- \`youtubeUrl\`: Full YouTube watch URL
- \`embedUrl\`: Embed URL for iframe usage
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiBody({
    schema: {
      type: 'object',
      required: ['video', 'title'],
      properties: {
        video: {
          type: 'string',
          format: 'binary',
          description: 'Video file (mp4, avi, mov, webm, mkv)',
        },
        title: {
          type: 'string',
          example: 'Lecture 1: Introduction to Data Structures',
          maxLength: 255,
        },
        description: {
          type: 'string',
          example: 'This video covers the basics of data structures.',
        },
        tags: {
          type: 'array',
          items: { type: 'string' },
          example: ['lecture', 'data-structures', 'cs101'],
        },
        weekNumber: {
          type: 'integer',
          example: 1,
          minimum: 1,
          maximum: 52,
        },
        orderIndex: {
          type: 'integer',
          example: 0,
          default: 0,
        },
        isPublished: {
          type: 'boolean',
          example: false,
          default: false,
        },
      },
    },
  })
  @ApiResponse({ 
    status: 201, 
    description: 'Video uploaded to YouTube and material created',
    schema: {
      example: {
        materialId: 1,
        courseId: 1,
        title: 'Lecture 1: Introduction',
        materialType: 'video',
        externalUrl: 'https://www.youtube.com/embed/dQw4w9WgXcQ',
        youtubeVideoId: 'dQw4w9WgXcQ',
        weekNumber: 1,
        orderIndex: 0,
        isPublished: false,
        youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        embedUrl: 'https://www.youtube.com/embed/dQw4w9WgXcQ',
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid input data or YouTube upload failed' })
  @ApiResponse({ status: 403, description: 'Forbidden - not assigned to course' })
  async uploadVideo(
    @Param('courseId', ParseIntPipe) courseId: number,
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: UploadVideoMaterialDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.materialsService.uploadVideoMaterial(
      courseId,
      file,
      dto.title,
      dto.description || '',
      dto.tags || [],
      userId,
      roles,
      dto.weekNumber,
      dto.orderIndex,
      dto.isPublished,
    );
  }

  @Post('document')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @UseInterceptors(FileInterceptor('document'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({
    summary: 'Upload document material to Google Drive',
    description: `
## Upload Document Material via Google Drive

Uploads a document file (PDF, PPT, Word, etc.) to Google Drive and creates a course material record.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, TA, ADMIN, IT_ADMIN
- **Authorization**: Must be assigned to the course (or be admin)

### Supported Document Formats
\`pdf\`, \`ppt\`, \`pptx\`, \`doc\`, \`docx\`, \`xls\`, \`xlsx\`, \`txt\`, \`md\`, \`zip\`

### Upload Flow
1. Backend validates user is authorized for this course
2. Course folder hierarchy is created/verified in Google Drive
3. Document is uploaded to the appropriate folder (Lectures or General)
4. Material record created with Drive metadata

### Form Data Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| document | file | ✅ | Document file to upload |
| title | string | ✅ | Document title (max 255 chars) |
| description | string | ❌ | Document description |
| materialType | enum | ❌ | Type: lecture, slide, reading, document (default: document) |
| weekNumber | number | ❌ | Week to assign (1-52) |
| orderIndex | number | ❌ | Sort order (default: 0) |
| isPublished | boolean | ❌ | Publish immediately (default: false/draft) |

### Folder Placement
- \`lecture\` and \`slide\` types → Course/Lectures/ folder
- \`reading\`, \`document\`, \`link\` → Course/General/ folder

### Response
Returns material object with:
- \`driveId\`: Google Drive file ID
- \`driveViewUrl\`: URL to view in Google Drive
- \`driveDownloadUrl\`: Direct download URL
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiBody({
    schema: {
      type: 'object',
      required: ['document', 'title'],
      properties: {
        document: {
          type: 'string',
          format: 'binary',
          description: 'Document file (pdf, ppt, pptx, doc, docx, xls, xlsx)',
        },
        title: {
          type: 'string',
          example: 'Week 1 Lecture Notes: Introduction to Data Structures',
          maxLength: 255,
        },
        description: {
          type: 'string',
          example: 'Comprehensive lecture notes covering the basics.',
        },
        materialType: {
          type: 'string',
          enum: ['lecture', 'slide', 'reading', 'document', 'link'],
          example: 'lecture',
          default: 'document',
        },
        weekNumber: {
          type: 'integer',
          example: 1,
          minimum: 1,
          maximum: 52,
        },
        orderIndex: {
          type: 'integer',
          example: 0,
          default: 0,
        },
        isPublished: {
          type: 'boolean',
          example: false,
          default: false,
        },
      },
    },
  })
  @ApiResponse({ 
    status: 201, 
    description: 'Document uploaded to Google Drive and material created',
    schema: {
      example: {
        materialId: 1,
        courseId: 1,
        title: 'Week 1 Lecture Notes',
        materialType: 'lecture',
        externalUrl: 'https://drive.google.com/file/d/abc123/view',
        driveId: 'abc123',
        driveViewUrl: 'https://drive.google.com/file/d/abc123/view',
        driveDownloadUrl: 'https://drive.google.com/uc?id=abc123&export=download',
        weekNumber: 1,
        orderIndex: 0,
        isPublished: false,
        fileName: 'Week01_Week_1_Lecture_Notes_v1.pdf',
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid input data or Drive upload failed' })
  @ApiResponse({ status: 403, description: 'Forbidden - not assigned to course' })
  async uploadDocument(
    @Param('courseId', ParseIntPipe) courseId: number,
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: UploadDocumentMaterialDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.materialsService.uploadDocumentMaterial(
      courseId,
      file,
      dto.title,
      dto.description || '',
      dto.materialType || MaterialType.DOCUMENT,
      userId,
      roles,
      dto.weekNumber,
      dto.orderIndex,
      dto.isPublished,
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

  @Post(':id/view')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Track material view',
    description: `
## Track Material View

Records that a user viewed a material and increments the view counter.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL

### Use Cases
- Analytics tracking for course engagement
- Identifying popular materials
- Measuring student participation

### Response
Returns updated view count for the material.
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiParam({ name: 'id', description: 'Material ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'View tracked successfully' })
  @ApiResponse({ status: 404, description: 'Material not found' })
  async trackView(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('id', ParseIntPipe) id: number,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.materialsService.trackView(id, userId, roles);
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
