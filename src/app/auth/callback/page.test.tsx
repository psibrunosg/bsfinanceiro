// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import AuthCallbackPage from "./page";
import { createClient } from "@/lib/supabase/client";
import { SupabaseClient } from "@supabase/supabase-js";

vi.mock("@/lib/supabase/client", () => ({
  createClient: vi.fn(),
}));

describe("AuthCallbackPage", () => {
  let mockExchangeCodeForSession: ReturnType<typeof vi.fn>;

  beforeEach(() => {
    vi.resetAllMocks();
    mockExchangeCodeForSession = vi.fn().mockResolvedValue({ error: null });
    vi.mocked(createClient).mockReturnValue({
      auth: { exchangeCodeForSession: mockExchangeCodeForSession }
    } as unknown as SupabaseClient);
    
    // Mock window.location
    Object.defineProperty(window, 'location', {
      value: {
        search: '?code=valid-code',
        pathname: '/',
        replace: vi.fn()
      },
      writable: true
    });
  });

  it("renders loading state", () => {
    render(<AuthCallbackPage />);
    expect(screen.getByText("Confirmando seu acesso...")).toBeDefined();
  });

  it("redirects to error if no code is present", async () => {
    window.location.search = '';
    render(<AuthCallbackPage />);
    
    // The effect runs immediately
    await new Promise(r => setTimeout(r, 0));
    
    expect(window.location.replace).toHaveBeenCalledWith("/entrar?erro=confirmacao");
    expect(mockExchangeCodeForSession).not.toHaveBeenCalled();
  });

  it("exchanges code and redirects to home on success", async () => {
    mockExchangeCodeForSession.mockResolvedValue({ error: null });
    
    render(<AuthCallbackPage />);
    
    await new Promise(r => setTimeout(r, 0));
    
    expect(mockExchangeCodeForSession).toHaveBeenCalledWith("valid-code");
    expect(window.location.replace).toHaveBeenCalledWith("/");
  });

  it("exchanges code and redirects to error on failure", async () => {
    mockExchangeCodeForSession.mockResolvedValue({ error: { message: "Invalid code" } });
    
    render(<AuthCallbackPage />);
    
    await new Promise(r => setTimeout(r, 0));
    
    expect(mockExchangeCodeForSession).toHaveBeenCalledWith("valid-code");
    expect(window.location.replace).toHaveBeenCalledWith("/entrar?erro=confirmacao");
  });
});
