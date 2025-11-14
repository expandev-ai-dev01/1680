/**
 * @summary Global test setup
 * @description Configuration and utilities for test environment
 */

import { config } from '@/config';

/**
 * @summary Test environment setup
 */
export function setupTestEnvironment(): void {
  process.env.NODE_ENV = 'test';
  process.env.DB_NAME = 'autoclean_test';
}

/**
 * @summary Test environment teardown
 */
export function teardownTestEnvironment(): void {
  // Cleanup logic here
}

export default {
  setupTestEnvironment,
  teardownTestEnvironment,
};
