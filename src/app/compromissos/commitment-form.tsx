"use client";

import { useActionState } from "react";
import { LoaderCircle } from "lucide-react";
import {
  createCommitment,
  updateCommitment,
  type CommitmentState,
} from "./actions";

type Option = { id: string; name: string };
type Initial = {
  id: string;
  description: string;
  amount: number;
  due_day: number;
  account_id: string | null;
  category_id: string | null;
};

export function CommitmentForm({
  accounts,
  categories,
  initial,
  compact = false,
}: {
  accounts: Option[];
  categories: Option[];
  initial?: Initial;
  compact?: boolean;
}) {
  const action = initial ? updateCommitment : createCommitment;
  const [state, formAction, pending] = useActionState<CommitmentState, FormData>(
    action,
    {},
  );
  return (
    <form action={formAction} className={`finance-form commitment-form${compact ? " compact" : ""}`}>
      {initial ? <input type="hidden" name="id" value={initial.id} /> : null}
      <label htmlFor={`description-${initial?.id ?? "new"}`}>Descrição</label>
      <input
        id={`description-${initial?.id ?? "new"}`}
        name="description"
        defaultValue={initial?.description}
        placeholder="Ex.: Aluguel"
        maxLength={100}
        required
      />
      <div className="commitment-fields">
        <div>
          <label htmlFor={`amount-${initial?.id ?? "new"}`}>Valor</label>
          <div className="money-input">
            <span>R$</span>
            <input
              id={`amount-${initial?.id ?? "new"}`}
              name="amount"
              inputMode="decimal"
              defaultValue={initial ? initial.amount.toFixed(2).replace(".", ",") : ""}
              placeholder="0,00"
              required
            />
          </div>
        </div>
        <div>
          <label htmlFor={`due-${initial?.id ?? "new"}`}>Dia do vencimento</label>
          <input
            id={`due-${initial?.id ?? "new"}`}
            name="due_day"
            type="number"
            min="1"
            max="31"
            defaultValue={initial?.due_day ?? 10}
            required
          />
        </div>
      </div>
      <label htmlFor={`account-${initial?.id ?? "new"}`}>Conta para pagamento (opcional)</label>
      <select id={`account-${initial?.id ?? "new"}`} name="account_id" defaultValue={initial?.account_id ?? ""}>
        <option value="">Definir depois</option>
        {accounts.map((account) => <option key={account.id} value={account.id}>{account.name}</option>)}
      </select>
      <label htmlFor={`category-${initial?.id ?? "new"}`}>Categoria (opcional)</label>
      <select id={`category-${initial?.id ?? "new"}`} name="category_id" defaultValue={initial?.category_id ?? ""}>
        <option value="">Sem categoria</option>
        {categories.map((category) => <option key={category.id} value={category.id}>{category.name}</option>)}
      </select>
      {state.error ? <p className="form-error" role="alert">{state.error}</p> : null}
      {state.success ? <p className="form-success" role="status">{state.success}</p> : null}
      <button disabled={pending}>
        {pending ? <LoaderCircle className="spin" /> : null}
        {pending ? "Salvando..." : initial ? "Salvar alterações" : "Adicionar compromisso"}
      </button>
    </form>
  );
}
