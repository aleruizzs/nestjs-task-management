import { Task } from './task.entity';
import { Repository, DataSource } from 'typeorm';
import { CreateTaskDto } from './dto/create-task.dto';
import { TaskStatus } from './task-status.enum';
import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { GetTasksFilterDto } from './dto/get-tasks-filter.dto';
import { User } from '../auth/user.entity';
import { Logger } from '@nestjs/common';

@Injectable()
export class TasksRepository extends Repository<Task> {
  private logger = new Logger('TasksRepository', { timestamp: true });
  constructor(private dataSource: DataSource) {
    super(Task, dataSource.createEntityManager());
  }
 
  async createTask(createTaskDto: CreateTaskDto, user: User): Promise<Task> {
    const { title, description } = createTaskDto;
    const task = this.create({
      title,
      description,
      status: TaskStatus.OPEN,
      user,
    });
    await this.save(task);
    return task;
  }

  async getTasks(filterDto: GetTasksFilterDto, user: User): Promise<Task[]> {
    const { search, status } = filterDto;
    const query = this.createQueryBuilder('task').where({ user });

    if (search) {
        query.andWhere(
            '(LOWER(task.description) LIKE LOWER(:search) OR LOWER(task.title) LIKE LOWER(:search))', {search: `%${search}%`}
        );
    }
    if (status) {
        query.andWhere('task.status = :status', {status});
    }
    
    try {
      const tasks = await query.getMany();
      return tasks;
    } catch (error) {
      this.logger.error(`Failed to get tasks for user: ${ user.username }. Filters: ${ JSON.stringify(filterDto) }`, error.stack);
      throw new InternalServerErrorException();
    }
  }
}