import {
  Controller,
  Get,
  Patch,
  Param,
  Query,
  Body,
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
import { ErrorsService } from '../services/errors.service';
import { ErrorQueryDto } from '../dto/error-query.dto';
import { UpdateErrorDto } from '../dto/update-error.dto';

@ApiTags('🐛 System Errors')
@ApiBearerAuth('JWT-auth')
@Controller('api/errors')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ErrorsController {
  constructor(private readonly errorsService: ErrorsService) {}

  @Get()
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get system errors (paginated, filterable)',
    description:
      'Retrieves a paginated list of system errors with optional filters for type, severity, and resolved status. ' +
      'Access roles: ADMIN, IT_ADMIN. Uses table: `system_errors`.',
  })
  @ApiResponse({ status: 200, description: 'Paginated system errors returned (data + meta)' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async getErrors(@Query() query: ErrorQueryDto) {
    return this.errorsService.getErrors(query);
  }

  @Get('stats')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get error statistics',
    description:
      'Returns error counts grouped by type and severity, plus total/unresolved counts. ' +
      'Access roles: ADMIN, IT_ADMIN. Uses table: `system_errors`.',
  })
  @ApiResponse({ status: 200, description: 'Error statistics returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async getErrorStats() {
    return this.errorsService.getErrorStats();
  }

  @Get(':id')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get error details by ID',
    description:
      'Returns full details of a specific system error including resolver info. ' +
      'Access roles: ADMIN, IT_ADMIN. Uses table: `system_errors`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'System error ID' })
  @ApiResponse({ status: 200, description: 'Error details returned' })
  @ApiResponse({ status: 404, description: 'Error not found' })
  async getErrorDetails(@Param('id', ParseIntPipe) id: number) {
    return this.errorsService.getErrorDetails(id);
  }

  @Patch(':id')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update error status',
    description:
      'Updates the status of a system error (investigating, resolved, ignored). ' +
      'Access roles: IT_ADMIN. Uses table: `system_errors`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'System error ID' })
  @ApiResponse({ status: 200, description: 'Error status updated' })
  @ApiResponse({ status: 404, description: 'Error not found' })
  async updateErrorStatus(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateErrorDto,
    @Request() req,
  ) {
    return this.errorsService.updateErrorStatus(id, dto, req.user.sub);
  }
}
