import { describe, expect, test } from "vitest";
import { parseOfxStatement } from "./statement-ofx";

const OFX_SGML = `
OFXHEADER:100
DATA:OFXSGML
VERSION:230
<OFX>
  <SIGNONMSGSRSV1><SONRS><STATUS><CODE>0<SEVERITY>INFO</SONRS>
  <BANKMSGSRSV1><STMTTRNRS><STMTRS>
    <BANKACCTFROM><BANKID>001<ACCTID>123456<ACCTTYPE>CHECKING</BANKACCTFROM>
    <STMTRS>
      <CURDEF>BRL
      <BANKTRANLIST>
        <STMTTRN>
          <TRNTYPE>DEBIT
          <DTPOSTED>20260715
          <TRNAMT>-42.50
          <NAME>Compra de teste
          <FITID>001
        </STMTTRN>
        <STMTTRN>
          <TRNTYPE>CREDIT
          <DTPOSTED>20260720
          <TRNAMT>3000.00
          <NAME>Salario
          <FITID>002
        </STMTTRN>
        <STMTTRN>
          <TRNTYPE>DEBIT
          <DTPOSTED>20260725120000
          <TRNAMT>-150,75
          <NAME>Transferencia PIX
          <FITID>003
        </STMTTRN>
      </BANKTRANLIST>
    </STMTRS>
  </STMTTRNRS>
</OFX>`;

const OFX_XML = `<?xml version="1.0" encoding="UTF-8"?>
<OFX>
  <BANKMSGSRSV1>
    <STMTTRNRS>
      <STMTRS>
        <BANKTRANLIST>
          <STMTTRN>
            <TRNTYPE>DEBIT</TRNTYPE>
            <DTPOSTED>20260801</DTPOSTED>
            <TRNAMT>-89.90</TRNAMT>
            <NAME>Supermercado</NAME>
          </STMTTRN>
        </BANKTRANLIST>
      </STMTRS>
    </STMTTRNRS>
  </BANKMSGSRSV1>
</OFX>`;

describe("parseOfxStatement", () => {
  test("parseia formato SGML com transações", () => {
    const items = parseOfxStatement(OFX_SGML);
    expect(items).toHaveLength(3);
  });

  test("extrai dados corretos de transação SGML", () => {
    const items = parseOfxStatement(OFX_SGML);
    const debit = items.find((i) => i.description === "Compra de teste")!;
    expect(debit.competenceDate).toBe("2026-07-15");
    expect(debit.amountCents).toBe(4250);
    expect(debit.type).toBe("expense");
  });

  test("credito é classificado como income", () => {
    const items = parseOfxStatement(OFX_SGML);
    const credit = items.find((i) => i.description === "Salario")!;
    expect(credit.type).toBe("income");
    expect(credit.amountCents).toBe(300000);
  });

  test("trata data com hora YYYYMMDDHHMMSS", () => {
    const items = parseOfxStatement(OFX_SGML);
    const pix = items.find((i) => i.description === "Transferencia PIX")!;
    expect(pix.competenceDate).toBe("2026-07-25");
    expect(pix.amountCents).toBe(15075);
  });

  test("parseia formato XML", () => {
    const items = parseOfxStatement(OFX_XML);
    expect(items).toHaveLength(1);
    expect(items[0].description).toBe("Supermercado");
    expect(items[0].amountCents).toBe(8990);
    expect(items[0].type).toBe("expense");
  });

  test("ignora blocos STMTTRN incompletos", () => {
    const ofx = `<OFX><STMTTRN><TRNTYPE>DEBIT</STMTTRN></OFX>`;
    const items = parseOfxStatement(ofx);
    expect(items).toHaveLength(0);
  });

  test("retorna vazio para OFX sem transações", () => {
    const items = parseOfxStatement("<OFX></OFX>");
    expect(items).toHaveLength(0);
  });

  test("retorna vazio para string vazia", () => {
    const items = parseOfxStatement("");
    expect(items).toHaveLength(0);
  });

  test("gera fingerprint determinístico", () => {
    const items = parseOfxStatement(OFX_SGML);
    const item = items[0];
    expect(item.fingerprint).toMatch(/^\d{4}-\d{2}-\d{2}\|\d+\|expense\|/);
  });
});
