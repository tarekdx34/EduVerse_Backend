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
  ParseIntPipe,
  Request,
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
import { StudyGroupsService } from '../services/study-groups.service';
import { CreateStudyGroupDto } from '../dto/create-study-group.dto';
import { UpdateStudyGroupDto } from '../dto/update-study-group.dto';

@ApiTags('📚 Study Groups')
@ApiBearerAuth('JWT-auth')
@Controller('api/study-groups')
@UseGuards(JwtAuthGuard, RolesGuard)
export class StudyGroupsController {
  constructor(private readonly studyGroupsService: StudyGroupsService) {}

  @Get()
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'List all study groups',
    description:
      'Retrieves all study groups. Optionally filter by courseId. ' +
      'Access roles: ALL. Uses tables: `study_groups`.',
  })
  @ApiQuery({ name: 'courseId', required: false, type: Number, description: 'Filter by course ID' })
  @ApiResponse({ status: 200, description: 'Study groups returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll(@Query('courseId') courseId?: number) {
    return this.studyGroupsService.findAll(courseId ? +courseId : undefined);
  }

  @Get('my')
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get my study groups',
    description:
      'Retrieves all study groups the current user is a member of. ' +
      'Access roles: ALL. Uses tables: `study_group_members`, `study_groups`.',
  })
  @ApiResponse({ status: 200, description: 'User study groups returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findMyGroups(@Request() req) {
    return this.studyGroupsService.findMyGroups(req.user.userId);
  }

  @Get(':id')
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get study group by ID',
    description:
      'Retrieves details of a specific study group. ' +
      'Access roles: ALL. Uses table: `study_groups`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Study group ID' })
  @ApiResponse({ status: 200, description: 'Study group details returned' })
  @ApiResponse({ status: 404, description: 'Study group not found' })
  async findById(@Param('id', ParseIntPipe) id: number) {
    return this.studyGroupsService.findById(id);
  }

  @Post()
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Create a study group',
    description:
      'Creates a new study group and automatically adds the creator as the first member with "creator" role. ' +
      'Access roles: ALL. Uses tables: `study_groups`, `study_group_members`.',
  })
  @ApiBody({ type: CreateStudyGroupDto })
  @ApiResponse({ status: 201, description: 'Study group created' })
  @ApiResponse({ status: 400, description: 'Validation error' })
  async create(@Body() dto: CreateStudyGroupDto, @Request() req) {
    return this.studyGroupsService.createGroup(dto, req.user.userId);
  }

  @Put(':id')
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update a study group',
    description:
      'Updates an existing study group. Only the group creator can update. ' +
      'Access roles: OWNER. Uses table: `study_groups`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Study group ID' })
  @ApiBody({ type: UpdateStudyGroupDto })
  @ApiResponse({ status: 200, description: 'Study group updated' })
  @ApiResponse({ status: 403, description: 'Forbidden – not the creator' })
  @ApiResponse({ status: 404, description: 'Study group not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateStudyGroupDto,
    @Request() req,
  ) {
    return this.studyGroupsService.updateGroup(id, dto, req.user.userId);
  }

  @Delete(':id')
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Delete a study group',
    description:
      'Deletes a study group and all its memberships. Only the group creator or admins can delete. ' +
      'Access roles: OWNER, ADMIN. Uses tables: `study_groups`, `study_group_members`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Study group ID' })
  @ApiResponse({ status: 200, description: 'Study group deleted' })
  @ApiResponse({ status: 403, description: 'Forbidden – not the creator or admin' })
  @ApiResponse({ status: 404, description: 'Study group not found' })
  async delete(@Param('id', ParseIntPipe) id: number, @Request() req) {
    const userRoles = req.user.roles || [];
    return this.studyGroupsService.deleteGroup(id, req.user.userId, userRoles);
  }

  @Post(':id/join')
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Join a study group',
    description:
      'Joins the current user to a study group. Checks if: group is active, not full, user not already a member. ' +
      'Access roles: ALL. Uses tables: `study_groups`, `study_group_members`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Study group ID' })
  @ApiResponse({ status: 201, description: 'Joined study group successfully' })
  @ApiResponse({ status: 400, description: 'Already a member or group is full' })
  @ApiResponse({ status: 404, description: 'Study group not found' })
  async join(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return this.studyGroupsService.joinGroup(id, req.user.userId);
  }

  @Delete(':id/leave')
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Leave a study group',
    description:
      'Removes the current user from a study group. The group creator cannot leave (must delete the group instead). ' +
      'Access roles: ALL. Uses tables: `study_groups`, `study_group_members`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Study group ID' })
  @ApiResponse({ status: 200, description: 'Left study group successfully' })
  @ApiResponse({ status: 400, description: 'Not a member or is creator' })
  @ApiResponse({ status: 404, description: 'Study group not found' })
  async leave(@Param('id', ParseIntPipe) id: number, @Request() req) {
    return this.studyGroupsService.leaveGroup(id, req.user.userId);
  }

  @Get(':id/members')
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'List study group members',
    description:
      'Retrieves all members of a specific study group. ' +
      'Access roles: ALL. Uses tables: `study_group_members`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Study group ID' })
  @ApiResponse({ status: 200, description: 'Members returned' })
  @ApiResponse({ status: 404, description: 'Study group not found' })
  async getMembers(@Param('id', ParseIntPipe) id: number) {
    return this.studyGroupsService.getMembers(id);
  }
}
