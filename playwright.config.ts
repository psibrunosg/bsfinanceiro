import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./e2e",
  testMatch: "**/*.e2e.ts",
  use: { baseURL: "http://127.0.0.1:3000", browserName: "chromium", screenshot: "only-on-failure" },
  webServer: { command: "npm run dev", url: "http://127.0.0.1:3000", reuseExistingServer: !process.env.CI },
  projects: [
    { name: "mobile", use: { viewport: { width: 375, height: 667 }, isMobile: true } },
    { name: "tablet", use: { viewport: { width: 768, height: 1024 } } },
    { name: "laptop", use: { viewport: { width: 1024, height: 768 } } },
    { name: "desktop", use: { viewport: { width: 1440, height: 900 } } },
  ],
});
