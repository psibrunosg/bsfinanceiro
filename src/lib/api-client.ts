const retryKeys = new Map<string, string>();

function mutationFingerprint(body: BodyInit | null | undefined): string {
  if (typeof FormData !== "undefined" && body instanceof FormData) {
    return JSON.stringify(Array.from(body.entries()).map(([key, value]) => [key,
      typeof value === "string" ? value : [value.name, value.size, value.lastModified],
    ]));
  }
  return String(body ?? "");
}

export function apiFetch(input: RequestInfo | URL, init: RequestInit = {}) {
  let token: string | null = null;
  if (typeof window !== "undefined") {
    try {
      token = window.localStorage.getItem("bsfinanceiro_token");
    } catch {
      token = null;
    }
  }

  if (typeof Headers !== "undefined") {
    const headers = new Headers(init.headers);
    if (token && !headers.has("Authorization")) {
      headers.set("Authorization", `Bearer ${token}`);
    }
    const route = String(input);
    const needsReceipt = init.method?.toUpperCase() === "POST" &&
      ["/api/payslips", "/api/investments/operations"].includes(route);
    let fingerprint: string | null = null;
    if (needsReceipt && !headers.has("X-Idempotency-Key")) {
      fingerprint = `${token ?? ""}|${route}|${mutationFingerprint(init.body)}`;
      if (!retryKeys.has(fingerprint)) {
        if (retryKeys.size >= 100) retryKeys.delete(retryKeys.keys().next().value!);
        retryKeys.set(fingerprint, crypto.randomUUID());
      }
      headers.set("X-Idempotency-Key", retryKeys.get(fingerprint)!);
    }
    return globalThis.fetch(input, { ...init, headers }).then(async (response) => {
      // Retain the key after network/server failure, when the commit may be ambiguous.
      if (fingerprint) {
        if (response.status >= 400 && response.status < 500 && response.status !== 408) {
          retryKeys.delete(fingerprint);
        } else if (response.ok) {
          try {
            const data = await response.clone().json();
            if (data?.success === true) retryKeys.delete(fingerprint);
          } catch { /* A truncated success body still has an ambiguous commit. */ }
        }
      }
      return response;
    });
  }

  const headers = {
    ...((init.headers as Record<string, string> | undefined) ?? {}),
  };
  if (
    token &&
    !Object.keys(headers).some((name) => name.toLowerCase() === "authorization")
  ) {
    headers.Authorization = `Bearer ${token}`;
  }
  return globalThis.fetch(input, { ...init, headers });
}
