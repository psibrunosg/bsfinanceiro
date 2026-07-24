"use client";

import { useState } from "react";

export function SimpleForm({
  children,
  onSubmit,
}: {
  children: React.ReactNode;
  onSubmit: (form: FormData) => Promise<void>;
}) {
  const [pending, setPending] = useState(false);

  return (
    <form
      className="finance-form"
      onSubmit={async (e) => {
        e.preventDefault();
        setPending(true);
        await onSubmit(new FormData(e.currentTarget));
        setPending(false);
      }}
    >
      {children}
      <fieldset disabled={pending} />
    </form>
  );
}
