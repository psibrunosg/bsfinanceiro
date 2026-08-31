import { describe, it, expect, vi, beforeEach } from "vitest";
import { login, signup } from "./actions";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";

vi.mock("@/lib/supabase/server", () => ({
  createClient: vi.fn(),
}));

vi.mock("next/navigation", () => ({
  redirect: vi.fn(),
}));

describe("Authentication Server Actions", () => {
  let mockSupabase: { auth: { signInWithPassword: ReturnType<typeof vi.fn>; signUp: ReturnType<typeof vi.fn> } };

  beforeEach(() => {
    vi.resetAllMocks();
    mockSupabase = {
      auth: {
        signInWithPassword: vi.fn(),
        signUp: vi.fn(),
      },
    };
    vi.mocked(createClient).mockResolvedValue(mockSupabase);
  });

  describe("login", () => {
    it("returns validation error for invalid email", async () => {
      const data = new FormData();
      data.append("email", "invalid");
      data.append("password", "123456");

      const result = await login({}, data);
      expect(result).toEqual({ error: "Informe um e-mail valido." });
      expect(mockSupabase.auth.signInWithPassword).not.toHaveBeenCalled();
    });

    it("returns error on supabase auth failure", async () => {
      mockSupabase.auth.signInWithPassword.mockResolvedValue({ error: { message: "Invalid credentials" } });
      
      const data = new FormData();
      data.append("email", "test@example.com");
      data.append("password", "password123");

      const result = await login({}, data);
      expect(result).toEqual({ error: "E-mail ou senha incorretos." });
    });

    it("redirects to onboarding on success", async () => {
      mockSupabase.auth.signInWithPassword.mockResolvedValue({ error: null, data: { user: {} } });
      
      const data = new FormData();
      data.append("email", "test@example.com");
      data.append("password", "password123");

      await login({}, data);
      expect(redirect).toHaveBeenCalledWith("/onboarding");
    });
  });

  describe("signup", () => {
    it("returns validation error for weak password", async () => {
      const data = new FormData();
      data.append("email", "test@example.com");
      data.append("password", "short");

      const result = await signup({}, data);
      expect(result).toEqual({ error: "Use pelo menos 8 caracteres." });
    });

    it("returns error on supabase auth failure", async () => {
      mockSupabase.auth.signUp.mockResolvedValue({ error: { message: "User already registered" } });
      
      const data = new FormData();
      data.append("email", "test@example.com");
      data.append("password", "password123");

      const result = await signup({}, data);
      expect(result.error).toBeDefined();
    });

    it("returns success message on successful signup", async () => {
      mockSupabase.auth.signUp.mockResolvedValue({ error: null, data: { user: {} } });
      
      const data = new FormData();
      data.append("email", "test@example.com");
      data.append("password", "password123");

      const result = await signup({}, data);
      expect(result).toEqual({ success: "Conta criada. Confira seu e-mail para confirmar o acesso." });
      
      expect(mockSupabase.auth.signUp).toHaveBeenCalledWith({
        email: "test@example.com",
        password: "password123",
        options: { emailRedirectTo: expect.stringContaining("/auth/callback") }
      });
    });
  });
});
