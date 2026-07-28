# Prevenção de envio duplicado em SimpleForm Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** impedir submissões financeiras duplicadas, desabilitando os controles de `SimpleForm` e expondo o estado de processamento de forma acessível.

**Architecture:** `SimpleForm` continua como a única fronteira compartilhada de submissão dos formulários financeiros. O estado local `pending` envolve os filhos em um `fieldset` desabilitado e inclui uma região de status; a finalização em `finally` garante a reativação após sucesso ou erro.

**Tech Stack:** Next.js 15, React 19, TypeScript, Vitest 3, Testing Library React.

## Global Constraints

- Alterar somente `src/app/components/SimpleForm.tsx` e seu teste associado.
- Não adicionar dependências, ações de servidor, validações ou regras financeiras.
- Durante `pending`, campos e botões descendentes precisam ficar desabilitados.
- O estado de processamento precisa ter texto e semântica acessível, sem depender de cor.
- TERRA implementa; LUA é o único papel que aceita ou pede correções.

---

### Task 1: Cobrir bloqueio e recuperação de SimpleForm

**Files:**
- Create: `src/app/components/__tests__/SimpleForm.test.tsx`
- Modify: `src/app/components/SimpleForm.tsx`

**Interfaces:**
- Consumes: `SimpleForm({ children, onSubmit })`, onde `onSubmit(form: FormData): Promise<void>`.
- Produces: controles descendentes bloqueados enquanto a promessa de `onSubmit` está pendente e uma região `role="status"` com texto de processamento.

- [ ] **Step 1: Escrever o teste que falha**

```tsx
// @vitest-environment jsdom
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
    expect((screen.getByLabelText("Nome") as HTMLInputElement).disabled).toBe(true);
    expect((screen.getByRole("button", { name: "Salvar" }) as HTMLButtonElement).disabled).toBe(true);
    expect(screen.getByRole("status").textContent).toBe("Salvando...");

    finish();

    await waitFor(() => {
      expect((screen.getByLabelText("Nome") as HTMLInputElement).disabled).toBe(false);
      expect((screen.getByRole("button", { name: "Salvar" }) as HTMLButtonElement).disabled).toBe(false);
    });
  });
});
```

- [ ] **Step 2: Executar o teste e confirmar a falha**

Run: `npm test -- src/app/components/__tests__/SimpleForm.test.tsx`

Expected: FAIL, porque o `fieldset` atual está vazio e não desabilita os controles filhos; a região de status ainda não existe.

- [ ] **Step 3: Implementar a alteração mínima**

Substituir os filhos soltos e o `fieldset` vazio por um único fieldset que envolva os filhos. Usar `try/finally` no handler para liberar `pending` quando `onSubmit` resolver ou rejeitar.

```tsx
<fieldset disabled={pending} aria-busy={pending}>
  {children}
</fieldset>
{pending ? <p role="status">Salvando...</p> : null}
```

```tsx
setPending(true);
try {
  await onSubmit(new FormData(e.currentTarget));
} finally {
  setPending(false);
}
```

- [ ] **Step 4: Executar o teste e confirmar aprovação**

Run: `npm test -- src/app/components/__tests__/SimpleForm.test.tsx`

Expected: PASS. O formulário permanece bloqueado durante a promessa e é reativado após `finish()`.

- [ ] **Step 5: Executar verificações do projeto**

Run: `npm test && npm run lint && npm run build`

Expected: todos os testes, lint e build passam. Se uma falha preexistente impedir uma verificação, registrar comando, saída e por que não é causada por esta alteração.

- [ ] **Step 6: Commit de implementação**

```bash
git add src/app/components/SimpleForm.tsx src/app/components/__tests__/SimpleForm.test.tsx
git commit -m "fix: prevent duplicate form submissions"
```

### Task 2: Handoff obrigatório para revisão LUA

**Files:**
- Modify: nenhum arquivo.

**Interfaces:**
- Consumes: diff do Task 1 e evidências dos comandos de verificação.
- Produces: `READY_FOR_LUA | mudanças=SimpleForm pending state | evidências=<resultados> | UX/a11y=fieldset disabled + role=status | deps=none | riscos=controles fora do fieldset`.

- [ ] **Step 1: Preparar evidências para o revisor**

Enviar ao papel LUA a lista de arquivos modificados, a saída resumida do teste específico, `npm test`, `npm run lint` e `npm run build`, além do hash do commit.

- [ ] **Step 2: Solicitar revisão exclusiva**

LUA executa `ponytail-review` no diff, valida os critérios de aceite e retorna somente `ACCEPTED` ou `CHANGES_REQUESTED`. SOL e TERRA não aceitam a própria implementação.

## Self-review

- Cobertura da spec: Task 1 atende os seis critérios de aceite; Task 2 preserva a separação de papéis e o gate de revisão.
- Sem dependências ou abstrações adicionais: a mudança fica confinada ao componente compartilhado e seu teste.
- Tipos consistentes: `onSubmit` mantém `Promise<void>` e o teste usa uma promessa controlada desse tipo.
