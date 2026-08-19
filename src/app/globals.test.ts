import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { expect, it } from "vitest";

it("keeps critical CSS independent from remote font hosts", () => {
  const css = readFileSync(resolve(process.cwd(), "src/app/globals.css"), "utf8");

  expect(css).not.toMatch(/https?:\/\/[^\s"')]*fonts\.(?:googleapis|gstatic)\.com/i);
});
