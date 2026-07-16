const githubPagesBase = "/bsfinanceiro";

// URL absoluta do logo. Fixa porque o app é acessado via redirect de outro
// repositório, onde o basePath detectado em runtime não é confiável.
export const LOGO_URL = "https://raw.githubusercontent.com/psibrunosg/bsfinanceiro/refs/heads/main/public/logo-bsfinanceiro.png";

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
