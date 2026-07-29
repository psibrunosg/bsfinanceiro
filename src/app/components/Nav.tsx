"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { appPath } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";

const directLinks = [
  { href: "/", label: "Painel" },
  { href: "/movimentacoes", label: "Movimentações" },
  { href: "/planejamento", label: "Planejamento" },
];

const moreLinks = [
  { href: "/contas", label: "Contas" },
  { href: "/cartoes", label: "Cartões" },
  { href: "/categorias", label: "Categorias" },
  { href: "/compromissos", label: "Compromissos" },
  { href: "/configuracoes", label: "Configurações" },
];

export function Nav() {
  const pathname = usePathname();
  const moreIsActive = moreLinks.some((link) => pathname === link.href);

  async function signOut() {
    const supabase = createClient();
    await supabase.auth.signOut();
    window.location.replace(appPath("/entrar"));
  }

  return (
    <nav className="quick-actions finance-nav" aria-label="Navegação principal">
      {directLinks.map((link) => (
        <Link
          key={link.href}
          className={`quick-link${pathname === link.href ? " active" : ""}`}
          href={link.href}
          aria-current={pathname === link.href ? "page" : undefined}
        >
          {link.label}
        </Link>
      ))}
      <details className="nav-more" open={moreIsActive || undefined}>
        <summary className={`quick-link${moreIsActive ? " active" : ""}`}>
          Mais
        </summary>
        <div className="nav-more-links">
          {moreLinks.map((link) => (
            <Link
              key={link.href}
              className={`quick-link${pathname === link.href ? " active" : ""}`}
              href={link.href}
              aria-current={pathname === link.href ? "page" : undefined}
            >
              {link.label}
            </Link>
          ))}
        </div>
      </details>
      <button className="quick-link nav-signout" type="button" onClick={signOut}>
        Sair
      </button>
    </nav>
  );
}
