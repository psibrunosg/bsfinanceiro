import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

const page = readFileSync(resolve(process.cwd(), "src/app/ganhos/page.tsx"), "utf8");

describe("Ganhos payslip document import", () => {
  it("keeps manual registration separate from Importar PDF review", () => {
    expect(page).toContain("Cadastrar contracheque");
    expect(page).toContain("Importar PDF");
    expect(page).toContain("create_payslip_document_import");
    expect(page).toContain("apply_payslip_document_import");
    expect(page).toContain('aria-live="polite"');
  });
});
