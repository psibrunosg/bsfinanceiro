import { Plus } from "lucide-react";
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
    <>
      <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: '20px' }}>
        <UserMenu />
      </div>

      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '32px', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <p className="eyebrow" style={{ margin: '0 0 4px', color: 'var(--muted)' }}>{workspaceName}</p>
          <h1 style={{ fontSize: '1.75rem', margin: '0 0 4px' }}>{title}</h1>
          <p className="muted" style={{ margin: 0 }}>{subtitle}</p>
        </div>
        
        {action && (
          <button
            type="button"
            className="page-header__action"
            onClick={action.onClick}
            aria-label={action.ariaLabel || action.label}
            style={{ padding: '12px 24px', borderRadius: '12px', background: 'var(--primary)', color: 'var(--bg)', border: 'none', fontWeight: 600, display: 'flex', gap: '8px', alignItems: 'center', cursor: 'pointer' }}
          >
            <Plus size={18} aria-hidden="true" />
            <span>{action.label}</span>
          </button>
        )}
      </div>
    </>
  );
}
