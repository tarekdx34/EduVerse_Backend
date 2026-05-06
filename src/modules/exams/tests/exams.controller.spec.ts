import { RoleName } from '../../auth/entities/role.entity';
import { ROLES_KEY } from '../../auth/roles.decorator';
import { ExamDraftsController } from '../exam-drafts.controller';
import { ExamsController } from '../exams.controller';

describe('Exam controllers roles', () => {
  it('keeps every exam endpoint instructor-only', () => {
    for (const controller of [ExamsController, ExamDraftsController]) {
      const methodNames = Object.getOwnPropertyNames(
        controller.prototype,
      ).filter((name) => name !== 'constructor');

      for (const methodName of methodNames) {
        const roles = Reflect.getMetadata(
          ROLES_KEY,
          controller.prototype[methodName],
        );
        expect(roles).toEqual([RoleName.INSTRUCTOR]);
      }
    }
  });
});
