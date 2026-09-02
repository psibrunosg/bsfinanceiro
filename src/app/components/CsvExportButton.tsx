"use client";
import { Category } from "./types";

export function CsvExportButton({ transactions, categories }: { transactions: Array<{ competence_date: string; type: string; amount: string | number; category_id?: string | null; account_id?: string | null; description?: string | null; id: string; }>, categories: Category[] }) {
  function handleDownload() {
    const header = ["Data", "Descrição", "Tipo", "Valor", "Categoria", "Conta"];
    const rows = transactions.map(t => {
      const cat = categories.find(c => c.id === t.category_id)?.name || "";
      return [
        t.competence_date,
        t.description || "",
        t.type,
        t.amount.toString(),
        cat,
        t.account_id || ""
      ].map(field => `"${field}"`).join(",");
    });
    
    const csvContent = [header.join(","), ...rows].join("\n");
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.setAttribute("download", `extrato-${new Date().toISOString().split("T")[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  return (
    <button type="button" onClick={handleDownload} className="primary-button">Baixar CSV</button>
  );
}
