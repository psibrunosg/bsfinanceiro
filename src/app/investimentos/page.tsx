"use client";

import { useState } from "react";
import { Nav } from "../components/Nav";
import { PageHeader } from "../components/PageHeader";
import { Dialog } from "../components/Dialog";
import { useFinance } from "../components/useFinance";
import { WalletCards } from "lucide-react";

export default function InvestimentosPage() {
  const { workspace, loading } = useFinance("dashboard");
  const [openDialog, setOpenDialog] = useState(false);

  if (loading || !workspace) {
    return <main className="management-page"><p className="muted">Carregando</p></main>;
  }

  return (
    <main className="management-page">
      <Nav />
      <PageHeader
        title="Investimentos"
        subtitle="Ativos, compras, vendas e cotações"
        workspaceName={workspace.name}
        action={{
          label: "Cadastrar ativo",
          onClick: () => setOpenDialog(true),
        }}
      />

      <section className="hub-overview">
        <article className="metric-card">
          <WalletCards aria-hidden="true" />
          <strong>R$ 0,00</strong>
          <span className="muted">Patrimônio investido</span>
       </article>
     </section>

      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} title="Cadastrar ativo">
        <p className="muted">Formulário de cadastro de ativo será exibido aqui</p>
      </Dialog>
   </main>
  );
}
