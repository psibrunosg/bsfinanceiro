export function List({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="dashboard-card">
      <h3 style={{ marginBottom: '16px', fontSize: '1.2rem' }}>{title}</h3>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        {children || <p className="muted">Nada por aqui ainda.</p>}
      </div>
    </div>
  );
}
