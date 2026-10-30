// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, cleanup, fireEvent, waitFor } from "@testing-library/react";
import { AuthForm } from "./auth-form";

describe("AuthForm", () => {
  beforeEach(() => {
    cleanup();
    vi.resetAllMocks();
    localStorage.clear();

    Object.defineProperty(window, "location", {
      value: {
        search: "",
        pathname: "/",
        replace: vi.fn(),
      },
      writable: true,
    });

    global.fetch = vi.fn().mockResolvedValue({
      ok: false,
      json: () => Promise.resolve({ error: "E-mail ou senha inválidos." }),
    });
  });

  it("renders login form and reports VPS authentication errors", async () => {
    render(<AuthForm mode="login" />);

    fireEvent.change(screen.getByLabelText("E-mail"), {
      target: { value: "test@example.com" },
    });
    fireEvent.change(screen.getByLabelText("Senha"), {
      target: { value: "password123" },
    });
    fireEvent.click(screen.getByRole("button", { name: "Entrar" }));

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith("/api/auth/login", expect.any(Object));
      expect(screen.getByRole("alert").textContent).toContain("E-mail ou senha inválidos");
    });
  });

  it("renders signup form and shows registration errors from the VPS", async () => {
    global.fetch = vi.fn().mockResolvedValue({
      ok: false,
      json: () => Promise.resolve({ error: "Este e-mail já está cadastrado. Faça login." }),
    });

    render(<AuthForm mode="signup" />);

    fireEvent.change(screen.getByLabelText("E-mail"), {
      target: { value: "test@example.com" },
    });
    fireEvent.change(screen.getByLabelText("Senha"), {
      target: { value: "password123" },
    });
    fireEvent.click(screen.getByRole("button", { name: "Criar conta" }));

    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith("/api/auth/register", expect.any(Object));
      expect(screen.getByRole("alert").textContent).toContain("já está cadastrado");
    });
  });

  it("authenticates via postgres API and persists the local session", async () => {
    global.fetch = vi.fn().mockResolvedValue({
      ok: true,
      json: () =>
        Promise.resolve({
          success: true,
          user: { id: "user-1", email: "test@example.com" },
          workspace: { id: "workspace-1", name: "Pessoal" },
          token: "signed-token",
        }),
    });

    render(<AuthForm mode="login" />);

    fireEvent.change(screen.getByLabelText("E-mail"), {
      target: { value: "test@example.com" },
    });
    fireEvent.change(screen.getByLabelText("Senha"), {
      target: { value: "password123" },
    });
    fireEvent.click(screen.getByRole("button", { name: "Entrar" }));

    await waitFor(() => {
      expect(localStorage.getItem("bsfinanceiro_token")).toBe("signed-token");
      expect(localStorage.getItem("bsfinanceiro_user")).toContain("user-1");
      expect(localStorage.getItem("bsfinanceiro_workspace")).toContain("workspace-1");
      expect(window.location.replace).toHaveBeenCalledWith("/");
    });
  });
});
