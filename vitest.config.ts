import { fileURLToPath } from "node:url";
import { defineConfig } from "vitest/config";

export default defineConfig({
  esbuild: { jsx: "automatic" },
  test: {
    // Sem isto, um git worktree em .claude/worktrees faz o vitest rodar a
    // suite duas vezes e reportar falhas de outra branch como se fossem daqui.
    exclude: ["**/node_modules/**", "**/dist/**", "**/out/**", "**/.next/**", "**/.claude/worktrees/**", "**/e2e/**", "**/.agents/**"],
  },
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
  },
});
