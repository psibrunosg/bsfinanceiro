"use client";

import { Suspense } from "react";
import Link from "next/link";
import { usePathname, useSearchParams } from "next/navigation";
import { BarChart3, CirclePlus, CreditCard, Landmark, LogOut, Menu, ReceiptText, Target, TrendingUp, WalletCards } from "lucide-react";
import { appPath } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";


const desktopLinks = [
  { href: "/", label: "Painel", icon: BarChart3 },
  { href: "/ganhos", label: "Ganhos", icon: TrendingUp },
  { href: "/gastos", label: "Gastos", icon: ReceiptText },
  { href: "/contas", label: "Contas", icon: Landmark },
  { href: "/cartoes", label: "Cartões", icon: CreditCard },
  { href: "/investimentos", label: "Investimentos", icon: WalletCards },
  { href: "/planejamento", label: "Planejamento", icon: Target },
  { href: "/categorias", label: "Categorias", icon: ReceiptText },
  { href: "/configuracoes", label: "Mais", icon: Menu },
];

function NavLinks({ pathname, isGastosRecorrentes }: { pathname: string | null; isGastosRecorrentes: boolean }) {
  const isCompromissos = pathname === "/compromissos";

  return (
    <nav>
      {desktopLinks.map(({ href, label, icon: Icon }) => (
        <Link
          key={href}
          href={href}
          className={(pathname === href || (isGastosRecorrentes && href === "/gastos")) ? "active" : ""}
          aria-current={(pathname === href || (isGastosRecorrentes && href === "/gastos")) ? "page" : undefined}
        >
          <Icon aria-hidden="true" />
          {label}
        </Link>
      ))}
      {isCompromissos && (
        <Link
          href="/gastos?tab=recorrentes"
          className="active"
          aria-current="page"
        >
          <Target aria-hidden="true" />
          Compromissos
        </Link>
      )}
    </nav>
  );
}

function NavLinksWithSearchParams({ pathname }: { pathname: string | null }) {
  const searchParams = useSearchParams();
  const isGastosRecorrentes = pathname === "/gastos" && searchParams?.get("tab") === "recorrentes";

  return <NavLinks pathname={pathname} isGastosRecorrentes={isGastosRecorrentes} />;
}

export function Nav() {
  const pathname = usePathname();

  async function signOut() {
    await createClient().auth.signOut();
    window.location.replace(appPath("/entrar"));
  }

  return <>
    <aside className="app-nav" aria-label="Navegação principal">
      <Link className="nav-brand" href="/"><span>BS</span><strong>Financeiro</strong></Link>
      <Suspense fallback={<NavLinks pathname={pathname} isGastosRecorrentes={false} />}>
        <NavLinksWithSearchParams pathname={pathname} />
      </Suspense>
      <div className="nav-bottom">

        <button onClick={() => void signOut()}><LogOut aria-hidden="true" /><span>Sair</span></button>
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
