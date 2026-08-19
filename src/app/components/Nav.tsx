"use client";

import Link from "next/link";
import { usePathname, useSearchParams } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import { Activity, BarChart3, ChartColumn, ChevronLeft, ChevronRight, CirclePlus, CreditCard, Landmark, LogOut, Menu, ReceiptText, Target, TrendingUp, WalletCards } from "lucide-react";
import { appPath } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";
import { useCurrentUser } from "./useCurrentUser";

const desktopLinks = [
  { href: "/", label: "Painel", icon: BarChart3 },
  { href: "/ganhos", label: "Ganhos", icon: TrendingUp },
  { href: "/gastos", label: "Gastos", icon: ReceiptText },
  { href: "/contas", label: "Contas", icon: Landmark },
  { href: "/cartoes", label: "Cartões", icon: CreditCard },
  { href: "/investimentos", label: "Investimentos", icon: WalletCards },
  { href: "/planejamento", label: "Planejamento", icon: Target },
  { href: "/relatorios", label: "Relatórios", icon: ChartColumn },
  { href: "/saude", label: "Saúde financeira", icon: Activity },
  { href: "/categorias", label: "Categorias", icon: ReceiptText },
  { href: "/configuracoes", label: "Mais", icon: Menu },
];

const COLLAPSE_KEY = "bsf-nav-collapsed";
const SIDEBAR_EXPANDED = "264px";
const SIDEBAR_COLLAPSED = "84px";

export function Nav() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const { displayName, initials } = useCurrentUser();
  const [collapsed, setCollapsed] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const stored = localStorage.getItem(COLLAPSE_KEY) === "true";
    setCollapsed(stored);
    document.documentElement.style.setProperty("--sidebar", stored ? SIDEBAR_COLLAPSED : SIDEBAR_EXPANDED);
  }, []);

  useEffect(() => {
    function onClickOutside(e: MouseEvent) {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) setMenuOpen(false);
    }
    document.addEventListener("mousedown", onClickOutside);
    return () => document.removeEventListener("mousedown", onClickOutside);
  }, []);

  function toggleCollapsed() {
    setCollapsed((prev) => {
      const next = !prev;
      localStorage.setItem(COLLAPSE_KEY, String(next));
      document.documentElement.style.setProperty("--sidebar", next ? SIDEBAR_COLLAPSED : SIDEBAR_EXPANDED);
      return next;
    });
  }

  async function signOut() {
    await createClient().auth.signOut();
    window.location.replace(appPath("/entrar"));
  }

  const isCompromissos = pathname === "/compromissos";
  const isGastosRecorrentes = pathname === "/gastos" && searchParams?.get("tab") === "recorrentes";

  return <>
    <aside className={`app-nav${collapsed ? " collapsed" : ""}`} aria-label="Navegação principal">
      <div className="nav-brand-row">
        <Link className="nav-brand" href="/"><span>BS</span><strong>Financeiro</strong></Link>
        <button
          type="button"
          className="nav-collapse-toggle"
          onClick={toggleCollapsed}
          aria-label={collapsed ? "Expandir menu" : "Recolher menu"}
          aria-pressed={collapsed}
        >
          {collapsed ? <ChevronRight aria-hidden="true" /> : <ChevronLeft aria-hidden="true" />}
        </button>
      </div>
      <nav>
        {desktopLinks.map(({ href, label, icon: Icon }) => (
          <Link
            key={href}
            href={href}
            className={(pathname === href || (isGastosRecorrentes && href === "/gastos")) ? "active" : ""}
            aria-current={(pathname === href || (isGastosRecorrentes && href === "/gastos")) ? "page" : undefined}
            title={collapsed ? label : undefined}
          >
            <Icon aria-hidden="true" />
            <span>{label}</span>
          </Link>
        ))}
        {isCompromissos && (
          <Link
            href="/gastos?tab=recorrentes"
            className="active"
            aria-current="page"
          >
            <Target aria-hidden="true" />
            <span>Compromissos</span>
          </Link>
        )}
      </nav>
      <div className="nav-bottom" ref={menuRef}>
        {menuOpen && (
          <div className="nav-user-menu">
            <button type="button" onClick={() => void signOut()}><LogOut aria-hidden="true" /><span>Sair</span></button>
          </div>
        )}
        <button
          type="button"
          className="nav-user-trigger"
          onClick={() => setMenuOpen((v) => !v)}
          aria-haspopup="menu"
          aria-expanded={menuOpen}
        >
          <span className="nav-user-avatar" aria-hidden="true">{initials}</span>
          <span className="nav-user-name">{displayName}</span>
        </button>
      </div>
    </aside>
    <nav className="mobile-nav" aria-label="Navegação móvel">
      <Link href="/" className={pathname === "/" ? "active" : ""}><BarChart3 aria-hidden="true" /><span>Painel</span></Link>
      <Link href="/ganhos" className={pathname === "/ganhos" ? "active" : ""}><TrendingUp aria-hidden="true" /><span>Ganhos</span></Link>
      <Link href="/movimentacoes" className="mobile-add" aria-label="Adicionar movimentação"><CirclePlus aria-hidden="true" /></Link>
      <Link href="/gastos" className={pathname === "/gastos" ? "active" : ""}><ReceiptText aria-hidden="true" /><span>Gastos</span></Link>
      <Link href="/configuracoes"><Menu aria-hidden="true" /><span>Mais</span></Link>
    </nav>
  </>;
}
