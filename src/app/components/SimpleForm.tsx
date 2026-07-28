"use client";

import React, { useState } from "react";

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
        try {
          await onSubmit(new FormData(e.currentTarget));
        } finally {
          setPending(false);
        }
      }}
    >
      <fieldset disabled={pending} aria-busy={pending}>
        {children}
      </fieldset>
      {pending ? <p role="status">Salvando...</p> : null}
    </form>
  );
}
