"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { BarChart3, CirclePlus, CreditCard, Landmark, LogOut, Menu, Moon, ReceiptText, Settings, Sun, Target } from "lucide-react";
import { appPath } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";
import { useThemePreference } from "./ThemeProvider";

const links = [
  { href: "/", label: "Painel", icon: BarChart3 },
  { href: "/contas", label: "Contas", icon: Landmark },
  { href: "/cartoes", label: "Cartões", icon: CreditCard },
  { href: "/movimentacoes", label: "Movimentações", icon: ReceiptText },
  { href: "/compromissos", label: "Compromissos", icon: Target },
  { href: "/planejamento", label: "Planejamento", icon: Target },
  { href: "/categorias", label: "Categorias", icon: Menu },
  { href: "/configuracoes", label: "Configurações", icon: Settings },
];

export function Nav() {
  const pathname = usePathname();
  const { preference, updateThemePreference } = useThemePreference();
  const nextTheme = preference === "dark" ? "light" : "dark";

  async function signOut() {
    await createClient().auth.signOut();
    window.location.replace(appPath("/entrar"));
  }

  return <>
    <aside className="app-nav" aria-label="Navegação principal">
      <Link className="nav-brand" href="/"><span>BS</span><strong>Financeiro</strong></Link>
      <nav>{links.map(({ href, label, icon: Icon }) => <Link key={href} href={href} className={pathname === href ? "active" : ""} aria-current={pathname === href ? "page" : undefined}><Icon aria-hidden="true" />{label}</Link>)}</nav>
      <div className="nav-bottom">
        <button aria-label="Alternar tema" onClick={() => void updateThemePreference(nextTheme)}>{preference === "dark" ? <Sun aria-hidden="true" /> : <Moon aria-hidden="true" />}<span>Tema</span></button>
        <button onClick={() => void signOut()}><LogOut aria-hidden="true" /><span>Sair</span></button>
      </div>
    </aside>
    <nav className="mobile-nav" aria-label="Navegação móvel">
      <Link href="/" className={pathname === "/" ? "active" : ""}><BarChart3 aria-hidden="true" /><span>Painel</span></Link>
      <Link href="/movimentacoes" className={pathname === "/movimentacoes" ? "active" : ""}><ReceiptText aria-hidden="true" /><span>Movimentos</span></Link>
      <Link href="/movimentacoes" className="mobile-add" aria-label="Adicionar movimentação"><CirclePlus aria-hidden="true" /></Link>
      <Link href="/planejamento" className={pathname === "/planejamento" ? "active" : ""}><Target aria-hidden="true" /><span>Planejar</span></Link>
      <Link href="/configuracoes"><Menu aria-hidden="true" /><span>Mais</span></Link>
    </nav>
  </>;
}
