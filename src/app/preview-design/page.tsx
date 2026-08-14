"use client";

import React from "react";
import { CreditCard, Wallet, TrendingUp, TrendingDown, Home, Coffee, Car, LayoutDashboard, Target, ArrowRightLeft, Settings, Bell, CircleDollarSign } from "lucide-react";
import styles from "./preview.module.css";

export default function PreviewDesignPage() {
  return (
    <div className={styles.layout}>
      {/* Sidebar */}
      <aside className={styles.sidebar}>
        <div className={styles.brand}>
          <div className={styles.brandIcon}><CircleDollarSign size={20} color="#fff" /></div>
          BS Financeiro
        </div>
        
        <nav className={styles.menu}>
          <div className={`${styles.menuItem} ${styles.active}`}>
            <LayoutDashboard size={20} />
            Dashboard
          </div>
          <div className={styles.menuItem}>
            <ArrowRightLeft size={20} />
            Movimentações
          </div>
          <div className={styles.menuItem}>
            <Wallet size={20} />
            Contas & Cartões
          </div>
          <div className={styles.menuItem}>
            <Target size={20} />
            Planejamento
          </div>
          <div className={styles.menuItem} style={{ marginTop: 'auto' }}>
            <Settings size={20} />
            Configurações
          </div>
        </nav>
      </aside>

      {/* Main Content */}
      <main className={styles.previewContainer}>
        <div className={styles.header}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h1>Preview: Premium Dark + Dynamic Cards</h1>
              <p>Um ambiente isolado misturando a elegância do modo escuro com a vibração dos cartões dinâmicos.</p>
            </div>
            <div style={{ display: 'flex', gap: '16px' }}>
              <div style={{ background: 'rgba(255,255,255,0.05)', padding: '12px', borderRadius: '50%', cursor: 'pointer' }}>
                <Bell size={20} color="#94A3B8" />
              </div>
            </div>
          </div>
        </div>

        {/* Seção Dashboard (Dynamic Cards) */}
        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>Dashboard (Resumo Mês)</h2>
          <div className={styles.grid}>
            <div className={`${styles.dynamicCard} ${styles.cardGradient1}`}>
              <Wallet className={styles.cardIcon} size={80} />
              <div className={styles.dynamicCardTitle}>Disponível para gastar</div>
              <div className={styles.dynamicCardValue}>R$ 4.250,00</div>
              <div style={{ marginTop: '8px', fontSize: '0.85rem', opacity: 0.9 }}>
                Próxima entrada em 5 dias
              </div>
            </div>
            
            <div className={`${styles.dynamicCard} ${styles.cardGradient2}`}>
              <TrendingUp className={styles.cardIcon} size={80} />
              <div className={styles.dynamicCardTitle}>Renda Total</div>
              <div className={styles.dynamicCardValue}>R$ 8.900,00</div>
              <div style={{ marginTop: '8px', fontSize: '0.85rem', opacity: 0.9 }}>
                +12% comparado ao mês anterior
              </div>
            </div>

            <div className={`${styles.dynamicCard} ${styles.cardGradient4}`}>
              <TrendingDown className={styles.cardIcon} size={80} />
              <div className={styles.dynamicCardTitle}>Despesas (Out)</div>
              <div className={styles.dynamicCardValue}>R$ 3.120,50</div>
              <div style={{ marginTop: '8px', fontSize: '0.85rem', opacity: 0.9 }}>
                Dentro do esperado
              </div>
            </div>
          </div>
        </div>

        {/* Seção Planejamento / Budgets (Dynamic Progress Cards) */}
        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>Planejamento e Orçamentos</h2>
          <div className={styles.grid}>
            <div className={styles.glassCard} style={{ borderTop: '4px solid #F59E0B' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
                <Coffee size={24} color="#F59E0B" />
                <div style={{ fontSize: '1.2rem', fontWeight: 600 }}>Alimentação</div>
              </div>
              <div className={styles.progressLabel}>
                <span>R$ 650 gastos</span>
                <span>Limite: R$ 800</span>
              </div>
              <div className={styles.progressBarTrack}>
                <div className={styles.progressBarFill} style={{ width: '81%', background: '#F59E0B' }}></div>
              </div>
              <div style={{ marginTop: '12px', color: '#94A3B8', fontSize: '0.85rem' }}>
                Restam R$ 150
              </div>
            </div>

            <div className={styles.glassCard} style={{ borderTop: '4px solid #3B82F6' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
                <Home size={24} color="#3B82F6" />
                <div style={{ fontSize: '1.2rem', fontWeight: 600 }}>Moradia & Contas</div>
              </div>
              <div className={styles.progressLabel}>
                <span>R$ 1.500 pagos</span>
                <span>Limite: R$ 1.600</span>
              </div>
              <div className={styles.progressBarTrack}>
                <div className={styles.progressBarFill} style={{ width: '93%', background: '#3B82F6' }}></div>
              </div>
              <div style={{ marginTop: '12px', color: '#94A3B8', fontSize: '0.85rem' }}>
                Restam R$ 100
              </div>
            </div>

            <div className={styles.glassCard} style={{ borderTop: '4px solid #10B981' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
                <Car size={24} color="#10B981" />
                <div style={{ fontSize: '1.2rem', fontWeight: 600 }}>Transporte</div>
              </div>
              <div className={styles.progressLabel}>
                <span>R$ 120 gastos</span>
                <span>Limite: R$ 400</span>
              </div>
              <div className={styles.progressBarTrack}>
                <div className={styles.progressBarFill} style={{ width: '30%', background: '#10B981' }}></div>
              </div>
              <div style={{ marginTop: '12px', color: '#94A3B8', fontSize: '0.85rem' }}>
                Restam R$ 280
              </div>
            </div>
          </div>
        </div>

        {/* Seção Contas e Cartões (Glassmorphism Dark) */}
        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>Suas Contas e Cartões</h2>
          <div className={styles.grid}>
            {/* Bank Account */}
            <div className={styles.glassCard}>
              <div className={styles.accountType}>Conta Corrente Principal</div>
              <div className={styles.accountName}>Nubank</div>
              <div className={styles.accountBalance}>R$ 12.458,30</div>
              <div className={styles.glassCardInner}>
                <div style={{ color: '#10B981', fontSize: '0.9rem', fontWeight: 600 }}>+ R$ 400,00 hoje</div>
                <button style={{ background: 'rgba(255,255,255,0.1)', border: 'none', color: '#fff', padding: '6px 12px', borderRadius: '8px', cursor: 'pointer' }}>
                  Extrato
                </button>
              </div>
            </div>

            {/* Credit Card */}
            <div className={styles.glassCard} style={{ background: 'linear-gradient(135deg, rgba(20,30,40,0.8) 0%, rgba(10,15,20,0.9) 100%)', border: '1px solid rgba(255,255,255,0.1)' }}>
              <CreditCard className={styles.cardIcon} size={100} style={{ opacity: 0.05 }} />
              <div className={styles.accountType}>Cartão de Crédito</div>
              <div className={styles.accountName}>Mastercard Black</div>
              <div style={{ display: 'flex', gap: '20px', marginTop: '16px' }}>
                <div>
                  <div style={{ fontSize: '0.8rem', color: '#94A3B8' }}>Fatura Atual</div>
                  <div style={{ fontSize: '1.4rem', fontWeight: 600 }}>R$ 1.845,22</div>
                </div>
                <div>
                  <div style={{ fontSize: '0.8rem', color: '#94A3B8' }}>Limite Disp.</div>
                  <div style={{ fontSize: '1.4rem', fontWeight: 600, color: '#10B981' }}>R$ 8.150,00</div>
                </div>
              </div>
              <div className={styles.glassCardInner}>
                <div style={{ fontSize: '0.9rem', color: '#94A3B8' }}>Vence em 10/Nov</div>
                <button style={{ background: '#3B82F6', border: 'none', color: '#fff', padding: '6px 12px', borderRadius: '8px', cursor: 'pointer', fontWeight: 600 }}>
                  Pagar Fatura
                </button>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
