export function List({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="account-list">
      <h2>{title}</h2>
      {children || <p className="muted">Nada por aqui ainda.</p>}
    </div>
  );
}
