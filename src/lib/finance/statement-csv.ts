export type StatementCsvMapping = {
  date?: string;
  description?: string;
  amount?: string;
};

export type StatementCsvValidItem = {
  rowNumber: number;
  competenceDate: string;
  description: string;
  amountCents: number;
  type: "income" | "expense";
  fingerprint: string;
};

export type StatementCsvInvalidItem = {
  rowNumber: number;
  reason: "missing_mapping" | "invalid_date" | "missing_description" | "invalid_description" | "invalid_amount";
};

export type StatementCsvPreview = {
  headers: string[];
  items: Array<StatementCsvValidItem | StatementCsvInvalidItem>;
  valid: number;
  invalid: number;
};

const HEADER_ALIASES = {
  date: ["date", "data", "data lancamento", "lancamento"],
  description: ["description", "descricao", "historico", "narrativa"],
  amount: ["amount", "valor", "value", "valor r"],
} as const;
export const STATEMENT_IMPORT_MAX_AMOUNT_CENTS = 99_999_999_999_999;

export function parseStatementCsv(input: string, mapping: StatementCsvMapping = {}): StatementCsvPreview {
  const rows = parseRows(input.replace(/^\uFEFF/, ""));
  const [headerRow, ...dataRows] = rows;
  const headers = headerRow?.map((header) => header.trim()) ?? [];
  const indexes = resolveIndexes(headers, mapping);
  const items = dataRows.flatMap<StatementCsvValidItem | StatementCsvInvalidItem>((row, offset) => {
    const rowNumber = offset + 2;
    const values = normalizeRowLength(row, headers.length, indexes.amount);

    if (values.every((value) => value.trim() === "")) return [];
    if (indexes.date === undefined || indexes.description === undefined || indexes.amount === undefined) {
      return [{ rowNumber, reason: "missing_mapping" as const }];
    }

    const competenceDate = parseDate(values[indexes.date]);
    if (!competenceDate) return [{ rowNumber, reason: "invalid_date" as const }];

    const description = values[indexes.description]?.trim();
    if (!description) return [{ rowNumber, reason: "missing_description" as const }];
    if (description.length > 160) return [{ rowNumber, reason: "invalid_description" as const }];

    const signedAmountCents = parseAmountCents(values[indexes.amount]);
    if (signedAmountCents === undefined || signedAmountCents === 0 || Math.abs(signedAmountCents) > STATEMENT_IMPORT_MAX_AMOUNT_CENTS) {
      return [{ rowNumber, reason: "invalid_amount" as const }];
    }

    const type = signedAmountCents > 0 ? "income" : "expense";
    const amountCents = Math.abs(signedAmountCents);
    return [{
      rowNumber,
      competenceDate,
      description,
      amountCents,
      type,
      fingerprint: statementTransactionFingerprint(competenceDate, amountCents, type, description),
    }];
  });

  const valid = items.filter((item): item is StatementCsvValidItem => "amountCents" in item).length;
  return { headers, items, valid, invalid: items.length - valid };
}

function resolveIndexes(headers: string[], mapping: StatementCsvMapping): Record<keyof StatementCsvMapping, number | undefined> {
  return {
    date: findHeader(headers, mapping.date, HEADER_ALIASES.date),
    description: findHeader(headers, mapping.description, HEADER_ALIASES.description),
    amount: findHeader(headers, mapping.amount, HEADER_ALIASES.amount),
  };
}

function findHeader(headers: string[], selected: string | undefined, aliases: readonly string[]): number | undefined {
  if (selected) {
    const index = headers.findIndex((header) => header === selected);
    return index === -1 ? undefined : index;
  }

  const index = headers.findIndex((header) => aliases.includes(normalizeText(header)));
  return index === -1 ? undefined : index;
}

function normalizeRowLength(row: string[], headerLength: number, amountIndex: number | undefined): string[] {
  if (row.length <= headerLength || amountIndex === undefined || amountIndex !== headerLength - 1) return row;

  return [...row.slice(0, amountIndex), row.slice(amountIndex).join(",")];
}

function parseRows(input: string): string[][] {
  const delimiter = detectDelimiter(input);
  const rows: string[][] = [];
  let row: string[] = [];
  let field = "";
  let quoted = false;

  for (let index = 0; index < input.length; index += 1) {
    const character = input[index];
    if (character === '"') {
      if (quoted && input[index + 1] === '"') {
        field += '"';
        index += 1;
      } else {
        quoted = !quoted;
      }
    } else if (!quoted && character === delimiter) {
      row.push(field);
      field = "";
    } else if (!quoted && (character === "\n" || character === "\r")) {
      if (character === "\r" && input[index + 1] === "\n") index += 1;
      row.push(field);
      rows.push(row);
      row = [];
      field = "";
    } else {
      field += character;
    }
  }

  if (field !== "" || row.length > 0) rows.push([...row, field]);
  return rows;
}

