// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, cleanup, fireEvent, waitFor } from "@testing-library/react";
import { AuthForm } from "./auth-form";
import { createClient } from "@/lib/supabase/client";

vi.mock("@/lib/supabase/client", () => ({
  createClient: vi.fn(),
}));

describe("AuthForm", () => {
  let mockSupabase: { auth: { signInWithPassword: ReturnType<typeof vi.fn>; getSession: ReturnType<typeof vi.fn> } };

  beforeEach(() => {
    cleanup();
    vi.resetAllMocks();
    mockSupabase = {
      auth: {
        signInWithPassword: vi.fn().mockResolvedValue({ error: null }),
        signUp: vi.fn().mockResolvedValue({ error: null }),
      },
    };
    vi.mocked(createClient).mockReturnValue(mockSupabase);
    
    // Mock window.location
    Object.defineProperty(window, 'location', {
      value: {
        search: '',
        pathname: '/',
        replace: vi.fn()
      },
      writable: true
    });
    
    // Mock fetch
    global.fetch = vi.fn().mockResolvedValue({
      ok: false,
      json: () => Promise.resolve({}),
    });
  });

  it("renders login form and authenticates with supabase as fallback", async () => {
    mockSupabase.auth.signInWithPassword.mockResolvedValue({ error: null });
    
    render(<AuthForm mode="login" />);
    
    const emailInput = screen.getByLabelText("E-mail");
    const passwordInput = screen.getByLabelText("Senha");
    const submitBtn = screen.getByRole("button", { name: "Entrar" });
    
    fireEvent.change(emailInput, { target: { value: "test@example.com" } });
    fireEvent.change(passwordInput, { target: { value: "password123" } });
    fireEvent.click(submitBtn);
    
    await waitFor(() => {
      expect(mockSupabase.auth.signInWithPassword).toHaveBeenCalledWith({
        email: "test@example.com",
        password: "password123",
      });
      expect(window.location.replace).toHaveBeenCalledWith("/");
    });
  });

  it("renders signup form and shows error from supabase", async () => {
    mockSupabase.auth.signUp.mockResolvedValue({ error: { message: "User already registered" } });
    
    render(<AuthForm mode="signup" />);
    
    const emailInput = screen.getByLabelText("E-mail");
    const passwordInput = screen.getByLabelText("Senha");
    const submitBtn = screen.getByRole("button", { name: "Criar conta" });
    
    fireEvent.change(emailInput, { target: { value: "test@example.com" } });
    fireEvent.change(passwordInput, { target: { value: "password123" } });
    fireEvent.click(submitBtn);
    
    await waitFor(() => {
      expect(screen.getByRole("alert")).toBeDefined();
    });
  });

  it("authenticates via postgres API primarily", async () => {
    global.fetch = vi.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({ success: true, user: { id: "1" }, workspace: { id: "1" } }),
    });
    
    render(<AuthForm mode="login" />);
    
    fireEvent.change(screen.getByLabelText("E-mail"), { target: { value: "test@example.com" } });
    fireEvent.change(screen.getByLabelText("Senha"), { target: { value: "password123" } });
    fireEvent.click(screen.getByRole("button", { name: "Entrar" }));
    
    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith("/api/auth/login", expect.any(Object));
      expect(mockSupabase.auth.signInWithPassword).not.toHaveBeenCalled();
      expect(window.location.replace).toHaveBeenCalledWith("/");
    });
  });
});
