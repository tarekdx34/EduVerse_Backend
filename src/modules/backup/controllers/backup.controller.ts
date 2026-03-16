import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
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
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { BackupService } from '../services/backup.service';

@ApiTags('💾 Backups')
@ApiBearerAuth('JWT-auth')
@Controller('api/backups')
@UseGuards(JwtAuthGuard, RolesGuard)
export class BackupController {
  constructor(private readonly backupService: BackupService) {}

  @Get()
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'List all backup records',
    description:
      'Retrieves all database backup records ordered by most recent. ' +
      'Access roles: ADMIN, IT_ADMIN. Uses table: `backup_records`.',
  })
  @ApiResponse({ status: 200, description: 'Backup records returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async listBackups() {
    return this.backupService.listBackups();
  }

  @Post()
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Create a new database backup',
    description:
      'Triggers a mysqldump of the database and saves the output to backups/ directory. ' +
      'Access roles: IT_ADMIN. Uses table: `backup_records`. Executes system command: `mysqldump`.',
  })
  @ApiResponse({ status: 201, description: 'Backup created (or failed with message)' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async createBackup(@Request() req) {
    return this.backupService.createBackup(req.user.sub);
  }

  @Get(':id')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get backup details by ID',
    description:
      'Retrieves full details of a specific backup record including creator info. ' +
      'Access roles: ADMIN, IT_ADMIN. Uses table: `backup_records`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Backup record ID' })
  @ApiResponse({ status: 200, description: 'Backup details returned' })
  @ApiResponse({ status: 404, description: 'Backup not found' })
  async getBackupDetails(@Param('id', ParseIntPipe) id: number) {
    return this.backupService.getBackupDetails(id);
  }

  @Delete(':id')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Delete a backup record and file',
    description:
      'Removes the backup record from the database and deletes the physical file from disk. ' +
      'Access roles: IT_ADMIN. Uses table: `backup_records`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Backup record ID' })
  @ApiResponse({ status: 200, description: 'Backup deleted' })
  @ApiResponse({ status: 404, description: 'Backup not found' })
  async deleteBackup(@Param('id', ParseIntPipe) id: number) {
    return this.backupService.deleteBackup(id);
  }
}
