"use client";

import { useEffect, useRef } from "react";
import { X } from "lucide-react";

type DialogProps = {
  open: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
};

export function Dialog({ open, onClose, title, children }: DialogProps) {
  const ref = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const node = ref.current;
    if (!node) return;
    if (open && !node.open) {
      node.showModal();
    } else if (!open && node.open) {
      node.close();
    }
  }, [open]);

  useEffect(() => {
    const node = ref.current;
    if (!node) return;
    function handleClose() { onClose(); }
    node.addEventListener("close", handleClose);
    return () => node.removeEventListener("close", handleClose);
  }, [onClose]);

  return (
    <dialog ref={ref} className="dialog" aria-label={title}>
      <header className="dialog__header">
        <h2>{title}</h2>
        <button type="button" onClick={onClose} aria-label="Fechar">
          <X aria-hidden="true" />
        </button>
      </header>
      <div className="dialog__body">{children}</div>
    </dialog>
  );
}
