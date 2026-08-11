export type CardStatementCandidate = {
  ordinal: number;
  purchasedOn: string;
  description: string;
  installmentAmountCents: number;
  installmentNumber: number;
  installmentCount: number;
  totalAmountCents: number | null;
  needsReview: boolean;
  sourceFingerprint: string;
};

export type SantanderStatement = {
  parserName: "santander";
  parserVersion: "1";
  closingDate: string;
  dueDate: string;
  declaredTotalCents: number;
  items: CardStatementCandidate[];
};

const MONEY = "(?:R\\$\\s*)?([0-9]{1,3}(?:\\.[0-9]{3})*,[0-9]{2}|[0-9]+,[0-9]{2})";

function fail(code: "unsupported_layout" | "ambiguous_financial_fields"): never {
  throw new Error(code);
}

function normalizedText(value: string) {
  return value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/\s+/g, " ").trim().toUpperCase();
}

export function parseBrazilianCurrencyCents(value: string): number {
  const match = value.trim().match(/^(?:R\$\s*)?([0-9]{1,3}(?:\.[0-9]{3})*|[0-9]+),([0-9]{2})$/);
  if (!match) fail("ambiguous_financial_fields");
  const cents = Number(`${match[1].replaceAll(".", "")}${match[2]}`);
  if (!Number.isSafeInteger(cents) || cents <= 0) fail("ambiguous_financial_fields");
  return cents;
}

function isoDate(day: number, month: number, year: number): string {
  const lastDay = new Date(year, month, 0).getDate();
  if (year < 2000 || year > 2100 || month < 1 || month > 12 || day < 1 || day > lastDay) fail("ambiguous_financial_fields");
  return `${year.toString().padStart(4, "0")}-${month.toString().padStart(2, "0")}-${day.toString().padStart(2, "0")}`;
}

function parseFullDate(value: string): string {
  const [day, month, year] = value.split("/").map(Number);
  return isoDate(day, month, year);
}

function purchaseDate(value: string, closingDate: string): string {
  const [day, month, explicitYear] = value.split("/").map(Number);
  if (explicitYear) return isoDate(day, month, explicitYear);
  const closingYear = Number(closingDate.slice(0, 4));
  const closingMonth = Number(closingDate.slice(5, 7));
  return isoDate(day, month, month > closingMonth ? closingYear - 1 : closingYear);
}

function singleMatch(text: string, pattern: RegExp): RegExpMatchArray {
  const matches = [...text.matchAll(pattern)];
  if (matches.length !== 1) fail("ambiguous_financial_fields");
  return matches[0];
}

async function fingerprint(item: Omit<CardStatementCandidate, "sourceFingerprint">): Promise<string> {
  const canonical = [item.ordinal, item.purchasedOn, item.description, item.installmentAmountCents, item.installmentNumber, item.installmentCount, item.totalAmountCents ?? "missing"].join("|");
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(canonical));
  return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
}

export async function parseSantanderStatement(content: string): Promise<SantanderStatement> {
  const text = normalizedText(content);
  if (!/^SANTANDER FATURA DO CARTAO\b/.test(text)) fail("unsupported_layout");
  const closingDate = parseFullDate(singleMatch(text, /\bFECHAMENTO\s+(\d{2}\/\d{2}\/\d{4})\b/g)[1]);
  const dueDate = parseFullDate(singleMatch(text, /\bVENCIMENTO\s+(\d{2}\/\d{2}\/\d{4})\b/g)[1]);
  const declaredTotalCents = parseBrazilianCurrencyCents(singleMatch(text, new RegExp(`\\bTOTAL DA FATURA\\s+${MONEY}\\b`, "g"))[1]);
  if (dueDate < closingDate) fail("ambiguous_financial_fields");
  const section = singleMatch(text, /\bCOMPRAS\s+(.+?)\s+FIM DAS COMPRAS\b/g)[1];
  const rawItems = [...section.matchAll(/(?:^|\s)COMPRA\s+(\d{2}\/\d{2}(?:\/\d{4})?)\s+(.+?)(?=\s+COMPRA\s+\d{2}\/\d{2}(?:\/\d{4})?\s+|$)/g)];
  if (!rawItems.length || rawItems.length > 500) fail("ambiguous_financial_fields");
  const items: CardStatementCandidate[] = [];
  for (const [index, raw] of rawItems.entries()) {
    const match = raw[2].match(new RegExp(`^(.+?)\\s+(?:(\\d{2})\\/(\\d{2})\\s+)?${MONEY}(?:\\s+TOTAL DA COMPRA\\s+${MONEY})?$`));
    if (!match || /\b(?:\d{2}\/\d{2}|TOTAL DA COMPRA)\b/.test(match[1])) fail("ambiguous_financial_fields");
    const installmentNumber = match[2] ? Number(match[2]) : 1;
    const installmentCount = match[3] ? Number(match[3]) : 1;
    if (installmentNumber < 1 || installmentCount < 1 || installmentNumber > installmentCount || installmentCount > 120) fail("ambiguous_financial_fields");
    const installmentAmountCents = parseBrazilianCurrencyCents(match[4]);
    const parsedTotal = match[5] ? parseBrazilianCurrencyCents(match[5]) : null;
    const totalAmountCents = installmentCount === 1 ? installmentAmountCents : parsedTotal;
    if (totalAmountCents !== null && totalAmountCents < installmentAmountCents) fail("ambiguous_financial_fields");
    const item = { ordinal: index + 1, purchasedOn: purchaseDate(raw[1], closingDate), description: match[1].trim(), installmentAmountCents, installmentNumber, installmentCount, totalAmountCents, needsReview: installmentCount > 1 && totalAmountCents === null };
    items.push({ ...item, sourceFingerprint: await fingerprint(item) });
  }
  if (items.length !== (section.match(/\bCOMPRA\s+\d{2}\/\d{2}/g) || []).length) fail("ambiguous_financial_fields");
  return { parserName: "santander", parserVersion: "1", closingDate, dueDate, declaredTotalCents, items };
}
