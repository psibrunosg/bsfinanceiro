import { Plus } from "lucide-react";
import { UserMenu } from "./UserMenu";
import { Button } from "@/components/ui/button";

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
      <div style={{ display: 'flex', justifyContent: 'flex-end', alignItems: 'center', marginBottom: '20px' }}>
        <UserMenu />
      </div>

      <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '32px', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <p className="eyebrow" style={{ margin: '0 0 4px', color: 'var(--muted)' }}>{workspaceName}</p>
          <h1 style={{ fontSize: '1.75rem', margin: '0 0 4px' }}>{title}</h1>
          <p className="muted" style={{ margin: 0 }}>{subtitle}</p>
        </div>
        
        {action && (
          <Button
            variant="primary"
            size="md"
            glow
            onClick={action.onClick}
            aria-label={action.ariaLabel || action.label}
            icon={<Plus size={18} aria-hidden="true" />}
            className="page-header__action"
          >
            {action.label}
          </Button>
        )}
      </div>
    </>
  );
}

