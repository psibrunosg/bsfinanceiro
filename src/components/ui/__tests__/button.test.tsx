// @vitest-environment jsdom
import React from "react";
import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { Button } from "../button";

describe("Button component", () => {
  it("renders with default primary variant and md size", () => {
    render(<Button>Confirmar</Button>);
    const button = screen.getByRole("button", { name: "Confirmar" }) as HTMLButtonElement;
    expect(button).toBeTruthy();
    expect(button.className).toContain("ui-button");
    expect(button.className).toContain("ui-button--primary");
    expect(button.className).toContain("ui-button--md");
  });

  it("applies secondary and glass variants correctly", () => {
    const { rerender } = render(<Button variant="glass">Vidro</Button>);
    let button = screen.getByRole("button", { name: "Vidro" });
    expect(button.className).toContain("ui-button--glass");

    rerender(<Button variant="secondary">Secundário</Button>);
    button = screen.getByRole("button", { name: "Secundário" });
    expect(button.className).toContain("ui-button--secondary");
  });

  it("applies glow class when glow prop is true", () => {
    render(<Button glow>Com Brilho</Button>);
    const button = screen.getByRole("button", { name: "Com Brilho" });
    expect(button.className).toContain("ui-button--glow");
  });

  it("handles onClick events and disabled state", () => {
    const handleClick = vi.fn();
    const { rerender } = render(<Button onClick={handleClick}>Ação</Button>);
    const button = screen.getByRole("button", { name: "Ação" });

    fireEvent.click(button);
    expect(handleClick).toHaveBeenCalledTimes(1);

    rerender(<Button onClick={handleClick} disabled>Desabilitado</Button>);
    const disabledBtn = screen.getByRole("button", { name: "Desabilitado" }) as HTMLButtonElement;
    expect(disabledBtn.disabled).toBe(true);
    fireEvent.click(disabledBtn);
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it("renders with custom icon and children", () => {
    render(
      <Button icon={<span data-testid="test-icon">+</span>}>
        Novo Item
      </Button>
    );
    expect(screen.getByTestId("test-icon")).toBeTruthy();
    expect(screen.getByText("Novo Item")).toBeTruthy();
  });
});
