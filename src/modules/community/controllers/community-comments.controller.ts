import {
  Controller,
  Put,
  Delete,
  Body,
  Param,
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
import { CommunityCommentsService } from '../services/community-comments.service';
import { UpdateCommentDto } from '../dto';

@ApiTags('💬 Community Comments')
@ApiBearerAuth('JWT-auth')
@Controller('api/community/comments')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CommunityCommentsController {
  constructor(private readonly commentsService: CommunityCommentsService) {}

  @Put(':id')
  @ApiOperation({
    summary: 'Update comment',
    description: `
Update a community post comment.

**Note**: Only the comment owner can update their comments.
    `,
  })
  @ApiParam({ name: 'id', description: 'Comment ID', example: 1 })
  @ApiBody({ type: UpdateCommentDto })
  @ApiResponse({ status: 200, description: 'Comment updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner' })
  @ApiResponse({ status: 404, description: 'Comment not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateCommentDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.commentsService.update(id, dto, userId);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete comment',
    description: `
Delete a community post comment.

**Allowed**: Comment owner or Admin
    `,
  })
  @ApiParam({ name: 'id', description: 'Comment ID', example: 1 })
  @ApiResponse({ status: 204, description: 'Comment deleted successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not owner or admin' })
  @ApiResponse({ status: 404, description: 'Comment not found' })
  async remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.commentsService.remove(id, userId, roles);
  }

  /**
   * Helper to extract role names from user object
   */
  private extractRoles(user: any): string[] {
    if (!user.roles) return [];
    return user.roles.map((r: any) => r.roleName || r.name || r);
  }
}
