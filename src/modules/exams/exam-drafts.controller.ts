import {
  Controller,
  Get,
  ParseIntPipe,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { RoleName } from '../auth/entities/role.entity';
import { ExamsService } from './exams.service';

@ApiTags('Exams')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('api/exam-drafts')
export class ExamDraftsController {
  constructor(private readonly examsService: ExamsService) {}

  @Get()
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  getDrafts(
    @Query('page', new ParseIntPipe({ optional: true })) page: number = 1,
    @Query('limit', new ParseIntPipe({ optional: true })) limit: number = 20,
  ) {
    return this.examsService.findDrafts(page, limit);
  }

  @Get('list')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  listDrafts(
    @Query('page', new ParseIntPipe({ optional: true })) page: number = 1,
    @Query('limit', new ParseIntPipe({ optional: true })) limit: number = 20,
  ) {
    return this.examsService.findDrafts(page, limit);
  }
}
