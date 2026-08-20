import { defineConfig, devices } from "@playwright/test";

const AUTH_SPECS = /(visual-hubs|validation-p27|redesign-audit|qa-dashboard|claro-multi-contas)\.e2e\.ts/;
const STORAGE_STATE = "e2e/.auth/user.json";
const hasE2ECredentials = Boolean(process.env.E2E_EMAIL && process.env.E2E_PASSWORD);

export default defineConfig({
  testDir: "./e2e",
  testMatch: "**/*.e2e.ts",
  use: { baseURL: "http://127.0.0.1:3000", browserName: "chromium", screenshot: "only-on-failure" },
  webServer: { command: "npm run dev", url: "http://127.0.0.1:3000", reuseExistingServer: !process.env.CI, timeout: 120000 },
  projects: [
    { name: "mobile", use: { ...devices["iPhone 13"] }, testIgnore: AUTH_SPECS },
    { name: "tablet", use: { viewport: { width: 768, height: 1024 } }, testIgnore: AUTH_SPECS },
    { name: "desktop", use: { viewport: { width: 1440, height: 900 } }, testIgnore: AUTH_SPECS },
    ...(hasE2ECredentials
      ? [
          { name: "setup", testMatch: /auth\.setup\.ts/ },
          {
            name: "mobile-auth",
            testMatch: AUTH_SPECS,
            dependencies: ["setup"],
            use: { ...devices["iPhone 13"], storageState: STORAGE_STATE },
          },
          {
            name: "desktop-auth",
            testMatch: AUTH_SPECS,
            dependencies: ["setup"],
            use: { viewport: { width: 1440, height: 900 }, storageState: STORAGE_STATE },
          },
        ]
      : []),
  ],
});
