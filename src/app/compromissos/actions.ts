"use server";

import { revalidatePath } from "next/cache";
import { z } from "zod";
import { requireFinanceContext } from "@/lib/finance/context";

export type CommitmentState = { error?: string; success?: string };

const nullableUuid = z.preprocess(
  (value) => (value === "" || value == null ? null : value),
  z.string().uuid().nullable(),
);
const money = z.preprocess(
  (value) =>
    typeof value === "string"
      ? Number(value.replace(/\./g, "").replace(",", "."))
      : value,
  z.number().finite().positive("Informe um valor maior que zero.").max(999999999),
);
const commitmentSchema = z.object({
  description: z
    .string()
    .trim()
    .min(2, "Informe uma descrição.")
    .max(100, "Use no máximo 100 caracteres."),
  amount: money,
  due_day: z.coerce.number().int().min(1).max(31),
  account_id: nullableUuid,
  category_id: nullableUuid,
});

function refreshCommitments() {
  revalidatePath("/compromissos");
  revalidatePath("/");
}

async function referencesBelongToWorkspace(
  accountId: string | null,
  categoryId: string | null,
) {
  const { supabase, userId, workspace } = await requireFinanceContext();
  const checks = [];
  if (accountId) {
    checks.push(
      supabase
        .from("accounts")
        .select("id")
        .eq("id", accountId)
        .eq("owner_id", userId)
        .eq("workspace_id", workspace.id)
        .eq("active", true)
        .maybeSingle(),
    );
  }
  if (categoryId) {
    checks.push(
      supabase
        .from("categories")
        .select("id")
        .eq("id", categoryId)
        .eq("owner_id", userId)
        .eq("workspace_id", workspace.id)
        .eq("active", true)
        .eq("kind", "expense")
        .maybeSingle(),
    );
  }
  const results = await Promise.all(checks);
  return {
    valid: results.every(({ data, error }) => !error && data),
    supabase,
    userId,
    workspace,
  };
}

export async function createCommitment(
  _: CommitmentState,
  data: FormData,
): Promise<CommitmentState> {
  const parsed = commitmentSchema.safeParse(Object.fromEntries(data));
  if (!parsed.success) return { error: parsed.error.issues[0]?.message };
  const { valid, supabase, userId, workspace } =
    await referencesBelongToWorkspace(
      parsed.data.account_id,
      parsed.data.category_id,
    );
  if (!valid) return { error: "Conta ou categoria inválida." };
  const { error } = await supabase.from("fixed_commitments").insert({
    ...parsed.data,
    owner_id: userId,
    workspace_id: workspace.id,
  });
  if (error) return { error: "Não foi possível criar o compromisso." };
  refreshCommitments();
  return { success: "Compromisso criado." };
}

export async function updateCommitment(
  _: CommitmentState,
  data: FormData,
): Promise<CommitmentState> {
  const id = z.string().uuid().safeParse(data.get("id"));
  const parsed = commitmentSchema.safeParse(Object.fromEntries(data));
  if (!id.success) return { error: "Compromisso inválido." };
  if (!parsed.success) return { error: parsed.error.issues[0]?.message };
  const { valid, supabase, userId, workspace } =
    await referencesBelongToWorkspace(
      parsed.data.account_id,
      parsed.data.category_id,
    );
  if (!valid) return { error: "Conta ou categoria inválida." };
  const { data: updated, error } = await supabase
    .from("fixed_commitments")
    .update(parsed.data)
    .eq("id", id.data)
    .eq("owner_id", userId)
    .eq("workspace_id", workspace.id)
    .select("id")
    .maybeSingle();
  if (error || !updated) return { error: "Não foi possível salvar as alterações." };
  refreshCommitments();
  return { success: "Alterações salvas." };
}

async function setActive(data: FormData, active: boolean) {
  const id = z.string().uuid().safeParse(data.get("id"));
  if (!id.success) return;
  const { supabase, userId, workspace } = await requireFinanceContext();
  await supabase
    .from("fixed_commitments")
    .update({ active })
    .eq("id", id.data)
    .eq("owner_id", userId)
    .eq("workspace_id", workspace.id);
  refreshCommitments();
}

export async function archiveCommitment(data: FormData) {
  await setActive(data, false);
}

export async function restoreCommitment(data: FormData) {
  await setActive(data, true);
}
