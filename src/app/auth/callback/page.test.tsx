// @vitest-environment jsdom
import { render, screen } from "@testing-library/react";
import { expect, it } from "vitest";
import AuthCallbackPage from "./page";
it("provides a safe login path for retired confirmation links", () => {
  render(<AuthCallbackPage />);
  expect(screen.getByRole("link", { name: "Ir para o acesso" }).getAttribute("href")).toBe("/entrar");
});
