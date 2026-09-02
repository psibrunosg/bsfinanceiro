"use client";
export function PrintButton() {
  return (
    <button onClick={() => window.print()} style={{ padding: "8px 16px", background: "#000", color: "#fff", border: "none", borderRadius: "6px", cursor: "pointer", marginTop: "1rem" }} className="no-print">
      Imprimir / Salvar PDF
    </button>
  );
}
