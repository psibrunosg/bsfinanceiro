"use client";

import Link from "next/link";
import { Nav } from "../components/Nav";
import { PageHeader } from "../components/PageHeader";
import { CreditCard, Landmark, Settings, Target, WalletCards, ReceiptText } from "lucide-react";
import { useFinance } from "../components/useFinance";

export default function MaisPage() {
  const { workspace, loading } = useFinance("dashboard");

  if (loading || !workspace) {
    return <main className="dashboard-shell"><p className="muted">Carregando...</p></main>;
  }

  const moreLinks = [
    { href: "/contas", label: "Contas", icon: Landmark, description: "Saldos e patrimonio" },
    { href: "/cartoes", label: "Cartoes", icon: CreditCard, description: "Faturas e limites" },
    { href: "/investimentos", label: "Investimentos", icon: WalletCards, description: "Carteira e rentabilidade" },
    { href: "/planejamento", label: "Planejamento", icon: Target, description: "Orcamento e metas" },
    { href: "/categorias", label: "Categorias", icon: ReceiptText, description: "Gestao de categorias" },
    { href: "/configuracoes", label: "Configuracoes", icon: Settings, description: "Preferencias e privacidade" },
  ];

  return (
    <main className="dashboard-shell">
      <Nav />
      <PageHeader
        title="Mais"
        subtitle="Acesso rapido a todas as areas"
        workspaceName={workspace.name}
      />
      <ul className="list list--grid">
        {moreLinks.map(({ href, label, icon: Icon, description }) => (
          <li key={href}>
            <Link href={href} className="list-card">
              <Icon aria-hidden="true" />
              <strong>{label}</strong>
              <small className="muted">{description}</small>
          </Link>
        </li>
        ))}
    </ul>
  </main>
  );
}

