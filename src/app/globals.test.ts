import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

describe("globals.css design system & responsive layout tokens", () => {
  const css = readFileSync(resolve(process.cwd(), "src/app/globals.css"), "utf8");

  it("keeps critical CSS independent from remote font hosts", () => {
    expect(css).not.toMatch(/https?:\/\/[^\s"')]*fonts\.(?:googleapis|gstatic)\.com/i);
  });

  it("defines Apple HIG glassmorphism and specular tokens in :root", () => {
    expect(css).toContain("--card-glass:");
    expect(css).toContain("--specular-shadow:");
    expect(css).toContain("--border-specular:");
    expect(css).toContain("--radius-pill:9999px");
    expect(css).toContain("backdrop-filter:blur(20px) saturate(180%)");
  });

  it("configures smooth transition on .dashboard-shell for sidebar toggles", () => {
    expect(css).toMatch(/\.dashboard-shell\s*\{[^}]*transition:[^}]*margin-left/);
    expect(css).toMatch(/\.dashboard-shell\s*\{[^}]*transition:[^}]*width/);
  });

  it("declares responsive bento grid classes without inline style requirements", () => {
    expect(css).toContain(".bento-row--4");
    expect(css).toContain(".bento-row--3");
    expect(css).toContain(".bento-row--2");
    expect(css).toContain(".bento-row--filters");
  });

  it("adapts bento-row--4 and filters on intermediate viewports (<= 1280px)", () => {
    expect(css).toContain("@media(max-width:1280px)");
    expect(css).toContain(".bento-row--4{grid-template-columns:repeat(2,1fr)}");
    expect(css).toContain(".bento-row--filters{grid-template-columns:repeat(2,1fr)}");
  });
});
