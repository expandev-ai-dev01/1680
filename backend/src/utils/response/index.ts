/**
 * @summary Response formatting utilities
 * @description Standardized response formats for API endpoints
 */

export interface SuccessResponse<T> {
  success: true;
  data: T;
  metadata?: {
    page?: number;
    pageSize?: number;
    total?: number;
    timestamp: string;
  };
}

export interface ErrorResponse {
  success: false;
  error: {
    message: string;
    details?: any;
  };
  timestamp: string;
}

/**
 * @summary Creates a standardized success response
 *
 * @param data Response data
 * @param metadata Optional metadata
 * @returns Formatted success response
 */
export function successResponse<T>(data: T, metadata?: any): SuccessResponse<T> {
  return {
    success: true,
    data,
    metadata: {
      ...metadata,
      timestamp: new Date().toISOString(),
    },
  };
}

/**
 * @summary Creates a standardized error response
 *
 * @param message Error message
 * @param details Optional error details
 * @returns Formatted error response
 */
export function errorResponse(message: string, details?: any): ErrorResponse {
  return {
    success: false,
    error: {
      message,
      details,
    },
    timestamp: new Date().toISOString(),
  };
}
