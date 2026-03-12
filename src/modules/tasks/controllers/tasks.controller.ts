import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  Req,
  ParseIntPipe,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiQuery,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { TasksService } from '../services/tasks.service';
import { RemindersService } from '../services/reminders.service';
import { CreateTaskDto, UpdateTaskDto, TaskQueryDto, CreateReminderDto } from '../dto';

@ApiTags('📋 Tasks & Reminders')
@ApiBearerAuth('JWT-auth')
@Controller('api/tasks')
@UseGuards(JwtAuthGuard, RolesGuard)
export class TasksController {
  constructor(
    private readonly tasksService: TasksService,
    private readonly remindersService: RemindersService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List my tasks' })
  @ApiResponse({ status: 200, description: 'Paginated list of tasks' })
  async findAll(@Query() query: TaskQueryDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.tasksService.findAll(userId, query);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new task' })
  @ApiResponse({ status: 201, description: 'Task created' })
  async create(@Body() dto: CreateTaskDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.tasksService.create(dto, userId);
  }

  // Static routes BEFORE :id param routes
  @Get('upcoming')
  @ApiOperation({ summary: 'Get upcoming tasks' })
  @ApiQuery({ name: 'days', required: false, type: Number, description: 'Number of days ahead (default 7)' })
  @ApiResponse({ status: 200, description: 'List of upcoming tasks' })
  async findUpcoming(@Query('days') days: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.tasksService.findUpcoming(userId, days ? +days : 7);
  }

  @Get('reminders')
  @ApiOperation({ summary: 'List my reminders' })
  @ApiResponse({ status: 200, description: 'List of reminders' })
  async findAllReminders(@Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.remindersService.findAll(userId);
  }

  @Post('reminders')
  @ApiOperation({ summary: 'Create a reminder' })
  @ApiResponse({ status: 201, description: 'Reminder created' })
  async createReminder(@Body() dto: CreateReminderDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.remindersService.create(dto, userId);
  }

  @Delete('reminders/:id')
  @ApiOperation({ summary: 'Delete a reminder' })
  @ApiParam({ name: 'id', description: 'Reminder ID' })
  @ApiResponse({ status: 200, description: 'Reminder deleted' })
  @ApiResponse({ status: 404, description: 'Reminder not found' })
  async removeReminder(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    await this.remindersService.remove(id, userId);
    return { message: 'Reminder deleted successfully' };
  }

  // Parameterized routes AFTER static routes
  @Get(':id')
  @ApiOperation({ summary: 'Get task detail' })
  @ApiParam({ name: 'id', description: 'Task ID' })
  @ApiResponse({ status: 200, description: 'Task details' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async findOne(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.tasksService.findOne(id, userId);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a task' })
  @ApiParam({ name: 'id', description: 'Task ID' })
  @ApiResponse({ status: 200, description: 'Task updated' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateTaskDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.tasksService.update(id, dto, userId);
  }

  @Post(':id/complete')
  @ApiOperation({ summary: 'Mark task as complete' })
  @ApiParam({ name: 'id', description: 'Task ID' })
  @ApiResponse({ status: 201, description: 'Task marked as complete' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async complete(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: { notes?: string; timeTakenMinutes?: number },
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.tasksService.complete(id, userId, body.notes, body.timeTakenMinutes);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a task' })
  @ApiParam({ name: 'id', description: 'Task ID' })
  @ApiResponse({ status: 200, description: 'Task deleted' })
  @ApiResponse({ status: 404, description: 'Task not found' })
  async remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    await this.tasksService.remove(id, userId);
    return { message: 'Task deleted successfully' };
  }
}
