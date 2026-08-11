export type CardStatementCandidate = { ordinal: number; purchasedOn: string; description: string; installmentAmountCents: number; installmentNumber: number; installmentCount: number; totalAmountCents: number | null; needsReview: boolean; sourceFingerprint: string };
export type SantanderStatement = { parserName: "santander"; parserVersion: "1"; closingDate: string; dueDate: string; declaredTotalCents: number; items: CardStatementCandidate[] };
const MONEY = "(?:R\\$\\s*)?([0-9]{1,3}(?:\\.[0-9]{3})*,[0-9]{2}|[0-9]+,[0-9]{2})";
function fail(code: "unsupported_layout" | "ambiguous_financial_fields"): never { throw new Error(code); }
function normalized(value: string) { return value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").split(/\r?\n/).map((line) => line.replace(/\s+/g, " ").trim().toUpperCase()).filter(Boolean).join("\n"); }
export function parseBrazilianCurrencyCents(value: string): number { const match = value.trim().match(/^(?:R\$\s*)?([0-9]{1,3}(?:\.[0-9]{3})*|[0-9]+),([0-9]{2})$/); if (!match) fail("ambiguous_financial_fields"); const cents = Number(`${match[1].replaceAll(".", "")}${match[2]}`); if (!Number.isSafeInteger(cents) || cents <= 0) fail("ambiguous_financial_fields"); return cents; }
function isoDate(day: number, month: number, year: number) { const last = new Date(year, month, 0).getDate(); if (year < 2000 || year > 2100 || month < 1 || month > 12 || day < 1 || day > last) fail("ambiguous_financial_fields"); return `${year.toString().padStart(4,"0")}-${month.toString().padStart(2,"0")}-${day.toString().padStart(2,"0")}`; }
function fullDate(value: string) { const [day,month,year] = value.split("/").map(Number); return isoDate(day,month,year); }
function dateInStatement(value: string, anchor: string) { const [day,month,year] = value.split("/").map(Number); if (year) return isoDate(day,month,year); const anchorYear = Number(anchor.slice(0,4)); const anchorMonth = Number(anchor.slice(5,7)); return isoDate(day,month,month > anchorMonth ? anchorYear - 1 : anchorYear); }
function once(text: string, pattern: RegExp) { const matches = [...text.matchAll(pattern)]; if (matches.length !== 1) fail("ambiguous_financial_fields"); return matches[0]; }
async function fingerprint(item: Omit<CardStatementCandidate,"sourceFingerprint">) { const value = [item.ordinal,item.purchasedOn,item.description,item.installmentAmountCents,item.installmentNumber,item.installmentCount,item.totalAmountCents ?? "missing"].join("|"); const digest = await crypto.subtle.digest("SHA-256",new TextEncoder().encode(value)); return Array.from(new Uint8Array(digest),byte => byte.toString(16).padStart(2,"0")).join(""); }

export async function parseSantanderStatement(content: string): Promise<SantanderStatement> {
  const text = normalized(content);
  if (!/\bESTA E A FATURA DO SEU CARTAO SANTANDER\b/.test(text)) fail("unsupported_layout");
  const dueDate = fullDate(once(text,/\bVENCIMENTO\s+(\d{2}\/\d{2}\/\d{4})\b/g)[1]);
  const closingDate = dateInStatement(once(text,/\bCOMPRAS E PAGAMENTOS REALIZADOS ATE\s+(\d{2}\/\d{2})\b/g)[1],dueDate);
  const declaredTotalCents = parseBrazilianCurrencyCents(once(text,new RegExp(`\\bTOTAL A PAGAR\\s+${MONEY}\\b`,"g"))[1]);
  if (dueDate < closingDate) fail("ambiguous_financial_fields");
  const ledgerMatch = text.includes("\n")
    ? text.match(/\bLANCAMENTOS\s*\n([\s\S]*?)(?=\n(?:LIMITES|FORMAS DE PAGAMENTO|MENSAGENS)\b|$)/)
    : text.match(/\bLANCAMENTOS\s+(.+?)(?=\s+(?:LIMITES|FORMAS DE PAGAMENTO|MENSAGENS)\b|$)/);
  if (!ledgerMatch) fail("ambiguous_financial_fields");
  const ledger = ledgerMatch[1];
  const rows: Array<{ date: string; body: string }> = [];
  if (ledger.includes("\n")) {
    for (const line of ledger.split("\n").map((value) => value.trim()).filter(Boolean)) {
      const total = line.match(new RegExp(`^TOTAL DA COMPRA\\s+${MONEY}$`));
      if (total) {
        const previous = rows.at(-1);
        if (!previous || /\bTOTAL DA COMPRA\b/.test(previous.body)) fail("ambiguous_financial_fields");
        previous.body += ` TOTAL DA COMPRA R$ ${total[1]}`;
        continue;
      }
      const item = line.match(/^(\d{2}\/\d{2}(?:\/\d{4})?)\s+(.+)$/);
      if (!item) fail("ambiguous_financial_fields");
      rows.push({ date: item[1], body: item[2] });
    }
  } else {
    rows.push(...[...ledger.matchAll(new RegExp(`(?:^|\\s)(\\d{2}\\/\\d{2}(?:\\/\\d{4})?)\\s+(.+?)\\s+(?:(\\d{2})\\/(\\d{2})\\s+)?${MONEY}(?:\\s+TOTAL DA COMPRA\\s+${MONEY})?(?=\\s+\\d{2}\\/\\d{2}\\s+(?!R\\$)[A-Z]|$)`, "g"))]
      .map((row) => ({ date: row[1], body: `${row[2]}${row[3] ? ` ${row[3]}/${row[4]}` : ""} R$ ${row[5]}${row[6] ? ` TOTAL DA COMPRA R$ ${row[6]}` : ""}` })));
  }
  if (!rows.length || rows.length > 500) fail("ambiguous_financial_fields");
  const items: CardStatementCandidate[] = [];
  for (const [index,row] of rows.entries()) {
    const withInstallment = row.body.match(new RegExp(`^(.+?)\\s+(\\d{2})\\/(\\d{2})\\s+${MONEY}(?:\\s+TOTAL DA COMPRA\\s+${MONEY})?$`));
    const cash = row.body.match(new RegExp(`^(.+?)\\s+${MONEY}$`));
    const match = withInstallment || cash;
    if (!match || /\b(?:TOTAL DA COMPRA|\d{2}\/\d{2})\b/.test(match[1])) fail("ambiguous_financial_fields");
    const installmentNumber = withInstallment ? Number(match[2]) : 1; const installmentCount = withInstallment ? Number(match[3]) : 1;
    if (installmentNumber < 1 || installmentCount < 1 || installmentNumber > installmentCount || installmentCount > 120) fail("ambiguous_financial_fields");
    const installmentAmountCents = parseBrazilianCurrencyCents(match[withInstallment ? 4 : 2]); const parsedTotal = withInstallment && match[5] ? parseBrazilianCurrencyCents(match[5]) : null; const totalAmountCents = installmentCount === 1 ? installmentAmountCents : parsedTotal;
    if (totalAmountCents !== null && totalAmountCents < installmentAmountCents) fail("ambiguous_financial_fields");
    const item = { ordinal:index+1,purchasedOn:dateInStatement(row.date,closingDate),description:match[1].trim(),installmentAmountCents,installmentNumber,installmentCount,totalAmountCents,needsReview:installmentCount > 1 && totalAmountCents === null };
    items.push({ ...item, sourceFingerprint:await fingerprint(item) });
  }
  if (!ledger.includes("\n") && !rows.length) fail("ambiguous_financial_fields");
  return { parserName:"santander",parserVersion:"1",closingDate,dueDate,declaredTotalCents,items };
}
