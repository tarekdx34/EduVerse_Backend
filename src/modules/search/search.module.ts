import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SearchIndex } from './entities/search-index.entity';
import { SearchHistory } from './entities/search-history.entity';
import { SearchService } from './services/search.service';
import { SearchController } from './controllers/search.controller';

@Module({
  imports: [TypeOrmModule.forFeature([SearchIndex, SearchHistory])],
  controllers: [SearchController],
  providers: [SearchService],
  exports: [SearchService],
})
export class SearchModule {}
