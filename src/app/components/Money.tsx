const brl = new Intl.NumberFormat("pt-BR", {
  style: "currency",
  currency: "BRL",
});

export function money(value: string | number | null | undefined) {
  return brl.format(Number(value || 0));
}

export function parseMoney(value: FormDataEntryValue | null) {
  const raw = String(value ?? "").trim();
  const negative = raw.startsWith("-");
  // mantem so digitos e separadores: descarta R$, espacos comuns e NBSP
  const digits = raw.replace(/[^\d.,]/g, "");
  if (!digits) return 0;

  const sep = Math.max(digits.lastIndexOf(","), digits.lastIndexOf("."));
  let intPart = digits;
  let decPart = "";
  if (sep >= 0) {
    const tail = digits.slice(sep + 1);
    // virgula e sempre decimal; ponto so quando sobram 1 ou 2 digitos (senao e milhar)
    if (digits[sep] === "," || tail.length === 1 || tail.length === 2) {
      intPart = digits.slice(0, sep);
      decPart = tail;
    }
  }

  const n = Number(`${intPart.replace(/[.,]/g, "")}.${decPart || "0"}`);
  if (!Number.isFinite(n)) return 0;
  return ((negative ? -1 : 1) * Math.round(n * 100)) / 100;
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
