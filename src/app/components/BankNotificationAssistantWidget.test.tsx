// @vitest-environment jsdom
import { describe, it, expect, afterEach, vi } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { BankNotificationAssistantWidget } from "./BankNotificationAssistantWidget";

describe("BankNotificationAssistantWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders notification parser and allows 1-click transaction registration", () => {
    const onAdd = vi.fn();
    render(<BankNotificationAssistantWidget onAddTransaction={onAdd} />);

    expect(screen.getByText("Captura Automática via Notificações (iOS & Bancos)")).toBeDefined();
    expect(screen.getByText("Testar Notificação Bancária / SMS")).toBeDefined();
    expect(screen.getByText("Como Criar a Automação no iPhone")).toBeDefined();

    const saveBtn = screen.getByRole("button", { name: /Registrar Transação com 1 Clique/i });
    fireEvent.click(saveBtn);

    expect(onAdd).toHaveBeenCalledWith(
      expect.objectContaining({
        type: "expense",
        amount: 42.9,
      })
    );
  });
});
