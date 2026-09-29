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
    return globalThis.fetch(input, { ...init, headers });
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
