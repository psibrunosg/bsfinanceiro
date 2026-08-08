const brl = new Intl.NumberFormat("pt-BR", {
  style: "currency",
  currency: "BRL",
});

export function money(value: string | number | null | undefined) {
  return brl.format(Number(value || 0));
}

/**
 * Converte texto monetário em número, aceitando pt-BR ("1.234,56") e o
 * formato com ponto decimal ("1234.56"). Ignora símbolos de moeda e espaços
 * (inclusive não separáveis) e nunca devolve NaN — entradas inválidas viram 0.
 */
export function parseMoney(value: FormDataEntryValue | null) {
  if (typeof value !== "string" && typeof value !== "number") return 0;

  // Mantém apenas dígitos, separadores e o sinal; descarta "R$", espaços etc.
  const raw = String(value).replace(/[^\d,.-]/g, "");
  if (!raw) return 0;

  const negative = /^-/.test(raw);
  const digits = raw.replace(/-/g, "");
  if (!digits) return 0;

  let normalized: string;
  if (digits.includes(",")) {
    // Vírgula é o separador decimal; pontos são separadores de milhar.
    const last = digits.lastIndexOf(",");
    normalized =
      digits.slice(0, last).replace(/[.,]/g, "") +
      "." +
      digits.slice(last + 1).replace(/[.,]/g, "");
  } else if (digits.includes(".")) {
    const last = digits.lastIndexOf(".");
    const decimals = digits.slice(last + 1);
    // Último ponto só é decimal se vier seguido de exatamente 1 ou 2 dígitos.
    normalized = /^\d{1,2}$/.test(decimals)
      ? digits.slice(0, last).replace(/\./g, "") + "." + decimals
      : digits.replace(/\./g, "");
  } else {
    normalized = digits;
  }

  if (!/^\d*\.?\d*$/.test(normalized) || !/\d/.test(normalized)) return 0;

  const parsed = Number(normalized);
  if (!Number.isFinite(parsed)) return 0;

  return Math.round((negative ? -parsed : parsed) * 100) / 100;
}

export const cents = (reais: number) => Math.round(Number(reais || 0) * 100);

export const dateFmt = new Intl.DateTimeFormat("pt-BR");

export const monthStart = () =>
  `${new Date().toISOString().slice(0, 7)}-01`;

export const nextMonthStart = () => {
  const d = new Date();
  return new Date(d.getFullYear(), d.getMonth() + 1, 1)
    .toISOString()
    .slice(0, 10);
};
