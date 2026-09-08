// @vitest-environment jsdom
import React from "react";
import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { GradientMenu } from "../gradient-menu";

describe("GradientMenu component", () => {
  it("renders default menu items with accessible labels", () => {
    render(<GradientMenu />);
    const nav = screen.getByRole("navigation", { name: "Menu de ações rápidas" });
    expect(nav).toBeTruthy();

    expect(screen.getByRole("button", { name: "Início" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Novo" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Insights" })).toBeTruthy();
  });

  it("triggers onClick callback when an item is clicked", () => {
    const handleAction = vi.fn();
    const customItems = [
      {
        title: "Test Item",
        icon: <span>*</span>,
        gradientFrom: "#000",
        gradientTo: "#fff",
        onClick: handleAction,
      },
    ];

    render(<GradientMenu items={customItems} />);
    const button = screen.getByRole("button", { name: "Test Item" });
    fireEvent.click(button);
    expect(handleAction).toHaveBeenCalledTimes(1);
  });

  it("renders anchor link when href is provided", () => {
    const customItems = [
      {
        title: "Link Item",
        icon: <span>#</span>,
        gradientFrom: "#111",
        gradientTo: "#222",
        href: "/painel",
      },
    ];

    render(<GradientMenu items={customItems} />);
    const link = screen.getByRole("link", { name: "Link Item" }) as HTMLAnchorElement;
    expect(link.getAttribute("href")).toBe("/painel");
  });
});
