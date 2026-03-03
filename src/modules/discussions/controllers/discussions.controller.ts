import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  Req,
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
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { DiscussionsService } from '../services/discussions.service';
import { CreateThreadDto, UpdateThreadDto, CreateReplyDto, ThreadQueryDto } from '../dto';

@ApiTags('💭 Discussions')
@ApiBearerAuth('JWT-auth')
@Controller('api/discussions')
@UseGuards(JwtAuthGuard, RolesGuard)
export class DiscussionsController {
  constructor(private readonly discussionsService: DiscussionsService) {}

  @Get()
  @ApiOperation({
    summary: 'List discussion threads',
    description: 'List discussion threads with optional course filter. Pinned threads appear first.',
  })
  @ApiResponse({ status: 200, description: 'Threads retrieved' })
  async findAll(@Query() query: ThreadQueryDto) {
    return this.discussionsService.findAll(query);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create discussion thread',
    description: 'Create a new discussion thread in a course.',
  })
  @ApiBody({ type: CreateThreadDto })
  @ApiResponse({ status: 201, description: 'Thread created' })
  async create(@Body() dto: CreateThreadDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.discussionsService.create(dto, userId);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get thread with replies',
    description: 'Get a discussion thread with paginated replies. Answers appear first. Increments view count.',
  })
  @ApiParam({ name: 'id', description: 'Thread ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Thread with replies' })
  async getThreadWithReplies(
    @Param('id', ParseIntPipe) id: number,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.discussionsService.getThreadWithReplies(id, page || 1, limit || 50);
  }

  @Put(':id')
  @ApiOperation({
    summary: 'Update thread',
    description: 'Update thread title/description. Author, instructors, and admins can update.',
  })
  @ApiParam({ name: 'id', description: 'Thread ID', example: 1 })
  @ApiBody({ type: UpdateThreadDto })
  @ApiResponse({ status: 200, description: 'Thread updated' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateThreadDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = req.user.roles?.map((r: any) => r.roleName || r.name) || [];
    return this.discussionsService.update(id, dto, userId, roles);
  }

  @Delete(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete thread',
    description: 'Delete a discussion thread and all its replies. Instructors and admins only.',
  })
  @ApiParam({ name: 'id', description: 'Thread ID', example: 1 })
  @ApiResponse({ status: 204, description: 'Thread deleted' })
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.discussionsService.remove(id);
  }

  @Post(':id/reply')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Post reply',
    description: 'Post a reply to a discussion thread. Fails if thread is locked.',
  })
  @ApiParam({ name: 'id', description: 'Thread ID', example: 1 })
  @ApiBody({ type: CreateReplyDto })
  @ApiResponse({ status: 201, description: 'Reply posted' })
  @ApiResponse({ status: 400, description: 'Thread is locked' })
  async addReply(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: CreateReplyDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.discussionsService.addReply(id, userId, dto);
  }

  @Patch(':id/pin')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Toggle pin thread',
    description: 'Pin or unpin a discussion thread. Pinned threads appear at the top of the list.',
  })
  @ApiParam({ name: 'id', description: 'Thread ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Pin status toggled' })
  async togglePin(@Param('id', ParseIntPipe) id: number) {
    return this.discussionsService.togglePin(id);
  }

  @Patch(':id/lock')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Toggle lock thread',
    description: 'Lock or unlock a discussion thread. Locked threads cannot receive new replies.',
  })
  @ApiParam({ name: 'id', description: 'Thread ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Lock status toggled' })
  async toggleLock(@Param('id', ParseIntPipe) id: number) {
    return this.discussionsService.toggleLock(id);
  }

  @Patch('replies/:replyId/mark-answer')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Toggle mark as answer',
    description: 'Mark or unmark a reply as the accepted answer. Answers appear first in the reply list.',
  })
  @ApiParam({ name: 'replyId', description: 'Reply message ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Answer status toggled' })
  async markAnswer(@Param('replyId', ParseIntPipe) replyId: number) {
    return this.discussionsService.markAnswer(replyId);
  }

  @Patch('replies/:replyId/endorse')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Toggle endorse reply',
    description: 'Endorse or un-endorse a reply. Shows instructor approval of the answer.',
  })
  @ApiParam({ name: 'replyId', description: 'Reply message ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Endorsement toggled' })
  async endorseReply(@Param('replyId', ParseIntPipe) replyId: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.discussionsService.endorseReply(replyId, userId);
  }
}
