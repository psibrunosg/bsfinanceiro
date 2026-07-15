const githubPagesBase = "/bsfinanceiro";

export function appPath(path = "/") {
  const normalized = path.startsWith("/") ? path : `/${path}`;
  if (typeof window === "undefined") return normalized;
  const base = window.location.pathname.startsWith(githubPagesBase)
    ? githubPagesBase
    : "";
  return `${base}${normalized === "/" ? "" : normalized}` || "/";
}

export function appUrl(path = "/") {
  if (typeof window === "undefined") return path;
  return `${window.location.origin}${appPath(path)}`;
}
