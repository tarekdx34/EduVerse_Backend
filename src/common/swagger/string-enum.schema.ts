import { ApiPropertyOptional } from '@nestjs/swagger';
import type { ApiPropertyOptions } from '@nestjs/swagger';

/**
 * OpenAPI schema for TypeScript string enums.
 * Passing `enum: MyEnum` into @ApiQuery / @ApiPropertyOptional breaks @nestjs/swagger when
 * reflected `type` stays as the enum object (merged metadata), which is mistaken for an object schema.
 */
export function stringEnumSchema<T extends Record<string, string>>(enumeration: T) {
  return {
    type: 'string' as const,
    enum: Object.values(enumeration),
  };
}

type StringEnumRecord = Record<string, string>;

/**
 * @ApiPropertyOptional with `schema` (some @nestjs/swagger typings omit `schema`; cast once here).
 */
export function ApiPropertyStringEnumOptional(
  options: Omit<ApiPropertyOptions, 'enum' | 'type'> & {
    enumObject: StringEnumRecord;
  },
): PropertyDecorator {
  const { enumObject, ...rest } = options;
  // `type: String` overrides reflected TS enum metadata; otherwise @nestjs/swagger treats the enum
  // object as an OpenAPI object schema and fails on keys like LOGIN, ACTIVE, etc.
  return ApiPropertyOptional({
    ...rest,
    type: String,
    schema: stringEnumSchema(enumObject),
  } as ApiPropertyOptions);
}
