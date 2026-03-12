import { Test, TestingModule } from '@nestjs/testing';
import { CourseSectionsController } from '../controllers/course-sections.controller';
import { CourseSectionsService } from '../services/course-sections.service';
import { CreateSectionDto, UpdateSectionDto } from '../dtos';

describe('CourseSectionsController', () => {
  let controller: CourseSectionsController;
  let service: CourseSectionsService;

  const mockSection = {
    id: 1,
    courseId: 1,
    semesterId: 1,
    sectionNumber: '01',
    maxCapacity: 40,
    currentEnrollment: 25,
    location: 'Building A, Room 101',
    status: 'open',
    createdAt: new Date(),
    updatedAt: new Date(),
    course: { id: 1, name: 'Data Structures', code: 'CS201' },
    semester: { id: 1, name: 'Fall 2025' },
    schedules: [],
  };

  const mockSectionsService = {
    findByCourseId: jest.fn(),
    findById: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    updateEnrollment: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [CourseSectionsController],
      providers: [
        {
          provide: CourseSectionsService,
          useValue: mockSectionsService,
        },
      ],
    }).compile();

    controller = module.get<CourseSectionsController>(CourseSectionsController);
    service = module.get<CourseSectionsService>(CourseSectionsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('findByCourseId', () => {
    it('should return sections for a course', async () => {
      mockSectionsService.findByCourseId.mockResolvedValue([mockSection]);

      const result = await controller.findByCourseId(1);

      expect(result).toHaveLength(1);
      expect(result[0].courseId).toBe(1);
      expect(service.findByCourseId).toHaveBeenCalledWith(1, undefined);
    });

    it('should filter by semester', async () => {
      mockSectionsService.findByCourseId.mockResolvedValue([mockSection]);

      const result = await controller.findByCourseId(1, 1);

      expect(service.findByCourseId).toHaveBeenCalledWith(1, 1);
    });
  });

  describe('findById', () => {
    it('should return a section by id', async () => {
      mockSectionsService.findById.mockResolvedValue(mockSection);

      const result = await controller.findById(1);

      expect(result).toBeDefined();
      expect(result.id).toBe(1);
      expect(service.findById).toHaveBeenCalledWith(1);
    });
  });

  describe('create', () => {
    it('should create a new section', async () => {
      const createDto: CreateSectionDto = {
        courseId: 1,
        semesterId: 1,
        sectionNumber: 1,
        maxCapacity: 40,
        currentEnrollment: 0,
        location: 'Building A, Room 101',
      };

      mockSectionsService.create.mockResolvedValue(mockSection);

      const result = await controller.create(createDto);

      expect(result).toBeDefined();
      expect(result.courseId).toBe(1);
      expect(service.create).toHaveBeenCalledWith(createDto);
    });
  });

  describe('update', () => {
    it('should update section details', async () => {
      const updateDto: UpdateSectionDto = {
        maxCapacity: 50,
        currentEnrollment: 30,
        location: 'Building B, Room 201',
      };

      const updated = { ...mockSection, ...updateDto };
      mockSectionsService.update.mockResolvedValue(updated);

      const result = await controller.update(1, updateDto);

      expect(result.maxCapacity).toBe(50);
      expect(result.location).toBe('Building B, Room 201');
      expect(service.update).toHaveBeenCalledWith(1, updateDto);
    });
  });

  describe('updateEnrollment', () => {
    it('should update section enrollment', async () => {
      const updated = { ...mockSection, currentEnrollment: 35 };
      mockSectionsService.updateEnrollment.mockResolvedValue(undefined);
      mockSectionsService.findById.mockResolvedValue(updated);

      const result = await controller.updateEnrollment(1, 35);

      expect(result.currentEnrollment).toBe(35);
      expect(service.updateEnrollment).toHaveBeenCalledWith(1, 35);
    });

    it('should not allow enrollment to exceed capacity', async () => {
      mockSectionsService.updateEnrollment.mockRejectedValue(
        new Error('Section is full'),
      );

      await expect(
        controller.updateEnrollment(1, 50),
      ).rejects.toThrow('Section is full');
    });
  });
});
