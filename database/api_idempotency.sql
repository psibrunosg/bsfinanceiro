BEGIN;
CREATE TABLE IF NOT EXISTS api_idempotency (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    route TEXT NOT NULL,
    request_key TEXT NOT NULL,
    payload_hash TEXT NOT NULL,
    response JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, route, request_key)
);
REVOKE ALL ON api_idempotency FROM PUBLIC;
COMMIT;
