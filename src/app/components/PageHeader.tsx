import Link from "next/link";
import { LOGO_URL } from "@/lib/app-path";

export function PageHeader({
  title,
  subtitle,
  workspaceName,
}: {
  title: string;
  subtitle: string;
  workspaceName: string;
}) {
  return (
    <header className="management-header">
      <Link href="/" aria-label="Voltar">
        ←
      </Link>
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        className="brand-logo"
        src={LOGO_URL}
        alt="BS Financeiro"
        width={44}
        height={44}
      />
      <div>
        <p className="eyebrow">{workspaceName}</p>
        <h1>{title}</h1>
        <p className="muted">{subtitle}</p>
      </div>
    </header>
  );
}
