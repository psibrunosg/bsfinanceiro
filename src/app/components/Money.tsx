const brl = new Intl.NumberFormat("pt-BR", {
  style: "currency",
  currency: "BRL",
});

export function money(value: string | number | null | undefined) {
  return brl.format(Number(value || 0));
}

export function parseMoney(value: FormDataEntryValue | null) {
  return Number(
    String(value || "0")
      .replace(/\./g, "")
      .replace(",", ".")
  );
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
