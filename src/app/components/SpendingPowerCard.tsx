import type { SpendingPower } from "../../lib/finance/spending-power";
import { dateFmt, money } from "./Money";

export function SpendingPowerCard({
  spendingPower,
}: {
  spendingPower: SpendingPower;
}) {
  return (
    <section
      className="spending-power-card"
      aria-labelledby="spending-power-title"
    >
      <h2 id="spending-power-title">Disponível para gastar</h2>
      <strong>{money(spendingPower.availableCents / 100)}</strong>
      <small>
        {spendingPower.nextIncomeDate ? (
          <>
            Até{" "}
            {dateFmt.format(
              new Date(`${spendingPower.nextIncomeDate}T12:00:00`),
            )}
          </>
        ) : (
          "Considerando os próximos 30 dias"
        )}
      </small>
      <details>
        <summary>Como calculamos</summary>
        <p>
          Compromissos reservados:{" "}
          {money(spendingPower.reservedCommitmentsCents / 100)}
        </p>
        <p>
          Despesas planejadas:{" "}
          {money(spendingPower.reservedExpenseCents / 100)}
        </p>
      </details>
    </section>
  );
}
