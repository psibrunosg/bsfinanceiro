import { describe, it, expect } from "vitest";
import { parseBankNotification } from "./bank-notification-parser";

describe("bank-notification-parser", () => {
  it("parses Nubank card purchase notification", () => {
    const text = "Compra de R$ 68,50 aprovada no Nubank em Padaria Bella Paulista.";
    const res = parseBankNotification(text);

    expect(res.bank).toBe("Nubank");
    expect(res.type).toBe("expense");
    expect(res.amount).toBe(68.5);
    expect(res.description).toContain("Padaria Bella Paulista");
    expect(res.suggestedCategory).toBe("Alimentação");
  });

  it("parses incoming Pix notification (income)", () => {
    const text = "Você recebeu um Pix de R$ 250,00 de Mariana Souza no Banco Inter.";
    const res = parseBankNotification(text);

    expect(res.bank).toBe("Inter");
    expect(res.type).toBe("income");
    expect(res.amount).toBe(250);
    expect(res.description).toContain("Mariana Souza");
  });

  it("parses Itaú card transaction", () => {
    const text = "Itau: Compra aprovada de R$ 142,90 no cartao final 5521 em Drogasil.";
    const res = parseBankNotification(text);

    expect(res.bank).toBe("Itaú");
    expect(res.type).toBe("expense");
    expect(res.amount).toBe(142.9);
    expect(res.suggestedCategory).toBe("Saúde");
  });

  it("parses outgoing Pix transfer to merchant", () => {
    const text = "Você transferiu R$ 45,00 para Farmácia Raia via Pix.";
    const res = parseBankNotification(text);

    expect(res.type).toBe("expense");
    expect(res.amount).toBe(45);
    expect(res.description).toContain("Farmácia Raia");
    expect(res.suggestedCategory).toBe("Saúde");
  });

  it("parses Santander Pix payment", () => {
    const text = "Santander: Pix enviado de R$ 85,00 para Posto Ipiranga com sucesso.";
    const res = parseBankNotification(text);

    expect(res.bank).toBe("Santander");
    expect(res.type).toBe("expense");
    expect(res.amount).toBe(85);
    expect(res.description).toContain("Posto Ipiranga");
    expect(res.suggestedCategory).toBe("Transporte");
  });
});
