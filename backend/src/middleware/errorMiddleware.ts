import { Request, Response, NextFunction } from 'express';
import { errorResponse } from '@/utils/response';

/**
 * @summary Global error handling middleware
 * @description Catches and formats all errors in the application
 *
 * @param error Error object
 * @param req Express request object
 * @param res Express response object
 * @param next Express next function
 */
export function errorMiddleware(error: any, req: Request, res: Response, next: NextFunction): void {
  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal server error';

  console.error('Error:', {
    message: error.message,
    stack: error.stack,
    path: req.path,
    method: req.method,
  });

  res.status(statusCode).json(
    errorResponse(message, {
      path: req.path,
      method: req.method,
      timestamp: new Date().toISOString(),
    })
  );
}
