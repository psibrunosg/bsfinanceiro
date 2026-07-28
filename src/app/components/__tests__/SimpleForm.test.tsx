// @vitest-environment jsdom
import React from "react";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { SimpleForm } from "../SimpleForm";

describe("SimpleForm", () => {
  it("bloqueia controles e os reativa após concluir", async () => {
    let finish!: () => void;
    const onSubmit = vi.fn(
      () => new Promise<void>((resolve) => { finish = resolve; })
    );

    render(
      <SimpleForm onSubmit={onSubmit}>
        <label htmlFor="name">Nome</label>
        <input id="name" name="name" />
        <button>Salvar</button>
      </SimpleForm>
    );

    fireEvent.click(screen.getByRole("button", { name: "Salvar" }));

    expect(onSubmit).toHaveBeenCalledTimes(1);
    expect(screen.getByLabelText("Nome").matches(":disabled")).toBe(true);
    expect(screen.getByRole("button", { name: "Salvar" }).matches(":disabled")).toBe(true);
    expect(screen.getByRole("status").textContent).toBe("Salvando...");

    finish();

    await waitFor(() => {
      expect(screen.getByLabelText("Nome").matches(":disabled")).toBe(false);
      expect(screen.getByRole("button", { name: "Salvar" }).matches(":disabled")).toBe(false);
    });
  });

  it("informa erro e reativa os controles quando o submit falha", async () => {
    render(
      <SimpleForm onSubmit={async () => { throw new Error("falha"); }}>
        <label htmlFor="name">Nome</label>
        <input id="name" name="name" />
        <button>Falhar</button>
      </SimpleForm>
    );

    fireEvent.click(screen.getByRole("button", { name: "Falhar" }));

    expect((await screen.findByRole("alert")).textContent).toContain(
      "Não foi possível salvar. Tente novamente."
    );
    expect(screen.getByLabelText("Nome").matches(":disabled")).toBe(false);
  });
});
