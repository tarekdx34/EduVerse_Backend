import {
  Controller,
  Get,
  Put,
  Patch,
  Body,
  Param,
  ParseIntPipe,
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
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { UserManagementService } from './user-management.service';
import {
  UpdateProfileDto,
  UpdateUserPreferencesDto,
  ChangePasswordDto,
} from './dto/user-management.dto';

@ApiTags('User Profile')
@ApiBearerAuth('JWT-auth')
@Controller('api/users')
@UseGuards(JwtAuthGuard)
export class UserProfileController {
  constructor(private readonly userManagementService: UserManagementService) {}

  @Get('profile')
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({
    status: 200,
    description: 'User profile with completeness score',
  })
  async getProfile(@Request() req) {
    return this.userManagementService.getProfile(req.user.userId);
  }

  @Put('profile')
  @ApiOperation({ summary: 'Update current user profile' })
  @ApiResponse({ status: 200, description: 'Updated profile' })
  async updateProfile(@Request() req, @Body() dto: UpdateProfileDto) {
    return this.userManagementService.updateProfile(req.user.userId, dto);
  }

  @Get('preferences')
  @ApiOperation({ summary: 'Get user preferences' })
  @ApiResponse({ status: 200, description: 'User preferences' })
  async getPreferences(@Request() req) {
    return this.userManagementService.getPreferences(req.user.userId);
  }

  @Get(':id/public')
  @ApiOperation({ summary: 'Get public profile for a user' })
  @ApiParam({ name: 'id', type: Number, description: 'User ID' })
  @ApiResponse({
    status: 200,
    description:
      'Public profile returned with non-sensitive contact details (email and social links)',
  })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getPublicProfile(@Param('id', ParseIntPipe) userId: number) {
    return this.userManagementService.getPublicProfile(userId);
  }

  @Put('preferences')
  @ApiOperation({ summary: 'Update user preferences' })
  @ApiResponse({ status: 200, description: 'Updated preferences' })
  async updatePreferences(
    @Request() req,
    @Body() dto: UpdateUserPreferencesDto,
  ) {
    return this.userManagementService.updatePreferences(req.user.userId, dto);
  }

  @Patch('password')
  @ApiOperation({ summary: 'Change password' })
  @ApiResponse({ status: 200, description: 'Password changed successfully' })
  @ApiResponse({ status: 400, description: 'Current password is incorrect' })
  async changePassword(@Request() req, @Body() dto: ChangePasswordDto) {
    return this.userManagementService.changePassword(req.user.userId, dto);
  }
}
