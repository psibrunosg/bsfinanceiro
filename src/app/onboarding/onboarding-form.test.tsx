// @vitest-environment jsdom
import React from "react";
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
const mocks = vi.hoisted(() => ({ fetch: vi.fn() }));
vi.mock("@/lib/api-client", () => ({ apiFetch: mocks.fetch }));
vi.mock("../../lib/app-path", () => ({ appPath: (path: string) => path, LOGO_URL: "/logo.png" }));
import { OnboardingForm } from "./onboarding-form";
afterEach(() => cleanup());
beforeEach(() => { mocks.fetch.mockReset(); });
function fillValidForm() {
  for (const [label, value] of [["Renda mensal","4000"],["Saldo atual","1200"],["Nome do cartão","Nubank"],["Fecha dia","5"],["Vence dia","12"]]) fireEvent.change(screen.getByLabelText(label), { target: { value } });
}
describe("OnboardingForm", () => {
 it("submits authenticated VPS data, disables resends and focuses server field errors", async () => {
  let finish!: (value: unknown) => void;
  mocks.fetch.mockImplementation(() => new Promise(resolve => { finish=resolve; }));
  render(<OnboardingForm suggestedName="Bruno" />); fillValidForm();
  fireEvent.submit(screen.getByRole("button", { name:"Concluir e ver meu painel" }).closest("form")!);
  await waitFor(() => expect(mocks.fetch).toHaveBeenCalledWith("/api/onboarding", expect.objectContaining({ method:"POST", body: JSON.stringify({display_name:"Bruno",monthly_income:4000,current_balance:1200,card_name:"Nubank",closing_day:5,due_day:12}) })));
  expect(screen.getByLabelText("Renda mensal").matches(":disabled")).toBe(true);
  finish({ok:false,json:async()=>({error:"invalid card day"})});
  await waitFor(()=>expect(document.activeElement).toBe(screen.getByLabelText("Fecha dia")));
  expect(screen.getByLabelText("Fecha dia").getAttribute("aria-describedby")).toBe("closing_day-error");
 });
 it("validates input before calling API", async()=>{
  render(<OnboardingForm suggestedName="Bruno" />);
  fireEvent.submit(screen.getByRole("button",{name:"Concluir e ver meu painel"}).closest("form")!);
  await waitFor(()=>expect(document.activeElement).toBe(screen.getByLabelText("Renda mensal")));
  expect(mocks.fetch).not.toHaveBeenCalled();
 });
 it("recovers from network failure with an actionable error", async()=>{
  mocks.fetch.mockRejectedValue(new Error("network")); render(<OnboardingForm suggestedName="Bruno" />); fillValidForm();
  fireEvent.submit(screen.getByRole("button",{name:"Concluir e ver meu painel"}).closest("form")!);
  await waitFor(()=>expect(screen.getByRole("alert").textContent).toContain("indisponível"));
  expect(screen.getByRole("button",{name:"Concluir e ver meu painel"}).matches(":disabled")).toBe(false);
 });
});
