"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useFinance } from "../components/useFinance";
import { Nav } from "../components/Nav";
import { PageHeader } from "../components/PageHeader";
import { Dialog } from "../components/Dialog";
import { SimpleForm } from "../components/SimpleForm";
import { List } from "../components/List";
import { money, parseMoney, dateFmt } from "../components/Money";
import { DashboardChart } from "../components/DashboardChart";
import { createClient } from "@/lib/supabase/client";
import { TrendingUp, Plus } from "lucide-react";

type Tab = "overview" | "payslips" | "patients" | "other";

type Patient = { id: string; full_name: string; created_at: string };
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
type DialogState =
  | { kind: "patient" }
  | { kind: "earning"; patientId: string }
  | { kind: "payslip" }
  | { kind: "receive"; earningId: string }
  | { kind: "other" }
  | null;

export default function GanhosPage() {
  const { workspace, accounts, categories, defaultCashAccountId, loading } =
    useFinance("dashboard");
  const supabase = useMemo(() => createClient(), []);
  const [tab, setTab] = useState<Tab>("overview");
  const [dialog, setDialog] = useState<DialogState>(null);
  const [message, setMessage] = useState("");
  const [patients, setPatients] = useState<Patient[]>([]);
  const [payslips, setPayslips] = useState<Payslip[]>([]);
  const [earnings, setEarnings] = useState<PatientEarning[]>([]);
  const [otherIncome, setOtherIncome] = useState<{ id: string; description: string; amount: number; competence_date: string; category_id: string | null }[]>([]);
  const [defaultContextId, setDefaultContextId] = useState<string | null>(null);
  const [hubLoading, setHubLoading] = useState(true);

  // Dados específicos do hub são carregados em consultas locais; o useFinance
  // fica responsável apenas por workspace, contas e categorias base.
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
          .select("id")
          .eq("workspace_id", workspace.id)
          .eq("kind", "pessoal")
          .limit(1)
          .maybeSingle(),
        supabase
          .from("patients")
          .select("id,full_name,created_at")
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
      setDefaultContextId(contextRows?.id ?? null);
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

  if (loading || !workspace || hubLoading) {
    return <main className="management-page"><p className="muted">Carregando...</p></main>;
  }

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
            : dialog?.kind === "other" ? "Registrar receita" : "";

  const earningDialog = dialog?.kind === "earning" ? dialog : null;
  const receiveDialog = dialog?.kind === "receive" ? dialog : null;
  const receiveEarning = receiveDialog
    ? earnings.find((e) => e.id === receiveDialog.earningId)
    : null;

  const payslipReceived = payslips.filter((p) => p.transaction_id);
  const earningsReceived = earnings.filter((e) => e.status === "received");
  const payslipTotal = payslipReceived.reduce((s, p) => s + Number(p.net_amount), 0);
  const patientTotal = earnings.reduce((s, e) => s + Number(e.amount), 0);
  const otherTotal = otherIncome.reduce((s, t) => s + Number(t.amount), 0);
  const totalIncome = payslipTotal + patientTotal + otherTotal;
  const composition = [
    { label: "Contracheques", value: payslipTotal },
    { label: "Atendimentos", value: patientTotal },
    { label: "Outras receitas", value: otherTotal },
  ];
  const today = new Date().toISOString().slice(0, 10);
  const incomeCategories = categories.filter((c) => c.kind === "income");

  async function submitPatient(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("patients").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      full_name: form.get("full_name"),
      context_id: defaultContextId,
    });
    setMessage(error ? "Não foi possível cadastrar o paciente." : "Paciente cadastrado.");
    if (!error) setDialog(null);
    await loadHub();
  }

  async function submitEarning(form: FormData, patientId: string) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("patient_earnings").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      patient_id: patientId,
      context_id: defaultContextId,
      amount: parseMoney(form.get("amount")),
      appointment_date: form.get("appointment_date"),
      due_date: form.get("due_date"),
      notes: form.get("notes") || null,
    });
    setMessage(error ? "Não foi possível registrar o atendimento." : "Atendimento registrado.");
    if (!error) setDialog(null);
    await loadHub();
  }

  async function submitReceive(earningId: string, form: FormData) {
    const { error } = await supabase.rpc("receive_patient_earning", {
      p_earning_id: earningId,
      p_account_id: form.get("account_id"),
      p_received_date: form.get("received_date"),
    });
    setMessage(error ? "Não foi possível registrar o recebimento." : "Recebimento registrado.");
    if (!error) setDialog(null);
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
      setMessage("Sessão expirada. Entre novamente.");
      return;
    }
    const receivedDate = form.get("received_date") || null;
    const accountId = form.get("account_id") || null;
    if (receivedDate && !accountId) {
      setMessage("Escolha a conta de recebimento para gerar a receita.");
      return;
    }
    const file = form.get("pdf") as File | null;
    let pdfPath: string | null = null;
    if (file && file.size > 0) {
      if (file.type !== "application/pdf") {
        setMessage("O arquivo deve ser um PDF.");
        return;
      }
      if (file.size > 10 * 1024 * 1024) {
        setMessage("O PDF deve ter no máximo 10 MB.");
        return;
      }
      // Bucket privado "payslips"; caminho com prefixo do owner garante
      // isolamento via policy (ver migração payslips_pdf_bucket).
      pdfPath = `${ownerId}/${crypto.randomUUID()}.pdf`;
      const { error: uploadError } = await supabase.storage
        .from("payslips")
        .upload(pdfPath, file, { contentType: "application/pdf" });
      if (uploadError) {
        setMessage("Não foi possível enviar o PDF.");
        return;
      }
    }
    const { error } = await supabase.rpc("register_payslip", {
      p_workspace_id: workspace.id,
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
      setMessage("Não foi possível cadastrar o contracheque.");
      if (pdfPath) await supabase.storage.from("payslips").remove([pdfPath]);
      return;
    }
    setMessage("Contracheque cadastrado.");
    setDialog(null);
    await loadHub();
  }

  async function submitOtherIncome(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("transactions").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      account_id: form.get("account_id"),
      category_id: form.get("category_id") || null,
      type: "income",
      amount: parseMoney(form.get("amount")),
      description: form.get("description"),
      competence_date: form.get("competence_date"),
      paid_at: form.get("competence_date"),
      status: "paid",
      idempotency_key: crypto.randomUUID(),
    });
    setMessage(error ? "Não foi possível registrar a receita." : "Receita registrada.");
    if (!error) setDialog(null);
    await loadHub();
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
      {message && <p className={message.startsWith("Não") ? "form-error" : "form-success"} role={message.startsWith("Não") ? "alert" : "status"}>{message}</p>}

      <nav className="hub-tabs" aria-label="Abas de ganhos">
        <button type="button" aria-pressed={tab === "overview"} onClick={() => setTab("overview")} className={tab === "overview" ? "active" : ""}>Visão geral</button>
        <button type="button" aria-pressed={tab === "payslips"} onClick={() => setTab("payslips")} className={tab === "payslips" ? "active" : ""}>Contracheques</button>
        <button type="button" aria-pressed={tab === "patients"} onClick={() => setTab("patients")} className={tab === "patients" ? "active" : ""}>Pacientes</button>
        <button type="button" aria-pressed={tab === "other"} onClick={() => setTab("other")} className={tab === "other" ? "active" : ""}>Outras receitas</button>
      </nav>

      {tab === "overview" && (
        <section>
          <section className="hub-overview">
            <article className="metric-card metric-card--positive">
              <TrendingUp aria-hidden="true" />
              <strong>{money(totalIncome)}</strong>
              <span className="muted">Total recebido</span>
            </article>
          </section>
          <section className="dashboard-columns" style={{ marginTop: 18 }}>
            <article className="dashboard-card">
              <h3>Composição dos ganhos</h3>
              <div className="chart-wrap">
                {totalIncome > 0 ? (
                  <DashboardChart type="doughnut" label="Ganhos" labels={composition.map((c) => c.label)} values={composition.map((c) => c.value)} color="var(--accent)" />
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
            {payslips.length === 0 && (
              <p className="dashboard-empty">Nenhum contracheque cadastrado.{" "}
                <button type="button" className="btn-primary" onClick={() => setDialog({ kind: "payslip" })}>Cadastrar primeiro contracheque</button>
              </p>
            )}
            {Object.entries(
              payslips.reduce((acc, p) => {
                const month = p.competence.slice(0, 7);
                if (!acc[month]) acc[month] = [];
                acc[month].push(p);
                return acc;
              }, {} as Record<string, typeof payslips>)
            ).sort((a, b) => b[0].localeCompare(a[0])).map(([month, ps]) => (
              <div key={month} style={{ marginBottom: 24 }}>
                <h4 style={{ margin: "0 0 12px", color: "var(--muted)" }}>
                  {new Date(`${month}-01T12:00:00`).toLocaleString('pt-BR', { month: 'long', year: 'numeric' }).replace(/^\w/, c => c.toUpperCase())}
                </h4>
                <div style={{ display: "grid", gap: 8 }}>
                  {ps.map((p) => (
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
                      {p.pdf_path && (
                        <button type="button" className="btn-primary" style={{ padding: "6px 12px", fontSize: "0.8rem" }} onClick={() => void openPayslipPdf(p.pdf_path!)}>PDF</button>
                      )}
                    </article>
                  ))}
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
            {patients.map((p) => {
              const pEarnings = earnings.filter((e) => e.patient_id === p.id);
              const pending = pEarnings.filter((e) => e.status === "pending");
              const received = pEarnings.filter((e) => e.status === "received");
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
                    <button type="button" className="btn-circle" title="Registrar Atendimento" onClick={() => setDialog({ kind: "earning", patientId: p.id })}><Plus aria-hidden="true" /></button>
                  </div>
                  {pEarnings.length > 0 && (
                    <ul className="list" style={{ display: "grid", gap: 6 }}>
                      {pEarnings.map((e) => (
                        <li key={e.id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12 }}>
                          <span>
                            {dateFmt.format(new Date(`${e.appointment_date}T12:00:00`))} · {money(e.amount)}
                            {e.notes ? ` · ${e.notes}` : ""}
                          </span>
                          {e.status === "pending" ? (
                            <button type="button" onClick={() => setDialog({ kind: "receive", earningId: e.id })}>Receber</button>
                          ) : (
                            <b data-status={e.status} className={e.status === "received" ? "form-success" : "muted"}>
                              {e.status === "received" ? "Recebido" : "Cancelado"}
                            </b>
                          )}
                        </li>
                      ))}
                    </ul>
                  )}
                </article>
              );
            })}
          </List>
        </section>
      )}

      {tab === "other" && (
        <section className="management-grid" style={{ gridTemplateColumns: "1fr" }}>
          <List title="Outras receitas">
            {otherIncome.length === 0 ? (
              <p className="dashboard-empty">Nenhuma receita manual registrada.{" "}
                <button type="button" className="btn-primary" onClick={() => setDialog({ kind: "other" })}>Registrar primeira receita</button>
              </p>
            ) : (
              <ul className="list" style={{ display: "grid", gap: 6 }}>
                {otherIncome.map((t) => (
                  <li key={t.id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12 }}>
                    <span>
                      {t.description} · {dateFmt.format(new Date(`${t.competence_date}T12:00:00`))}
                    </span>
                    <b>{money(t.amount)}</b>
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
            <label htmlFor="earning-notes">Observação</label>
            <input id="earning-notes" name="notes" placeholder="Observação" />
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
            <label htmlFor="other-date">Data</label>
            <input id="other-date" name="competence_date" type="date" defaultValue={today} required />
            <button>Registrar receita</button>
          </SimpleForm>
        )}
      </Dialog>
    </main>
  );
}
