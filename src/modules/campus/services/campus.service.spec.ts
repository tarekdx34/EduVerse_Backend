import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CampusService } from './campus.service';
import { Campus } from '../entities/campus.entity';
import { CreateCampusDto, UpdateCampusDto } from '../dtos/campus.dto';
import { Status } from '../enums/status.enum';
import {
  CampusNotFoundException,
  CampusCodeAlreadyExistsException,
  CannotDeleteCampusWithDepartmentsException,
} from '../exceptions/campus.exceptions';

describe('CampusService', () => {
  let service: CampusService;
  let campusRepository: Repository<Campus>;

  const mockCampus: Campus = {
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
    departments: [],
  };

  const mockCampus2: Campus = {
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
    departments: [],
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CampusService,
        {
          provide: getRepositoryToken(Campus),
          useValue: {
            find: jest.fn(),
            findOne: jest.fn(),
            create: jest.fn(),
            save: jest.fn(),
            remove: jest.fn(),
            createQueryBuilder: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<CampusService>(CampusService);
    campusRepository = module.get<Repository<Campus>>(
      getRepositoryToken(Campus),
    );
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('findAll', () => {
    it('should return all campuses when no status filter is provided', async () => {
      const mockQueryBuilder = {
        where: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        getMany: jest.fn().mockResolvedValue([mockCampus, mockCampus2]),
      };

      jest
        .spyOn(campusRepository, 'createQueryBuilder')
        .mockReturnValue(mockQueryBuilder as any);

      const result = await service.findAll();

      expect(result).toEqual([mockCampus, mockCampus2]);
      expect(mockQueryBuilder.orderBy).toHaveBeenCalledWith(
        'campus.name',
        'ASC',
      );
    });

    it('should filter campuses by status', async () => {
      const mockQueryBuilder = {
        where: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        getMany: jest.fn().mockResolvedValue([mockCampus]),
      };

      jest
        .spyOn(campusRepository, 'createQueryBuilder')
        .mockReturnValue(mockQueryBuilder as any);

      const result = await service.findAll(Status.ACTIVE);

      expect(result).toEqual([mockCampus]);
      expect(mockQueryBuilder.where).toHaveBeenCalledWith(
        'campus.status = :status',
        { status: Status.ACTIVE },
      );
    });

    it('should return empty array when no campuses exist', async () => {
      const mockQueryBuilder = {
        where: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        getMany: jest.fn().mockResolvedValue([]),
      };

      jest
        .spyOn(campusRepository, 'createQueryBuilder')
        .mockReturnValue(mockQueryBuilder as any);

      const result = await service.findAll();

      expect(result).toEqual([]);
    });
  });

  describe('findById', () => {
    it('should return a campus by id with its departments', async () => {
      jest.spyOn(campusRepository, 'findOne').mockResolvedValue(mockCampus);

      const result = await service.findById(1);

      expect(result).toEqual(mockCampus);
      expect(campusRepository.findOne).toHaveBeenCalledWith({
        where: { id: 1 },
        relations: ['departments'],
      });
    });

    it('should throw CampusNotFoundException when campus does not exist', async () => {
      jest.spyOn(campusRepository, 'findOne').mockResolvedValue(null);

      await expect(service.findById(999)).rejects.toThrow(
        CampusNotFoundException,
      );
    });
  });

  describe('create', () => {
    it('should create a new campus with default values', async () => {
      const createDto: CreateCampusDto = {
        name: 'Main Campus',
        code: 'MAIN',
        address: '123 University St',
        city: 'New York',
        country: 'USA',
        phone: '+1-555-0123',
        email: 'main@university.edu',
      };

      jest.spyOn(campusRepository, 'findOne').mockResolvedValue(null);
      jest.spyOn(campusRepository, 'create').mockReturnValue(mockCampus);
      jest.spyOn(campusRepository, 'save').mockResolvedValue(mockCampus);

      const result = await service.create(createDto);

      expect(result).toEqual(mockCampus);
      expect(campusRepository.create).toHaveBeenCalledWith({
        name: 'Main Campus',
        code: 'MAIN',
        address: '123 University St',
        city: 'New York',
        country: 'USA',
        phone: '+1-555-0123',
        email: 'main@university.edu',
        timezone: 'UTC',
        status: Status.ACTIVE,
      });
      expect(campusRepository.save).toHaveBeenCalledWith(mockCampus);
    });

    it('should create a campus with custom timezone and status', async () => {
      const createDto: CreateCampusDto = {
        name: 'Main Campus',
        code: 'MAIN',
        timezone: 'America/New_York',
        status: Status.INACTIVE,
      };

      jest.spyOn(campusRepository, 'findOne').mockResolvedValue(null);
      jest.spyOn(campusRepository, 'create').mockReturnValue(mockCampus);
      jest.spyOn(campusRepository, 'save').mockResolvedValue(mockCampus);

      await service.create(createDto);

      expect(campusRepository.create).toHaveBeenCalledWith({
        name: 'Main Campus',
        code: 'MAIN',
        address: undefined,
        city: undefined,
        country: undefined,
        phone: undefined,
        email: undefined,
        timezone: 'America/New_York',
        status: Status.INACTIVE,
      });
    });

    it('should throw CampusCodeAlreadyExistsException when code already exists', async () => {
      const createDto: CreateCampusDto = {
        name: 'Main Campus',
        code: 'MAIN',
      };

      jest.spyOn(campusRepository, 'findOne').mockResolvedValue(mockCampus);

      await expect(service.create(createDto)).rejects.toThrow(
        CampusCodeAlreadyExistsException,
      );
    });
  });

  describe('update', () => {
    it('should update campus fields', async () => {
      const updateDto: UpdateCampusDto = {
        name: 'Main Campus Updated',
        city: 'Boston',
      };

      const updatedCampus = { ...mockCampus, ...updateDto };

      jest.spyOn(campusRepository, 'findOne').mockResolvedValue(mockCampus);
      jest.spyOn(campusRepository, 'save').mockResolvedValue(updatedCampus);

      const result = await service.update(1, updateDto);

      expect(result).toEqual(updatedCampus);
      expect(campusRepository.save).toHaveBeenCalled();
    });

    it('should throw CampusNotFoundException when campus does not exist', async () => {
      const updateDto: UpdateCampusDto = { name: 'Updated' };

      jest.spyOn(campusRepository, 'findOne').mockResolvedValue(null);

      await expect(service.update(999, updateDto)).rejects.toThrow(
        CampusNotFoundException,
      );
    });

    it('should validate new code is not already taken', async () => {
      const updateDto: UpdateCampusDto = { code: 'NEWCODE' };

      jest.spyOn(campusRepository, 'findOne')
        .mockResolvedValueOnce(mockCampus) // First call for findById
        .mockResolvedValueOnce(mockCampus2); // Second call for existing code check

      await expect(service.update(1, updateDto)).rejects.toThrow(
        CampusCodeAlreadyExistsException,
      );
    });

    it('should allow updating code to same value', async () => {
      const updateDto: UpdateCampusDto = { code: 'MAIN' };

      jest.spyOn(campusRepository, 'findOne').mockResolvedValue(mockCampus);
      jest.spyOn(campusRepository, 'save').mockResolvedValue(mockCampus);

      const result = await service.update(1, updateDto);

      expect(result).toEqual(mockCampus);
      // Should not check for duplicate code when code is the same
      expect(campusRepository.save).toHaveBeenCalled();
    });

    it('should allow updating code when new code is not taken', async () => {
      const updateDto: UpdateCampusDto = { code: 'NEWCODE' };
      const updatedCampus = { ...mockCampus, code: 'NEWCODE' };

      jest.spyOn(campusRepository, 'findOne')
        .mockResolvedValueOnce(mockCampus) // First call for findById
        .mockResolvedValueOnce(null); // Second call for existing code check

      jest.spyOn(campusRepository, 'save').mockResolvedValue(updatedCampus);

      const result = await service.update(1, updateDto);

      expect(result).toEqual(updatedCampus);
      expect(campusRepository.save).toHaveBeenCalled();
    });
  });

  describe('delete', () => {
    it('should delete a campus without departments', async () => {
      const mockQueryBuilder = {
        leftJoin: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        getRawOne: jest.fn().mockResolvedValue({ count: '0' }),
      };

      jest.spyOn(campusRepository, 'findOne').mockResolvedValue(mockCampus);
      jest
        .spyOn(campusRepository, 'createQueryBuilder')
        .mockReturnValue(mockQueryBuilder as any);
      jest.spyOn(campusRepository, 'remove').mockResolvedValue(mockCampus);

      await service.delete(1);

      expect(campusRepository.remove).toHaveBeenCalledWith(mockCampus);
    });

    it('should throw error when trying to delete campus with departments', async () => {
      const mockQueryBuilder = {
        leftJoin: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        getRawOne: jest.fn().mockResolvedValue({ count: '2' }),
      };

      jest.spyOn(campusRepository, 'findOne').mockResolvedValue(mockCampus);
      jest
        .spyOn(campusRepository, 'createQueryBuilder')
        .mockReturnValue(mockQueryBuilder as any);

      await expect(service.delete(1)).rejects.toThrow(
        CannotDeleteCampusWithDepartmentsException,
      );
      expect(campusRepository.remove).not.toHaveBeenCalled();
    });

    it('should throw CampusNotFoundException when campus does not exist', async () => {
      jest.spyOn(campusRepository, 'findOne').mockResolvedValue(null);

      await expect(service.delete(999)).rejects.toThrow(
        CampusNotFoundException,
      );
    });
  });

  describe('getCampusWithDepartmentCount', () => {
    it('should return campus with department count', async () => {
      const mockQueryBuilder = {
        leftJoinAndSelect: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        loadRelationCountAndMap: jest.fn().mockReturnThis(),
        getOne: jest.fn().mockResolvedValue({
          ...mockCampus,
          departmentCount: 5,
        }),
      };

      jest
        .spyOn(campusRepository, 'createQueryBuilder')
        .mockReturnValue(mockQueryBuilder as any);

      const result = await service.getCampusWithDepartmentCount(1);

      expect(result.departmentCount).toBe(5);
      expect(mockQueryBuilder.where).toHaveBeenCalledWith('campus.id = :id', {
        id: 1,
      });
    });

    it('should throw CampusNotFoundException when campus does not exist', async () => {
      const mockQueryBuilder = {
        leftJoinAndSelect: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        loadRelationCountAndMap: jest.fn().mockReturnThis(),
        getOne: jest.fn().mockResolvedValue(null),
      };

      jest
        .spyOn(campusRepository, 'createQueryBuilder')
        .mockReturnValue(mockQueryBuilder as any);

      await expect(service.getCampusWithDepartmentCount(999)).rejects.toThrow(
        CampusNotFoundException,
      );
    });
  });
});
