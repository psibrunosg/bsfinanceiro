"use client";

import { useState, useRef, useEffect } from "react";
import { Bot, Send, Sparkles } from "lucide-react";
import {
  askFinancialAssistant,
  type FinancialAssistantData,
  type FinancialAssistantResponse,
} from "@/lib/finance/financial-assistant";

type Message = {
  id: string;
  sender: "user" | "assistant";
  text: string;
  chips?: string[];
  matchedTransactions?: FinancialAssistantResponse["matchedTransactions"];
};

type FinancialAssistantWidgetProps = {
  data: FinancialAssistantData;
};

export function FinancialAssistantWidget({ data }: FinancialAssistantWidgetProps) {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: "welcome",
      sender: "assistant",
      text: "Olá! Sou seu assistente financeiro inteligente. Como posso te ajudar a entender seus gastos hoje?",
      chips: [
        "Qual meu saldo total?",
        "Qual foi meu maior gasto?",
        "O que vence nos próximos dias?",
        "Quanto gastei com alimentação?",
      ],
    },
  ]);
  const [inputQuery, setInputQuery] = useState("");
  const chatBottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (typeof chatBottomRef.current?.scrollIntoView === "function") {
      chatBottomRef.current.scrollIntoView({ behavior: "smooth" });
    }
  }, [messages]);

  const handleSend = (queryText: string) => {
    const q = queryText.trim();
    if (!q) return;

    const userMsgId = `user-${Date.now()}`;
    const userMsg: Message = {
      id: userMsgId,
      sender: "user",
      text: q,
    };

    const res = askFinancialAssistant(q, data);
    const botMsg: Message = {
      id: `bot-${Date.now()}`,
      sender: "assistant",
      text: res.text,
      chips: res.chips,
      matchedTransactions: res.matchedTransactions,
    };

    setMessages((prev) => [...prev, userMsg, botMsg]);
    setInputQuery("");
  };

  return (
    <section
      className="dashboard-card"
      aria-label="Assistente Financeiro IA"
      style={{
        padding: "1.5rem",
        borderRadius: "16px",
        background: "var(--surface)",
        border: "1px solid var(--border)",
        boxShadow: "0 4px 20px rgba(0, 0, 0, 0.15)",
        marginBottom: "1.5rem",
        display: "flex",
        flexDirection: "column",
        gap: "1rem",
      }}
    >
      <header style={{ display: "flex", alignItems: "center", gap: "0.6rem" }}>
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
          <Bot size={20} />
        </span>
        <div>
          <h2 style={{ fontSize: "1.1rem", fontWeight: 700, margin: 0, color: "var(--text)" }}>
            Assistente Financeiro IA
          </h2>
          <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
            Pergunte sobre categorias, saldo, contas ou despesas em linguagem natural.
          </p>
        </div>
      </header>

      {/* Message history */}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: "12px",
          maxHeight: "320px",
          overflowY: "auto",
          padding: "8px 4px",
        }}
      >
        {messages.map((m) => (
          <div
            key={m.id}
            style={{
              display: "flex",
              flexDirection: "column",
              alignItems: m.sender === "user" ? "flex-end" : "flex-start",
              gap: "6px",
            }}
          >
            <div
              style={{
                maxWidth: "85%",
                padding: "10px 14px",
                borderRadius: m.sender === "user" ? "14px 14px 2px 14px" : "14px 14px 14px 2px",
                background:
                  m.sender === "user" ? "var(--primary, #8b5cf6)" : "var(--surface-2, rgba(255,255,255,0.04))",
                border: m.sender === "user" ? "none" : "1px solid var(--border)",
                color: m.sender === "user" ? "#ffffff" : "var(--text)",
                fontSize: "0.88rem",
                whiteSpace: "pre-line",
                lineHeight: "1.5",
              }}
            >
              {m.text}

              {/* Matched Transactions details */}
              {m.matchedTransactions && m.matchedTransactions.length > 0 && (
                <div
                  style={{
                    marginTop: "8px",
                    paddingTop: "8px",
                    borderTop: "1px solid rgba(255,255,255,0.1)",
                    fontSize: "0.78rem",
                  }}
                >
                  <strong style={{ display: "block", marginBottom: "4px" }}>Movimentações detalhadas:</strong>
                  {m.matchedTransactions.slice(0, 4).map((tx) => (
                    <div
                      key={tx.id}
                      style={{
                        display: "flex",
                        justifyContent: "space-between",
                        padding: "2px 0",
                        color: "var(--muted)",
                      }}
                    >
                      <span>{tx.description} ({tx.competence_date})</span>
                      <span style={{ fontWeight: 600, color: "var(--text)" }}>
                        R$ {Number(tx.amount).toFixed(2).replace(".", ",")}
                      </span>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Chips suggested */}
            {m.chips && m.chips.length > 0 && (
              <div
                style={{
                  display: "flex",
                  flexWrap: "wrap",
                  gap: "6px",
                  marginTop: "2px",
                }}
              >
                {m.chips.map((chip, idx) => (
                  <button
                    key={idx}
                    type="button"
                    onClick={() => handleSend(chip)}
                    style={{
                      background: "rgba(139, 92, 246, 0.1)",
                      border: "1px solid rgba(139, 92, 246, 0.25)",
                      color: "var(--accent, #8b5cf6)",
                      borderRadius: "16px",
                      padding: "4px 10px",
                      fontSize: "0.75rem",
                      cursor: "pointer",
                      display: "inline-flex",
                      alignItems: "center",
                      gap: "4px",
                      transition: "background 0.2s",
                    }}
                  >
                    <Sparkles size={11} />
                    {chip}
                  </button>
                ))}
              </div>
            )}
          </div>
        ))}
        <div ref={chatBottomRef} />
      </div>

      {/* Input box */}
      <form
        onSubmit={(e) => {
          e.preventDefault();
          handleSend(inputQuery);
        }}
        style={{
          display: "flex",
          alignItems: "center",
          gap: "8px",
          borderTop: "1px solid var(--border)",
          paddingTop: "12px",
        }}
      >
        <input
          type="text"
          value={inputQuery}
          onChange={(e) => setInputQuery(e.target.value)}
          placeholder="Faça uma pergunta sobre seus gastos..."
          style={{
            flex: 1,
            padding: "10px 14px",
            borderRadius: "10px",
            border: "1px solid var(--border)",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            color: "var(--text)",
            fontSize: "0.88rem",
            outline: "none",
          }}
        />
        <button
          type="submit"
          aria-label="Enviar pergunta"
          disabled={!inputQuery.trim()}
          style={{
            display: "inline-flex",
            alignItems: "center",
            justifyContent: "center",
            width: "40px",
            height: "40px",
            borderRadius: "10px",
            background: "var(--primary, #8b5cf6)",
            border: "none",
            color: "#ffffff",
            cursor: inputQuery.trim() ? "pointer" : "not-allowed",
            opacity: inputQuery.trim() ? 1 : 0.5,
          }}
        >
          <Send size={16} />
        </button>
      </form>
    </section>
  );
}