function detectDelimiter(input: string): "," | ";" {
  const header = input.split(/\r?\n/, 1)[0] ?? "";
  return header.split(";").length > header.split(",").length ? ";" : ",";
}

function parseDate(value: string | undefined): string | undefined {
  const match = value?.trim().match(/^(?:(\d{4})-(\d{2})-(\d{2})|(\d{2})\/(\d{2})\/(\d{4}))$/);
  if (!match) return undefined;

  const [, isoYear, isoMonth, isoDay, brDay, brMonth, brYear] = match;
  const year = Number(isoYear ?? brYear);
  const month = Number(isoMonth ?? brMonth);
  const day = Number(isoDay ?? brDay);
  const candidate = new Date(Date.UTC(year, month - 1, day));
  if (candidate.getUTCFullYear() !== year || candidate.getUTCMonth() !== month - 1 || candidate.getUTCDate() !== day) return undefined;

  return `${year.toString().padStart(4, "0")}-${month.toString().padStart(2, "0")}-${day.toString().padStart(2, "0")}`;
}

function parseAmountCents(value: string | undefined): number | undefined {
  let input = value?.trim().replace(/\s/g, "");
  if (!input) return undefined;

  const wrappedInParentheses = input.startsWith("(") || input.endsWith(")");
  if (wrappedInParentheses && !(input.startsWith("(") && input.endsWith(")"))) return undefined;

  const negative = input.startsWith("-") || wrappedInParentheses;
  input = input.replace(/^[-+]/, "").replace(/^\(/, "").replace(/\)$/, "").replace(/^R\$/i, "");
  const amountParts = splitAmount(input);
  if (!amountParts) return undefined;

  const { integerPart, decimalPart } = amountParts;
  const integer = integerPart.replace(/[.,]/g, "");

  const cents = Number(integer) * 100 + Number(decimalPart.padEnd(2, "0"));
  return Number.isSafeInteger(cents) ? (negative ? -cents : cents) : undefined;
}

function splitAmount(input: string): { integerPart: string; decimalPart: string } | undefined {
  if (!/^[\d.,]+$/.test(input)) return undefined;

  const commaCount = countOccurrences(input, ",");
  const dotCount = countOccurrences(input, ".");
  const separator = commaCount > 0 && dotCount > 0
    ? input.lastIndexOf(",") > input.lastIndexOf(".") ? "," : "."
    : commaCount === 1 && input.split(",")[1].length <= 2 ? ","
      : dotCount === 1 && input.split(".")[1].length <= 2 ? "."
        : undefined;
  const groupingSeparator = separator === "," ? "." : separator === "." ? "," : commaCount > 0 ? "," : dotCount > 0 ? "." : undefined;

  if (separator && countOccurrences(input, separator) !== 1) return undefined;

  const [integerPart, decimalPart = ""] = separator ? input.split(separator) : [input];
  if (!integerPart || (separator && !/^\d{1,2}$/.test(decimalPart)) || !isValidIntegerPart(integerPart, groupingSeparator)) return undefined;

  return { integerPart, decimalPart };
}

function isValidIntegerPart(value: string, groupingSeparator: string | undefined): boolean {
  if (!groupingSeparator || !value.includes(groupingSeparator)) return /^\d+$/.test(value);

  const escapedSeparator = groupingSeparator === "." ? "\\." : groupingSeparator;
  return new RegExp(`^\\d{1,3}(?:${escapedSeparator}\\d{3})*$`).test(value);
}

function countOccurrences(value: string, character: string): number {
  return value.split(character).length - 1;
}

export function statementTransactionFingerprint(competenceDate: string, amountCents: number, type: "income" | "expense", description: string): string {
  return `${competenceDate}|${amountCents}|${type}|${normalizeText(description)}`;
}

function normalizeText(value: string): string {
  return value
    .normalize("NFD")
    .replace(/\p{Diacritic}/gu, "")
    .toLocaleLowerCase("pt-BR")
    .replace(/[^a-z0-9]+/g, " ")
    .trim()
    .replace(/\s+/g, " ");
}
