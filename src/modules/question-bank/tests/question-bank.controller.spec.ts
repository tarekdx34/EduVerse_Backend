import { RoleName } from '../../auth/entities/role.entity';
import { ROLES_KEY } from '../../auth/roles.decorator';
import { QuestionBankController } from '../question-bank.controller';

describe('QuestionBankController roles', () => {
  it('keeps every endpoint instructor-only', () => {
    const methodNames = Object.getOwnPropertyNames(
      QuestionBankController.prototype,
    ).filter((name) => name !== 'constructor');

    for (const methodName of methodNames) {
      const roles = Reflect.getMetadata(
        ROLES_KEY,
        QuestionBankController.prototype[methodName],
      );
      expect(roles).toEqual([RoleName.INSTRUCTOR]);
    }
  });
});
