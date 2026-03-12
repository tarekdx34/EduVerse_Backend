import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Body,
  Query,
  Req,
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { ReportsService } from '../services/reports.service';
import { GenerateReportDto } from '../dto/generate-report.dto';
import { ReportQueryDto } from '../dto/report-query.dto';

@ApiTags('📑 Reports')
@ApiBearerAuth('JWT-auth')
@Controller('api/reports')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  // Static routes MUST come before :id param routes

  @Get('templates')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'List report templates' })
  @ApiResponse({ status: 200, description: 'Report templates retrieved successfully' })
  async getTemplates(@Query() query: ReportQueryDto) {
    return this.reportsService.getTemplates(query);
  }

  @Post('generate')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Generate a report' })
  @ApiResponse({ status: 201, description: 'Report generated successfully' })
  async generate(@Body() dto: GenerateReportDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.reportsService.generate(dto, userId);
  }

  @Get('history')
  @ApiOperation({ summary: 'Get report generation history' })
  @ApiResponse({ status: 200, description: 'Report history retrieved successfully' })
  async getHistory(@Req() req: any, @Query() query: ReportQueryDto) {
    const userId = req.user.userId || req.user.id;
    return this.reportsService.getHistory(userId, query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get report details' })
  @ApiResponse({ status: 200, description: 'Report details retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Report not found' })
  async getReport(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const isAdmin = this.isAdmin(req);
    return this.reportsService.getReport(id, userId, isAdmin);
  }

  @Get(':id/download')
  @ApiOperation({ summary: 'Download a report' })
  @ApiResponse({ status: 200, description: 'Report download data retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Report not found' })
  async downloadReport(
    @Param('id', ParseIntPipe) id: number,
    @Query('format') format: string,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const isAdmin = this.isAdmin(req);
    return this.reportsService.downloadReport(id, userId, format, isAdmin);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a report' })
  @ApiResponse({ status: 200, description: 'Report deleted successfully' })
  @ApiResponse({ status: 404, description: 'Report not found' })
  async deleteReport(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const isAdmin = this.isAdmin(req);
    return this.reportsService.deleteReport(id, userId, isAdmin);
  }

  private isAdmin(req: any): boolean {
    return req.user?.roles?.some(
      (role) =>
        role.roleName === RoleName.ADMIN || role.roleName === RoleName.IT_ADMIN,
    );
  }
}
