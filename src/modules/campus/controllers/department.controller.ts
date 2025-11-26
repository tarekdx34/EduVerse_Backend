import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  HttpCode,
  ParseIntPipe,
} from '@nestjs/common';
import { DepartmentService } from '../services/department.service';
import {
  CreateDepartmentDto,
  UpdateDepartmentDto,
  DepartmentDto,
} from '../dtos/department.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';

@Controller('api')
@UseGuards(JwtAuthGuard, RolesGuard)
export class DepartmentController {
  constructor(private readonly departmentService: DepartmentService) {}

  @Get('campuses/:campusId/departments')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  async findByCampusId(
    @Param('campusId', ParseIntPipe) campusId: number,
  ): Promise<DepartmentDto[]> {
    return this.departmentService.findByCampusId(campusId) as Promise<
      DepartmentDto[]
    >;
  }

  @Post('departments')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(201)
  async create(@Body() dto: CreateDepartmentDto): Promise<DepartmentDto> {
    return this.departmentService.create(dto) as Promise<DepartmentDto>;
  }

  @Get('departments/:id')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  async findById(
    @Param('id', ParseIntPipe) id: number,
  ): Promise<DepartmentDto> {
    return this.departmentService.findById(id) as Promise<DepartmentDto>;
  }

  @Put('departments/:id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateDepartmentDto,
  ): Promise<DepartmentDto> {
    return this.departmentService.update(id, dto) as Promise<DepartmentDto>;
  }

  @Delete('departments/:id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(204)
  async delete(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.departmentService.delete(id);
  }
}
