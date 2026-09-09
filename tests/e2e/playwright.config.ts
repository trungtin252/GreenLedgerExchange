import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: '.',
  testMatch: 'smoke.spec.ts',
  use: { baseURL: process.env.GLX_E2E_BASE_URL ?? 'http://localhost:5173' }
});
