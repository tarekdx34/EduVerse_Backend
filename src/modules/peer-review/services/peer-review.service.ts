import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PeerReview } from '../entities/peer-review.entity';
import { AssignReviewsDto } from '../dto/assign-reviews.dto';
import { SubmitReviewDto } from '../dto/submit-review.dto';
import { AssignmentSubmission } from '../../assignments/entities/assignment-submission.entity';

@Injectable()
export class PeerReviewService {
  private readonly logger = new Logger(PeerReviewService.name);

  constructor(
    @InjectRepository(PeerReview)
    private reviewRepo: Repository<PeerReview>,
    @InjectRepository(AssignmentSubmission)
    private submissionRepo: Repository<AssignmentSubmission>,
  ) {}

  async findAll() {
    const data = await this.reviewRepo.find({
      relations: ['reviewer', 'reviewee'],
      order: { createdAt: 'DESC' },
    });
    return { data };
  }

  async findById(id: number) {
    const review = await this.reviewRepo.findOne({
      where: { reviewId: id },
      relations: ['reviewer', 'reviewee'],
    });
    if (!review) {
      throw new NotFoundException(`Peer review #${id} not found`);
    }
    return { data: review };
  }

  async assignReviews(dto: AssignReviewsDto) {
    const perSub = dto.reviewersPerSubmission || 2;

    // Get all submissions for this assignment
    const submissions = await this.submissionRepo.find({
      where: { assignmentId: dto.assignmentId },
    });

    if (submissions.length < 2) {
      throw new BadRequestException(
        'Need at least 2 submissions to assign peer reviews',
      );
    }

    const created: PeerReview[] = [];

    // Simple round-robin assignment: for each submission, assign N different reviewers
    for (let i = 0; i < submissions.length; i++) {
      const submission = submissions[i];
      let assigned = 0;
      let j = 1;

      while (assigned < perSub && j < submissions.length) {
        const reviewerIndex = (i + j) % submissions.length;
        const reviewerSubmission = submissions[reviewerIndex];

        // Don't let someone review their own submission
        if (reviewerSubmission.userId !== submission.userId) {
          // Check if review already exists
          const existing = await this.reviewRepo.findOne({
            where: {
              submissionId: submission.id,
              reviewerId: reviewerSubmission.userId,
            },
          });

          if (!existing) {
            const review = this.reviewRepo.create({
              submissionId: submission.id,
              reviewerId: reviewerSubmission.userId,
              revieweeId: submission.userId,
              status: 'pending',
            });
            const saved = await this.reviewRepo.save(review);
            created.push(saved);
          }
          assigned++;
        }
        j++;
      }
    }

    return {
      data: created,
      message: `Assigned ${created.length} peer reviews for assignment #${dto.assignmentId}`,
    };
  }

  async getPendingReviews(userId: number) {
    const data = await this.reviewRepo.find({
      where: { reviewerId: userId, status: 'pending' },
      relations: ['reviewee'],
      order: { createdAt: 'DESC' },
    });
    return { data };
  }

  async getReceivedReviews(userId: number) {
    const data = await this.reviewRepo.find({
      where: { revieweeId: userId },
      relations: ['reviewer'],
      order: { createdAt: 'DESC' },
    });
    return { data };
  }

  async submitReview(id: number, dto: SubmitReviewDto, userId: number) {
    const review = await this.reviewRepo.findOne({
      where: { reviewId: id },
    });
    if (!review) {
      throw new NotFoundException(`Peer review #${id} not found`);
    }
    if (review.reviewerId != userId) {
      throw new BadRequestException('You are not assigned to this review');
    }
    if (review.status !== 'pending') {
      throw new BadRequestException('This review has already been submitted');
    }

    review.reviewText = dto.reviewText;
    review.rating = dto.rating ?? null;
    review.criteriaScores = dto.criteriaScores ?? null;
    review.status = 'submitted';
    review.submittedAt = new Date();

    const saved = await this.reviewRepo.save(review);
    return { data: saved, message: `Peer review #${id} submitted successfully` };
  }

  async getAssignmentSummary(assignmentId: number) {
    const reviews = await this.reviewRepo
      .createQueryBuilder('pr')
      .leftJoinAndSelect('pr.reviewer', 'reviewer')
      .leftJoinAndSelect('pr.reviewee', 'reviewee')
      .innerJoin('assignment_submissions', 'sub', 'sub.submission_id = pr.submission_id')
      .where('sub.assignment_id = :assignmentId', { assignmentId })
      .orderBy('pr.revieweeId', 'ASC')
      .getMany();

    const total = reviews.length;
    const submitted = reviews.filter((r) => r.status === 'submitted').length;
    const pending = reviews.filter((r) => r.status === 'pending').length;

    return {
      data: {
        assignmentId,
        total,
        submitted,
        pending,
        reviews,
      },
    };
  }
}
