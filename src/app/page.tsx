"use client";

import { useMemo, useState } from "react";
import { ArrowDownRight, ArrowUpRight, Bell, CalendarDays, ChevronRight, CircleDollarSign, CreditCard, Eye, EyeOff, Landmark, Moon, PiggyBank, Plus, Search, Sun, WalletCards } from "lucide-react";

const money = new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" });
const transactions = [
  { id: 1, title: "Atendimentos", category: "Receita", value: 2850, date: "Hoje", kind: "in" },
  { id: 2, title: "Supermercado", category: "Alimentação", value: -487.32, date: "Ontem", kind: "out" },
  { id: 3, title: "Internet", category: "Conta fixa", value: -119.9, date: "10 jul", kind: "out" },
];

export default function Dashboard() {
  const [dark, setDark] = useState(false);
  const [hidden, setHidden] = useState(false);
  const [query, setQuery] = useState("");
  const filtered = useMemo(() => transactions.filter((item) => item.title.toLowerCase().includes(query.toLowerCase())), [query]);

  return <div className={dark ? "app dark" : "app"}>
    <a className="skip" href="#conteudo">Ir para o conteúdo</a>
    <aside className="sidebar" aria-label="Navegação principal">
      <div className="brand"><span>BS</span><strong>Financeiro</strong></div>
      <nav>
        <a className="active" href="#inicio"><CircleDollarSign size={20}/>Visão geral</a>
        <a href="#movimentacoes"><WalletCards size={20}/>Movimentações</a>
        <a href="#planejamento"><CalendarDays size={20}/>Planejamento</a>
        <a href="#cartoes"><CreditCard size={20}/>Cartões</a>
        <a href="#investimentos"><PiggyBank size={20}/>Investimentos</a>
      </nav>
      <div className="week-card"><strong>Revisão semanal</strong><p>Você está com 3 pontos para revisar.</p><button>Começar revisão <ChevronRight size={16}/></button></div>
    </aside>
    <main id="conteudo">
      <header>
        <div><p className="eyebrow">DOMINGO, 12 DE JULHO</p><h1>Boa noite, Bruno</h1><p className="muted">Aqui está o que importa nas suas finanças.</p></div>
        <div className="header-actions"><button className="icon" aria-label="Alternar tema" onClick={() => setDark(!dark)}>{dark ? <Sun/> : <Moon/>}</button><button className="icon" aria-label="Notificações"><Bell/></button><button className="avatar" aria-label="Abrir perfil">BG</button></div>
      </header>

      <section className="balance" id="inicio">
        <div><div className="label-row"><span>Dinheiro disponível</span><button className="eye" onClick={() => setHidden(!hidden)} aria-label={hidden ? "Mostrar valores" : "Ocultar valores"}>{hidden ? <Eye size={18}/> : <EyeOff size={18}/>}</button></div><strong>{hidden ? "R$ ••••••" : money.format(4238.68)}</strong><p><span className="positive"><ArrowUpRight size={16}/> R$ 1.240</span> livres até o fim do mês</p></div>
        <div className="balance-side"><span>Saldo nas contas</span><strong>{hidden ? "••••••" : money.format(7998.68)}</strong><span>Comprometido</span><strong>{hidden ? "••••••" : money.format(3760)}</strong></div>
      </section>

      <section className="quick" aria-label="Ações rápidas">
        <button className="primary"><Plus size={20}/>Nova movimentação</button><button><Landmark size={20}/>Importar extrato</button><button><CreditCard size={20}/>Adicionar cartão</button>
      </section>

      <section className="grid">
        <article className="card"><div className="card-title"><div><span>Resumo de julho</span><strong>Para onde foi seu dinheiro</strong></div><button>Ver detalhes</button></div><div className="summary"><div><span>Entrou</span><strong className="positive">{money.format(8240)}</strong></div><div><span>Saiu</span><strong>{money.format(5121.32)}</strong></div><div><span>Sobrou</span><strong>{money.format(3118.68)}</strong></div></div><div className="bar" aria-label="62 por cento da renda já utilizada"><span/></div><p className="muted">62% da sua renda já foi utilizada neste mês.</p></article>
        <article className="card alert-card"><div className="alert-icon"><ArrowDownRight/></div><div><span>Oportunidade da semana</span><strong>Você gastou 28% a mais com delivery</strong><p>Reduzir duas compras pode liberar cerca de <b>R$ 140</b>.</p><button>Ver sugestão <ChevronRight size={16}/></button></div></article>
      </section>

      <section className="grid lower">
        <article className="card" id="movimentacoes"><div className="card-title"><div><span>Últimas movimentações</span><strong>Atividade recente</strong></div><label className="search"><Search size={17}/><input aria-label="Buscar movimentação" placeholder="Buscar" value={query} onChange={(e) => setQuery(e.target.value)}/></label></div><div className="transactions">{filtered.map(item => <div key={item.id} className="transaction"><div className={item.kind === "in" ? "transaction-icon in" : "transaction-icon"}>{item.kind === "in" ? <ArrowUpRight/> : <ArrowDownRight/>}</div><div><strong>{item.title}</strong><span>{item.category} · {item.date}</span></div><b className={item.kind === "in" ? "positive" : ""}>{money.format(item.value)}</b></div>)}</div></article>
        <article className="card"><div className="card-title"><div><span>Próximos 7 dias</span><strong>Contas e vencimentos</strong></div></div><div className="bills"><div><span><b>15</b> JUL</span><p><strong>Fatura Nubank</strong><small>Cartão de crédito</small></p><b>{money.format(1840.21)}</b></div><div><span><b>18</b> JUL</span><p><strong>Aluguel da clínica</strong><small>Conta fixa</small></p><b>{money.format(1250)}</b></div></div><button className="full">Ver todos os vencimentos</button></article>
      </section>
    </main>
    <nav className="mobile-nav" aria-label="Navegação móvel"><a className="active" href="#inicio"><CircleDollarSign/><span>Início</span></a><a href="#movimentacoes"><WalletCards/><span>Movimentos</span></a><button aria-label="Nova movimentação"><Plus/></button><a href="#planejamento"><CalendarDays/><span>Planejar</span></a><a href="#cartoes"><CreditCard/><span>Cartões</span></a></nav>
  </div>;
}
