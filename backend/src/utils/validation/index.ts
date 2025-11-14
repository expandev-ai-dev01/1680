import { z } from 'zod';

/**
 * @summary Common Zod validation schemas
 * @description Reusable validation schemas for common data types
 */

export const zString = z.string().min(1);
export const zNullableString = (maxLength?: number) => {
  let schema = z.string();
  if (maxLength) {
    schema = schema.max(maxLength);
  }
  return schema.nullable();
};

export const zName = z.string().min(1).max(200);
export const zNullableDescription = z.string().max(500).nullable();

export const zBit = z.number().int().min(0).max(1);

export const zFK = z.number().int().positive();
export const zNullableFK = z.number().int().positive().nullable();

export const zDateString = z.string().datetime();

export const zEmail = z.string().email();

export const zNumeric = (precision: number = 15, scale: number = 2) => {
  return z.number();
};

export const zPrice = z.number();

export default {
  zString,
  zNullableString,
  zName,
  zNullableDescription,
  zBit,
  zFK,
  zNullableFK,
  zDateString,
  zEmail,
  zNumeric,
  zPrice,
};
