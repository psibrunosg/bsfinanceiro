import fs from "node:fs";
import path from "node:path";
import { describe, expect, it } from "vitest";

const root = process.cwd();
const read = (relative: string) =>
  fs.readFileSync(path.join(root, relative), "utf8");

describe("VPS deploy security regressions", () => {
  it("never exports PHP source from Next public assets", () => {
    expect(fs.existsSync(path.join(root, "public", "api.php"))).toBe(false);
    expect(fs.existsSync(path.join(root, "public", "index.php"))).toBe(false);
    expect(fs.existsSync(path.join(root, "server", "api.php"))).toBe(true);
  });

  it("blocks php files at the static frontend nginx boundary", () => {
    const nginx = read("deploy/nginx.conf");
    expect(nginx).toMatch(/location\s+~\*\s+\\?\.php\$/);
    expect(nginx).toContain("return 404;");
  });

  it("keeps heavy local artifacts out of Docker build contexts", () => {
    const dockerignore = read(".dockerignore");
    for (const entry of [
      "node_modules",
      ".next",
      "out",
      "test-results",
      "work",
      ".git",
      ".env",
    ]) {
      expect(dockerignore.split(/\r?\n/)).toContain(entry);
    }
  });

  it("copies only the PHP server runtime into the API image", () => {
    const dockerfile = read("deploy/api.Dockerfile");
    expect(dockerfile).toContain("COPY server ./server");
    expect(dockerfile).not.toMatch(/^COPY\s+\.\s+\.$/m);
  });

  it("guards private API routes before the workspace bootstrap", () => {
    const api = read("server/api.php");
    const globalGuard = api.indexOf("$sessionUser = requireSessionUser($db);");
    const bootstrap = api.indexOf("if ($uri === '/bootstrap'");
    expect(globalGuard).toBeGreaterThan(-1);
    expect(bootstrap).toBeGreaterThan(globalGuard);
    expect(api).toContain("requireWorkspaceAccess($db, $sessionUser['id'], $requestedWorkspaceId)");
  });

  it("does not echo raw registration credentials on validation errors", () => {
    const api = read("server/api.php");
    expect(api).not.toContain("'received' => $body");
    expect(api).not.toContain("'raw' => $rawInput");
  });
});
