"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { useRouter } from "next/navigation";

const ROUTES = [
  { id: "dashboard", label: "Painel", href: "/" },
  { id: "movimentacoes", label: "Movimentações", href: "/movimentacoes/" },
  { id: "ganhos", label: "Ganhos", href: "/ganhos/" },
  { id: "gastos", label: "Gastos", href: "/gastos/" },
  { id: "contas", label: "Contas", href: "/contas/" },
  { id: "cartoes", label: "Cartões", href: "/cartoes/" },
  { id: "investimentos", label: "Investimentos", href: "/investimentos/" },
  { id: "dividas", label: "Dívidas", href: "/dividas/" },
  { id: "planejamento", label: "Planejamento", href: "/planejamento/" },
  { id: "relatorios", label: "Relatórios", href: "/relatorios/" },
  { id: "saude", label: "Saúde financeira", href: "/saude/" },
  { id: "categorias", label: "Categorias", href: "/categorias/" },
  { id: "mais", label: "Mais", href: "/mais/" },
  { id: "configuracoes", label: "Configurações", href: "/configuracoes/" },
] as const;

export function CommandMenu() {
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");
  const router = useRouter();
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "k" && (event.metaKey || event.ctrlKey)) {
        event.preventDefault();
        setOpen((value) => !value);
        return;
      }

      if (
        event.target instanceof HTMLInputElement ||
        event.target instanceof HTMLTextAreaElement ||
        event.target instanceof HTMLSelectElement
      ) {
        return;
      }

      if (event.key === "/") {
        event.preventDefault();
        setOpen(true);
      } else if (event.key.toLowerCase() === "n") {
        event.preventDefault();
        router.push("/movimentacoes?new=1");
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [router]);

  useEffect(() => {
    if (!open) return;
    setQuery("");
    const timer = window.setTimeout(() => inputRef.current?.focus(), 50);
    return () => window.clearTimeout(timer);
  }, [open]);

  const results = useMemo(() => {
    const term = query.trim().toLocaleLowerCase("pt-BR");
    if (!term) return ROUTES.slice(0, 7);
    return ROUTES.filter((route) =>
      route.label.toLocaleLowerCase("pt-BR").includes(term),
    );
  }, [query]);

  if (!open) return null;

  return (
    <div className="modal-backdrop" style={{ zIndex: 9999 }} onClick={() => setOpen(false)}>
      <div
        className="modal-content command-menu"
        role="dialog"
        aria-modal="true"
        aria-label="Navegação rápida"
        onClick={(event) => event.stopPropagation()}
        style={{ maxWidth: "600px", padding: 0, overflow: "hidden", display: "flex", flexDirection: "column" }}
      >
        <label htmlFor="command-menu-search" className="sr-only">Buscar área do BS Financeiro</label>
        <input
          id="command-menu-search"
          ref={inputRef}
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="Busque uma área do BS Financeiro..."
          style={{ width: "100%", padding: "20px", border: "none", borderBottom: "1px solid var(--border)", fontSize: "1.1rem", background: "transparent", color: "var(--text)", outline: "none" }}
        />
        <div style={{ maxHeight: "340px", overflowY: "auto" }}>
          {results.length ? (
            <ul style={{ listStyle: "none", padding: 0, margin: 0 }}>
              {results.map((result) => (
                <li key={result.id}>
                  <button
                    type="button"
                    onClick={() => {
                      router.push(result.href);
                      setOpen(false);
                    }}
                    style={{ width: "100%", padding: "16px 20px", border: "none", borderBottom: "1px solid var(--border)", background: "transparent", color: "var(--text)", textAlign: "left", cursor: "pointer" }}
                  >
                    {result.label}
                  </button>
                </li>
              ))}
            </ul>
          ) : (
            <p style={{ padding: "20px", margin: 0, color: "var(--muted)", textAlign: "center" }}>
              Nenhuma área encontrada.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
