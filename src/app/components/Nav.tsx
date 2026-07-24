"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { appPath } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";

const links = [
  { href: "/", label: "Painel" },
  { href: "/contas", label: "Contas" },
  { href: "/cartoes", label: "Cartões" },
  { href: "/movimentacoes", label: "Movimentações" },
  { href: "/categorias", label: "Categorias" },
  { href: "/compromissos", label: "Compromissos" },
  { href: "/planejamento", label: "Planejamento" },
  { href: "/configuracoes", label: "Configurações" },
];

export function Nav() {
  const pathname = usePathname();

  async function signOut() {
    const supabase = createClient();
    await supabase.auth.signOut();
    window.location.replace(appPath("/entrar"));
  }

  return (
    <nav className="quick-actions">
      {links.map((link) => (
        <Link
          key={link.href}
          className={`quick-link${pathname === link.href ? " active" : ""}`}
          href={link.href}
        >
          {link.label}
        </Link>
      ))}
      <button className="quick-link" onClick={signOut}>
        Sair
      </button>
    </nav>
  );
}
