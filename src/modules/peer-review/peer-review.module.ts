import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PeerReview } from './entities/peer-review.entity';
import { AssignmentSubmission } from '../assignments/entities/assignment-submission.entity';
import { PeerReviewService } from './services/peer-review.service';
import { PeerReviewController } from './controllers/peer-review.controller';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([PeerReview, AssignmentSubmission]),
    NotificationsModule,
  ],
  controllers: [PeerReviewController],
  providers: [PeerReviewService],
  exports: [PeerReviewService],
})
export class PeerReviewModule {}
