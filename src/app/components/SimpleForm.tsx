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
  const [error, setError] = useState("");

  return (
    <form
      className="finance-form"
      onSubmit={async (e) => {
        e.preventDefault();
        setError("");
        setPending(true);
        try {
          await onSubmit(new FormData(e.currentTarget));
        } catch {
          setError("Não foi possível salvar. Tente novamente.");
        } finally {
          setPending(false);
        }
      }}
    >
      <fieldset disabled={pending} aria-busy={pending}>
        {children}
      </fieldset>
      {pending ? <p role="status">Salvando...</p> : null}
      {error ? (
        <p className="form-error" role="alert">
          {error}
        </p>
      ) : null}
    </form>
  );
}
