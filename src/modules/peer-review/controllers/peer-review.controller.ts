import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UseGuards,
  ParseIntPipe,
  Request,
  Query,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiBody,
  ApiQuery,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { PeerReviewService } from '../services/peer-review.service';
import { AssignReviewsDto } from '../dto/assign-reviews.dto';
import { SubmitReviewDto } from '../dto/submit-review.dto';

@ApiTags('🔍 Peer Reviews')
@ApiBearerAuth('JWT-auth')
@Controller('api/peer-reviews')
@UseGuards(JwtAuthGuard, RolesGuard)
export class PeerReviewController {
  constructor(private readonly peerReviewService: PeerReviewService) {}

  @Get()
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'List all peer reviews',
    description:
      'Retrieves all peer reviews with reviewer and reviewee details. ' +
      'Access roles: ALL. Uses table: `peer_reviews`.',
  })
  @ApiResponse({ status: 200, description: 'Peer reviews returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll() {
    return this.peerReviewService.findAll();
  }

  @Get('pending')
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA)
  @ApiOperation({
    summary: 'Get pending reviews for current user',
    description:
      'Retrieves all peer reviews assigned to the current user that are still pending. ' +
      'Access roles: STUDENT, INSTRUCTOR, TA. Uses table: `peer_reviews`.',
  })
  @ApiResponse({ status: 200, description: 'Pending reviews returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getPendingReviews(@Request() req) {
    return this.peerReviewService.getPendingReviews(req.user.userId);
  }

  @Get('received')
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA)
  @ApiOperation({
    summary: 'Get reviews received by current user',
    description:
      'Retrieves all peer reviews received for the current user\'s submissions. ' +
      'Access roles: STUDENT, INSTRUCTOR, TA. Uses table: `peer_reviews`.',
  })
  @ApiResponse({ status: 200, description: 'Received reviews returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getReceivedReviews(@Request() req) {
    return this.peerReviewService.getReceivedReviews(req.user.userId);
  }

  @Get('assignment/:assignmentId/summary')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get peer review summary for an assignment',
    description:
      'Retrieves a summary of all peer reviews for a specific assignment, including counts and individual reviews. ' +
      'Access roles: INSTRUCTOR, TA, ADMIN, IT_ADMIN. Uses tables: `peer_reviews`, `assignment_submissions`.',
  })
  @ApiParam({ name: 'assignmentId', type: Number, description: 'Assignment ID' })
  @ApiResponse({ status: 200, description: 'Assignment review summary returned' })
  async getAssignmentSummary(
    @Param('assignmentId', ParseIntPipe) assignmentId: number,
  ) {
    return this.peerReviewService.getAssignmentSummary(assignmentId);
  }

  @Get(':id')
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get peer review details',
    description:
      'Retrieves details of a specific peer review. ' +
      'Access roles: ALL. Uses table: `peer_reviews`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Peer review ID' })
  @ApiResponse({ status: 200, description: 'Peer review details returned' })
  @ApiResponse({ status: 404, description: 'Peer review not found' })
  async findById(@Param('id', ParseIntPipe) id: number) {
    return this.peerReviewService.findById(id);
  }

  @Post('assign')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA)
  @ApiOperation({
    summary: 'Assign peer reviews for an assignment',
    description:
      'Automatically assigns peer reviews using round-robin allocation across all submissions for the given assignment. ' +
      'Each submission gets the specified number of reviewers assigned. ' +
      'Access roles: INSTRUCTOR, TA. Uses tables: `peer_reviews`, `assignment_submissions`.',
  })
  @ApiBody({ type: AssignReviewsDto })
  @ApiResponse({ status: 201, description: 'Peer reviews assigned' })
  @ApiResponse({ status: 400, description: 'Not enough submissions for peer review' })
  async assignReviews(@Body() dto: AssignReviewsDto) {
    return this.peerReviewService.assignReviews(dto);
  }

  @Post(':id/submit')
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA)
  @ApiOperation({
    summary: 'Submit a peer review',
    description:
      'Submits the review text, rating, and optional criteria scores for a pending peer review. ' +
      'Only the assigned reviewer can submit. ' +
      'Access roles: STUDENT, INSTRUCTOR, TA. Uses table: `peer_reviews`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Peer review ID' })
  @ApiBody({ type: SubmitReviewDto })
  @ApiResponse({ status: 201, description: 'Peer review submitted' })
  @ApiResponse({ status: 400, description: 'Not the assigned reviewer or already submitted' })
  @ApiResponse({ status: 404, description: 'Peer review not found' })
  async submitReview(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: SubmitReviewDto,
    @Request() req,
  ) {
    return this.peerReviewService.submitReview(id, dto, req.user.userId);
  }
}
