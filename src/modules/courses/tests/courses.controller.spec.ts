import { Test, TestingModule } from '@nestjs/testing';
import { CoursesController } from '../controllers/courses.controller';
import { CoursesService } from '../services/courses.service';
import { CreateCourseDto, UpdateCourseDto } from '../dtos';
import { CourseStatus } from '../enums';

describe('CoursesController', () => {
  let controller: CoursesController;
  let service: CoursesService;

  const mockCourse = {
    id: 1,
    departmentId: 1,
    name: 'Data Structures',
    code: 'CS201',
    description: 'Study of data structures',
    credits: 3,
    level: 'SOPHOMORE',
    syllabusUrl: 'https://example.com/syllabus.pdf',
    status: CourseStatus.ACTIVE,
    sections: [],
    prerequisites: [],
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
  };

  const mockCoursesService = {
    findAll: jest.fn(),
    findById: jest.fn(),
    findByDepartment: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    softDelete: jest.fn(),
    getPrerequisites: jest.fn(),
    addPrerequisite: jest.fn(),
    removePrerequisite: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [CoursesController],
      providers: [
        {
          provide: CoursesService,
          useValue: mockCoursesService,
        },
      ],
    }).compile();

    controller = module.get<CoursesController>(CoursesController);
    service = module.get<CoursesService>(CoursesService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('findAll', () => {
    it('should return all courses with pagination', async () => {
      const mockResult = {
        data: [mockCourse],
        meta: {
          total: 1,
          page: 1,
          limit: 20,
          totalPages: 1,
        },
      };

      mockCoursesService.findAll.mockResolvedValue(mockResult);

      const result = await controller.findAll(1, 'SOPHOMORE', CourseStatus.ACTIVE, '', 1, 20);

      expect(result).toEqual(mockResult);
      expect(service.findAll).toHaveBeenCalledWith(1, 'SOPHOMORE', CourseStatus.ACTIVE, '', 1, 20);
    });

    it('should return courses filtered by department', async () => {
      const mockResult = {
        data: [mockCourse],
        meta: { total: 1, page: 1, limit: 20, totalPages: 1 },
      };

      mockCoursesService.findAll.mockResolvedValue(mockResult);

      const result = await controller.findAll(1);

      expect(result.data).toHaveLength(1);
      expect(service.findAll).toHaveBeenCalled();
    });
  });

  describe('findById', () => {
    it('should return a course by id', async () => {
      mockCoursesService.findById.mockResolvedValue(mockCourse);
      mockCoursesService.getPrerequisites.mockResolvedValue([]);

      const result = await controller.findById(1);

      expect(result).toBeDefined();
      expect(result.id).toBe(1);
      expect(service.findById).toHaveBeenCalledWith(1);
    });

    it('should include prerequisite count', async () => {
      const mockPrerequisites = [{ id: 1, prerequisiteCourseId: 2 }];
      mockCoursesService.findById.mockResolvedValue(mockCourse);
      mockCoursesService.getPrerequisites.mockResolvedValue(mockPrerequisites);

      const result = await controller.findById(1);

      expect(result.prerequisitesCount).toBe(1);
    });
  });

  describe('create', () => {
    it('should create a new course', async () => {
      const createDto: CreateCourseDto = {
        departmentId: 1,
        name: 'New Course',
        code: 'CS301',
        description: 'New course description',
        credits: 4,
        level: 'JUNIOR',
        syllabusUrl: 'https://example.com/new-syllabus.pdf',
      };

      mockCoursesService.create.mockResolvedValue({ ...mockCourse, ...createDto });

      const result = await controller.create(createDto);

      expect(result).toBeDefined();
      expect(result.code).toBe('CS301');
      expect(service.create).toHaveBeenCalledWith(createDto);
    });
  });

  describe('update', () => {
    it('should update course details', async () => {
      const updateDto: UpdateCourseDto = {
        name: 'Updated Course Name',
        credits: 4,
      };

      const updated = { ...mockCourse, ...updateDto };
      mockCoursesService.update.mockResolvedValue(updated);

      const result = await controller.update(1, updateDto);

      expect(result.name).toBe('Updated Course Name');
      expect(result.credits).toBe(4);
      expect(service.update).toHaveBeenCalledWith(1, updateDto);
    });
  });

  describe('delete', () => {
    it('should soft delete a course', async () => {
      mockCoursesService.softDelete.mockResolvedValue(undefined);

      await controller.delete(1);

      expect(service.softDelete).toHaveBeenCalledWith(1);
    });
  });

  describe('findByDepartment', () => {
    it('should return courses by department', async () => {
      mockCoursesService.findByDepartment.mockResolvedValue([mockCourse]);

      const result = await controller.findByDepartment(1);

      expect(result).toHaveLength(1);
      expect(service.findByDepartment).toHaveBeenCalledWith(1);
    });
  });

  describe('prerequisites', () => {
    it('should get prerequisites for a course', async () => {
      const mockPrerequisites = [
        {
          id: 1,
          courseId: 1,
          prerequisiteCourseId: 2,
          isMandatory: true,
        },
      ];

      mockCoursesService.getPrerequisites.mockResolvedValue(mockPrerequisites);

      const result = await controller.getPrerequisites(1);

      expect(result).toHaveLength(1);
      expect(service.getPrerequisites).toHaveBeenCalledWith(1);
    });

    it('should add a prerequisite', async () => {
      const addDto = { prerequisiteCourseId: 2, isMandatory: true };
      const result = { id: 1, courseId: 1, ...addDto };

      mockCoursesService.addPrerequisite.mockResolvedValue(result);

      const response = await controller.addPrerequisite(1, addDto);

      expect(response).toBeDefined();
      expect(service.addPrerequisite).toHaveBeenCalledWith(1, 2, true);
    });

    it('should remove a prerequisite', async () => {
      mockCoursesService.removePrerequisite.mockResolvedValue(undefined);

      await controller.removePrerequisite(1, 1);

      expect(service.removePrerequisite).toHaveBeenCalledWith(1, 1);
    });
  });
});
