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
import { ProgramService } from '../services/program.service';
import {
  CreateProgramDto,
  UpdateProgramDto,
  ProgramDto,
} from '../dtos/program.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';

@Controller('api')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ProgramController {
  constructor(private readonly programService: ProgramService) {}

  @Get('departments/:deptId/programs')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  async findByDepartmentId(
    @Param('deptId', ParseIntPipe) deptId: number,
  ): Promise<ProgramDto[]> {
    return this.programService.findByDepartmentId(deptId) as Promise<
      ProgramDto[]
    >;
  }

  @Post('programs')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(201)
  async create(@Body() dto: CreateProgramDto): Promise<ProgramDto> {
    return this.programService.create(dto) as Promise<ProgramDto>;
  }

  @Get('programs/:id')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  async findById(@Param('id', ParseIntPipe) id: number): Promise<ProgramDto> {
    return this.programService.findById(id) as Promise<ProgramDto>;
  }

  @Put('programs/:id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateProgramDto,
  ): Promise<ProgramDto> {
    return this.programService.update(id, dto) as Promise<ProgramDto>;
  }

  @Delete('programs/:id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(204)
  async delete(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.programService.delete(id);
  }
}
