<?php
// Included after the API session/workspace guard. Documents never have public URLs.
function earningsError(string $message, int $status = 400): never {
    http_response_code($status);
    echo json_encode(['success' => false, 'error' => $message]);
    exit;
}
function earningsDate(mixed $value): string {
    if (!is_string($value) || !preg_match('/^\d{4}-\d{2}-\d{2}$/D', $value)) {
        earningsError('Informe uma data válida.');
    }
    [$year, $month, $day] = array_map('intval', explode('-', $value));
    if (!checkdate($month, $day, $year)) earningsError('Informe uma data válida.');
    return $value;
}
function earningsAmount(mixed $value): float {
    if (!is_numeric($value) || !is_finite((float)$value) || (float)$value < 0 || (float)$value > 999999999999.99) {
        earningsError('Informe um valor válido.');
    }
    return round((float)$value, 2);
}

if ($uri === '/patient-earnings' && $method === 'POST') {
    $workspaceId = (string)($body['workspace_id'] ?? '');
    $patientId = (string)($body['patient_id'] ?? '');
    if ($workspaceId === '' || $patientId === '') earningsError('Paciente e espaço financeiro são obrigatórios.');
    requireWorkspaceAccess($db, $sessionUser['id'], $workspaceId);
    if (requireResourceWorkspaceAccess($db, $sessionUser['id'], 'patients', $patientId) !== $workspaceId) {
        earningsError('O paciente não pertence ao mesmo espaço financeiro.');
    }
    $amount = earningsAmount($body['amount'] ?? null);
    if ($amount <= 0) earningsError('Informe um valor maior que zero.');
    $appointment = earningsDate($body['appointment_date'] ?? null);
    $due = earningsDate($body['due_date'] ?? $appointment);
    $stmt = $db->prepare("INSERT INTO patient_earnings
        (workspace_id, owner_id, patient_id, amount, appointment_date, due_date, status, notes)
        VALUES (?, ?, ?, ?, ?, ?, 'pending', ?) RETURNING *");
    $stmt->execute([$workspaceId, $sessionUser['id'], $patientId, $amount, $appointment, $due, $body['notes'] ?? null]);
    echo json_encode(['success' => true, 'earning' => $stmt->fetch()]);
    exit;
}

if ($uri === '/patient-earnings/receive' && $method === 'POST') {
    $earningId = (string)($body['earning_id'] ?? '');
    $accountId = (string)($body['account_id'] ?? '');
    $received = earningsDate($body['received_date'] ?? null);
    if ($earningId === '' || $accountId === '') earningsError('Atendimento e conta são obrigatórios.');
    $workspaceId = requireResourceWorkspaceAccess($db, $sessionUser['id'], 'patient_earnings', $earningId);
    if (requireResourceWorkspaceAccess($db, $sessionUser['id'], 'accounts', $accountId) !== $workspaceId) {
        earningsError('A conta não pertence ao mesmo espaço financeiro.');
    }
    $db->beginTransaction();
    try {
        $stmt = $db->prepare("SELECT e.*, p.name AS patient_name FROM patient_earnings e
            JOIN patients p ON p.id = e.patient_id AND p.workspace_id = e.workspace_id
            WHERE e.id = ? AND e.workspace_id = ? FOR UPDATE OF e");
        $stmt->execute([$earningId, $workspaceId]);
        $earning = $stmt->fetch();
        if (!$earning || $earning['status'] === 'cancelled') {
            $db->rollBack();
            earningsError('Atendimento indisponível para recebimento.', 409);
        }
        if ($earning['status'] === 'received') {
            $db->commit();
            echo json_encode(['success' => true, 'already_received' => true, 'transaction_id' => $earning['transaction_id']]);
            exit;
        }
        $stmt = $db->prepare("INSERT INTO transactions
            (workspace_id, owner_id, account_id, type, description, amount, interest_amount, competence_date, paid_at, status)
            VALUES (?, ?, ?, 'income', ?, ?, 0, ?, ?, 'paid') RETURNING id");
        $stmt->execute([$workspaceId, $sessionUser['id'], $accountId, 'Recebimento de paciente - ' . $earning['patient_name'],
            $earning['amount'], $received, $received]);
        $txId = $stmt->fetchColumn();
        $stmt = $db->prepare("UPDATE patient_earnings SET status = 'received', transaction_id = ? WHERE id = ?");
        $stmt->execute([$txId, $earningId]);
        $db->commit();
        echo json_encode(['success' => true, 'transaction_id' => $txId]);
        exit;
    } catch (Throwable $e) {
        if ($db->inTransaction()) $db->rollBack();
        throw $e;
    }
}

if (preg_match('#^/payslips/([a-f0-9-]{36})/document$#D', $uri, $match) && $method === 'GET') {
    $stmt = $db->prepare('SELECT workspace_id FROM payslips WHERE id = ?');
    $stmt->execute([$match[1]]);
    $workspaceId = $stmt->fetchColumn();
    if (!$workspaceId) earningsError('Documento não encontrado.', 404);
    requireWorkspaceAccess($db, $sessionUser['id'], $workspaceId);
    $stmt = $db->prepare("SELECT encode(content, 'base64') FROM payslip_documents WHERE payslip_id = ?");
    $stmt->execute([$match[1]]);
    $encoded = $stmt->fetchColumn();
    if (!$encoded) earningsError('Documento não disponível na VPS.', 404);
    header('Content-Type: application/pdf');
    header('Content-Disposition: attachment; filename="contracheque.pdf"');
    header('Cache-Control: private, no-store');
    header('X-Content-Type-Options: nosniff');
    echo base64_decode($encoded);
    exit;
}

if ($uri === '/payslips' && $method === 'POST') {
    $workspaceId = (string)($body['workspace_id'] ?? '');
    if ($workspaceId === '') earningsError('Espaço financeiro é obrigatório.');
    requireWorkspaceAccess($db, $sessionUser['id'], $workspaceId);
    $employer = trim((string)($body['employer'] ?? ''));
    if ($employer === '' || preg_match_all('/./us', $employer) > 120) earningsError('Informe um empregador válido.');
    $competence = earningsDate($body['competence'] ?? null);
    $gross = earningsAmount($body['gross_amount'] ?? null);
    $discounts = earningsAmount($body['discounts_amount'] ?? null);
    $net = earningsAmount($body['net_amount'] ?? null);
    if ((int)round($gross * 100) - (int)round($discounts * 100) !== (int)round($net * 100)) {
        earningsError('O valor líquido deve ser igual ao bruto menos os descontos.');
    }
    $received = !empty($body['received_date']) ? earningsDate($body['received_date']) : null;
    $accountId = !empty($body['account_id']) ? (string)$body['account_id'] : null;
    if (($received !== null) !== ($accountId !== null)) earningsError('Informe a conta e a data de recebimento juntas.');
    if ($accountId && requireResourceWorkspaceAccess($db, $sessionUser['id'], 'accounts', $accountId) !== $workspaceId) {
        earningsError('A conta não pertence ao mesmo espaço financeiro.');
    }
    $pdf = null;
    if (isset($_FILES['pdf']) && $_FILES['pdf']['error'] !== UPLOAD_ERR_NO_FILE) {
        $upload = $_FILES['pdf'];
        if ($upload['error'] !== UPLOAD_ERR_OK || $upload['size'] > 10 * 1024 * 1024 || !is_uploaded_file($upload['tmp_name'])) {
            earningsError('Não foi possível enviar o PDF (máximo 10 MB).');
        }
        $pdf = file_get_contents($upload['tmp_name']);
        if ($pdf === false || !str_starts_with($pdf, '%PDF-')) earningsError('O arquivo deve ser um PDF.');
    }
    $receipt = beginIdempotentMutation($db, $sessionUser['id'], $uri, [...$body, 'pdf_sha256' => $pdf === null ? null : hash('sha256', $pdf)]);
    try {
        $txId = null;
        if ($received && $net > 0) {
            $stmt = $db->prepare("INSERT INTO transactions
                (workspace_id, owner_id, account_id, type, description, amount, interest_amount, competence_date, paid_at, status)
                VALUES (?, ?, ?, 'income', ?, ?, 0, ?, ?, 'paid') RETURNING id");
            $stmt->execute([$workspaceId, $sessionUser['id'], $accountId, 'Contracheque ' . $employer, $net, $received, $received]);
            $txId = $stmt->fetchColumn();
        }
        $stmt = $db->prepare('INSERT INTO payslips
            (workspace_id, owner_id, employer, competence, gross_amount, discounts_amount, net_amount, received_date, transaction_id, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING *');
        $stmt->execute([$workspaceId, $sessionUser['id'], $employer, $competence, $gross, $discounts, $net, $received, $txId, $body['notes'] ?? null]);
        $payslip = $stmt->fetch();
        if ($pdf !== null) {
            $stmt = $db->prepare("INSERT INTO payslip_documents (payslip_id, content) VALUES (?, decode(?, 'base64'))");
            $stmt->execute([$payslip['id'], base64_encode($pdf)]);
            $payslip['pdf_path'] = '/api/payslips/' . $payslip['id'] . '/document';
            $stmt = $db->prepare('UPDATE payslips SET pdf_path = ? WHERE id = ?');
            $stmt->execute([$payslip['pdf_path'], $payslip['id']]);
        }
        commitIdempotentMutation($db, $receipt, ['success' => true, 'payslip' => $payslip, 'transaction_id' => $txId]);
        exit;
    } catch (Throwable $e) {
        if ($db->inTransaction()) $db->rollBack();
        throw $e;
    }
}
