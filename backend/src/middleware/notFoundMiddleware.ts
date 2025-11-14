import { Request, Response } from 'express';
import { errorResponse } from '@/utils/response';

/**
 * @summary 404 Not Found middleware
 * @description Handles requests to non-existent routes
 *
 * @param req Express request object
 * @param res Express response object
 */
export function notFoundMiddleware(req: Request, res: Response): void {
  res.status(404).json(
    errorResponse('Route not found', {
      path: req.path,
      method: req.method,
    })
  );
}
