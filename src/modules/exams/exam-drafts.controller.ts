import {
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { RoleName } from '../auth/entities/role.entity';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { ExamDraftListQueryDto } from './dto/exam-query.dto';
import { ExamsService } from './exams.service';

type AuthenticatedRequest = {
  user: {
    userId: number;
  };
};

@ApiTags('Exams')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('api/exam-drafts')
export class ExamDraftsController {
  constructor(private readonly examsService: ExamsService) {}

  @Get()
  @Roles(RoleName.INSTRUCTOR)
  getDrafts(
    @Req() req: AuthenticatedRequest,
    @Query() query: ExamDraftListQueryDto,
  ) {
    return this.examsService.findDrafts(
      req.user.userId,
      query.page,
      query.limit,
      query,
    );
  }

  @Get('list')
  @Roles(RoleName.INSTRUCTOR)
  listDrafts(
    @Req() req: AuthenticatedRequest,
    @Query() query: ExamDraftListQueryDto,
  ) {
    return this.examsService.findDrafts(
      req.user.userId,
      query.page,
      query.limit,
      query,
    );
  }

  @Get(':draftId')
  @Roles(RoleName.INSTRUCTOR)
  getDraftById(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.findDraftById(draftId, req.user.userId);
  }
}
