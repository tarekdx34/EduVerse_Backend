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
import { CampusService } from '../services/campus.service';
import {
  CreateCampusDto,
  UpdateCampusDto,
  CampusDto,
} from '../dtos/campus.dto';
import { Status } from '../enums/status.enum';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';

@Controller('api/campuses')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CampusController {
  constructor(private readonly campusService: CampusService) {}

  @Get()
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  async findAll(@Query('status') status?: Status): Promise<CampusDto[]> {
    return this.campusService.findAll(status) as Promise<CampusDto[]>;
  }

  @Post()
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(201)
  async create(@Body() dto: CreateCampusDto): Promise<CampusDto> {
    return this.campusService.create(dto) as Promise<CampusDto>;
  }

  @Get(':id')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  async findById(@Param('id', ParseIntPipe) id: number): Promise<CampusDto> {
    return this.campusService.findById(id) as Promise<CampusDto>;
  }

  @Put(':id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateCampusDto,
  ): Promise<CampusDto> {
    return this.campusService.update(id, dto) as Promise<CampusDto>;
  }

  @Delete(':id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(204)
  async delete(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.campusService.delete(id);
  }
}
