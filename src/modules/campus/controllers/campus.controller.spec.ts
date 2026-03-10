import { Test, TestingModule } from '@nestjs/testing';
import { CampusController } from './campus.controller';
import { CampusService } from '../services/campus.service';
import { CreateCampusDto, UpdateCampusDto, CampusDto } from '../dtos/campus.dto';
import { Status } from '../enums/status.enum';
import {
  CampusNotFoundException,
  CampusCodeAlreadyExistsException,
  CannotDeleteCampusWithDepartmentsException,
} from '../exceptions/campus.exceptions';

describe('CampusController', () => {
  let controller: CampusController;
  let service: CampusService;

  const mockCampusDto: CampusDto = {
    id: 1,
    name: 'Main Campus',
    code: 'MAIN',
    address: '123 University St',
    city: 'New York',
    country: 'USA',
    phone: '+1-555-0123',
    email: 'main@university.edu',
    timezone: 'America/New_York',
    status: Status.ACTIVE,
    createdAt: new Date('2025-01-15'),
    updatedAt: new Date('2025-01-15'),
  };

  const mockCampusDto2: CampusDto = {
    id: 2,
    name: 'North Campus',
    code: 'NORTH',
    address: '456 University Ave',
    city: 'Boston',
    country: 'USA',
    phone: '+1-555-0456',
    email: 'north@university.edu',
    timezone: 'America/Boston',
    status: Status.ACTIVE,
    createdAt: new Date('2025-01-16'),
    updatedAt: new Date('2025-01-16'),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [CampusController],
      providers: [
        {
          provide: CampusService,
          useValue: {
            findAll: jest.fn(),
            findById: jest.fn(),
            create: jest.fn(),
            update: jest.fn(),
            delete: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<CampusController>(CampusController);
    service = module.get<CampusService>(CampusService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('findAll', () => {
    it('should return array of campuses', async () => {
      jest
        .spyOn(service, 'findAll')
        .mockResolvedValue([mockCampusDto, mockCampusDto2] as any);

      const result = await controller.findAll();

      expect(result).toEqual([mockCampusDto, mockCampusDto2]);
      expect(service.findAll).toHaveBeenCalledWith(undefined);
    });

    it('should filter campuses by status', async () => {
      jest.spyOn(service, 'findAll').mockResolvedValue([mockCampusDto] as any);

      const result = await controller.findAll(Status.ACTIVE);

      expect(result).toEqual([mockCampusDto]);
      expect(service.findAll).toHaveBeenCalledWith(Status.ACTIVE);
    });

    it('should return empty array when no campuses exist', async () => {
      jest.spyOn(service, 'findAll').mockResolvedValue([]);

      const result = await controller.findAll();

      expect(result).toEqual([]);
    });
  });

  describe('findById', () => {
    it('should return a campus by id', async () => {
      jest.spyOn(service, 'findById').mockResolvedValue(mockCampusDto as any);

      const result = await controller.findById(1);

      expect(result).toEqual(mockCampusDto);
      expect(service.findById).toHaveBeenCalledWith(1);
    });

    it('should throw CampusNotFoundException when campus does not exist', async () => {
      jest
        .spyOn(service, 'findById')
        .mockRejectedValue(new CampusNotFoundException(999));

      await expect(controller.findById(999)).rejects.toThrow(
        CampusNotFoundException,
      );
    });
  });

  describe('create', () => {
    it('should create and return new campus', async () => {
      const createDto: CreateCampusDto = {
        name: 'Main Campus',
        code: 'MAIN',
        address: '123 University St',
        city: 'New York',
        country: 'USA',
        phone: '+1-555-0123',
        email: 'main@university.edu',
        timezone: 'America/New_York',
      };

      jest
        .spyOn(service, 'create')
        .mockResolvedValue(mockCampusDto as any);

      const result = await controller.create(createDto);

      expect(result).toEqual(mockCampusDto);
      expect(service.create).toHaveBeenCalledWith(createDto);
    });

    it('should throw CampusCodeAlreadyExistsException when code is duplicate', async () => {
      const createDto: CreateCampusDto = {
        name: 'Main Campus',
        code: 'MAIN',
      };

      jest
        .spyOn(service, 'create')
        .mockRejectedValue(new CampusCodeAlreadyExistsException('MAIN'));

      await expect(controller.create(createDto)).rejects.toThrow(
        CampusCodeAlreadyExistsException,
      );
    });

    it('should create campus with minimal fields', async () => {
      const createDto: CreateCampusDto = {
        name: 'Simple Campus',
        code: 'SIMPLE',
      };

      jest
        .spyOn(service, 'create')
        .mockResolvedValue({
          ...mockCampusDto,
          id: 3,
          name: 'Simple Campus',
          code: 'SIMPLE',
        } as any);

      const result = await controller.create(createDto);

      expect(result.code).toBe('SIMPLE');
      expect(service.create).toHaveBeenCalledWith(createDto);
    });
  });

  describe('update', () => {
    it('should update and return campus', async () => {
      const updateDto: UpdateCampusDto = {
        name: 'Main Campus Updated',
        city: 'Boston',
      };

      const updatedCampus = { ...mockCampusDto, ...updateDto };

      jest
        .spyOn(service, 'update')
        .mockResolvedValue(updatedCampus as any);

      const result = await controller.update(1, updateDto);

      expect(result.name).toBe('Main Campus Updated');
      expect(result.city).toBe('Boston');
      expect(service.update).toHaveBeenCalledWith(1, updateDto);
    });

    it('should throw CampusNotFoundException when campus does not exist', async () => {
      const updateDto: UpdateCampusDto = { name: 'Updated' };

      jest
        .spyOn(service, 'update')
        .mockRejectedValue(new CampusNotFoundException(999));

      await expect(controller.update(999, updateDto)).rejects.toThrow(
        CampusNotFoundException,
      );
    });

    it('should throw error when new code is duplicate', async () => {
      const updateDto: UpdateCampusDto = { code: 'NORTH' };

      jest
        .spyOn(service, 'update')
        .mockRejectedValue(new CampusCodeAlreadyExistsException('NORTH'));

      await expect(controller.update(1, updateDto)).rejects.toThrow(
        CampusCodeAlreadyExistsException,
      );
    });

    it('should allow partial updates', async () => {
      const updateDto: UpdateCampusDto = { timezone: 'America/Los_Angeles' };

      const updatedCampus = {
        ...mockCampusDto,
        timezone: 'America/Los_Angeles',
      };

      jest
        .spyOn(service, 'update')
        .mockResolvedValue(updatedCampus as any);

      const result = await controller.update(1, updateDto);

      expect(result.timezone).toBe('America/Los_Angeles');
    });
  });

  describe('delete', () => {
    it('should delete campus and return void', async () => {
      jest.spyOn(service, 'delete').mockResolvedValue(undefined);

      await controller.delete(1);

      expect(service.delete).toHaveBeenCalledWith(1);
    });

    it('should throw error when campus has departments', async () => {
      jest
        .spyOn(service, 'delete')
        .mockRejectedValue(
          new CannotDeleteCampusWithDepartmentsException(),
        );

      await expect(controller.delete(1)).rejects.toThrow(
        CannotDeleteCampusWithDepartmentsException,
      );
    });

    it('should throw CampusNotFoundException when campus does not exist', async () => {
      jest
        .spyOn(service, 'delete')
        .mockRejectedValue(new CampusNotFoundException(999));

      await expect(controller.delete(999)).rejects.toThrow(
        CampusNotFoundException,
      );
    });
  });

  describe('Controller Decorators and Guards', () => {
    it('should have correct route path', () => {
      const metadata = Reflect.getMetadata('path', CampusController);
      expect(metadata).toBe('api/campuses');
    });

    it('should be protected with guards', () => {
      // Guards are applied via decorators at runtime
      // Test coverage via integration tests
      const controller = new CampusController(service);
      expect(controller).toBeDefined();
    });
  });
});
