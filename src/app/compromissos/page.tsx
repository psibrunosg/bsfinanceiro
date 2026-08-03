import { redirect } from "next/navigation";

// /compromissos foi absorvido pelo hub de Gastos na aba Recorrentes.
export default function Page() {
  redirect("/gastos?tab=recorrentes");
}
