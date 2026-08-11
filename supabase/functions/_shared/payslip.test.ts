import { describe, expect, it } from "vitest";
import { parsePayslip } from "./payslip";
import { extractSelectablePdfText } from "./pdf-text";
import { textualPdfWithText } from "./pdf-test-fixture";

const payslip = `
  CONTRACHEQUE
  EMPREGADOR: ACME SERVIÇOS LTDA
  COMPETÊNCIA: 07/2026
  PROVENTOS R$ 5.000,00
  DESCONTOS R$ 1.250,00
  VALOR LÍQUIDO R$ 3.750,00
`;

describe("parsePayslip", () => {
  it("parses the allow-listed textual payslip into integer cents", async () => {
    await expect(parsePayslip(payslip)).resolves.toMatchObject({
      employer: "ACME SERVIÇOS LTDA",
      competence: "2026-07-01",
      grossAmountCents: 500000,
      discountsAmountCents: 125000,
      netAmountCents: 375000,
      parserName: "payslip",
      parserVersion: "1",
    });
  });

  it("produces a stable SHA-256 fingerprint", async () => {
    const first = await parsePayslip(payslip);
    const second = await parsePayslip(payslip.replace("PROVENTOS R$", "PROVENTOS\nR$"));
    expect(first.sourceFingerprint).toMatch(/^[a-f0-9]{64}$/);
    expect(second.sourceFingerprint).toBe(first.sourceFingerprint);
  });

  it("parses the flattened text returned by the selectable-PDF extractor", async () => {
    const fixture = `CONTRACHEQUE\nEMPREGADOR: ACME SERVICOS LTDA\nCOMPETENCIA: 07/2026\nPROVENTOS R$ 5.000,00\nDESCONTOS R$ 1.250,00\nVALOR LIQUIDO R$ 3.750,00`;
    const { text } = await extractSelectablePdfText(textualPdfWithText(fixture));
    await expect(parsePayslip(text)).resolves.toMatchObject({
      employer: "ACME SERVICOS LTDA",
      competence: "2026-07-01",
      netAmountCents: 375000,
    });
  });

  it.each([
    [payslip.replace("CONTRACHEQUE", "EXTRATO BANCÁRIO"), "unsupported_layout"],
    [payslip.replace("DESCONTOS R$ 1.250,00", ""), "ambiguous_financial_fields"],
    [payslip.replace("07/2026", "13/2026"), "ambiguous_financial_fields"],
    [payslip.replace("3.750,00", "3.749,99"), "ambiguous_financial_fields"],
    [payslip.replace("5.000,00", "-5.000,00"), "ambiguous_financial_fields"],
  ])("fails closed for invalid document data", async (text, code) => {
    await expect(parsePayslip(text)).rejects.toThrow(code);
  });
});
