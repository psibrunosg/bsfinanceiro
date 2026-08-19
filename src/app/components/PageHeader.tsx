import Link from "next/link";
import { ArrowLeft, Plus } from "lucide-react";
import { LOGO_URL } from "@/lib/app-path";
import { UserMenu } from "./UserMenu";

type PageHeaderProps = {
  title: string;
  subtitle: string;
  workspaceName: string;
  action?: {
    label: string;
    onClick: () => void;
    ariaLabel?: string;
  };
};

export function PageHeader({
  title,
  subtitle,
  workspaceName,
  action,
}: PageHeaderProps) {
  return (
    <header className="management-header">
      <Link href="/" aria-label="Voltar"><ArrowLeft aria-hidden="true" /></Link>
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
      {action && (
        <button
          type="button"
          className="page-header__action"
          onClick={action.onClick}
          aria-label={action.ariaLabel || action.label}
        >
          <Plus aria-hidden="true" />
          <span>{action.label}</span>
        </button>
      )}
      <UserMenu />
    </header>
  );
}
