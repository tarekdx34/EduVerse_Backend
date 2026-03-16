import {
  Controller,
  Get,
  Param,
  UseGuards,
  ParseIntPipe,
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
import { SslService } from '../services/ssl.service';

@ApiTags('🔐 SSL Certificates')
@ApiBearerAuth('JWT-auth')
@Controller('api/ssl')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SslController {
  constructor(private readonly sslService: SslService) {}

  @Get()
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get all SSL certificates',
    description:
      'Retrieves all SSL certificates ordered by expiry date (soonest first). ' +
      'Access roles: ADMIN, IT_ADMIN. Uses table: `ssl_certificates`.',
  })
  @ApiResponse({ status: 200, description: 'SSL certificates returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async getCertificates() {
    return this.sslService.getCertificates();
  }

  @Get('expiring')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get expiring/expired SSL certificates',
    description:
      'Retrieves only certificates with status expiring_soon or expired. ' +
      'Access roles: IT_ADMIN. Uses table: `ssl_certificates`.',
  })
  @ApiResponse({ status: 200, description: 'Expiring certificates returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async getExpiringCertificates() {
    return this.sslService.getExpiringCertificates();
  }

  @Get(':id')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get SSL certificate details by ID',
    description:
      'Retrieves full details of a specific SSL certificate. ' +
      'Access roles: ADMIN, IT_ADMIN. Uses table: `ssl_certificates`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Certificate ID' })
  @ApiResponse({ status: 200, description: 'Certificate details returned' })
  @ApiResponse({ status: 404, description: 'Certificate not found' })
  async getCertificateDetails(@Param('id', ParseIntPipe) id: number) {
    return this.sslService.getCertificateDetails(id);
  }
}
