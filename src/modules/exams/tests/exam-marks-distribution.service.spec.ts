import {
  ExamMarkDistributionMode,
  ExamRoundingPolicy,
} from '../entities/exam-draft.entity';
import { makeExamsService } from './exams-test-utils';

describe('Exam mark distribution', () => {
  it('keeps equal distribution totals exact after rounding', () => {
    const { service } = makeExamsService();
    const items = [
      { weight: 1, marks: null },
      { weight: 1, marks: null },
      { weight: 1, marks: null },
    ];

    (service as any).applyMarks(
      items,
      10,
      ExamMarkDistributionMode.EQUAL,
      ExamRoundingPolicy.NEAREST_0_5,
    );

    expect(items.reduce((sum, item) => sum + Number(item.marks), 0)).toBe(10);
  });
});
