"use client";

import { useEffect, useState, useRef, useMemo } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

export function CommandMenu() {
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<{ id: string; label: string; href: string }[]>([]);
  const router = useRouter();
  const inputRef = useRef<HTMLInputElement>(null);
  const supabase = useMemo(() => createClient(), []);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "k" && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        setOpen((o) => !o);
      }
      
      // se nÃ£o estÃ¡ em input
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;

      if (e.key === "/") {
        e.preventDefault();
        setOpen(true);
      }
      if (e.key.toLowerCase() === "n") {
        e.preventDefault();
        router.push("/movimentacoes?new=1");
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [router]);

  useEffect(() => {
    if (open) {
      setTimeout(() => inputRef.current?.focus(), 50);
      setQuery("");
      setResults([]);
    }
  }, [open]);

  useEffect(() => {
    if (!open || query.trim().length < 2) {
      setResults([]);
      return;
    }
    let active = true;

    async function search() {
      // Very simple remote search over accounts and categories to avoid full state load
      const term = `%${query}%`;
      const [acc, cat] = await Promise.all([
        supabase.from("accounts").select("id,name").ilike("name", term).limit(5),
        supabase.from("categories").select("id,name").ilike("name", term).limit(5)
      ]);

      if (!active) return;

      const items: { id: string; label: string; href: string }[] = [];
      
      if (acc.data) {
        acc.data.forEach(a => items.push({ id: a.id, label: `Conta: ${a.name}`, href: "/contas" }));
      }
      if (cat.data) {
        cat.data.forEach(c => items.push({ id: c.id, label: `Categoria: ${c.name}`, href: "/categorias" }));
      }
      
      // Static routes
      const staticRoutes = [
        { id: "s1", label: "Ir para Dashboard", href: "/" },
        { id: "s2", label: "Ir para MovimentaÃ§Ãµes", href: "/movimentacoes" },
        { id: "s3", label: "Ir para Contas", href: "/contas" },
        { id: "s4", label: "Ir para Categorias", href: "/categorias" },
        { id: "s5", label: "Ir para RelatÃ³rios", href: "/relatorios" },
        { id: "s6", label: "Ir para Planejamento", href: "/planejamento" },
        { id: "s7", label: "Ir para Investimentos", href: "/investimentos" }
      ];

      const filteredRoutes = staticRoutes.filter(r => r.label.toLowerCase().includes(query.toLowerCase()));
      
      setResults([...filteredRoutes, ...items]);
    }

    const t = setTimeout(search, 300);
    return () => { active = false; clearTimeout(t); };
  }, [query, open, supabase]);

  if (!open) return null;

  return (
    <div className="modal-backdrop" style={{ zIndex: 9999 }} onClick={() => setOpen(false)}>
      <div className="modal-content command-menu" onClick={e => e.stopPropagation()} style={{ maxWidth: "600px", padding: 0, overflow: "hidden", display: "flex", flexDirection: "column" }}>
        <input 
          ref={inputRef}
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Busque contas, categorias, transações ou digite um comando..."
          style={{ width: "100%", padding: "20px", border: "none", borderBottom: "1px solid var(--border)", fontSize: "1.1rem", background: "transparent", color: "var(--text)", outline: "none" }}
        />
        <div style={{ maxHeight: "300px", overflowY: "auto" }}>
          {results.length > 0 ? (
            <ul style={{ listStyle: "none", padding: 0, margin: 0 }}>
              {results.map((r, i) => (
                <li key={`${r.id}-${i}`}>
                  <button 
                    onClick={() => { router.push(r.href); setOpen(false); }}
                    style={{ width: "100%", padding: "16px 20px", border: "none", borderBottom: "1px solid var(--border)", background: "transparent", color: "var(--text)", textAlign: "left", cursor: "pointer", transition: "background 0.2s" }}
                    onMouseEnter={(e) => e.currentTarget.style.background = "var(--surface-2)"}
                    onMouseLeave={(e) => e.currentTarget.style.background = "transparent"}
                  >
                    {r.label}
                  </button>
                </li>
              ))}
            </ul>
          ) : query.length >= 2 ? (
            <p style={{ padding: "20px", margin: 0, color: "var(--muted)", textAlign: "center" }}>Nenhum resultado encontrado.</p>
          ) : (
            <div style={{ padding: "20px", color: "var(--muted)", fontSize: "0.9rem" }}>
              <p style={{ margin: "0 0 10px 0" }}><strong>Dica de atalhos:</strong></p>
              <ul style={{ margin: 0, paddingLeft: "20px" }}>
                <li><kbd style={{ background: "var(--surface-2)", padding: "2px 6px", borderRadius: "4px" }}>N</kbd> Nova transaÃ§Ã£o</li>
                <li><kbd style={{ background: "var(--surface-2)", padding: "2px 6px", borderRadius: "4px" }}>/</kbd> Abrir busca</li>
                <li><kbd style={{ background: "var(--surface-2)", padding: "2px 6px", borderRadius: "4px" }}>Cmd + K</kbd> Abrir busca</li>
              </ul>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
