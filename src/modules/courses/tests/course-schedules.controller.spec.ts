import { Test, TestingModule } from '@nestjs/testing';
import { CourseSchedulesController } from '../controllers/course-schedules.controller';
import { CourseSchedulesService } from '../services/course-schedules.service';
import { CreateScheduleDto } from '../dtos';

describe('CourseSchedulesController', () => {
  let controller: CourseSchedulesController;
  let service: CourseSchedulesService;

  const mockSchedule = {
    id: 1,
    sectionId: 1,
    dayOfWeek: 'MONDAY',
    startTime: '10:00',
    endTime: '11:30',
    room: '101',
    building: 'Building A',
    scheduleType: 'LECTURE',
    createdAt: new Date(),
  };

  const mockSchedulesService = {
    findBySectionId: jest.fn(),
    findById: jest.fn(),
    create: jest.fn(),
    delete: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [CourseSchedulesController],
      providers: [
        {
          provide: CourseSchedulesService,
          useValue: mockSchedulesService,
        },
      ],
    }).compile();

    controller = module.get<CourseSchedulesController>(CourseSchedulesController);
    service = module.get<CourseSchedulesService>(CourseSchedulesService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('findBySectionId', () => {
    it('should return schedules for a section', async () => {
      mockSchedulesService.findBySectionId.mockResolvedValue([mockSchedule]);

      const result = await controller.findBySectionId(1);

      expect(result).toHaveLength(1);
      expect(result[0].sectionId).toBe(1);
      expect(service.findBySectionId).toHaveBeenCalledWith(1);
    });

    it('should return empty array when no schedules exist', async () => {
      mockSchedulesService.findBySectionId.mockResolvedValue([]);

      const result = await controller.findBySectionId(999);

      expect(result).toHaveLength(0);
    });
  });

  describe('findById', () => {
    it('should return a schedule by id', async () => {
      mockSchedulesService.findById.mockResolvedValue(mockSchedule);

      const result = await controller.findById(1);

      expect(result).toBeDefined();
      expect(result.id).toBe(1);
      expect(service.findById).toHaveBeenCalledWith(1);
    });
  });

  describe('create', () => {
    it('should create a new schedule', async () => {
      const createDto: CreateScheduleDto = {
        dayOfWeek: 'MONDAY',
        startTime: '10:00',
        endTime: '11:30',
        room: '101',
        building: 'Building A',
        scheduleType: 'LECTURE',
      };

      mockSchedulesService.create.mockResolvedValue(mockSchedule);

      const result = await controller.create(1, createDto);

      expect(result).toBeDefined();
      expect(result.dayOfWeek).toBe('MONDAY');
      expect(service.create).toHaveBeenCalledWith(1, createDto);
    });

    it('should reject invalid time range', async () => {
      const createDto: CreateScheduleDto = {
        dayOfWeek: 'MONDAY',
        startTime: '11:30',
        endTime: '10:00', // End before start
        room: '101',
        building: 'Building A',
        scheduleType: 'LECTURE',
      };

      mockSchedulesService.create.mockRejectedValue(
        new Error('Invalid time range'),
      );

      await expect(controller.create(1, createDto)).rejects.toThrow('Invalid time range');
    });

    it('should detect schedule conflicts', async () => {
      const createDto: CreateScheduleDto = {
        dayOfWeek: 'MONDAY',
        startTime: '10:30', // Overlaps with existing
        endTime: '12:00',
        room: '101',
        building: 'Building A',
        scheduleType: 'LECTURE',
      };

      mockSchedulesService.create.mockRejectedValue(
        new Error('Schedule conflict detected'),
      );

      await expect(controller.create(1, createDto)).rejects.toThrow('Schedule conflict');
    });
  });

  describe('delete', () => {
    it('should delete a schedule', async () => {
      mockSchedulesService.delete.mockResolvedValue(undefined);

      await controller.delete(1);

      expect(service.delete).toHaveBeenCalledWith(1);
    });
  });
});
