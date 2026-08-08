import { defineConfig, devices } from "@playwright/test";

// Specs que exigem sessão autenticada (rodam só nos projetos *-auth).
const AUTH_SPECS = /visual-hubs\.e2e\.ts/;
const STORAGE_STATE = "e2e/.auth/user.json";

export default defineConfig({
  testDir: "./e2e",
  testMatch: "**/*.e2e.ts",
  use: { baseURL: "http://127.0.0.1:3000", browserName: "chromium", screenshot: "only-on-failure" },
  webServer: { command: "npm run dev", url: "http://127.0.0.1:3000", reuseExistingServer: !process.env.CI },
  projects: [
    // Faz login uma vez e grava o storageState. Pula sozinho sem credenciais.
    { name: "setup", testMatch: /auth\.setup\.ts/ },

    // Projetos deslogados: nunca carregam o storageState (que pode não existir).
    { name: "mobile", use: { ...devices["iPhone 13"] }, testIgnore: AUTH_SPECS },
    { name: "tablet", use: { viewport: { width: 768, height: 1024 } }, testIgnore: AUTH_SPECS },
    { name: "desktop", use: { viewport: { width: 1440, height: 900 } }, testIgnore: AUTH_SPECS },

    // Projetos autenticados: só os specs autenticados, com sessão do setup.
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
  ],
});
