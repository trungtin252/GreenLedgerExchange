import { defineConfig } from "@playwright/test";

const externalBaseUrl = process.env.GLX_E2E_BASE_URL;
const localBaseUrl = "http://127.0.0.1:5173";

export default defineConfig({
  testDir: ".",
  testMatch: "smoke.spec.ts",
  use: { baseURL: externalBaseUrl ?? localBaseUrl },
  webServer: externalBaseUrl
    ? undefined
    : {
        command: "pnpm --filter @glx/web-portal run dev",
        url: localBaseUrl,
        reuseExistingServer: !process.env.CI,
        timeout: 120_000,
      },
});
