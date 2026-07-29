"use client";

import { useMemo, useRef, useState, type FormEvent } from "react";
import { todayInSaoPaulo } from "@/lib/finance/local-date";
import { createClient } from "@/lib/supabase/client";
import { parseMoney } from "./Money";
import type { Account, Category } from "./types";

type TransactionType = "expense" | "income";

type QuickTransactionFormProps = {
  workspaceId: string;
  ownerId: string;
  defaultCashAccountId: string | null;
  accounts: Account[];
  categories: Category[];
  onSubmitStart: () => void;
  onSaved: () => Promise<void>;
};

export function QuickTransactionForm({
  workspaceId,
  ownerId,
  defaultCashAccountId,
  accounts,
  categories,
  onSubmitStart,
  onSaved,
}: QuickTransactionFormProps) {
  const supabase = useMemo(() => createClient(), []);
  const today = useMemo(todayInSaoPaulo, []);
  const initialAccountId =
    accounts.find((account) => account.id === defaultCashAccountId)?.id ?? "";
  const [type, setType] = useState<TransactionType>("expense");
  const [amount, setAmount] = useState("");
  const [description, setDescription] = useState("");
  const [selectedAccountId, setSelectedAccountId] =
    useState(initialAccountId);
  const [selectedCategoryId, setSelectedCategoryId] = useState("");
  const [selectedDate, setSelectedDate] = useState(today);
  const [pending, setPending] = useState(false);
  const [error, setError] = useState("");
  const [status, setStatus] = useState("");
  const submittingRef = useRef(false);
  const detailsRef = useRef<HTMLDetailsElement>(null);
  const accountRef = useRef<HTMLSelectElement>(null);

  const availableCategories = categories.filter(
    (category) => category.kind === type,
  );

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (submittingRef.current) return;

    onSubmitStart();
    setError("");
    setStatus("");

    if (!accounts.some((account) => account.id === selectedAccountId)) {
      if (detailsRef.current) detailsRef.current.open = true;
      accountRef.current?.focus();
      setError("Escolha uma conta.");
      return;
    }

    const parsedAmount = parseMoney(amount);
    if (!Number.isFinite(parsedAmount) || parsedAmount <= 0) {
      setError("Informe um valor maior que zero.");
      return;
    }

    const trimmedDescription = description.trim();
    if (!trimmedDescription) {
      setError("Informe uma descrição.");
      return;
    }

    if (!selectedDate) {
      setError("Informe uma data.");
      return;
    }

    const categoryId = availableCategories.some(
      (category) => category.id === selectedCategoryId,
    )
      ? selectedCategoryId
      : null;

    submittingRef.current = true;
    setPending(true);

    try {
      const { error: insertError } = await supabase
        .from("transactions")
        .insert({
          workspace_id: workspaceId,
          owner_id: ownerId,
          account_id: selectedAccountId,
          category_id: categoryId,
          destination_account_id: null,
          type,
          amount: parsedAmount,
          description: trimmedDescription,
          competence_date: selectedDate,
          paid_at: selectedDate,
          status: "paid",
          idempotency_key: crypto.randomUUID(),
        });

      if (insertError) {
        setError("Não foi possível registrar. Tente novamente.");
        return;
      }

      setAmount("");
      setDescription("");

      try {
        await onSaved();
        setStatus("Movimentação registrada.");
      } catch {
        setStatus(
          "Movimentação registrada, mas o painel não pôde ser atualizado.",
        );
      }
    } catch {
      setError("Não foi possível registrar. Tente novamente.");
    } finally {
      submittingRef.current = false;
      setPending(false);
    }
  }

  return (
    <section className="quick-transaction-card" aria-labelledby="quick-entry-title">
      <div className="quick-transaction-heading">
        <div>
          <p className="eyebrow">Registro rápido</p>
          <h2 id="quick-entry-title">Como seu saldo mudou?</h2>
        </div>
        {selectedDate === today ? <span>Pago hoje</span> : null}
      </div>

      <form className="quick-transaction-form" onSubmit={submit}>
        <fieldset className="quick-transaction-type">
          <legend>Tipo</legend>
          <label>
            <input
              type="radio"
              name="type"
              value="expense"
              checked={type === "expense"}
              onChange={() => {
                setType("expense");
                setSelectedCategoryId("");
              }}
            />
            Despesa
          </label>
          <label>
            <input
              type="radio"
              name="type"
              value="income"
              checked={type === "income"}
              onChange={() => {
                setType("income");
                setSelectedCategoryId("");
              }}
            />
            Receita
          </label>
        </fieldset>

        <label className="quick-transaction-field">
          <span>Valor</span>
          <input
            name="amount"
            inputMode="decimal"
            placeholder="0,00"
            value={amount}
            onChange={(event) => setAmount(event.currentTarget.value)}
            aria-required="true"
          />
        </label>

        <label className="quick-transaction-field quick-description">
          <span>Descrição</span>
          <input
            name="description"
            placeholder="Ex.: café, salário"
            value={description}
            onChange={(event) => setDescription(event.currentTarget.value)}
            aria-required="true"
          />
        </label>

        <button type="submit" disabled={pending} aria-busy={pending}>
          {pending ? "Registrando..." : "Registrar"}
        </button>

        <details className="quick-transaction-details" ref={detailsRef}>
          <summary>Mais detalhes</summary>
          <div>
            <label className="quick-transaction-field">
              <span>Conta</span>
              <select
                ref={accountRef}
                name="account_id"
                value={selectedAccountId}
                onChange={(event) => {
                  setSelectedAccountId(event.currentTarget.value);
                  if (error === "Escolha uma conta.") setError("");
                }}
                aria-required="true"
                aria-invalid={
                  error === "Escolha uma conta." ? "true" : undefined
                }
                aria-describedby={
                  error === "Escolha uma conta."
                    ? "quick-transaction-account-error"
                    : undefined
                }
              >
                <option value="">Escolha uma conta</option>
                {accounts.map((account) => (
                  <option key={account.id} value={account.id}>
                    {account.name}
                  </option>
                ))}
              </select>
            </label>

            <label className="quick-transaction-field">
              <span>Categoria</span>
              <select
                name="category_id"
                value={selectedCategoryId}
                onChange={(event) =>
                  setSelectedCategoryId(event.currentTarget.value)
                }
              >
                <option value="">Sem categoria</option>
                {availableCategories.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.name}
                  </option>
                ))}
              </select>
            </label>

            <label className="quick-transaction-field">
              <span>Data</span>
              <input
                name="competence_date"
                type="date"
                value={selectedDate}
                onChange={(event) => setSelectedDate(event.currentTarget.value)}
                aria-required="true"
              />
            </label>
          </div>
        </details>

        {error ? (
          <p
            className="form-error quick-transaction-message"
            id={
              error === "Escolha uma conta."
                ? "quick-transaction-account-error"
                : undefined
            }
            role="alert"
          >
            {error}
          </p>
        ) : null}
        {status ? (
          <p className="form-success quick-transaction-message" role="status">
            {status}
          </p>
        ) : null}
      </form>
    </section>
  );
}
