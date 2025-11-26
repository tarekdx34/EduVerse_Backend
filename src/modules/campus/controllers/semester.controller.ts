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
  HttpCode,
  ParseIntPipe,
} from '@nestjs/common';
import { SemesterService } from '../services/semester.service';
import {
  CreateSemesterDto,
  UpdateSemesterDto,
  SemesterDto,
} from '../dtos/semester.dto';
import { SemesterStatus } from '../enums/semester-status.enum';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';

@Controller('api/semesters')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SemesterController {
  constructor(private readonly semesterService: SemesterService) {}

  @Get()
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  async findAll(
    @Query('status') status?: SemesterStatus,
    @Query('year') year?: string,
  ): Promise<SemesterDto[]> {
    const yearNum = year ? parseInt(year, 10) : undefined;
    return this.semesterService.findAll(status, yearNum) as Promise<
      SemesterDto[]
    >;
  }

  @Get('current')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  async getCurrentSemester(): Promise<SemesterDto> {
    return this.semesterService.findCurrentSemester() as Promise<SemesterDto>;
  }

  @Post()
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(201)
  async create(@Body() dto: CreateSemesterDto): Promise<SemesterDto> {
    return this.semesterService.create(dto) as Promise<SemesterDto>;
  }

  @Get(':id')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  async findById(@Param('id', ParseIntPipe) id: number): Promise<SemesterDto> {
    return this.semesterService.findById(id) as Promise<SemesterDto>;
  }

  @Put(':id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateSemesterDto,
  ): Promise<SemesterDto> {
    return this.semesterService.update(id, dto) as Promise<SemesterDto>;
  }

  @Delete(':id')
  @Roles(RoleName.IT_ADMIN)
  @HttpCode(204)
  async delete(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.semesterService.delete(id);
  }
}
