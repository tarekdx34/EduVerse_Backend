/**
 * Translation Service Interface
 *
 * Stub for Sprint 1 — full implementation in Sprint 5 (Localization Module).
 * All modules should accept Accept-Language header from day one.
 */
export interface ITranslationService {
  applyTranslations<T>(
    entities: T[],
    entityType: string,
    lang: string,
  ): Promise<T[]>;
  getTranslation(
    entityType: string,
    entityId: number,
    field: string,
    lang: string,
  ): Promise<string>;
  setTranslation(
    entityType: string,
    entityId: number,
    field: string,
    lang: string,
    value: string,
  ): Promise<void>;
}
