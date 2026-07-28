// @vitest-environment jsdom
import React from "react";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({ getUser: vi.fn(), rpc: vi.fn() }));

vi.mock("../../lib/app-path", () => ({ appPath: (path: string) => path, LOGO_URL: "/logo.png" }));
vi.mock("../../lib/supabase/client", () => ({
  createClient: () => ({ auth: { getUser: mocks.getUser }, rpc: mocks.rpc }),
}));

import { OnboardingForm } from "./onboarding-form";

describe("OnboardingForm", () => {
  it("bloqueia reenvio e reabilita o formulário após erro da RPC", async () => {
    let finish!: (value: { error: { message: string } }) => void;
    mocks.getUser.mockResolvedValue({ data: { user: { id: "user-1" } } });
    mocks.rpc.mockImplementation(() => new Promise((resolve) => { finish = resolve; }));

    render(<OnboardingForm suggestedName="Bruno" />);
    fireEvent.change(screen.getByLabelText("Renda mensal"), { target: { value: "4000" } });
    fireEvent.change(screen.getByLabelText("Saldo atual"), { target: { value: "1200" } });
    fireEvent.change(screen.getByLabelText("Nome do cartão"), { target: { value: "Nubank" } });
    fireEvent.change(screen.getByLabelText("Fecha dia"), { target: { value: "5" } });
    fireEvent.change(screen.getByLabelText("Vence dia"), { target: { value: "12" } });
    fireEvent.submit(screen.getByRole("button", { name: "Concluir e ver meu painel" }).closest("form")!);

    await waitFor(() => expect(mocks.rpc).toHaveBeenCalledWith("complete_compact_onboarding", {
      p_display_name: "Bruno",
      p_monthly_income: 4000,
      p_current_balance: 1200,
      p_card_name: "Nubank",
      p_card_closing_day: 5,
      p_card_due_day: 12,
    }));
    expect(screen.getByLabelText("Renda mensal").matches(":disabled")).toBe(true);
    expect(screen.getByRole("button", { name: "Salvando..." }).matches(":disabled")).toBe(true);

    finish({ error: { message: "offline" } });

    await waitFor(() => {
      expect(screen.getByRole("alert").textContent).toContain("Não foi possível concluir agora");
      expect(screen.getByLabelText("Renda mensal").matches(":disabled")).toBe(false);
      expect(screen.getByRole("button", { name: "Concluir e ver meu painel" }).matches(":disabled")).toBe(false);
    });
  });
});
