import { Request, Response, NextFunction } from 'express';
import { z, ZodSchema } from 'zod';
import { errorResponse } from '@/utils/response';

/**
 * @summary Request validation middleware factory
 * @description Creates middleware to validate request data against Zod schema
 *
 * @param schema Zod schema for validation
 * @returns Express middleware function
 */
export function validationMiddleware(schema: ZodSchema) {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      req.body = await schema.parseAsync(req.body);
      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        res.status(400).json(
          errorResponse('Validation failed', {
            errors: error.errors.map((err) => ({
              field: err.path.join('.'),
              message: err.message,
            })),
          })
        );
      } else {
        next(error);
      }
    }
  };
}
