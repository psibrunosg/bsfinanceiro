"use client";

import { useEffect, useState } from "react";
import { Download } from "lucide-react";

const DISMISS_KEY = "bsf:install-dismissed";

type InstallPromptEvent = Event & {
  prompt: () => Promise<void>;
};

function isInstallPromptEvent(event: Event): event is InstallPromptEvent {
  return "prompt" in event && typeof (event as { prompt?: unknown }).prompt === "function";
}

export function InstallPrompt() {
  const [deferred, setDeferred] = useState<InstallPromptEvent | null>(null);

  useEffect(() => {
    if (window.localStorage.getItem(DISMISS_KEY) === "1") return;
    if (window.matchMedia("(display-mode: standalone)").matches) return;
    const onBeforeInstallPrompt = (event: Event) => {
      event.preventDefault();
      if (isInstallPromptEvent(event)) setDeferred(event);
    };
    window.addEventListener("beforeinstallprompt", onBeforeInstallPrompt);
    return () => window.removeEventListener("beforeinstallprompt", onBeforeInstallPrompt);
  }, []);

  if (!deferred) return null;

  const install = () => {
    void deferred.prompt();
    setDeferred(null);
  };

  const dismiss = () => {
    window.localStorage.setItem(DISMISS_KEY, "1");
    setDeferred(null);
  };

  return (
    <div className="install-prompt" role="dialog" aria-label="Instalar aplicativo">
      <Download aria-hidden="true" />
      <p>Instalar o BS Financeiro no celular</p>
      <div className="install-prompt__actions">
        <button type="button" className="install-prompt__install" onClick={install}>Instalar</button>
        <button type="button" className="install-prompt__dismiss" onClick={dismiss}>Agora não</button>
      </div>
    </div>
  );
}
