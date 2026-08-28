export type ParsedBankNotification = {
  rawText: string;
  bank: "Nubank" | "Itaú" | "Inter" | "Bradesco" | "C6" | "Santander" | "Outro";
  type: "expense" | "income";
  amount: number;
  description: string;
  suggestedCategory: string;
  confidence: number;
};

const BANK_PATTERNS: { name: ParsedBankNotification["bank"]; regex: RegExp }[] = [
  { name: "Nubank", regex: /nubank|nu\b/i },
  { name: "Itaú", regex: /ita[uú]/i },
  { name: "Inter", regex: /inter\b/i },
  { name: "Bradesco", regex: /bradesco/i },
  { name: "C6", regex: /c6\b/i },
  { name: "Santander", regex: /santander/i },
];

const CATEGORY_KEYWORDS: { category: string; regex: RegExp }[] = [
  { category: "Alimentação", regex: /padaria|restaurante|lanchonete|ifood|uber\s*eats|burguer|pizza|mercado|supermercado|p[aã]o/i },
  { category: "Transporte", regex: /posto|gasolina|combust[ií]vel|uber|99app|estacionamento|ped[aá]gio|ipva/i },
  { category: "Saúde", regex: /farm[aá]cia|droga|hospital|cl[ií]nica|m[eé]dico|laborat[oó]rio|unimed/i },
  { category: "Moradia", regex: /aluguel|condom[ií]nio|enel|sabesp|cpfl|luz|energia|[aá]gua|iptu/i },
  { category: "Lazer", regex: /cinema|netflix|spotify|ingresso|show|teatro|steam|playstation/i },
];

/**
 * Converte strings de valor em reais para número decimal.
 * Ex: "R$ 1.450,90" -> 1450.90
 */
function extractAmount(text: string): number {
  const match = text.match(/R\$\s*([\d.,]+)/i) || text.match(/([\d.]+,\d{2})/);
  if (!match) return 0;

  const rawNum = match[1];
  const cleaned = rawNum.replace(/\./g, "").replace(",", ".");
  return parseFloat(cleaned) || 0;
}

/**
 * Analisa o texto de uma notificação bancária recebida no celular e extrai os dados do lançamento.
 */
export function parseBankNotification(text: string): ParsedBankNotification {
  const rawText = text.trim();

  // 1. Detectar Banco
  let bank: ParsedBankNotification["bank"] = "Outro";
  for (const b of BANK_PATTERNS) {
    if (b.regex.test(rawText)) {
      bank = b.name;
      break;
    }
  }

  // 2. Detectar Tipo (Entrada vs Saída)
  const isIncome = /recebeu|recebimento|pix recebido|transfer[eê]ncia recebida|dep[oó]sito/i.test(
    rawText
  );
  const type: ParsedBankNotification["type"] = isIncome ? "income" : "expense";

  // 3. Extrair Valor
  const amount = extractAmount(rawText);

  // 4. Extrair Descrição / Estabelecimento / Beneficiário
  let description = "Notificação Bancária";
  const emMatch = rawText.match(/\bem\s+([^.,;\n]+)/i);
  const allDeMatches = Array.from(rawText.matchAll(/\bde\s+([^.,;\n]+)/gi));
  const validDeMatch = allDeMatches.find(
    (m) => !m[1].toLowerCase().includes("r$") && !/^\d/.test(m[1].trim())
  );
  const paraMatch = rawText.match(/\bpara\s+([^.,;\n]+)/i);

  if (isIncome && validDeMatch) {
    const nameOnly = validDeMatch[1].replace(/\s+no\s+banco.*$/i, "").trim();
    description = `Recebido de ${nameOnly}`;
  } else if (!isIncome && emMatch) {
    description = emMatch[1].trim();
  } else if (!isIncome && paraMatch) {
    description = `Pix para ${paraMatch[1].trim()}`;
  } else {
    description = isIncome ? `Pix Recebido (${bank})` : `Compra ${bank}`;
  }

  // 5. Sugerir Categoria
  let suggestedCategory = isIncome ? "Receita" : "Outros";
  for (const cat of CATEGORY_KEYWORDS) {
    if (cat.regex.test(rawText)) {
      suggestedCategory = cat.category;
      break;
    }
  }

  const confidence = amount > 0 && bank !== "Outro" ? 0.95 : 0.7;

  return {
    rawText,
    bank,
    type,
    amount,
    description,
    suggestedCategory,
    confidence,
  };
}
