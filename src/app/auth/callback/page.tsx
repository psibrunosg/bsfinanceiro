import Link from "next/link";
export default function AuthCallbackPage() {
  return <main className="auth-shell"><section className="auth-card">
    <p className="eyebrow">BS Financeiro</p><h1>Acesse sua conta</h1>
    <p className="muted">Este link de confirmação pertence ao serviço de acesso anterior. Entre com seu e-mail e senha.</p>
    <Link href="/entrar">Ir para o acesso</Link>
  </section></main>;
}
