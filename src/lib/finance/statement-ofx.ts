import { StatementCsvValidItem, statementTransactionFingerprint } from "./statement-csv";

/**
 * Parse OFX (Open Financial Exchange) file and extract transactions.
 * OFX uses SGML-like tags: <STMTTRN> blocks with <TRNTYPE>, <DTPOSTED>, <TRNAMT>, <NAME>.
 * Returns StatementCsvValidItem[] for compatibility with the existing review UI.
 */
export function parseOfxStatement(content: string): StatementCsvValidItem[] {
  const items: StatementCsvValidItem[] = [];
  // Match all STMTTRN blocks (SGML or XML style)
  const blockRegex = /<STMTTRN[^>]*>([\s\S]*?)<\/STMTTRN>/gi;
  let match: RegExpExecArray | null;

  while ((match = blockRegex.exec(content)) !== null) {
    const block = match[1];
    const trnType = extractTag(block, "TRNTYPE")?.toUpperCase();
    const dtPosted = extractTag(block, "DTPOSTED");
    const trnAmt = extractTag(block, "TRNAMT");
    const name = extractTag(block, "NAME") || extractTag(block, "MEMO") || "";

    if (!dtPosted || !trnAmt || !name) continue;

    // Parse date: YYYYMMDD or YYYYMMDDHHMMSS[.XXX:TZ]
    const dateStr = dtPosted.replace(/[^0-9]/g, "").slice(0, 8);
    if (dateStr.length !== 8) continue;
    const year = dateStr.slice(0, 4);
    const month = dateStr.slice(4, 6);
    const day = dateStr.slice(6, 8);
    const competenceDate = `${year}-${month}-${day}`;

    // Parse amount: includes sign, may use comma or dot as decimal
    const amountStr = trnAmt.replace(",", ".");
    const amount = parseFloat(amountStr);
    if (isNaN(amount)) continue;

    const amountCents = Math.round(Math.abs(amount) * 100);
    // OFX: positive = credit/income, negative = debit/expense
    const type: "income" | "expense" = amount >= 0 ? "income" : "expense";

    // Some OFX files use DEBIT/CREDIT instead of signed amounts
    let resolvedType = type;
    if (trnType === "CREDIT" || trnType === "DEP") resolvedType = "income";
    else if (trnType === "DEBIT" || trnType === "POS" || trnType === "FEE") resolvedType = "expense";

    const fingerprint = statementTransactionFingerprint(competenceDate, amountCents, resolvedType, name);

    items.push({
      rowNumber: items.length + 1,
      competenceDate,
      description: name.slice(0, 200),
      amountCents,
      type: resolvedType,
      fingerprint,
    });
  }

  return items;
}

function extractTag(block: string, tagName: string): string | null {
  // SGML style: <TAGNAME>value
  const sgml = new RegExp(`<${tagName}>\\s*([^<\\r\\n]+)`, "i").exec(block);
  if (sgml) return sgml[1].trim();

  // XML style: <TAGNAME>value</TAGNAME>
  const xml = new RegExp(`<${tagName}>\\s*([\\s\\S]*?)\\s*</${tagName}>`, "i").exec(block);
  if (xml) return xml[1].trim();

  // XML with attributes: <TAGNAME attr="...">value</TAGNAME>
  const xmlAttr = new RegExp(`<${tagName}[^>]*>\\s*([\\s\\S]*?)\\s*</${tagName}>`, "i").exec(block);
  if (xmlAttr) return xmlAttr[1].trim();

  return null;
}
