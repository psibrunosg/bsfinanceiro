-- Registro rápido por dispositivo (VPS PostgreSQL)
CREATE TABLE IF NOT EXISTS shortcut_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    token_hash CHAR(64) UNIQUE NOT NULL,
    token_hint VARCHAR(20),
    default_account_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
    default_category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    last_used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_shortcut_devices_owner
    ON shortcut_devices(owner_id, workspace_id);
CREATE TABLE IF NOT EXISTS shortcut_request_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id UUID NOT NULL REFERENCES shortcut_devices(id) ON DELETE CASCADE,
    request_key VARCHAR(120) NOT NULL,
    response_json JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (device_id, request_key)
);

CREATE INDEX IF NOT EXISTS idx_shortcut_request_log_created
    ON shortcut_request_log(device_id, created_at DESC);
