"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useWorkspaceBasics } from "../components/useWorkspaceBasics";
import { Nav } from "../components/Nav";
import { PageHeader } from "../components/PageHeader";
import { Dialog } from "../components/Dialog";
import { SimpleForm } from "../components/SimpleForm";
import { List } from "../components/List";
import { money, parseMoney, dateFmt } from "../components/Money";
import { DashboardChart } from "../components/DashboardChart";
import { PeriodFilter, periodRange, type PeriodKey } from "../components/PeriodFilter";
import { useToast } from "../components/Toast";
import { createClient } from "@/lib/supabase/client";
import { TrendingUp, Plus, Pencil, Trash2, Archive } from "lucide-react";

type Tab = "overview" | "payslips" | "patients" | "other";

type Patient = {
  id: string;
  full_name: string;
  context_id: string | null;
  created_at: string;
};
type FinancialContext = { id: string; kind: string; name: string | null };
type PatientEarning = {
  id: string;
  patient_id: string;
  amount: number;
  appointment_date: string;
  due_date: string;
  status: "pending" | "received" | "cancelled";
  transaction_id: string | null;
  notes: string | null;
  created_at: string;
};
type Payslip = {
  id: string;
  employer: string;
  competence: string;
  gross_amount: number;
  discounts_amount: number;
  net_amount: number;
  received_date: string | null;
  transaction_id: string | null;
  pdf_path: string | null;
  notes: string | null;
  created_at: string;
};
type OtherIncome = {
  id: string;
  description: string;
  amount: number;
  competence_date: string;
  category_id: string | null;
};
type DialogState =
  | { kind: "patient" }
  | { kind: "earning"; patientId: string }
  | { kind: "payslip" }
  | { kind: "receive"; earningId: string }
  | { kind: "other" }
  | { kind: "edit-payslip"; payslip: Payslip }
  | { kind: "edit-earning"; earning: PatientEarning }
  | { kind: "edit-other"; income: OtherIncome }
  | { kind: "delete-payslip"; payslip: Payslip }
  | { kind: "delete-earning"; earning: PatientEarning }
  | { kind: "delete-other"; income: OtherIncome }
  | { kind: "deactivate-patient"; patient: Patient }
  | null;

/** Valor monetário para o `defaultValue` dos formulários de edição. */
const moneyInput = (value: number) => Number(value).toFixed(2).replace(".", ",");

/** Rótulo do contexto: usa o nome cadastrado e cai para o `kind` quando vazio. */
const contextLabel = (context: FinancialContext) =>
  context.name?.trim() || (context.kind === "clinica" ? "Clínica" : "Pessoal");

