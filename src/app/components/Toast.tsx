"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import { CircleAlert, CircleCheck, X } from "lucide-react";

export type ToastKind = "success" | "error";

type ToastItem = { id: number; text: string; kind: ToastKind };

type ToastContextValue = {
  /** Empilha um aviso; o tipo vem do código, nunca do texto da mensagem. */
  toast: (text: string, kind?: ToastKind) => void;
};

/** Erros ficam mais tempo na tela porque costumam trazer o motivo da falha. */
const DURATION_MS: Record<ToastKind, number> = { success: 4000, error: 6000 };

const ToastContext = createContext<ToastContextValue>({ toast: () => {} });

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [items, setItems] = useState<ToastItem[]>([]);
  const timers = useRef(new Map<number, ReturnType<typeof setTimeout>>());
  const lastId = useRef(0);

  const dismiss = useCallback((id: number) => {
    const timer = timers.current.get(id);
    if (timer) {
      clearTimeout(timer);
      timers.current.delete(id);
    }
    setItems((current) => current.filter((item) => item.id !== id));
  }, []);

  const toast = useCallback(
    (text: string, kind: ToastKind = "success") => {
      const id = ++lastId.current;
      setItems((current) => [...current, { id, text, kind }]);
      timers.current.set(
        id,
        setTimeout(() => dismiss(id), DURATION_MS[kind]),
      );
    },
    [dismiss],
  );

  // Timers pendentes não podem sobreviver ao desmonte do provider.
  useEffect(() => {
    const pending = timers.current;
    return () => {
      pending.forEach((timer) => clearTimeout(timer));
      pending.clear();
    };
  }, []);

  const value = useMemo(() => ({ toast }), [toast]);

  return (
    <ToastContext.Provider value={value}>
      {children}
      <div className="toast-viewport" aria-live="polite" aria-atomic="false">
        {items.map((item) => (
          <div
            key={item.id}
            className={`toast toast--${item.kind}`}
            role={item.kind === "error" ? "alert" : undefined}
          >
            {item.kind === "error" ? (
              <CircleAlert aria-hidden="true" />
            ) : (
              <CircleCheck aria-hidden="true" />
            )}
            <p>{item.text}</p>
            <button
              type="button"
              className="toast__close"
              aria-label="Fechar aviso"
              title="Fechar aviso"
              onClick={() => dismiss(item.id)}
            >
              <X aria-hidden="true" />
            </button>
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}

export function useToast() {
  return useContext(ToastContext);
}
