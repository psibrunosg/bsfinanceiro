export type PayslipCandidate = {
  employer: string;
  competence: string;
  grossAmountCents: number;
  discountsAmountCents: number;
  netAmountCents: number;
  parserName: "payslip";
  parserVersion: "1";
  sourceFingerprint: string;
};

type ParseCode = "unsupported_layout" | "ambiguous_financial_fields";
const fail = (code: ParseCode): never => { throw new Error(code); };

function normalized(value: string) {
  return value.replace(/\r/g, "").split("\n").map((line) => line.replace(/\s+/g, " ").trim()).filter(Boolean).join("\n");
}

function canonical(value: string) {
  return value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toUpperCase();
}

function one(text: string, expression: RegExp) {
  const values = [...text.matchAll(expression)];
  if (values.length !== 1) fail("ambiguous_financial_fields");
  return values[0][1].trim();
}

function cents(value: string) {
  const match = value.trim().match(/^(?:R\$\s*)?([0-9]{1,3}(?:\.[0-9]{3})*|[0-9]+),([0-9]{2})$/);
  if (!match) return fail("ambiguous_financial_fields");
  const result = Number(`${match[1].replaceAll(".", "")}${match[2]}`);
  if (!Number.isSafeInteger(result) || result < 0) fail("ambiguous_financial_fields");
  return result;
}

async function fingerprint(candidate: Omit<PayslipCandidate, "sourceFingerprint">) {
  const data = [candidate.employer, candidate.competence, candidate.grossAmountCents, candidate.discountsAmountCents, candidate.netAmountCents].join("|");
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(data));
  return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
}

export async function parsePayslip(content: string): Promise<PayslipCandidate> {
  const text = normalized(content);
  const folded = canonical(text);
  if (!/(?:^|\n)(?:CONTRACHEQUE|DEMONSTRATIVO DE PAGAMENTO)(?:\n|$)/.test(folded)) fail("unsupported_layout");
  const employer = one(text, /(?:^|\n)EMPREGADOR\s*:\s*([^\n]+)(?=\n|$)/g);
  if (employer.length < 2 || employer.length > 120) fail("ambiguous_financial_fields");
  const competences = [...folded.matchAll(/(?:^|\n)COMPETENCIA\s*:\s*(\d{2})\/(\d{4})(?=\n|$)/g)];
  if (competences.length !== 1) fail("ambiguous_financial_fields");
  const month = Number(competences[0][1]);
  const year = Number(competences[0][2]);
  if (month < 1 || month > 12 || year < 2000 || year > 2100) fail("ambiguous_financial_fields");
  const money = "(?:R\\$\\s*)?([0-9]{1,3}(?:\\.[0-9]{3})*,[0-9]{2}|[0-9]+,[0-9]{2})";
  const grossAmountCents = cents(one(folded, new RegExp(`(?:^|\\n)PROVENTOS\\s+${money}(?=\\n|$)`, "g")));
  const discountsAmountCents = cents(one(folded, new RegExp(`(?:^|\\n)DESCONTOS\\s+${money}(?=\\n|$)`, "g")));
  const netAmountCents = cents(one(folded, new RegExp(`(?:^|\\n)VALOR LIQUIDO\\s+${money}(?=\\n|$)`, "g")));
  if (grossAmountCents - discountsAmountCents !== netAmountCents) fail("ambiguous_financial_fields");
  const candidate: Omit<PayslipCandidate, "sourceFingerprint"> = {
    employer,
    competence: `${year.toString().padStart(4, "0")}-${month.toString().padStart(2, "0")}-01`,
    grossAmountCents,
    discountsAmountCents,
    netAmountCents,
    parserName: "payslip",
    parserVersion: "1",
  };
  return { ...candidate, sourceFingerprint: await fingerprint(candidate) };
}
