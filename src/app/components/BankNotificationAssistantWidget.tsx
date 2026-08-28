"use client";

import { useState } from "react";
import {
  Bell,
  Check,
  CheckCircle2,
  Copy,
  Plus,
  Smartphone,
  Sparkles,
  Zap,
} from "lucide-react";
import { money } from "./Money";
import {
  parseBankNotification,
  ParsedBankNotification,
} from "@/lib/finance/bank-notification-parser";

type BankNotificationAssistantWidgetProps = {
  onAddTransaction?: (tx: {
    description: string;
    amount: number;
    type: "expense" | "income";
    category?: string;
  }) => void;
};

const SAMPLE_NOTIFICATIONS = [
  "Compra de R$ 42,90 aprovada no Nubank em Padaria Estrela.",
  "Você recebeu um Pix de R$ 300,00 de Rafael Lima no Banco Inter.",
  "Itau: Compra no cartao final 8820 no valor de R$ 129,00 em Droga Raia.",
];

export function BankNotificationAssistantWidget({
  onAddTransaction,
}: BankNotificationAssistantWidgetProps) {
  const [inputText, setInputText] = useState(SAMPLE_NOTIFICATIONS[0]);
  const [parsed, setParsed] = useState<ParsedBankNotification>(() =>
    parseBankNotification(SAMPLE_NOTIFICATIONS[0])
  );
  const [savedSuccess, setSavedSuccess] = useState(false);
  const [copiedShortcut, setCopiedShortcut] = useState(false);

  function handleProcessText(text: string) {
    setInputText(text);
    const res = parseBankNotification(text);
    setParsed(res);
    setSavedSuccess(false);
  }

  function handleConfirmSave() {
    if (parsed && parsed.amount > 0) {
      if (onAddTransaction) {
        onAddTransaction({
          description: parsed.description,
          amount: parsed.amount,
          type: parsed.type,
          category: parsed.suggestedCategory,
        });
      }
      setSavedSuccess(true);
      setTimeout(() => setSavedSuccess(false), 3000);
    }
  }

  function handleCopyShortcutInstructions() {
    const text = `1. Abra o app 'Atalhos' no iPhone e vá na aba 'Automação'.\n2. Toque em '+' e escolha 'Notificação do App'.\n3. Selecione os apps de banco (Nubank, Itaú, Inter, C6).\n4. Adicione a ação 'Obter texto da notificação' e chame o BS Financeiro para registrar a transação automaticamente.`;
    if (typeof navigator !== "undefined" && navigator?.clipboard?.writeText) {
      navigator.clipboard.writeText(text).catch(() => {});
    }
    setCopiedShortcut(true);
    setTimeout(() => setCopiedShortcut(false), 2500);
  }

  return (
    <section
      aria-label="Captura Automática via Notificações Bancárias do iOS"
      className="dashboard-card"
      style={{
        padding: "1.5rem",
        borderRadius: "16px",
        background: "var(--surface)",
        border: "1px solid var(--border)",
        boxShadow: "0 4px 20px rgba(0, 0, 0, 0.15)",
        marginBottom: "1.5rem",
      }}
    >
      <header
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: "1.25rem",
          flexWrap: "wrap",
          gap: "10px",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: "0.6rem" }}>
          <span
            style={{
              display: "inline-flex",
              alignItems: "center",
              justifyContent: "center",
              width: "36px",
              height: "36px",
              borderRadius: "10px",
              background: "rgba(139, 92, 246, 0.15)",
              color: "var(--primary, #8b5cf6)",
            }}
          >
            <Smartphone size={20} aria-hidden="true" />
          </span>
          <div>
            <h2
              style={{
                fontSize: "1.1rem",
                fontWeight: 700,
                letterSpacing: "-0.02em",
                margin: 0,
                color: "var(--text)",
              }}
            >
              Captura Automática via Notificações (iOS & Bancos)
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Cole notificações bancárias ou use o Atalho do iPhone para registrar gastos instantaneamente sem digitar.
            </p>
          </div>
        </div>

        {/* Badges de Automação */}
        <div style={{ display: "flex", gap: "6px", flexWrap: "wrap" }}>
          <span
            style={{
              fontSize: "0.75rem",
              fontWeight: 600,
              padding: "0.3rem 0.6rem",
              borderRadius: "20px",
              background: "rgba(139, 92, 246, 0.15)",
              color: "var(--primary, #8b5cf6)",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <Zap size={12} /> Automação iOS Shortcuts
          </span>

          <span
            style={{
              fontSize: "0.75rem",
              fontWeight: 600,
              padding: "0.3rem 0.6rem",
              borderRadius: "20px",
              background: "rgba(34, 197, 94, 0.15)",
              color: "var(--positive, #22c55e)",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <Sparkles size={12} /> IA Parser Multi-Banco
          </span>
        </div>
      </header>

      {/* Grid: Processador de Notificação + Guia do iOS */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Processador em Tempo Real */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
          }}
        >
          <div>
            <strong style={{ fontSize: "0.85rem", color: "var(--text)", display: "block", marginBottom: "8px" }}>
              Testar Notificação Bancária / SMS
            </strong>

            <textarea
              rows={2}
              value={inputText}
              onChange={(e) => handleProcessText(e.target.value)}
              placeholder="Cole a notificação do Nubank, Itaú, Inter, C6 ou Bradesco aqui..."
              style={{
                width: "100%",
                padding: "8px",
                fontSize: "0.8rem",
                borderRadius: "8px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                marginBottom: "8px",
                resize: "none",
              }}
            />

            {/* Exemplos Rápidos */}
            <div style={{ display: "flex", gap: "4px", flexWrap: "wrap", marginBottom: "12px" }}>
              {SAMPLE_NOTIFICATIONS.map((sample, i) => (
                <button
                  key={i}
                  type="button"
                  onClick={() => handleProcessText(sample)}
                  style={{
                    padding: "2px 6px",
                    borderRadius: "4px",
                    background: "var(--surface)",
                    border: "1px solid var(--border)",
                    fontSize: "0.65rem",
                    color: "var(--muted)",
                    cursor: "pointer",
                  }}
                >
                  Exemplo {i + 1}
                </button>
              ))}
            </div>

            {/* Card do Lançamento Extraído */}
            {parsed && (
              <div
                style={{
                  padding: "10px",
                  borderRadius: "8px",
                  background: "var(--surface)",
                  border: "1px solid var(--border)",
                  fontSize: "0.8rem",
                }}
              >
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "6px" }}>
                  <span
                    style={{
                      fontSize: "0.7rem",
                      fontWeight: 700,
                      padding: "2px 6px",
                      borderRadius: "4px",
                      background: parsed.type === "income" ? "rgba(34, 197, 94, 0.15)" : "rgba(239, 68, 68, 0.15)",
                      color: parsed.type === "income" ? "var(--positive, #22c55e)" : "var(--danger, #ef4444)",
                    }}
                  >
                    {parsed.type === "income" ? "Entrada (Pix/Depósito)" : "Saída (Compra)"} · {parsed.bank}
                  </span>
                  <span style={{ fontSize: "0.7rem", color: "var(--muted)" }}>
                    Cat: {parsed.suggestedCategory}
                  </span>
                </div>

                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
                  <strong style={{ color: "var(--text)", fontSize: "0.9rem" }}>{parsed.description}</strong>
                  <strong style={{ fontSize: "1.1rem", color: parsed.type === "income" ? "var(--positive, #22c55e)" : "var(--text)" }}>
                    {money(parsed.amount)}
                  </strong>
                </div>
              </div>
            )}
          </div>

          {/* Botão de Lançamento */}
          <div style={{ marginTop: "1rem" }}>
            <button
              type="button"
              onClick={handleConfirmSave}
              style={{
                width: "100%",
                padding: "8px 12px",
                borderRadius: "8px",
                background: savedSuccess ? "var(--positive, #22c55e)" : "var(--primary, #8b5cf6)",
                color: "#fff",
                border: "none",
                fontSize: "0.8rem",
                fontWeight: 700,
                cursor: "pointer",
                display: "inline-flex",
                alignItems: "center",
                justifyContent: "center",
                gap: "6px",
              }}
            >
              {savedSuccess ? <CheckCircle2 size={16} /> : <Plus size={16} />}
              {savedSuccess ? "Transação Registrada com Sucesso!" : "Registrar Transação com 1 Clique"}
            </button>
          </div>
        </div>

        {/* Bloco 2: Como Ativar no iPhone (iOS Shortcuts) */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
          }}
        >
          <div>
            <div style={{ display: "flex", alignItems: "center", gap: "6px", marginBottom: "8px" }}>
              <Bell size={16} color="var(--primary, #8b5cf6)" />
              <strong style={{ fontSize: "0.85rem", color: "var(--text)" }}>
                Como Criar a Automação no iPhone
              </strong>
            </div>

            <ol style={{ fontSize: "0.75rem", color: "var(--muted)", margin: "0 0 12px 1rem", padding: 0, lineHeight: "1.5" }}>
              <li>Abra o app <strong>Atalhos (Shortcuts)</strong> no iPhone.</li>
              <li>Acesse a aba <strong>Automação</strong> e crie uma <strong>Automação Pessoal</strong>.</li>
              <li>Escolha o gatilho <strong>Notificação do App</strong> (selecione Nubank, Itaú, Inter, etc).</li>
              <li>Adicione a ação para repassar o texto da notificação para o BS Financeiro.</li>
            </ol>
          </div>

          <button
            type="button"
            onClick={handleCopyShortcutInstructions}
            style={{
              padding: "8px 12px",
              borderRadius: "8px",
              background: "var(--surface)",
              border: "1px solid var(--border)",
              color: "var(--text)",
              fontSize: "0.75rem",
              fontWeight: 600,
              cursor: "pointer",
              display: "inline-flex",
              alignItems: "center",
              justifyContent: "center",
              gap: "6px",
            }}
          >
            {copiedShortcut ? <Check size={14} /> : <Copy size={14} />}
            {copiedShortcut ? "Instruções Copiadas!" : "Copiar Passo a Passo do Atalho"}
          </button>
        </div>
      </div>
    </section>
  );
}
