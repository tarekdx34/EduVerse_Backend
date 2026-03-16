import {
  Controller,
  Get,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { DatabaseService } from '../services/database.service';

@ApiTags('🗄️ Database')
@ApiBearerAuth('JWT-auth')
@Controller('api/database')
@UseGuards(JwtAuthGuard, RolesGuard)
export class DatabaseController {
  constructor(private readonly databaseService: DatabaseService) {}

  @Get('status')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get database status',
    description:
      'Returns MySQL server uptime, connected threads, and version. ' +
      'Access roles: ADMIN, IT_ADMIN. Uses: MySQL SHOW GLOBAL STATUS queries.',
  })
  @ApiResponse({ status: 200, description: 'Database status returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async getStatus() {
    return this.databaseService.getStatus();
  }

  @Get('tables')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get database table sizes',
    description:
      'Returns information about all tables including row count, data size, index size. ' +
      'Access roles: ADMIN, IT_ADMIN. Uses: `information_schema.TABLES`.',
  })
  @ApiResponse({ status: 200, description: 'Table size information returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async getTables() {
    return this.databaseService.getTables();
  }

  @Post('optimize')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Optimize all database tables',
    description:
      'Runs OPTIMIZE TABLE on every table in the database to reclaim space and defragment. ' +
      'Access roles: IT_ADMIN. Uses: MySQL OPTIMIZE TABLE command on all tables.',
  })
  @ApiResponse({ status: 200, description: 'Optimization results returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async optimizeDatabase() {
    return this.databaseService.optimizeDatabase();
  }
}
