export function isVerifiedServiceRoleRequest(request: Request): boolean {
  const payloadSegment = request.headers.get("Authorization")?.match(/^Bearer ([^.]+)\.([^.]+)\.([^.]+)$/)?.[2];
  if (!payloadSegment) return false;
  try {
    const normalized = payloadSegment.replace(/-/g, "+").replace(/_/g, "/");
    const padded = normalized.padEnd(normalized.length + ((4 - normalized.length % 4) % 4), "=");
    return JSON.parse(atob(padded)).role === "service_role";
  } catch {
    return false;
  }
}
