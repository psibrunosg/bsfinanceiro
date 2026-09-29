"use client";

import { useEffect, useState } from "react";

type StoredUser = {
  email?: string;
  display_name?: string;
};

export function useCurrentUser() {
  const [user, setUser] = useState<StoredUser>({});

  useEffect(() => {
    try {
      const stored = window.localStorage.getItem("bsfinanceiro_user");
      if (stored) setUser(JSON.parse(stored));
    } catch {
      setUser({});
    }
  }, []);

  const email = user.email ?? null;
  const localPart = email?.split("@")[0] ?? "";
  const displayName =
    user.display_name?.trim() ||
    (localPart
      ? localPart.charAt(0).toUpperCase() + localPart.slice(1)
      : "Usuário");
  const initials = displayName.charAt(0).toUpperCase() || "U";

  return { email, displayName, initials };
}
