export class QuestionBankGroupSummaryDto {
  groupItemId: number;
  groupId: number;
  itemOrder: number;
  courseId: number;
  chapterId: number | null;
  title: string | null;
  sharedPrompt: string | null;
  sharedFileId: number | null;
  sharedFileCaption: string | null;
  sharedFileAltText: string | null;
  groupType: string;
}

export class QuestionBankPrivateResponseDto {
  id: number;
  questionId: number;
  courseId: number;
  chapterId: number;
  questionType: string;
  difficulty: string;
  bloomLevel: string;
  status: string;
  questionText: string | null;
  questionFileId: number | null;
  questionImageUrl: string | null;
  questionFileCaption: string | null;
  questionFileAltText: string | null;
  expectedAnswerText: string | null;
  hints: string | null;
  options?: unknown[];
  fillBlanks?: unknown[];
  attachments?: unknown[];
  groups?: QuestionBankGroupSummaryDto[];
  createdAt: Date;
  updatedAt: Date;
  createdBy: number;
}