export default function GanhosPage() {
  const { workspace, accounts, categories, defaultCashAccountId, loading } =
    useWorkspaceBasics();
  const supabase = useMemo(() => createClient(), []);
  const [tab, setTab] = useState<Tab>("overview");
  const [period, setPeriod] = useState<PeriodKey>("month");
  const [dialog, setDialog] = useState<DialogState>(null);
  const [patients, setPatients] = useState<Patient[]>([]);
  const [payslips, setPayslips] = useState<Payslip[]>([]);
  const [earnings, setEarnings] = useState<PatientEarning[]>([]);
  const [otherIncome, setOtherIncome] = useState<OtherIncome[]>([]);
  const [contexts, setContexts] = useState<FinancialContext[]>([]);
  const [hubLoading, setHubLoading] = useState(true);
  const { toast } = useToast();

  // Dados específicos do hub são carregados em consultas locais; o
  // useWorkspaceBasics fica responsável apenas por workspace, contas e categorias.
  const loadHub = useCallback(async () => {
    if (!workspace) return;
    try {
      const { data: userData } = await supabase.auth.getUser();
      const ownerId = userData.user?.id;
      if (!ownerId) return;
      const [
        { data: contextRows },
        { data: patientRows },
        { data: payslipRows },
        { data: earningRows },
        { data: incomeRows },
      ] = await Promise.all([
        supabase
          .from("financial_contexts")
          .select("id,kind,name")
          .eq("workspace_id", workspace.id)
          .eq("active", true),
        supabase
          .from("patients")
          .select("id,full_name,context_id,created_at")
          .eq("workspace_id", workspace.id)
          .eq("active", true)
          .order("full_name"),
        supabase
          .from("payslips")
          .select("id,employer,competence,gross_amount,discounts_amount,net_amount,received_date,transaction_id,pdf_path,notes,created_at")
          .eq("workspace_id", workspace.id)
          .order("competence", { ascending: false })
          .limit(50),
        supabase
          .from("patient_earnings")
          .select("id,patient_id,amount,appointment_date,due_date,status,transaction_id,notes,created_at")
          .eq("workspace_id", workspace.id)
          .order("due_date", { ascending: false })
          .limit(200),
        // "Outras receitas" = receitas manuais; as criadas por RPC são
        // identificadas pelo texto fixo de descrição.
        supabase
          .from("transactions")
          .select("id,description,amount,competence_date,category_id")
          .eq("workspace_id", workspace.id)
          .eq("type", "income")
          .not("description", "ilike", "Contracheque %")
          .not("description", "ilike", "Recebimento de paciente%")
          .order("competence_date", { ascending: false })
          .limit(100),
      ]);
      setContexts(contextRows ?? []);
      setPatients(patientRows ?? []);
      setPayslips(payslipRows ?? []);
      setEarnings(earningRows ?? []);
      setOtherIncome(incomeRows ?? []);
    } finally {
      setHubLoading(false);
    }
  }, [supabase, workspace]);

  useEffect(() => {
    void loadHub();
  }, [loadHub]);

  // Contexto padrão dos formulários: o pessoal, derivado da lista carregada.
  const defaultContextId =
    contexts.find((c) => c.kind === "pessoal")?.id ?? null;

  if (loading || !workspace || hubLoading) {
    // Mantém navegação e cabeçalho durante o carregamento para a interface não sumir.
    return (
      <main className="management-page">
        <Nav />
        <PageHeader
          title="Ganhos"
          subtitle="Contracheques, pacientes e outras receitas"
          workspaceName=""
        />
        <p className="muted">Carregando...</p>
      </main>
    );
  }

  // Capturado após o guard: funções declaradas não herdam o narrowing de `workspace`.
  const activeWorkspace = workspace;

  const action =
    tab === "payslips"
      ? { label: "Cadastrar contracheque", onClick: () => setDialog({ kind: "payslip" }) }
      : tab === "patients"
        ? { label: "Cadastrar paciente", onClick: () => setDialog({ kind: "patient" }) }
        : tab === "other"
          ? { label: "Registrar receita", onClick: () => setDialog({ kind: "other" }) }
          : { label: "Registrar ganho", onClick: () => setDialog({ kind: "other" }) };

  const dialogTitle =
    dialog?.kind === "patient" ? "Cadastrar paciente"
      : dialog?.kind === "earning" ? "Registrar atendimento"
        : dialog?.kind === "payslip" ? "Cadastrar contracheque"
          : dialog?.kind === "receive" ? "Registrar recebimento"
            : dialog?.kind === "other" ? "Registrar receita"
              : dialog?.kind === "edit-payslip" ? "Editar contracheque"
                : dialog?.kind === "edit-earning" ? "Editar atendimento"
                  : dialog?.kind === "edit-other" ? "Editar receita"
                    : dialog?.kind === "delete-payslip" ? "Excluir contracheque"
                      : dialog?.kind === "delete-earning" ? "Excluir atendimento"
                        : dialog?.kind === "delete-other" ? "Excluir receita"
                          : dialog?.kind === "deactivate-patient" ? "Desativar paciente" : "";

  const earningDialog = dialog?.kind === "earning" ? dialog : null;
  const receiveDialog = dialog?.kind === "receive" ? dialog : null;
  const receiveEarning = receiveDialog
    ? earnings.find((e) => e.id === receiveDialog.earningId)
    : null;
  const editPayslip = dialog?.kind === "edit-payslip" ? dialog.payslip : null;
  const editEarning = dialog?.kind === "edit-earning" ? dialog.earning : null;
  const editOther = dialog?.kind === "edit-other" ? dialog.income : null;
  const deletePayslip = dialog?.kind === "delete-payslip" ? dialog.payslip : null;
  const deleteEarning = dialog?.kind === "delete-earning" ? dialog.earning : null;
  const deleteOther = dialog?.kind === "delete-other" ? dialog.income : null;
  const deactivatePatient =
    dialog?.kind === "deactivate-patient" ? dialog.patient : null;

  // Recorte de período: `start` inclusivo, `end` exclusivo; sem limites em "Todo o período".
  const range = periodRange(period);
  const inPeriod = (date: string) =>
    (!range.start || date >= range.start) && (!range.end || date < range.end);

  const periodPayslips = payslips.filter((p) => inPeriod(p.competence));
  const periodEarnings = earnings.filter((e) => inPeriod(e.due_date));
  const periodOtherIncome = otherIncome.filter((t) => inPeriod(t.competence_date));

  const payslipReceived = periodPayslips.filter((p) => p.transaction_id);
  const earningsReceived = periodEarnings.filter((e) => e.status === "received");
  const payslipTotal = payslipReceived.reduce((s, p) => s + Number(p.net_amount), 0);
  // "Total recebido" considera apenas atendimentos efetivamente recebidos.
  const patientTotal = earningsReceived.reduce((s, e) => s + Number(e.amount), 0);
  const otherTotal = periodOtherIncome.reduce((s, t) => s + Number(t.amount), 0);
  const totalIncome = payslipTotal + patientTotal + otherTotal;
  const composition = [
    { label: "Contracheques", value: payslipTotal },
    { label: "Atendimentos", value: patientTotal },
    { label: "Outras receitas", value: otherTotal },
  ];
  const today = new Date().toISOString().slice(0, 10);
  const incomeCategories = categories.filter((c) => c.kind === "income");

  // Pacientes com movimento no período vêm primeiro (maior valor primeiro);
  // os demais ficam agrupados sob "Sem movimento", em ordem alfabética.
  const patientRows = patients.map((patient) => {
    const pEarnings = periodEarnings.filter((e) => e.patient_id === patient.id);
    return {
      patient,
      pEarnings,
      pending: pEarnings.filter((e) => e.status === "pending"),
      received: pEarnings.filter((e) => e.status === "received"),
      total: pEarnings.reduce((s, e) => s + Number(e.amount), 0),
    };
  });
  const activePatients = patientRows
    .filter((row) => row.pEarnings.length > 0)
    .sort(
      (a, b) =>
        b.total - a.total ||
        a.patient.full_name.localeCompare(b.patient.full_name, "pt-BR"),
    );
  const idlePatients = patientRows
    .filter((row) => row.pEarnings.length === 0)
    .sort((a, b) =>
      a.patient.full_name.localeCompare(b.patient.full_name, "pt-BR"),
    );

  async function submitPatient(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("patients").insert({
      workspace_id: activeWorkspace.id,
      owner_id: userData.user?.id,
      full_name: form.get("full_name"),
      context_id: form.get("context_id") || null,
    });
    if (error) {
      toast("Não foi possível cadastrar o paciente.", "error");
    } else {
      toast("Paciente cadastrado.");
      setDialog(null);
    }
    await loadHub();
  }

  async function submitEarning(form: FormData, patientId: string) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("patient_earnings").insert({
      workspace_id: activeWorkspace.id,
      owner_id: userData.user?.id,
      patient_id: patientId,
      // O atendimento herda o contexto do paciente.
      context_id: patients.find((p) => p.id === patientId)?.context_id ?? null,
      amount: parseMoney(form.get("amount")),
      appointment_date: form.get("appointment_date"),
      due_date: form.get("due_date"),
    });
    if (error) {
      toast("Não foi possível registrar o atendimento.", "error");
    } else {
      toast("Atendimento registrado.");
      setDialog(null);
    }
    await loadHub();
  }

  async function submitReceive(earningId: string, form: FormData) {
    const { error } = await supabase.rpc("receive_patient_earning", {
      p_earning_id: earningId,
      p_account_id: form.get("account_id"),
      p_received_date: form.get("received_date"),
    });
    if (error) {
      toast("Não foi possível registrar o recebimento.", "error");
    } else {
      toast("Recebimento registrado.");
      setDialog(null);
    }
    await loadHub();
  }

  async function openPayslipPdf(path: string) {
    const { data } = await supabase.storage.from("payslips").createSignedUrl(path, 120);
    if (data?.signedUrl) window.open(data.signedUrl, "_blank", "noopener");
  }

  async function submitPayslip(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const ownerId = userData.user?.id;
    if (!ownerId) {
      toast("Sessão expirada. Entre novamente.", "error");
      return;
    }
    const receivedDate = form.get("received_date") || null;
    const accountId = form.get("account_id") || null;
    if (receivedDate && !accountId) {
      toast("Escolha a conta de recebimento para gerar a receita.", "error");
      return;
    }
    const file = form.get("pdf") as File | null;
    let pdfPath: string | null = null;
    if (file && file.size > 0) {
      if (file.type !== "application/pdf") {
        toast("O arquivo deve ser um PDF.", "error");
        return;
      }
      if (file.size > 10 * 1024 * 1024) {
        toast("O PDF deve ter no máximo 10 MB.", "error");
        return;
      }
      // Bucket privado "payslips"; caminho com prefixo do owner garante
      // isolamento via policy (ver migração payslips_pdf_bucket).
      pdfPath = `${ownerId}/${crypto.randomUUID()}.pdf`;
      const { error: uploadError } = await supabase.storage
        .from("payslips")
        .upload(pdfPath, file, { contentType: "application/pdf" });
      if (uploadError) {
        toast("Não foi possível enviar o PDF.", "error");
        return;
      }
    }
    const { error } = await supabase.rpc("register_payslip", {
      p_workspace_id: activeWorkspace.id,
      p_owner_id: ownerId,
      p_context_id: defaultContextId,
      p_employer: form.get("employer"),
      p_competence: form.get("competence"),
      p_gross_amount: parseMoney(form.get("gross_amount")),
      p_discounts_amount: parseMoney(form.get("discounts_amount")),
      p_net_amount: parseMoney(form.get("net_amount")),
      p_received_date: receivedDate,
      p_account_id: accountId,
      p_pdf_path: pdfPath,
      p_notes: form.get("notes") || null,
    });
    if (error) {
      toast("Não foi possível cadastrar o contracheque.", "error");
      if (pdfPath) await supabase.storage.from("payslips").remove([pdfPath]);
      return;
    }
    toast("Contracheque cadastrado.");
    setDialog(null);
    await loadHub();
  }

  async function submitOtherIncome(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("transactions").insert({
      workspace_id: activeWorkspace.id,
      owner_id: userData.user?.id,
      account_id: form.get("account_id"),
      category_id: form.get("category_id") || null,
      context_id: form.get("context_id") || null,
      type: "income",
      amount: parseMoney(form.get("amount")),
      description: form.get("description"),
      competence_date: form.get("competence_date"),
      paid_at: form.get("competence_date"),
      status: "paid",
      idempotency_key: crypto.randomUUID(),
    });
    if (error) {
      toast("Não foi possível registrar a receita.", "error");
    } else {
      toast("Receita registrada.");
      setDialog(null);
    }
    await loadHub();
  }

  async function updatePayslip(id: string, form: FormData) {
    const { error } = await supabase
      .from("payslips")
      .update({
        employer: form.get("employer"),
        competence: form.get("competence"),
        gross_amount: parseMoney(form.get("gross_amount")),
        discounts_amount: parseMoney(form.get("discounts_amount")),
        net_amount: parseMoney(form.get("net_amount")),
        notes: form.get("notes") || null,
      })
      .eq("id", id)
      .eq("workspace_id", activeWorkspace.id);
    if (error) {
      toast(`Não foi possível salvar: ${error.message}`, "error");
    } else {
      toast("Contracheque atualizado.");
      setDialog(null);
    }
    await loadHub();
  }

  async function updateEarning(id: string, form: FormData) {
    const { error } = await supabase
      .from("patient_earnings")
      .update({
        amount: parseMoney(form.get("amount")),
        appointment_date: form.get("appointment_date"),
        due_date: form.get("due_date"),
      })
      .eq("id", id)
      .eq("workspace_id", activeWorkspace.id);
    if (error) {
      toast(`Não foi possível salvar: ${error.message}`, "error");
    } else {
      toast("Atendimento atualizado.");
      setDialog(null);
    }
    await loadHub();
  }

  async function updateOtherIncome(id: string, form: FormData) {
    const competenceDate = form.get("competence_date");
    const { error } = await supabase
      .from("transactions")
      .update({
        description: form.get("description"),
        amount: parseMoney(form.get("amount")),
        category_id: form.get("category_id") || null,
        competence_date: competenceDate,
        paid_at: competenceDate,
      })
      .eq("id", id)
      .eq("workspace_id", activeWorkspace.id);
    if (error) {
      toast(`Não foi possível salvar: ${error.message}`, "error");
    } else {
      toast("Receita atualizada.");
      setDialog(null);
    }
    await loadHub();
  }

  /**
   * Documentos liquidados têm uma transação vinculada. Apagar só o documento
   * deixaria a receita órfã no caixa, então a transação vai embora primeiro.
   */
  async function removeRecord(
    table: "payslips" | "patient_earnings" | "transactions",
    id: string,
    transactionId: string | null,
    successMessage: string,
  ) {
    if (transactionId) {
      const { error: txError } = await supabase
        .from("transactions")
        .delete()
        .eq("id", transactionId);
      if (txError) {
        toast(`Não foi possível excluir: ${txError.message}`, "error");
        await loadHub();
        return;
      }
    }
    const { error } = await supabase
      .from(table)
      .delete()
      .eq("id", id)
      .eq("workspace_id", activeWorkspace.id);
    if (error) {
      toast(`Não foi possível excluir: ${error.message}`, "error");
    } else {
      toast(successMessage);
      setDialog(null);
    }
    await loadHub();
  }

  async function disablePatient(id: string) {
    const { error } = await supabase
      .from("patients")
      .update({ active: false })
      .eq("id", id)
      .eq("workspace_id", activeWorkspace.id);
    if (error) {
      toast(`Não foi possível desativar: ${error.message}`, "error");
    } else {
      toast("Paciente desativado.");
      setDialog(null);
    }
    await loadHub();
  }

  function renderPatient(row: (typeof patientRows)[number]) {
    const { patient: p, pEarnings, pending, received } = row;
    return (
      <article className="account-row" key={p.id} style={{ display: "grid", gap: 8 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12 }}>
          <div>
            <strong>{p.full_name}</strong>
            <small>
              {received.length} recebido(s) · {money(received.reduce((s, e) => s + Number(e.amount), 0))} ·{" "}
              {pending.length} pendente(s) · {money(pending.reduce((s, e) => s + Number(e.amount), 0))}
            </small>
          </div>
          <span className="row-actions">
            <button type="button" className="btn-circle" title="Registrar atendimento" aria-label="Registrar atendimento" onClick={() => setDialog({ kind: "earning", patientId: p.id })}><Plus aria-hidden="true" /></button>
            <button type="button" aria-label="Desativar paciente" title="Desativar paciente" onClick={() => setDialog({ kind: "deactivate-patient", patient: p })}><Archive aria-hidden="true" /></button>
          </span>
        </div>
        {pEarnings.length > 0 && (
          <ul className="list" style={{ display: "grid", gap: 6 }}>
            {pEarnings.map((e) => (
              <li key={e.id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12 }}>
                <span>
                  {dateFmt.format(new Date(`${e.appointment_date}T12:00:00`))} · {money(e.amount)}
                </span>
                {e.status === "pending" ? (
                  <button type="button" onClick={() => setDialog({ kind: "receive", earningId: e.id })}>Receber</button>
                ) : (
                  <b data-status={e.status} className={e.status === "received" ? "form-success" : "muted"}>
                    {e.status === "received" ? "Recebido" : "Cancelado"}
                  </b>
                )}
                <span className="row-actions">
                  <button type="button" aria-label="Editar atendimento" title="Editar atendimento" onClick={() => setDialog({ kind: "edit-earning", earning: e })}><Pencil aria-hidden="true" /></button>
                  <button type="button" className="danger" aria-label="Excluir atendimento" title="Excluir atendimento" onClick={() => setDialog({ kind: "delete-earning", earning: e })}><Trash2 aria-hidden="true" /></button>
                </span>
              </li>
            ))}
          </ul>
        )}
      </article>
    );
  }

  return (
    <main className="management-page">
      <Nav />
      <PageHeader
        title="Ganhos"
        subtitle="Contracheques, pacientes e outras receitas"
        workspaceName={workspace.name}
        action={action}
      />

      <nav className="hub-tabs" aria-label="Abas de ganhos">
        <button type="button" aria-pressed={tab === "overview"} onClick={() => setTab("overview")} className={tab === "overview" ? "active" : ""}>Visão geral</button>
        <button type="button" aria-pressed={tab === "payslips"} onClick={() => setTab("payslips")} className={tab === "payslips" ? "active" : ""}>Contracheques</button>
        <button type="button" aria-pressed={tab === "patients"} onClick={() => setTab("patients")} className={tab === "patients" ? "active" : ""}>Pacientes</button>
        <button type="button" aria-pressed={tab === "other"} onClick={() => setTab("other")} className={tab === "other" ? "active" : ""}>Outras receitas</button>
      </nav>

      <PeriodFilter value={period} onChange={setPeriod} />

      {tab === "overview" && (
        <section>
          <section className="hub-overview">
            <article className="metric-card metric-card--positive">
              <TrendingUp aria-hidden="true" />
              <strong>{money(totalIncome)}</strong>
              <span className="muted">{`Recebido · ${range.label}`}</span>
            </article>
          </section>
          <section className="dashboard-columns" style={{ marginTop: 18 }}>
            <article className="dashboard-card">
              <h3>Composição dos ganhos</h3>
              <div className="chart-wrap">
                {/* Fontes zeradas viram legenda sem fatia; só entram no gráfico as com valor. */}
                {totalIncome > 0 ? (
                  <DashboardChart type="doughnut" label="Ganhos" labels={composition.filter((c) => c.value > 0).map((c) => c.label)} values={composition.filter((c) => c.value > 0).map((c) => c.value)} color="var(--accent)" />
                ) : (
                  <p className="dashboard-empty">Nenhum ganho recebido ainda.{" "}
                    <button type="button" className="btn-primary" onClick={() => setDialog({ kind: "other" })}>Registrar primeiro ganho</button>
                  </p>
                )}
              </div>
            </article>
            <article className="dashboard-card">
              <h3>Fontes</h3>
              <ul className="list" style={{ display: "grid", gap: 10 }}>
                {composition.map((c) => (
                  <li key={c.label} style={{ display: "flex", justifyContent: "space-between" }}>
                    <span>{c.label}</span>
                    <b>{money(c.value)}</b>
                  </li>
                ))}
              </ul>
            </article>
          </section>
        </section>
      )}

      {tab === "payslips" && (
        <section className="management-grid" style={{ gridTemplateColumns: "1fr" }}>
          <List title="Contracheques">
            {periodPayslips.length === 0 && (
              <p className="dashboard-empty">Nenhum contracheque cadastrado.{" "}
                <button type="button" className="btn-primary" onClick={() => setDialog({ kind: "payslip" })}>Cadastrar primeiro contracheque</button>
              </p>
            )}
            {Object.entries(
              Object.groupBy(periodPayslips, (p) => p.competence.slice(0, 7))
            ).sort((a, b) => b[0].localeCompare(a[0])).map(([month, ps = []]) => (
              <div key={month} style={{ marginBottom: 24 }}>
                <h4 style={{ margin: "0 0 12px", color: "var(--muted)" }}>
                  {new Date(`${month}-01T12:00:00`).toLocaleString('pt-BR', { month: 'long', year: 'numeric' }).replace(/^\w/, c => c.toUpperCase())}
                </h4>
                <div style={{ display: "grid", gap: 8 }}>
                  {ps.map((p) => {
                    // Capturado fora do JSX: o closure do onClick não herda o narrowing da prop.
                    const pdfPath = p.pdf_path;
                    return (
                    <article className="account-row" key={p.id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12 }}>
                      <div>
                        <strong style={{ display: "block", marginBottom: 4 }}>{p.employer}</strong>
                        <small>
                          {dateFmt.format(new Date(`${p.competence}T12:00:00`))}
                          {p.received_date ? ` · recebido ${dateFmt.format(new Date(`${p.received_date}T12:00:00`))}` : " · não recebido"}
                          {p.notes ? ` · ${p.notes}` : ""}
                        </small>
                      </div>
                      <div style={{ textAlign: "right", display: "grid", gap: 4 }}>
                        <b>{money(p.net_amount)}</b>
                        <small className="muted">bruto {money(p.gross_amount)} · desc. {money(p.discounts_amount)}</small>
                      </div>
                      {pdfPath && (
                        <button type="button" className="btn-primary" style={{ padding: "6px 12px", fontSize: "0.8rem" }} onClick={() => void openPayslipPdf(pdfPath)}>PDF</button>
                      )}
                      <span className="row-actions">
                        <button type="button" aria-label="Editar contracheque" title="Editar contracheque" onClick={() => setDialog({ kind: "edit-payslip", payslip: p })}><Pencil aria-hidden="true" /></button>
                        <button type="button" className="danger" aria-label="Excluir contracheque" title="Excluir contracheque" onClick={() => setDialog({ kind: "delete-payslip", payslip: p })}><Trash2 aria-hidden="true" /></button>
                      </span>
                    </article>
                    );
                  })}
                </div>
              </div>
            ))}
          </List>
        </section>
      )}

      {tab === "patients" && (
        <section className="management-grid" style={{ gridTemplateColumns: "1fr" }}>
          <List title="Pacientes">
            {patients.length === 0 && (
              <p className="dashboard-empty">Nenhum paciente cadastrado.{" "}
                <button type="button" className="btn-primary" onClick={() => setDialog({ kind: "patient" })}>Cadastrar primeiro paciente</button>
              </p>
            )}
            {activePatients.map(renderPatient)}
            {idlePatients.length > 0 && <h4>Sem movimento</h4>}
            {idlePatients.map(renderPatient)}
          </List>
        </section>
      )}

      {tab === "other" && (
        <section className="management-grid" style={{ gridTemplateColumns: "1fr" }}>
          <List title="Outras receitas">
            {periodOtherIncome.length === 0 ? (
              <p className="dashboard-empty">Nenhuma receita manual registrada.{" "}
                <button type="button" className="btn-primary" onClick={() => setDialog({ kind: "other" })}>Registrar primeira receita</button>
              </p>
            ) : (
              <ul className="list" style={{ display: "grid", gap: 6 }}>
                {periodOtherIncome.map((t) => (
                  <li key={t.id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12 }}>
                    <span>
                      {t.description} · {dateFmt.format(new Date(`${t.competence_date}T12:00:00`))}
                    </span>
                    <b>{money(t.amount)}</b>
                    <span className="row-actions">
                      <button type="button" aria-label="Editar receita" title="Editar receita" onClick={() => setDialog({ kind: "edit-other", income: t })}><Pencil aria-hidden="true" /></button>
                      <button type="button" className="danger" aria-label="Excluir receita" title="Excluir receita" onClick={() => setDialog({ kind: "delete-other", income: t })}><Trash2 aria-hidden="true" /></button>
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </List>
        </section>
      )}

      <Dialog open={dialog !== null} onClose={() => setDialog(null)} title={dialogTitle}>
        {dialog?.kind === "patient" && (
          <SimpleForm key="patient" onSubmit={submitPatient}>
            <label htmlFor="patient-name">Nome completo</label>
            <input id="patient-name" name="full_name" minLength={2} maxLength={120} placeholder="Nome completo do paciente" required autoFocus />
            <label htmlFor="patient-context">Contexto</label>
            <select id="patient-context" name="context_id" defaultValue={defaultContextId ?? ""}>
              <option value="">Sem contexto</option>
              {contexts.map((c) => (
                <option key={c.id} value={c.id}>{contextLabel(c)}</option>
              ))}
            </select>
            <button>Cadastrar paciente</button>
          </SimpleForm>
        )}
        {earningDialog && (
          <SimpleForm key="earning" onSubmit={(form) => submitEarning(form, earningDialog.patientId)}>
            <p className="muted">Registre apenas os dados financeiros do atendimento, sem informações clínicas.</p>
            <label htmlFor="earning-amount">Valor do atendimento</label>
            <input id="earning-amount" name="amount" placeholder="0,00" required />
            <label htmlFor="earning-appointment-date">Data do atendimento</label>
            <input id="earning-appointment-date" name="appointment_date" type="date" defaultValue={today} required />
            <label htmlFor="earning-due-date">Previsão de recebimento</label>
            <input id="earning-due-date" name="due_date" type="date" defaultValue={today} required />
            <button>Registrar atendimento</button>
          </SimpleForm>
        )}
        {dialog?.kind === "payslip" && (
          <SimpleForm key="payslip" onSubmit={submitPayslip}>
            <label htmlFor="payslip-employer">Empregador</label>
            <input id="payslip-employer" name="employer" maxLength={120} placeholder="Empregador" required autoFocus />
            <label htmlFor="payslip-competence">Competência</label>
            <input id="payslip-competence" name="competence" type="date" required />
            <label htmlFor="payslip-gross">Valor bruto</label>
            <input id="payslip-gross" name="gross_amount" placeholder="0,00" required />
            <label htmlFor="payslip-discounts">Descontos</label>
            <input id="payslip-discounts" name="discounts_amount" placeholder="0,00" defaultValue="0,00" required />
            <label htmlFor="payslip-net">Valor líquido</label>
            <input id="payslip-net" name="net_amount" placeholder="0,00" required />
            <label htmlFor="payslip-received-date">Data de recebimento</label>
            <input id="payslip-received-date" name="received_date" type="date" />
            <label htmlFor="payslip-account">Conta de recebimento</label>
            <select id="payslip-account" name="account_id" defaultValue={defaultCashAccountId ?? ""}>
              <option value="">Conta (opcional)</option>
              {accounts.map((a) => (
                <option key={a.id} value={a.id}>{a.name}</option>
              ))}
            </select>
            <label htmlFor="payslip-pdf">Contracheque (PDF privado, até 10 MB)</label>
            <input id="payslip-pdf" name="pdf" type="file" accept="application/pdf" />
            <label htmlFor="payslip-notes">Observação</label>
            <input id="payslip-notes" name="notes" placeholder="Observação" />
            <button>Cadastrar contracheque</button>
          </SimpleForm>
        )}
        {receiveDialog && receiveEarning && (
          <SimpleForm key="receive" onSubmit={(form) => submitReceive(receiveEarning.id, form)}>
            <p className="muted">Registrar recebimento de {money(receiveEarning.amount)}.</p>
            <label htmlFor="receive-account">Conta de recebimento</label>
            <select id="receive-account" name="account_id" defaultValue={defaultCashAccountId ?? ""} required>
              <option value="">Escolha uma conta</option>
              {accounts.map((a) => (
                <option key={a.id} value={a.id}>{a.name}</option>
              ))}
            </select>
            <label htmlFor="receive-date">Data de recebimento</label>
            <input id="receive-date" name="received_date" type="date" defaultValue={today} required />
            <button>Registrar recebimento</button>
          </SimpleForm>
        )}
        {dialog?.kind === "other" && (
          <SimpleForm key="other" onSubmit={submitOtherIncome}>
            <label htmlFor="other-description">Descrição</label>
            <input id="other-description" name="description" placeholder="Descrição da receita" required autoFocus />
            <label htmlFor="other-amount">Valor</label>
            <input id="other-amount" name="amount" placeholder="0,00" required />
            <label htmlFor="other-account">Conta</label>
            <select id="other-account" name="account_id" defaultValue={defaultCashAccountId ?? ""} required>
              <option value="">Escolha uma conta</option>
              {accounts.map((a) => (
                <option key={a.id} value={a.id}>{a.name}</option>
              ))}
            </select>
            <label htmlFor="other-category">Categoria</label>
            <select id="other-category" name="category_id">
              <option value="">Sem categoria</option>
              {incomeCategories.map((c) => (
                <option key={c.id} value={c.id}>{c.name}</option>
              ))}
            </select>
            <label htmlFor="other-context">Contexto</label>
            <select id="other-context" name="context_id" defaultValue={defaultContextId ?? ""}>
              <option value="">Sem contexto</option>
              {contexts.map((c) => (
                <option key={c.id} value={c.id}>{contextLabel(c)}</option>
              ))}
            </select>
            <label htmlFor="other-date">Data</label>
            <input id="other-date" name="competence_date" type="date" defaultValue={today} required />
            <button>Registrar receita</button>
          </SimpleForm>
        )}
        {editPayslip && (
          <SimpleForm key={`edit-payslip-${editPayslip.id}`} onSubmit={(form) => updatePayslip(editPayslip.id, form)}>
            <label htmlFor="edit-payslip-employer">Empregador</label>
            <input id="edit-payslip-employer" name="employer" maxLength={120} defaultValue={editPayslip.employer} required autoFocus />
            <label htmlFor="edit-payslip-competence">Competência</label>
            <input id="edit-payslip-competence" name="competence" type="date" defaultValue={editPayslip.competence} required />
            <label htmlFor="edit-payslip-gross">Valor bruto</label>
            <input id="edit-payslip-gross" name="gross_amount" defaultValue={moneyInput(editPayslip.gross_amount)} required />
            <label htmlFor="edit-payslip-discounts">Descontos</label>
            <input id="edit-payslip-discounts" name="discounts_amount" defaultValue={moneyInput(editPayslip.discounts_amount)} required />
            <label htmlFor="edit-payslip-net">Valor líquido</label>
            <input id="edit-payslip-net" name="net_amount" defaultValue={moneyInput(editPayslip.net_amount)} required />
            <label htmlFor="edit-payslip-notes">Observação</label>
            <input id="edit-payslip-notes" name="notes" defaultValue={editPayslip.notes ?? ""} placeholder="Observação" />
            <button>Salvar contracheque</button>
          </SimpleForm>
        )}
        {editEarning && (
          <SimpleForm key={`edit-earning-${editEarning.id}`} onSubmit={(form) => updateEarning(editEarning.id, form)}>
            <p className="muted">Registre apenas os dados financeiros do atendimento, sem informações clínicas.</p>
            <label htmlFor="edit-earning-amount">Valor do atendimento</label>
            <input id="edit-earning-amount" name="amount" defaultValue={moneyInput(editEarning.amount)} required autoFocus />
            <label htmlFor="edit-earning-appointment-date">Data do atendimento</label>
            <input id="edit-earning-appointment-date" name="appointment_date" type="date" defaultValue={editEarning.appointment_date} required />
            <label htmlFor="edit-earning-due-date">Previsão de recebimento</label>
            <input id="edit-earning-due-date" name="due_date" type="date" defaultValue={editEarning.due_date} required />
            <button>Salvar atendimento</button>
          </SimpleForm>
        )}
        {editOther && (
          <SimpleForm key={`edit-other-${editOther.id}`} onSubmit={(form) => updateOtherIncome(editOther.id, form)}>
            <label htmlFor="edit-other-description">Descrição</label>
            <input id="edit-other-description" name="description" defaultValue={editOther.description} required autoFocus />
            <label htmlFor="edit-other-amount">Valor</label>
            <input id="edit-other-amount" name="amount" defaultValue={moneyInput(editOther.amount)} required />
            <label htmlFor="edit-other-category">Categoria</label>
            <select id="edit-other-category" name="category_id" defaultValue={editOther.category_id ?? ""}>
              <option value="">Sem categoria</option>
              {incomeCategories.map((c) => (
                <option key={c.id} value={c.id}>{c.name}</option>
              ))}
            </select>
            <label htmlFor="edit-other-date">Data</label>
            <input id="edit-other-date" name="competence_date" type="date" defaultValue={editOther.competence_date} required />
            <button>Salvar receita</button>
          </SimpleForm>
        )}
        {deletePayslip && (
          <SimpleForm
            key={`delete-payslip-${deletePayslip.id}`}
            onSubmit={() => removeRecord("payslips", deletePayslip.id, deletePayslip.transaction_id, "Contracheque excluído.")}
          >
            <p>
              Excluir o contracheque de {deletePayslip.employer} (competência{" "}
              {dateFmt.format(new Date(`${deletePayslip.competence}T12:00:00`))}), no valor líquido de {money(deletePayslip.net_amount)}?
            </p>
            {deletePayslip.transaction_id && (
              <p className="form-error">
                Este contracheque está liquidado: a receita correspondente também será removida do caixa.
              </p>
            )}
            <button>Excluir contracheque</button>
          </SimpleForm>
        )}
        {deleteEarning && (
          <SimpleForm
            key={`delete-earning-${deleteEarning.id}`}
            onSubmit={() => removeRecord("patient_earnings", deleteEarning.id, deleteEarning.transaction_id, "Atendimento excluído.")}
          >
            <p>
              Excluir o atendimento de{" "}
              {dateFmt.format(new Date(`${deleteEarning.appointment_date}T12:00:00`))}, no valor de {money(deleteEarning.amount)}?
            </p>
            {deleteEarning.transaction_id && (
              <p className="form-error">
                Este atendimento já foi recebido: a receita correspondente também será removida do caixa.
              </p>
            )}
            <button>Excluir atendimento</button>
          </SimpleForm>
        )}
        {deleteOther && (
          <SimpleForm
            key={`delete-other-${deleteOther.id}`}
            onSubmit={() => removeRecord("transactions", deleteOther.id, null, "Receita excluída.")}
          >
            <p>
              Excluir a receita &quot;{deleteOther.description}&quot; de{" "}
              {dateFmt.format(new Date(`${deleteOther.competence_date}T12:00:00`))}, no valor de {money(deleteOther.amount)}?
            </p>
            <button>Excluir receita</button>
          </SimpleForm>
        )}
        {deactivatePatient && (
          <SimpleForm
            key={`deactivate-${deactivatePatient.id}`}
            onSubmit={() => disablePatient(deactivatePatient.id)}
          >
            <p>Desativar {deactivatePatient.full_name}?</p>
            <p className="muted">
              Desativar não exclui nada: o paciente sai da lista, mas todo o histórico de
              atendimentos e recebimentos é preservado.
            </p>
            <button>Desativar paciente</button>
          </SimpleForm>
        )}
      </Dialog>
    </main>
  );
}
