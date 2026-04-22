import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
  Delete,
  Param,
  Body,
  Query,
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
  ApiBody,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { OfficeHoursService } from '../services/office-hours.service';
import { CreateSlotDto } from '../dto/create-slot.dto';
import { UpdateSlotDto } from '../dto/update-slot.dto';
import { BookAppointmentDto } from '../dto/book-appointment.dto';
import { UpdateAppointmentDto } from '../dto/update-appointment.dto';

@ApiTags('🕐 Office Hours')
@ApiBearerAuth('JWT-auth')
@Controller('api/office-hours')
@UseGuards(JwtAuthGuard, RolesGuard)
export class OfficeHoursController {
  constructor(private readonly officeHoursService: OfficeHoursService) {}

  // ── Slots ──

  @Get('slots')
  @Roles(
    RoleName.STUDENT,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.ADMIN,
    RoleName.IT_ADMIN,
  )
  @ApiOperation({
    summary: 'List all office hour slots',
    description:
      'Retrieves all office hour slots with instructor details. ' +
      'Access roles: ALL. Uses table: `office_hour_slots`.',
  })
  @ApiResponse({ status: 200, description: 'Slots returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getSlots(
    @Query('instructorId') instructorId?: string,
    @Query('dayOfWeek') dayOfWeek?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.officeHoursService.getSlots({
      instructorId: instructorId ? Number(instructorId) : undefined,
      dayOfWeek,
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
    });
  }

  @Get()
  @Roles(
    RoleName.STUDENT,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.ADMIN,
    RoleName.IT_ADMIN,
  )
  @ApiOperation({
    summary: 'List office hours (compatibility route)',
    description:
      'Compatibility alias for list slots. Returns paginated office hour slots for admin/front-end clients using /api/office-hours.',
  })
  @ApiResponse({ status: 200, description: 'Office hours returned' })
  async getOfficeHours(
    @Query('instructorId') instructorId?: string,
    @Query('dayOfWeek') dayOfWeek?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.officeHoursService.getSlots({
      instructorId: instructorId ? Number(instructorId) : undefined,
      dayOfWeek,
      page: page ? Number(page) : undefined,
      limit: limit ? Number(limit) : undefined,
    });
  }

  @Get('my-slots')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: "Get instructor's own office hour slots",
    description:
      'Retrieves all office hour slots created by the current instructor. ' +
      'Access roles: INSTRUCTOR, TA, ADMIN, IT_ADMIN. Uses table: `office_hour_slots`.',
  })
  @ApiResponse({ status: 200, description: "Instructor's slots returned" })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getMySlots(@Request() req) {
    return this.officeHoursService.getMySlots(req.user.userId);
  }

  @Get('available')
  @Roles(
    RoleName.STUDENT,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.ADMIN,
    RoleName.IT_ADMIN,
  )
  @ApiOperation({
    summary: 'Get available office hour slots for booking',
    description:
      'Retrieves all active office hour slots that students can book. ' +
      'Access roles: ALL. Uses table: `office_hour_slots`.',
  })
  @ApiResponse({ status: 200, description: 'Available slots returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getAvailableSlots(@Query('instructorId') instructorId?: string) {
    return this.officeHoursService.getAvailableSlots(
      instructorId ? Number(instructorId) : undefined,
    );
  }

  @Post('slots')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Create an office hour slot',
    description:
      'Creates a new weekly office hour slot for the current instructor. ' +
      'Access roles: INSTRUCTOR, ADMIN, IT_ADMIN. Uses table: `office_hour_slots`.',
  })
  @ApiBody({ type: CreateSlotDto })
  @ApiResponse({ status: 201, description: 'Slot created' })
  @ApiResponse({ status: 400, description: 'Validation error' })
  async createSlot(@Body() dto: CreateSlotDto, @Request() req) {
    const callerUserId = req.user.userId;
    const roles = this.extractRoles(req.user);
    const isAdmin =
      roles.includes(RoleName.ADMIN) || roles.includes(RoleName.IT_ADMIN);
    const targetInstructorId =
      isAdmin && dto.instructorId ? dto.instructorId : callerUserId;
    return this.officeHoursService.createSlot(dto, targetInstructorId);
  }

  @Post()
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Create an office hour (compatibility route)',
    description:
      'Compatibility alias for creating slots via /api/office-hours.',
  })
  @ApiBody({ type: CreateSlotDto })
  @ApiResponse({ status: 201, description: 'Office hour created' })
  async createOfficeHour(@Body() dto: CreateSlotDto, @Request() req) {
    const callerUserId = req.user.userId;
    const roles = this.extractRoles(req.user);
    const isAdmin =
      roles.includes(RoleName.ADMIN) || roles.includes(RoleName.IT_ADMIN);
    const targetInstructorId =
      isAdmin && dto.instructorId ? dto.instructorId : callerUserId;
    return this.officeHoursService.createSlot(dto, targetInstructorId);
  }

  @Put('slots/:id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update an office hour slot',
    description:
      'Updates an existing office hour slot. ' +
      'Access roles: INSTRUCTOR, ADMIN, IT_ADMIN. Uses table: `office_hour_slots`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Slot ID' })
  @ApiBody({ type: UpdateSlotDto })
  @ApiResponse({ status: 200, description: 'Slot updated' })
  @ApiResponse({ status: 404, description: 'Slot not found' })
  async updateSlot(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateSlotDto,
    @Request() req,
  ) {
    return this.officeHoursService.updateSlot(id, dto, req.user.userId);
  }

  @Put(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update an office hour (compatibility route)',
    description:
      'Compatibility alias for updating slots via /api/office-hours/:id.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Slot ID' })
  @ApiBody({ type: UpdateSlotDto })
  @ApiResponse({ status: 200, description: 'Office hour updated' })
  async updateOfficeHour(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateSlotDto,
    @Request() req,
  ) {
    return this.officeHoursService.updateSlot(id, dto, req.user.userId);
  }

  @Delete('slots/:id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Delete an office hour slot',
    description:
      'Deletes a slot and cancels all future appointments for it. ' +
      'Access roles: INSTRUCTOR, ADMIN, IT_ADMIN. Uses tables: `office_hour_slots`, `office_hour_appointments`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Slot ID' })
  @ApiResponse({ status: 200, description: 'Slot deleted' })
  @ApiResponse({ status: 404, description: 'Slot not found' })
  async deleteSlot(@Param('id', ParseIntPipe) id: number) {
    return this.officeHoursService.deleteSlot(id);
  }

  @Delete(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Delete an office hour (compatibility route)',
    description:
      'Compatibility alias for deleting slots via /api/office-hours/:id.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Slot ID' })
  @ApiResponse({ status: 200, description: 'Office hour deleted' })
  async deleteOfficeHour(@Param('id', ParseIntPipe) id: number) {
    return this.officeHoursService.deleteSlot(id);
  }

  // ── Appointments ──

  @Get('appointments')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'List all appointments',
    description:
      'Retrieves all appointments. For instructors, returns appointments for their slots. ' +
      'Access roles: INSTRUCTOR, ADMIN, IT_ADMIN. Uses tables: `office_hour_appointments`, `office_hour_slots`.',
  })
  @ApiResponse({ status: 200, description: 'Appointments returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getAppointments(@Request() req, @Query('slotId') slotId?: string) {
    return this.officeHoursService.getAppointments(
      req.user.userId,
      slotId ? Number(slotId) : undefined,
    );
  }

  @Get('my-appointments')
  @Roles(
    RoleName.STUDENT,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.ADMIN,
    RoleName.IT_ADMIN,
  )
  @ApiOperation({
    summary: "Get student's own appointments",
    description:
      'Retrieves all appointments the current user has booked. ' +
      'Access roles: ALL. Uses tables: `office_hour_appointments`, `office_hour_slots`.',
  })
  @ApiResponse({ status: 200, description: "Student's appointments returned" })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getMyAppointments(@Request() req) {
    return this.officeHoursService.getMyAppointments(req.user.userId);
  }

  @Get(':id')
  @Roles(
    RoleName.STUDENT,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.ADMIN,
    RoleName.IT_ADMIN,
  )
  @ApiOperation({
    summary: 'Get office hour slot by ID',
    description: 'Retrieves one office hour slot by slot ID.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Slot ID' })
  @ApiResponse({ status: 200, description: 'Slot returned' })
  @ApiResponse({ status: 404, description: 'Slot not found' })
  async getSlotById(@Param('id', ParseIntPipe) id: number) {
    return this.officeHoursService.getSlotById(id);
  }

  @Post('appointments')
  @Roles(
    RoleName.STUDENT,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.ADMIN,
    RoleName.IT_ADMIN,
  )
  @ApiOperation({
    summary: 'Book an appointment',
    description:
      'Books an appointment for an available office hour slot. Validates slot is active and not full. ' +
      'Access roles: ALL (primarily STUDENT). Uses tables: `office_hour_appointments`, `office_hour_slots`.',
  })
  @ApiBody({ type: BookAppointmentDto })
  @ApiResponse({ status: 201, description: 'Appointment booked' })
  @ApiResponse({ status: 400, description: 'Slot is full or not active' })
  @ApiResponse({ status: 404, description: 'Slot not found' })
  async bookAppointment(@Body() dto: BookAppointmentDto, @Request() req) {
    return this.officeHoursService.bookAppointment(dto, req.user.userId);
  }

  @Patch('appointments/:id')
  @Roles(
    RoleName.STUDENT,
    RoleName.INSTRUCTOR,
    RoleName.ADMIN,
    RoleName.IT_ADMIN,
  )
  @ApiOperation({
    summary: 'Update an appointment',
    description:
      'Updates status or notes of an appointment (confirm, cancel, complete, no_show). ' +
      'Access roles: STUDENT, INSTRUCTOR, ADMIN, IT_ADMIN. Uses table: `office_hour_appointments`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Appointment ID' })
  @ApiBody({ type: UpdateAppointmentDto })
  @ApiResponse({ status: 200, description: 'Appointment updated' })
  @ApiResponse({ status: 404, description: 'Appointment not found' })
  async updateAppointment(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateAppointmentDto,
    @Request() req,
  ) {
    return this.officeHoursService.updateAppointment(id, dto, req.user.userId);
  }

  @Delete('appointments/:id')
  @Roles(
    RoleName.STUDENT,
    RoleName.INSTRUCTOR,
    RoleName.ADMIN,
    RoleName.IT_ADMIN,
  )
  @ApiOperation({
    summary: 'Cancel an appointment',
    description:
      'Cancels an appointment and records who cancelled it. ' +
      'Access roles: STUDENT, INSTRUCTOR, ADMIN, IT_ADMIN. Uses table: `office_hour_appointments`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Appointment ID' })
  @ApiResponse({ status: 200, description: 'Appointment cancelled' })
  @ApiResponse({ status: 404, description: 'Appointment not found' })
  async cancelAppointment(
    @Param('id', ParseIntPipe) id: number,
    @Request() req,
  ) {
    return this.officeHoursService.cancelAppointment(id, req.user.userId);
  }

  private extractRoles(user: any): string[] {
    if (Array.isArray(user.roles)) {
      return user.roles.map((r: any) =>
        typeof r === 'string' ? r : r.roleName || r.name,
      );
    }
    return [];
  }
}
