import { Test } from '@nestjs/testing';
import { TasksRepository } from './tasks.repository';
import { TasksService } from './tasks.service';
import { TaskStatus } from './task-status.enum';
import { NotFoundException } from '@nestjs/common';

const mockTasksRepository = () => ({
  getTasks: jest.fn(),
  findOneBy: jest.fn(),
});

const mockUser = {
  username: 'username',
  id: 'someid',
  password: 'password',
  tasks: [],
};

describe('TaskService', () => {
  let tasksService: TasksService;
  let tasksRepository: TasksRepository;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        TasksService,
        { provide: TasksRepository, useFactory: mockTasksRepository },
      ],
    }).compile();

    tasksService = await module.get(TasksService);
    tasksRepository = module.get(TasksRepository);
  });

  describe('getTasks', () => {
    it('calls TasksRepository.getTasks and returns the result', async () => {
      tasksRepository.getTasks.mockResolvedValue('someValue');
      const result = await tasksService.getTasks(null, mockUser);
      expect(tasksRepository.getTasks).toHaveBeenCalled();
      expect(result).toEqual('someValue');
    });
  });
  describe('getTasksById', () => {
    it('calls TasksRepository.findOneBy and returns the result', async () => {
      const mockTask = {
        id: 'someId',
        title: 'test title',
        description: 'test description',
        status: TaskStatus.OPEN,
      };

      tasksRepository.findOneBy.mockResolvedValue(mockTask);

      const result = await tasksService.getTaskById(null, mockUser);
      expect(result).toEqual(mockTask);
    });

    it('calls TasksRepository.findOneBy and handles the exception', async () => {
      tasksRepository.findOneBy.mockResolvedValue(null);
      expect(tasksService.getTaskById(null, mockUser)).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
