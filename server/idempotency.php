<?php
// The receipt and financial effects commit together. Advisory locks serialize retries.
function beginIdempotentMutation(PDO $db, string $userId, string $route, array $payload): ?array {
    $key = $_SERVER['HTTP_X_IDEMPOTENCY_KEY'] ?? '';
    if ($key !== '' && !preg_match('/^[a-f0-9-]{36}$/D', $key)) {
        http_response_code(400); echo json_encode(['error' => 'Chave de repetição inválida.']); exit;
    }
    $db->beginTransaction();
    if ($key === '') return null; // Compatibility for existing API consumers.
    ksort($payload);
    $hash = hash('sha256', json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
    $db->prepare('SELECT pg_advisory_xact_lock(hashtextextended(?, 0))')->execute([$userId . ':' . $route . ':' . $key]);
    $stmt = $db->prepare('SELECT payload_hash, response FROM api_idempotency WHERE user_id = ? AND route = ? AND request_key = ?');
    $stmt->execute([$userId, $route, $key]);
    $receipt = $stmt->fetch();
    if ($receipt) {
        $db->rollBack();
        if (!hash_equals($receipt['payload_hash'], $hash)) {
            http_response_code(409); echo json_encode(['error' => 'A chave já foi usada com outros dados.']); exit;
        }
        echo $receipt['response']; exit;
    }
    return [$userId, $route, $key, $hash];
}
function commitIdempotentMutation(PDO $db, ?array $receipt, array $response): void {
    $json = json_encode($response, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if ($receipt !== null) {
        $stmt = $db->prepare('INSERT INTO api_idempotency (user_id, route, request_key, payload_hash, response) VALUES (?, ?, ?, ?, ?::jsonb)');
        $stmt->execute([...$receipt, $json]);
    }
    $db->commit();
    echo $json;
}
