// Logos das bandeiras de cartão mais usadas no Brasil.
// Representações simples e reconhecíveis (não são as artes oficiais).

const norm = (v?: string | null) =>
  (v || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z]/g, "");

export const CARD_BRANDS = ["Visa", "Mastercard", "Elo", "Hipercard", "American Express"] as const;

export function BrandLogo({ brand }: { brand?: string | null }) {
  const key = norm(brand);
  const common = { width: 40, height: 26, viewBox: "0 0 40 26", role: "img" as const, "aria-label": brand || "Cartão" };
  const rx = 5;

  if (key.includes("visa"))
    return (
      <svg {...common}>
        <rect width="40" height="26" rx={rx} fill="#1a1f71" />
        <text x="20" y="18" textAnchor="middle" fontSize="11" fontStyle="italic" fontWeight="700" fill="#fff" fontFamily="Arial, sans-serif" letterSpacing="1">VISA</text>
      </svg>
    );

  if (key.includes("master"))
    return (
      <svg {...common}>
        <rect width="40" height="26" rx={rx} fill="#16110d" />
        <circle cx="17" cy="13" r="7" fill="#eb001b" />
        <circle cx="24" cy="13" r="7" fill="#f79e1b" fillOpacity="0.9" />
      </svg>
    );

  if (key.includes("elo"))
    return (
      <svg {...common}>
        <rect width="40" height="26" rx={rx} fill="#000" />
        <circle cx="14" cy="10" r="2.4" fill="#ffcb05" />
        <circle cx="20" cy="16" r="2.4" fill="#ef4123" />
        <circle cx="26" cy="10" r="2.4" fill="#00a4e0" />
        <text x="20" y="23" textAnchor="middle" fontSize="6" fontWeight="700" fill="#fff" fontFamily="Arial, sans-serif" letterSpacing="1">elo</text>
      </svg>
    );

  if (key.includes("hiper"))
    return (
      <svg {...common}>
        <rect width="40" height="26" rx={rx} fill="#822124" />
        <text x="20" y="16" textAnchor="middle" fontSize="7" fontWeight="700" fill="#fff" fontFamily="Arial, sans-serif">Hiper</text>
      </svg>
    );

  if (key.includes("amex") || key.includes("americanexpress") || key.includes("express"))
    return (
      <svg {...common}>
        <rect width="40" height="26" rx={rx} fill="#2e77bc" />
        <text x="20" y="16" textAnchor="middle" fontSize="8" fontWeight="800" fill="#fff" fontFamily="Arial, sans-serif" letterSpacing="1">AMEX</text>
      </svg>
    );

  // Sem bandeira reconhecida: emoji genérico.
  return <span aria-label="Cartão">💳</span>;
}
