import {
  Controller,
  Get,
  Delete,
  Query,
  Req,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiQuery,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { SearchService } from '../services/search.service';
import { GlobalSearchDto } from '../dto/global-search.dto';
import { SearchHistoryQueryDto } from '../dto/search-history-query.dto';

@ApiTags('🔍 Search')
@ApiBearerAuth('JWT-auth')
@Controller('api/search')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SearchController {
  constructor(private readonly searchService: SearchService) {}

  @Get()
  @ApiOperation({
    summary: 'Global search',
    description: 'Search across all indexed entities (courses, materials, users, etc.) with optional filters.',
  })
  @ApiResponse({ status: 200, description: 'Search results grouped by entity type' })
  async globalSearch(@Query() dto: GlobalSearchDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.searchService.globalSearch(dto, userId);
  }

  @Get('courses')
  @ApiOperation({
    summary: 'Search courses',
    description: 'Search specifically within indexed courses.',
  })
  @ApiQuery({ name: 'query', required: true, description: 'Search query string' })
  @ApiQuery({ name: 'page', required: false, description: 'Page number', example: 1 })
  @ApiQuery({ name: 'limit', required: false, description: 'Results per page', example: 20 })
  @ApiResponse({ status: 200, description: 'Paginated course search results' })
  async searchCourses(
    @Query('query') query: string,
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 20,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.searchService.searchCourses(query, userId, +page || 1, +limit || 20);
  }

  @Get('users')
  @ApiOperation({
    summary: 'Search users',
    description: 'Search specifically within indexed users.',
  })
  @ApiQuery({ name: 'query', required: true, description: 'Search query string' })
  @ApiQuery({ name: 'page', required: false, description: 'Page number', example: 1 })
  @ApiQuery({ name: 'limit', required: false, description: 'Results per page', example: 20 })
  @ApiResponse({ status: 200, description: 'Paginated user search results' })
  async searchUsers(
    @Query('query') query: string,
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 20,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.searchService.searchUsers(query, userId, +page || 1, +limit || 20);
  }

  @Get('materials')
  @ApiOperation({
    summary: 'Search materials',
    description: 'Search specifically within indexed materials.',
  })
  @ApiQuery({ name: 'query', required: true, description: 'Search query string' })
  @ApiQuery({ name: 'page', required: false, description: 'Page number', example: 1 })
  @ApiQuery({ name: 'limit', required: false, description: 'Results per page', example: 20 })
  @ApiResponse({ status: 200, description: 'Paginated material search results' })
  async searchMaterials(
    @Query('query') query: string,
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 20,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.searchService.searchMaterials(query, userId, +page || 1, +limit || 20);
  }

  @Get('history')
  @ApiOperation({
    summary: 'Get search history',
    description: 'Retrieve the authenticated user\'s search history with pagination.',
  })
  @ApiResponse({ status: 200, description: 'Paginated search history' })
  async getHistory(@Query() dto: SearchHistoryQueryDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.searchService.getHistory(userId, dto.page, dto.limit);
  }

  @Delete('history')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Clear search history',
    description: 'Delete all search history for the authenticated user.',
  })
  @ApiResponse({ status: 200, description: 'Search history cleared successfully' })
  async clearHistory(@Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.searchService.clearHistory(userId);
  }
}
