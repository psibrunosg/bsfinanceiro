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
    { href: "/contas", label: "Contas", icon: Landmark, description: "Saldos e patrimônio" },
    { href: "/cartoes", label: "Cartões", icon: CreditCard, description: "Faturas e limites" },
    { href: "/investimentos", label: "Investimentos", icon: WalletCards, description: "Carteira e rentabilidade" },
    { href: "/planejamento", label: "Planejamento", icon: Target, description: "Orçamento e metas" },
    { href: "/categorias", label: "Categorias", icon: ReceiptText, description: "Gestão de categorias" },
    { href: "/configuracoes", label: "Configurações", icon: Settings, description: "Preferências e privacidade" },
  ];

  return (
    <main className="dashboard-shell">
      <Nav />
      <PageHeader
        title="Mais"
        subtitle="Acesso rápido a todas as áreas"
        workspaceName={workspace.name}
      />
      <div className="bento-row" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))' }}>
        {moreLinks.map(({ href, label, icon: Icon, description }) => (
          <Link
            key={href}
            href={href}
            className="dashboard-card"
            style={{ display: 'flex', flexDirection: 'column', gap: '10px', textDecoration: 'none', color: 'inherit' }}
          >
            <span className="metric-icon-badge" style={{ background: "rgba(139,92,246,.15)", color: "#8B5CF6", marginLeft: 0 }}>
              <Icon size={18} aria-hidden="true" />
            </span>
            <strong>{label}</strong>
            <small className="muted">{description}</small>
          </Link>
        ))}
      </div>
    </main>
  );
}
