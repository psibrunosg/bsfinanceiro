<?php
// BS Financeiro - REST API (PostgreSQL na VPS)
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-Shortcut-Token, X-Idempotency-Key');

$allowedOrigin = getenv('APP_ORIGIN') ?: '';
$requestOrigin = $_SERVER['HTTP_ORIGIN'] ?? '';
if ($allowedOrigin !== '' && $requestOrigin === $allowedOrigin) {
    header('Access-Control-Allow-Origin: ' . $allowedOrigin);
    header('Vary: Origin');
}

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    if ($requestOrigin !== '' && ($allowedOrigin === '' || $requestOrigin !== $allowedOrigin)) {
        http_response_code(403);
        exit;
    }
    http_response_code(204);
    exit;
}

// Database Connection
function getDb() {
    static $pdo = null;
    if ($pdo !== null) return $pdo;

    $host = getenv('DB_HOST') ?: 'deploy-nginx-fpm-db-1';
    $port = getenv('DB_PORT') ?: '5432';
    $dbname = getenv('DB_NAME') ?: 'bsfinanceiro';
    $user = getenv('DB_USER') ?: 'bstrainer';
    $pass = getenv('DB_PASSWORD') ?: getenv('DB_PASS');

    if (!$pass) {
        http_response_code(500);
        echo json_encode(['error' => 'Database password is not configured.']);
        exit;
    }

    try {
        $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
        $pdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
        return $pdo;
    } catch (PDOException $e) {
        error_log('BS Financeiro database connection failed: ' . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'Não foi possível conectar ao banco de dados.']);
        exit;
    }
}

function base64UrlEncode(string $value): string {
    return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
}

function base64UrlDecode(string $value): string|false {
    $padding = strlen($value) % 4;
    if ($padding) $value .= str_repeat('=', 4 - $padding);
    return base64_decode(strtr($value, '-_', '+/'), true);
}

function authSecret(): string {
    $secret = getenv('APP_AUTH_SECRET') ?: getenv('DB_PASSWORD') ?: getenv('DB_PASS');
    if (!$secret || strlen($secret) < 32) {
        http_response_code(500);
        echo json_encode(['error' => 'APP_AUTH_SECRET is not configured securely.']);
        exit;
    }
    return $secret;
}

function issueAuthToken(string $userId, string $email): string {
    $payload = base64UrlEncode(json_encode([
        'uid' => $userId,
        'email' => $email,
        'exp' => time() + 86400 * 30,
    ], JSON_UNESCAPED_SLASHES));
    $signature = base64UrlEncode(hash_hmac('sha256', $payload, authSecret(), true));
    return $payload . '.' . $signature;
}

function readAuthToken(): ?string {
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if (preg_match('/Bearer\s+(.+)$/i', $header, $matches)) {
        return trim($matches[1]);
    }
    return null;
}

function requireSessionUser(PDO $db): array {
    $token = readAuthToken();
    if (!$token || !str_contains($token, '.')) {
        http_response_code(401);
        echo json_encode(['error' => 'Sessão inválida. Entre novamente no BS Financeiro.']);
        exit;
    }

    [$payloadPart, $signaturePart] = explode('.', $token, 2);
    $expected = base64UrlEncode(hash_hmac('sha256', $payloadPart, authSecret(), true));
    if (!hash_equals($expected, $signaturePart)) {
        http_response_code(401);
        echo json_encode(['error' => 'Sessão inválida. Entre novamente no BS Financeiro.']);
        exit;
    }

    $decoded = base64UrlDecode($payloadPart);
    $payload = $decoded ? json_decode($decoded, true) : null;
    if (!is_array($payload) || empty($payload['uid']) || ($payload['exp'] ?? 0) < time()) {
        http_response_code(401);
        echo json_encode(['error' => 'Sessão expirada. Entre novamente no BS Financeiro.']);
        exit;
    }

    $stmt = $db->prepare('SELECT id, email, display_name FROM users WHERE id = ? LIMIT 1');
    $stmt->execute([$payload['uid']]);
    $user = $stmt->fetch();
    if (!$user) {
        http_response_code(401);
        echo json_encode(['error' => 'Usuário da sessão não encontrado.']);
        exit;
    }
    return $user;
}

function requireWorkspaceAccess(PDO $db, string $userId, string $workspaceId): void {
    $stmt = $db->prepare(
        'SELECT w.id, w.owner_id, wu.role
         FROM workspaces w
         LEFT JOIN workspace_users wu
           ON wu.workspace_id = w.id AND wu.user_id = ?
         WHERE w.id = ? AND (w.owner_id = ? OR wu.user_id IS NOT NULL)
         LIMIT 1'
    );
    $stmt->execute([$userId, $workspaceId, $userId]);
    $access = $stmt->fetch();
    if (!$access) {
        http_response_code(403);
        echo json_encode(['error' => 'Você não tem acesso a este espaço financeiro.']);
        exit;
    }
    if (!in_array($_SERVER['REQUEST_METHOD'], ['GET', 'HEAD', 'OPTIONS'], true)
        && $access['owner_id'] !== $userId && !in_array($access['role'], ['admin', 'editor'], true)) {
        http_response_code(403);
        echo json_encode(['error' => 'Seu perfil permite apenas consultar este espaço financeiro.']);
        exit;
    }
}

function requireResourceWorkspaceAccess(
    PDO $db,
    string $userId,
    string $table,
    string $resourceId
): string {
    $allowedTables = [
        'accounts',
        'categories',
        'credit_cards',
        'credit_card_invoices',
        'transactions',
        'debts',
        'fixed_commitments',
        'fixed_commitment_occurrences',
        'patients',
        'patient_earnings',
        'financial_goals',
        'financial_contexts',
        'investment_assets',
    ];
    if (!in_array($table, $allowedTables, true)) {
        throw new RuntimeException('Tabela de autorização inválida.');
    }

    $stmt = $db->prepare("SELECT workspace_id FROM {$table} WHERE id = ? LIMIT 1");
    $stmt->execute([$resourceId]);
    $workspaceId = $stmt->fetchColumn();
    if (!$workspaceId) {
        http_response_code(404);
        echo json_encode(['error' => 'Recurso não encontrado.']);
        exit;
    }

    requireWorkspaceAccess($db, $userId, (string)$workspaceId);
    return (string)$workspaceId;
}

function canManageWorkspace(PDO $db, string $userId, string $workspaceId): bool {
    $stmt = $db->prepare("SELECT w.id FROM workspaces w
        LEFT JOIN workspace_users wu ON wu.workspace_id = w.id AND wu.user_id = ?
        WHERE w.id = ? AND (w.owner_id = ? OR wu.role = 'admin')");
    $stmt->execute([$userId, $workspaceId, $userId]);
    return (bool)$stmt->fetchColumn();
}

function ensureShortcutSchema(PDO $db): void {
    $db->exec("CREATE TABLE IF NOT EXISTS shortcut_devices (
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
    )");
    $db->exec("CREATE TABLE IF NOT EXISTS shortcut_request_log (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        device_id UUID NOT NULL REFERENCES shortcut_devices(id) ON DELETE CASCADE,
        request_key VARCHAR(120) NOT NULL,
        response_json JSONB NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        UNIQUE (device_id, request_key)
    )");
}

function ensureCompatibilitySchema(PDO $db): void {
    static $done = false;
    if ($done) return;

    // Compatibilidade idempotente para instalações VPS criadas antes da
    // migração completa do Supabase. Mantém o deploy seguro sem exigir
    // recriar o volume PostgreSQL existente.
    $db->exec("ALTER TABLE transactions
        ADD COLUMN IF NOT EXISTS context_id UUID REFERENCES financial_contexts(id) ON DELETE SET NULL");

    $db->exec("ALTER TABLE workspace_preferences
        ADD COLUMN IF NOT EXISTS default_context_id UUID REFERENCES financial_contexts(id) ON DELETE SET NULL,
        ADD COLUMN IF NOT EXISTS default_period VARCHAR(30) DEFAULT 'current_month',
        ADD COLUMN IF NOT EXISTS hide_values BOOLEAN NOT NULL DEFAULT false,
        ADD COLUMN IF NOT EXISTS compact_mode BOOLEAN NOT NULL DEFAULT false,
        ADD COLUMN IF NOT EXISTS personal_color VARCHAR(20) DEFAULT '#087f5b',
        ADD COLUMN IF NOT EXISTS clinic_color VARCHAR(20) DEFAULT '#b93636',
        ADD COLUMN IF NOT EXISTS default_category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
        ADD COLUMN IF NOT EXISTS default_appointment_value NUMERIC(14,2) DEFAULT 0,
        ADD COLUMN IF NOT EXISTS default_billing_deadline_days INTEGER DEFAULT 30,
        ADD COLUMN IF NOT EXISTS alert_overdue_earnings BOOLEAN NOT NULL DEFAULT true,
        ADD COLUMN IF NOT EXISTS alert_stale_quotes BOOLEAN NOT NULL DEFAULT true");

    $db->exec("ALTER TABLE alert_preferences
        ADD COLUMN IF NOT EXISTS budget_alerts BOOLEAN NOT NULL DEFAULT true,
        ADD COLUMN IF NOT EXISTS goal_alerts BOOLEAN NOT NULL DEFAULT true,
        ADD COLUMN IF NOT EXISTS fixed_commitment_alerts BOOLEAN NOT NULL DEFAULT true,
        ADD COLUMN IF NOT EXISTS credit_card_alerts BOOLEAN NOT NULL DEFAULT true,
        ADD COLUMN IF NOT EXISTS low_balance_alerts BOOLEAN NOT NULL DEFAULT true,
        ADD COLUMN IF NOT EXISTS weekly_digest BOOLEAN NOT NULL DEFAULT true,
        ADD COLUMN IF NOT EXISTS budget_warning_percent SMALLINT NOT NULL DEFAULT 80,
        ADD COLUMN IF NOT EXISTS low_balance_amount NUMERIC(14,2) NOT NULL DEFAULT 0,
        ADD COLUMN IF NOT EXISTS weekly_digest_day SMALLINT NOT NULL DEFAULT 1");

    $done = true;
}

function shortcutBearerToken(): ?string {
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if (preg_match('/Bearer\s+(.+)$/i', $header, $matches)) return trim($matches[1]);
    return $_SERVER['HTTP_X_SHORTCUT_TOKEN'] ?? null;
}

$uri = $_SERVER['REQUEST_URI'];
$uri = strtok($uri, '?');
$uri = rtrim($uri, '/');
$uri = preg_replace('#^/api#', '', $uri);
$method = $_SERVER['REQUEST_METHOD'];

$rawInput = file_get_contents('php://input');
$body = json_decode($rawInput, true);
if (!is_array($body) || empty($body)) {
    $body = !empty($_POST) ? $_POST : [];
}

try {
    $db = getDb();
    ensureCompatibilitySchema($db);

    // 1. Health Check
    if ($uri === '' || $uri === '/health') {
        echo json_encode(['status' => 'online', 'database' => 'connected', 'timestamp' => date('c')]);
        exit;
    }

    // 1.1 Backup Status
    if ($uri === '/backup-status' && $method === 'GET') {
        requireSessionUser($db);
        $statusFile = '/opt/backups/bsfinanceiro/latest.json';
        if (file_exists($statusFile)) {
            $data = json_decode(file_get_contents($statusFile), true);
            echo json_encode(array_merge(['configured' => true], is_array($data) ? $data : []));
        } else {
            echo json_encode(['configured' => true, 'status' => 'pending', 'message' => 'Nenhum backup registrado ainda']);
        }
        exit;
    }

    require __DIR__ . "/auth-routes.php";

    // 2. Auth: Register
    if ($uri === '/auth/register' && $method === 'POST') {
        $email = trim(strtolower($body['email'] ?? ''));
        $password = $body['password'] ?? '';
        $name = trim($body['name'] ?? explode('@', $email)[0]);

        if (empty($email) || empty($password) || strlen($password) < 8) {
            http_response_code(400);
            echo json_encode(['error' => 'E-mail e senha (mínimo 8 caracteres) são obrigatórios.']);
            exit;
        }

        // Check if user exists
        $stmt = $db->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            http_response_code(400);
            echo json_encode(['error' => 'Este e-mail já está cadastrado. Faça login.']);
            exit;
        }

        $db->beginTransaction();

        // Create user
        $hash = password_hash($password, PASSWORD_BCRYPT);
        $stmt = $db->prepare("INSERT INTO users (email, password_hash, display_name) VALUES (?, ?, ?) RETURNING id, email, display_name");
        $stmt->execute([$email, $hash, $name]);
        $user = $stmt->fetch();
        $userId = $user['id'];

        // Create profile
        $db->prepare("INSERT INTO profiles (id, display_name) VALUES (?, ?)")->execute([$userId, $name]);

        // Create default workspace
        $stmt = $db->prepare("INSERT INTO workspaces (owner_id, name, kind) VALUES (?, 'Finanças Pessoais', 'personal') RETURNING id, name, kind");
        $stmt->execute([$userId]);
        $workspace = $stmt->fetch();
        $workspaceId = $workspace['id'];

        // Create default checking account
        $stmt = $db->prepare("INSERT INTO accounts (workspace_id, owner_id, name, type, initial_balance) VALUES (?, ?, 'Conta Principal', 'checking', 0.00) RETURNING id");
        $stmt->execute([$workspaceId, $userId]);
        $accountId = $stmt->fetchColumn();

        // Set default cash account in preferences
        $db->prepare("INSERT INTO workspace_preferences (workspace_id, owner_id, default_cash_account_id) VALUES (?, ?, ?)")
            ->execute([$workspaceId, $userId, $accountId]);

        // Create default categories
        $categories = [
            ['Alimentação & Mercado', 'expense', '#ef4444'],
            ['Moradia & Contas', 'expense', '#f59e0b'],
            ['Transporte & Mobilidade', 'expense', '#3b82f6'],
            ['Saúde & Farmácia', 'expense', '#10b981'],
            ['Lazer & Restaurantes', 'expense', '#8b5cf6'],
            ['Salário & Renda', 'income', '#22c55e'],
            ['Consultas & Atendimentos', 'income', '#0ea5e9'],
            ['Rendimentos & Investimentos', 'income', '#6366f1'],
        ];

        $catStmt = $db->prepare("INSERT INTO categories (workspace_id, owner_id, name, kind, color) VALUES (?, ?, ?, ?, ?)");
        foreach ($categories as $cat) {
            $catStmt->execute([$workspaceId, $userId, $cat[0], $cat[1], $cat[2]]);
        }

        $db->commit();

        echo json_encode([
            'success' => true,
            'user' => $user,
            'workspace' => $workspace,
            'token' => issueAuthToken($userId, $email)
        ]);
        exit;
    }

    // 3. Auth: Login
    if ($uri === '/auth/login' && $method === 'POST') {
        $email = trim(strtolower($body['email'] ?? ''));
        $password = $body['password'] ?? '';

        if (empty($email) || empty($password)) {
            http_response_code(400);
            echo json_encode(['error' => 'E-mail e senha são obrigatórios.']);
            exit;
        }

        $stmt = $db->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if (!$user || !password_verify($password, $user['password_hash'])) {
            http_response_code(401);
            echo json_encode(['error' => 'E-mail ou senha inválidos.']);
            exit;
        }

        // Get user's primary workspace
        $stmt = $db->prepare("SELECT * FROM workspaces WHERE owner_id = ? ORDER BY created_at ASC LIMIT 1");
        $stmt->execute([$user['id']]);
        $workspace = $stmt->fetch();

        $onboardingStmt = $db->prepare('SELECT onboarding_completed_at FROM profiles WHERE id = ?');
        $onboardingStmt->execute([$user['id']]);
        $onboardingRequired = !$onboardingStmt->fetchColumn();

        echo json_encode([
            'success' => true,
            'onboarding_required' => $onboardingRequired,
            'user' => [
                'id' => $user['id'],
                'email' => $user['email'],
                'display_name' => $user['display_name']
            ],
            'workspace' => $workspace,
            'token' => issueAuthToken($user['id'], $user['email'])
        ]);
        exit;
    }

    // Relatório compartilhado é público somente por token opaco e com expiração.
    if ($uri === '/reports/shared' && $method === 'GET') {
        header('Cache-Control: no-store');
        $token = trim((string)($_GET['token'] ?? ''));

        if (!preg_match('/^[a-f0-9]{48}$/', $token)) {
            http_response_code(404);
            echo json_encode(['error' => 'Relatório não encontrado ou link inválido.']);
            exit;
        }

        try {
            $stmt = $db->prepare("SELECT data, expires_at
                FROM shared_reports
                WHERE token = ? AND expires_at > NOW()
                LIMIT 1");
            $stmt->execute([$token]);
            $shared = $stmt->fetch();

            if (!$shared) {
                http_response_code(404);
                echo json_encode(['error' => 'Relatório não encontrado ou link inválido.']);
                exit;
            }

            $data = is_string($shared['data'])
                ? json_decode($shared['data'], true)
                : $shared['data'];

            if (!is_array($data) || !isset($data['report'], $data['transactions'])) {
                error_log('Shared report payload is malformed for token ' . substr($token, 0, 8));
                http_response_code(500);
                echo json_encode(['error' => 'Não foi possível carregar o relatório.']);
                exit;
            }

            echo json_encode([
                'success' => true,
                'data' => $data,
                'expires_at' => $shared['expires_at'],
            ]);
            exit;
        } catch (Throwable $e) {
            error_log('Shared report read failed: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Não foi possível carregar o relatório.']);
            exit;
        }
    }

    // Todas as rotas abaixo são privadas, exceto o endpoint de captura rápida,
    // que usa seu próprio token de dispositivo.
    $sessionUser = null;
    $isShortcutCapture = $uri === '/shortcuts' && $method === 'POST';
    if (!$isShortcutCapture) {
        $sessionUser = requireSessionUser($db);
        // Identidade nunca é aceita do cliente em rotas privadas.
        $body['owner_id'] = $sessionUser['id'];

        $requestedWorkspaceId = $_GET['workspace_id'] ?? $body['workspace_id'] ?? null;
        if (is_string($requestedWorkspaceId) && $requestedWorkspaceId !== '') {
            requireWorkspaceAccess($db, $sessionUser['id'], $requestedWorkspaceId);
        }
    }

    require_once __DIR__ . "/idempotency.php";
    require __DIR__ . "/earnings-routes.php";
    require_once __DIR__ . "/card-import-routes.php";
    if (handleCardImportRoutes($db, $uri, $method)) exit;

    // 3.1. Auth: Change Password
    if ($uri === '/auth/change-password' && $method === 'POST') {
        $userId = $sessionUser['id'];
        $currentPassword = $body['current_password'] ?? '';
        $newPassword = $body['new_password'] ?? '';

        if (empty($currentPassword) || empty($newPassword) || strlen($newPassword) < 8) {
            http_response_code(400);
            echo json_encode(['error' => 'Preencha a senha atual e a nova senha (mínimo 8 caracteres).']);
            exit;
        }

        $stmt = $db->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        $user = $stmt->fetch();

        if (!$user || !password_verify($currentPassword, $user['password_hash'])) {
            http_response_code(401);
            echo json_encode(['error' => 'Senha atual incorreta.']);
            exit;
        }

        $newHash = password_hash($newPassword, PASSWORD_BCRYPT);
        $stmt = $db->prepare("UPDATE users SET password_hash = ? WHERE id = ?");
        $stmt->execute([$newHash, $userId]);

        echo json_encode(['success' => true, 'message' => 'Senha alterada com sucesso!']);
        exit;
    }

    // 3.2. Profile: Get & Update Profile Customization
    if ($uri === '/profile' && $method === 'GET') {
        $userId = $sessionUser['id'];

        $stmt = $db->prepare("SELECT u.id, u.email, u.display_name, p.age, p.birth_date, p.profession, p.phone, p.avatar_color, p.theme_preference 
                              FROM users u LEFT JOIN profiles p ON p.id = u.id WHERE u.id = ?");
        $stmt->execute([$userId]);
        $profile = $stmt->fetch();

        echo json_encode(['profile' => $profile]);
        exit;
    }

    if ($uri === '/profile/update' && $method === 'POST') {
        $userId = $sessionUser['id'];
        $displayName = trim($body['display_name'] ?? '');
        $age = !empty($body['age']) ? (int)$body['age'] : null;
        $profession = trim($body['profession'] ?? '');
        $phone = trim($body['phone'] ?? '');
        $avatarColor = trim($body['avatar_color'] ?? '#8b5cf6');

        if (!empty($displayName)) {
            $db->prepare("UPDATE users SET display_name = ? WHERE id = ?")->execute([$displayName, $userId]);
        }

        $stmt = $db->prepare("INSERT INTO profiles (id, display_name, age, profession, phone, avatar_color)
            VALUES (?, ?, ?, ?, ?, ?)
            ON CONFLICT (id) DO UPDATE SET 
                display_name = EXCLUDED.display_name,
                age = EXCLUDED.age,
                profession = EXCLUDED.profession,
                phone = EXCLUDED.phone,
                avatar_color = EXCLUDED.avatar_color");
        $stmt->execute([$userId, $displayName, $age, $profession, $phone, $avatarColor]);

        echo json_encode([
            'success' => true,
            'profile' => [
                'id' => $userId,
                'display_name' => $displayName,
                'age' => $age,
                'profession' => $profession,
                'phone' => $phone,
                'avatar_color' => $avatarColor
            ]
        ]);
        exit;
    }

    // 4. Data: Bootstrap All Workspace Data
    if ($uri === '/bootstrap' && $method === 'GET') {
        $workspaceId = $_GET['workspace_id'] ?? null;
        if (!$workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'workspace_id is required']);
            exit;
        }

        $accounts = $db->prepare("SELECT id, name, type, initial_balance, is_shared, active, is_system FROM accounts WHERE workspace_id = ? AND active = true ORDER BY name ASC");
        $accounts->execute([$workspaceId]);

        $categories = $db->prepare("SELECT id, name, kind, color, budget_limit FROM categories WHERE workspace_id = ? ORDER BY name ASC");
        $categories->execute([$workspaceId]);

        $transactions = $db->prepare("SELECT id, account_id, destination_account_id, invoice_id, type, status, description, amount, interest_amount, competence_date, due_date, installment_current, installment_total, category_id, context_id, paid_at FROM transactions WHERE workspace_id = ? ORDER BY competence_date DESC, created_at DESC LIMIT 10000");
        $transactions->execute([$workspaceId]);

        $budgets = $db->prepare("SELECT id, category_id, amount, month FROM monthly_budgets WHERE workspace_id = ?");
        $budgets->execute([$workspaceId]);

        $goals = $db->prepare("SELECT id, name, target_amount, current_amount, deadline, status FROM financial_goals WHERE workspace_id = ? AND status = 'active'");
        $goals->execute([$workspaceId]);

        $cards = $db->prepare("SELECT id, account_id, name, brand, last_four, closing_day, due_day, COALESCE(credit_limit, limit_amount, 0) as credit_limit FROM credit_cards WHERE workspace_id = ?");
        $cards->execute([$workspaceId]);

        $investments = $db->prepare("SELECT * FROM investment_assets WHERE workspace_id = ? AND active = true");
        $investments->execute([$workspaceId]);

        $commitments = [];
        try {
            $stmt = $db->prepare("SELECT * FROM fixed_commitments WHERE workspace_id = ? AND active = true ORDER BY due_day ASC");
            $stmt->execute([$workspaceId]);
            $commitments = $stmt->fetchAll();

            $currentMonthDate = date('Y-m-01');
            foreach ($commitments as $c) {
                $chk = $db->prepare("SELECT id FROM fixed_commitment_occurrences WHERE commitment_id = ? AND month_date = ?");
                $chk->execute([$c['id'], $currentMonthDate]);
                if (!$chk->fetch()) {
                    $ins = $db->prepare("INSERT INTO fixed_commitment_occurrences (commitment_id, workspace_id, owner_id, month_date, status) VALUES (?, ?, ?, ?, 'pending')");
                    $ins->execute([$c['id'], $c['workspace_id'], $c['owner_id'], $currentMonthDate]);
                }
            }
        } catch (Exception $e) {}

        $occurrences = [];
        try {
            $stmt = $db->prepare("SELECT o.id, o.commitment_id AS fixed_commitment_id, o.commitment_id, o.workspace_id, o.owner_id, o.month_date, 
                CASE WHEN o.status = 'pending' THEN 'planned' ELSE o.status END AS status,
                o.transaction_id, o.created_at,
                c.description, c.amount, c.due_day, c.category_id,
                TO_CHAR(o.month_date, 'YYYY-MM') || '-' || LPAD(c.due_day::text, 2, '0') AS due_date
                FROM fixed_commitment_occurrences o 
                JOIN fixed_commitments c ON c.id = o.commitment_id 
                WHERE c.workspace_id = ? AND c.active = true ORDER BY o.month_date ASC, c.due_day ASC");
            $stmt->execute([$workspaceId]);
            $occurrences = $stmt->fetchAll();
        } catch (Exception $e) {}

        $debts = [];
        try {
            $stmt = $db->prepare("SELECT * FROM debts WHERE workspace_id = ? ORDER BY created_at DESC");
            $stmt->execute([$workspaceId]);
            $debts = $stmt->fetchAll();
        } catch (Exception $e) {}

        $workspaceUsers = [];
        try {
            $stmt = $db->prepare("SELECT u.id, u.workspace_id, u.user_id, u.role, us.display_name, us.email FROM workspace_users u JOIN users us ON us.id = u.user_id WHERE u.workspace_id = ?");
            $stmt->execute([$workspaceId]);
            $workspaceUsers = $stmt->fetchAll();
        } catch (Exception $e) {}

        $workspaceInvites = [];
        try {
            if (canManageWorkspace($db, $sessionUser['id'], $workspaceId)) {
                $stmt = $db->prepare("SELECT id, workspace_id, token, role, expires_at, created_at FROM workspace_invites WHERE workspace_id = ? AND expires_at > NOW() AND accepted_at IS NULL ORDER BY created_at DESC");
                $stmt->execute([$workspaceId]);
                $workspaceInvites = $stmt->fetchAll();
            }
        } catch (Exception $e) {}

        $contexts = [];
        try {
            $stmt = $db->prepare("SELECT id, workspace_id, owner_id, kind, name, color, active, created_at FROM financial_contexts WHERE workspace_id = ? AND active = true ORDER BY name ASC");
            $stmt->execute([$workspaceId]);
            $contexts = $stmt->fetchAll();
        } catch (Exception $e) {}

        $categoryRules = [];
        try {
            $stmt = $db->prepare("SELECT id, pattern, category_id FROM transaction_category_rules WHERE workspace_id = ? ORDER BY created_at DESC");
            $stmt->execute([$workspaceId]);
            $categoryRules = $stmt->fetchAll();
        } catch (Exception $e) {}

        $transactionImportBatches = [];
        try {
            $stmt = $db->prepare("SELECT id, account_id, file_name, status, created_at, applied_at, discarded_at
                FROM transaction_import_batches
                WHERE workspace_id = ? AND owner_id = ?
                ORDER BY created_at DESC
                LIMIT 10");
            $stmt->execute([$workspaceId, $sessionUser['id']]);
            $transactionImportBatches = $stmt->fetchAll();

            $itemsStmt = $db->prepare("SELECT id, batch_id, row_number, competence_date, description, amount_cents, type, status, reason, fingerprint, category_id, transaction_id, created_at
                FROM transaction_import_items
                WHERE batch_id = ? AND owner_id = ?
                ORDER BY row_number ASC");

            foreach ($transactionImportBatches as &$batch) {
                $itemsStmt->execute([$batch['id'], $sessionUser['id']]);
                $batch['transaction_import_items'] = $itemsStmt->fetchAll();
            }
            unset($batch);
        } catch (Exception $e) {
            $transactionImportBatches = [];
        }

        $alertPrefs = null;
        try {
            $stmt = $db->prepare("SELECT * FROM alert_preferences WHERE workspace_id = ? LIMIT 1");
            $stmt->execute([$workspaceId]);
            $alertPrefs = $stmt->fetch() ?: null;
        } catch (Exception $e) {}

        $workspacePrefs = null;
        try {
            $stmt = $db->prepare("SELECT * FROM workspace_preferences WHERE workspace_id = ? LIMIT 1");
            $stmt->execute([$workspaceId]);
            $workspacePrefs = $stmt->fetch() ?: null;
        } catch (Exception $e) {}

        $patients = [];
        try {
            $stmt = $db->prepare("SELECT * FROM patients WHERE workspace_id = ? ORDER BY name ASC");
            $stmt->execute([$workspaceId]);
            $patients = $stmt->fetchAll();
        } catch (Exception $e) {}

        $patientEarnings = [];
        try {
            $stmt = $db->prepare("SELECT e.*, p.name as patient_name FROM patient_earnings e JOIN patients p ON p.id = e.patient_id WHERE e.workspace_id = ? ORDER BY e.appointment_date DESC");
            $stmt->execute([$workspaceId]);
            $patientEarnings = $stmt->fetchAll();
        } catch (Exception $e) {}

        $payslips = [];
        try {
            $stmt = $db->prepare("SELECT * FROM payslips WHERE workspace_id = ? ORDER BY competence DESC");
            $stmt->execute([$workspaceId]);
            $payslips = $stmt->fetchAll();
        } catch (Exception $e) {}

        $investmentOps = [];
        try {
            $stmt = $db->prepare("SELECT o.*, a.name as asset_name, a.ticker FROM investment_operations o JOIN investment_assets a ON a.id = o.asset_id WHERE o.workspace_id = ? ORDER BY o.operation_date DESC");
            $stmt->execute([$workspaceId]);
            $investmentOps = $stmt->fetchAll();
        } catch (Exception $e) {}

        $investmentQuotes = [];
        try {
            $stmt = $db->prepare("SELECT * FROM investment_quotes WHERE workspace_id = ? ORDER BY quote_date DESC");
            $stmt->execute([$workspaceId]);
            $investmentQuotes = $stmt->fetchAll();
        } catch (Exception $e) {}

        $goalContribs = [];
        try {
            $stmt = $db->prepare("SELECT * FROM goal_contributions WHERE workspace_id = ? ORDER BY created_at DESC");
            $stmt->execute([$workspaceId]);
            $goalContribs = $stmt->fetchAll();
        } catch (Exception $e) {}

        $invoices = [];
        try {
            $stmt = $db->prepare("SELECT id, account_id, credit_card_id, workspace_id, month, year, due_date, closing_date, paid_at, status, total_amount FROM credit_card_invoices WHERE workspace_id = ? ORDER BY due_date DESC, year DESC, month DESC");
            $stmt->execute([$workspaceId]);
            $invoices = $stmt->fetchAll();

            if (!empty($invoices)) {
                $instStmt = $db->prepare("
                    SELECT i.id, i.invoice_id, i.installment_number, i.amount, i.competence_date,
                           p.description, p.installment_count
                    FROM credit_card_installments i
                    JOIN credit_card_purchases p ON p.id = i.purchase_id
                    WHERE i.workspace_id = ?
                    AND (i.competence_date >= (CURRENT_DATE - INTERVAL '12 months')::date)
                    ORDER BY i.competence_date ASC, i.installment_number ASC
                ");
                $instStmt->execute([$workspaceId]);
                $allInstallments = $instStmt->fetchAll();

                $installmentsByInvoice = [];
                foreach ($allInstallments as $inst) {
                    $invId = $inst['invoice_id'];
                    if (!isset($installmentsByInvoice[$invId])) {
                        $installmentsByInvoice[$invId] = [];
                    }
                    $installmentsByInvoice[$invId][] = [
                        'amount' => (float)$inst['amount'],
                        'installment_number' => (int)$inst['installment_number'],
                        'credit_card_purchases' => [
                            'description' => $inst['description'],
                            'installment_count' => (int)$inst['installment_count']
                        ]
                    ];
                }

                foreach ($invoices as &$inv) {
                    $inv['credit_card_installments'] = $installmentsByInvoice[$inv['id']] ?? [];
                }
                unset($inv);
            }
        } catch (Exception $e) {}

        echo json_encode([
            'accounts' => $accounts->fetchAll(),
            'categories' => $categories->fetchAll(),
            'transactions' => $transactions->fetchAll(),
            'budgets' => $budgets->fetchAll(),
            'goals' => $goals->fetchAll(),
            'cards' => $cards->fetchAll(),
            'invoices' => $invoices,
            'investments' => $investments->fetchAll(),
            'investment_operations' => $investmentOps,
            'investment_quotes' => $investmentQuotes,
            'commitments' => $commitments,
            'occurrences' => $occurrences,
            'debts' => $debts,
            'patients' => $patients,
            'patient_earnings' => $patientEarnings,
            'payslips' => $payslips,
            'goal_contributions' => $goalContribs,
            'workspace_users' => $workspaceUsers,
            'workspace_invites' => $workspaceInvites,
            'contexts' => $contexts,
            'category_rules' => $categoryRules,
            'transaction_import_batches' => $transactionImportBatches,
            'alert_preferences' => $alertPrefs,
            'workspace_preferences' => $workspacePrefs,
        ]);
        exit;
    }

    // 4.0 Relatórios compartilhados: criar snapshot público com expiração
    if ($uri === '/reports/share' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $name = trim((string)($body['name'] ?? 'Relatório Consolidado'));
        $ownerId = $sessionUser['id'];

        if (!$workspaceId) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'workspace_id é obrigatório.']);
            exit;
        }

        requireWorkspaceAccess($db, $ownerId, $workspaceId);

        if ($name === '') $name = 'Relatório Consolidado';
        if (strlen($name) > 120) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Nome do relatório é muito longo.']);
            exit;
        }

        try {
            $transactionsStmt = $db->prepare("SELECT id, type, amount, competence_date, description
                FROM transactions
                WHERE workspace_id = ?
                  AND type IN ('income', 'expense')
                ORDER BY competence_date DESC, created_at DESC
                LIMIT 10000");
            $transactionsStmt->execute([$workspaceId]);
            $transactions = $transactionsStmt->fetchAll();

            $token = bin2hex(random_bytes(24));
            $payload = json_encode([
                'report' => ['name' => $name],
                'transactions' => $transactions,
            ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

            $stmt = $db->prepare("INSERT INTO shared_reports
                (token, workspace_id, data, expires_at)
                VALUES (?, ?, ?::jsonb, NOW() + INTERVAL '7 days')
                RETURNING token, expires_at");
            $stmt->execute([$token, $workspaceId, $payload]);
            $shared = $stmt->fetch();

            echo json_encode([
                'success' => true,
                'token' => $shared['token'],
                'expires_at' => $shared['expires_at'],
            ]);
            exit;
        } catch (Throwable $e) {
            error_log('Shared report creation failed: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['success' => false, 'error' => 'Não foi possível gerar o link compartilhável.']);
            exit;
        }
    }

    // 4.1 Importação de extrato: criar lote e itens de prévia
    if ($uri === '/imports/preview' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $accountId = $body['account_id'] ?? null;
        $fileName = trim($body['file_name'] ?? '');
        $items = $body['items'] ?? null;
        $ownerId = $sessionUser['id'];

        if (!$workspaceId || !$accountId || $fileName === '' || !is_array($items) || count($items) === 0) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'workspace_id, account_id, file_name e items são obrigatórios.']);
            exit;
        }

        if (strlen($fileName) > 255 || count($items) > 5000) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Arquivo ou lote de importação excede o limite permitido.']);
            exit;
        }

        if (requireResourceWorkspaceAccess($db, $sessionUser['id'], 'accounts', $accountId) !== $workspaceId) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'A conta não pertence ao espaço financeiro informado.']);
            exit;
        }

        $validatedItems = [];
        foreach ($items as $item) {
            if (!is_array($item)) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'Item de importação inválido.']);
                exit;
            }

            $rowNumber = (int)($item['row_number'] ?? 0);
            $status = $item['status'] ?? '';
            $competenceDate = $item['competence_date'] ?? null;
            $description = isset($item['description']) ? trim((string)$item['description']) : null;
            $amountCents = isset($item['amount_cents']) ? (int)$item['amount_cents'] : null;
            $type = $item['type'] ?? null;
            $reason = isset($item['reason']) ? trim((string)$item['reason']) : null;
            $fingerprint = isset($item['fingerprint']) ? trim((string)$item['fingerprint']) : null;
            $categoryId = $item['category_id'] ?? null;

            if ($rowNumber <= 0 || !in_array($status, ['ready', 'duplicate', 'invalid'], true)) {
                http_response_code(400);
                echo json_encode(['success' => false, 'error' => 'Linha ou status de importação inválido.']);
                exit;
            }

            if ($status === 'invalid') {
                if (!$reason) {
                    http_response_code(400);
                    echo json_encode(['success' => false, 'error' => 'Itens inválidos precisam informar o motivo.']);
                    exit;
                }
                $competenceDate = null;
                $description = null;
                $amountCents = null;
                $type = null;
                $fingerprint = null;
                $categoryId = null;
            } else {
                if (!$competenceDate || !$description || strlen($description) > 160 || !$amountCents || $amountCents <= 0
                    || !in_array($type, ['income', 'expense'], true) || !$fingerprint) {
                    http_response_code(400);
                    echo json_encode(['success' => false, 'error' => 'Item pronto/duplicado está incompleto.']);
                    exit;
                }

                if ($categoryId && requireResourceWorkspaceAccess($db, $sessionUser['id'], 'categories', $categoryId) !== $workspaceId) {
                    http_response_code(400);
                    echo json_encode(['success' => false, 'error' => 'A categoria não pertence ao mesmo espaço financeiro.']);
                    exit;
                }
            }

            $validatedItems[] = [
                'row_number' => $rowNumber,
                'competence_date' => $competenceDate,
                'description' => $description,
                'amount_cents' => $amountCents,
                'type' => $type,
                'status' => $status,
                'reason' => $reason,
                'fingerprint' => $fingerprint,
                'category_id' => $categoryId,
            ];
        }

        try {
            $db->beginTransaction();

            $stmt = $db->prepare("INSERT INTO transaction_import_batches
                (workspace_id, owner_id, account_id, file_name, status)
                VALUES (?, ?, ?, ?, 'pending')
                RETURNING id, workspace_id, owner_id, account_id, file_name, status, created_at, applied_at, discarded_at");
            $stmt->execute([$workspaceId, $ownerId, $accountId, $fileName]);
            $batch = $stmt->fetch();

            $itemStmt = $db->prepare("INSERT INTO transaction_import_items
                (batch_id, workspace_id, owner_id, row_number, competence_date, description, amount_cents, type, status, reason, fingerprint, category_id)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                RETURNING id, row_number, competence_date, description, amount_cents, type, status, reason, fingerprint, category_id, transaction_id, created_at");

            $savedItems = [];
            foreach ($validatedItems as $item) {
                $itemStmt->execute([
                    $batch['id'],
                    $workspaceId,
                    $ownerId,
                    $item['row_number'],
                    $item['competence_date'],
                    $item['description'],
                    $item['amount_cents'],
                    $item['type'],
                    $item['status'],
                    $item['reason'],
                    $item['fingerprint'],
                    $item['category_id'],
                ]);
                $savedItems[] = $itemStmt->fetch();
            }

            $db->commit();
            $batch['transaction_import_items'] = $savedItems;

            echo json_encode(['success' => true, 'batch' => $batch]);
            exit;
        } catch (Throwable $e) {
            if ($db->inTransaction()) $db->rollBack();
            error_log('Statement import preview failed: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['success' => false, 'error' => 'Não foi possível criar a prévia da importação.']);
            exit;
        }
    }

    // 4.2 Importação de extrato: confirmar lote pendente
    if ($method === 'POST' && preg_match('#^/imports/([0-9a-fA-F-]{36})/apply$#', $uri, $matches)) {
        $batchId = $matches[1];
        $ownerId = $sessionUser['id'];

        try {
            $db->beginTransaction();

            $stmt = $db->prepare("SELECT id, workspace_id, owner_id, account_id, file_name, status
                FROM transaction_import_batches
                WHERE id = ? AND owner_id = ?
                FOR UPDATE");
            $stmt->execute([$batchId, $ownerId]);
            $batch = $stmt->fetch();

            if (!$batch) {
                $db->rollBack();
                http_response_code(404);
                echo json_encode(['success' => false, 'error' => 'Lote de importação não encontrado.']);
                exit;
            }

            requireWorkspaceAccess($db, $ownerId, $batch['workspace_id']);

            if ($batch['status'] === 'discarded') {
                $db->rollBack();
                http_response_code(409);
                echo json_encode(['success' => false, 'error' => 'Lote de importação já foi descartado.']);
                exit;
            }

            if ($batch['status'] === 'applied') {
                $idsStmt = $db->prepare("SELECT transaction_id
                    FROM transaction_import_items
                    WHERE batch_id = ? AND transaction_id IS NOT NULL
                    ORDER BY row_number");
                $idsStmt->execute([$batchId]);
                $transactionIds = array_values(array_filter(array_column($idsStmt->fetchAll(), 'transaction_id')));
                $db->commit();
                echo json_encode(['success' => true, 'already_applied' => true, 'transaction_ids' => $transactionIds]);
                exit;
            }

            $itemsStmt = $db->prepare("SELECT id, row_number, competence_date, description, amount_cents, type, status, reason, fingerprint, category_id, transaction_id
                FROM transaction_import_items
                WHERE batch_id = ? AND owner_id = ?
                ORDER BY row_number
                FOR UPDATE");
            $itemsStmt->execute([$batchId, $ownerId]);
            $items = $itemsStmt->fetchAll();

            $seenFingerprints = [];
            $transactionIds = [];

            $findExisting = $db->prepare("SELECT id
                FROM transactions
                WHERE workspace_id = ?
                  AND owner_id = ?
                  AND account_id = ?
                  AND type = ?
                  AND status = 'paid'
                  AND competence_date = ?
                  AND amount = ?
                  AND LOWER(TRIM(description)) = LOWER(TRIM(?))
                ORDER BY created_at ASC
                LIMIT 1");

            $insertTransaction = $db->prepare("INSERT INTO transactions
                (workspace_id, owner_id, account_id, category_id, type, status, description, amount, competence_date, paid_at, notes)
                VALUES (?, ?, ?, ?, ?, 'paid', ?, ?, ?, ?, ?)
                RETURNING id");

            $markDuplicate = $db->prepare("UPDATE transaction_import_items
                SET status = 'duplicate', reason = ?, transaction_id = NULL
                WHERE id = ? AND batch_id = ?");

            $markAppliedItem = $db->prepare("UPDATE transaction_import_items
                SET transaction_id = ?
                WHERE id = ? AND batch_id = ? AND status = 'ready'");

            foreach ($items as $item) {
                if ($item['status'] !== 'ready') continue;

                $fingerprint = trim((string)($item['fingerprint'] ?? ''));
                if ($fingerprint !== '' && isset($seenFingerprints[$fingerprint])) {
                    $markDuplicate->execute(['duplicate_file', $item['id'], $batchId]);
                    continue;
                }
                if ($fingerprint !== '') $seenFingerprints[$fingerprint] = true;

                $amount = ((int)$item['amount_cents']) / 100;
                $findExisting->execute([
                    $batch['workspace_id'],
                    $ownerId,
                    $batch['account_id'],
                    $item['type'],
                    $item['competence_date'],
                    $amount,
                    $item['description'],
                ]);
                $existingId = $findExisting->fetchColumn();

                if ($existingId) {
                    $markDuplicate->execute(['duplicate_existing', $item['id'], $batchId]);
                    continue;
                }

                $insertTransaction->execute([
                    $batch['workspace_id'],
                    $ownerId,
                    $batch['account_id'],
                    $item['category_id'],
                    $item['type'],
                    trim((string)$item['description']),
                    $amount,
                    $item['competence_date'],
                    $item['competence_date'],
                    'Importado do lote de extrato ' . $batchId,
                ]);
                $transactionId = $insertTransaction->fetchColumn();
                $markAppliedItem->execute([$transactionId, $item['id'], $batchId]);
                $transactionIds[] = $transactionId;
            }

            $finish = $db->prepare("UPDATE transaction_import_batches
                SET status = 'applied', applied_at = NOW(), discarded_at = NULL
                WHERE id = ? AND owner_id = ? AND status = 'pending'");
            $finish->execute([$batchId, $ownerId]);

            $db->commit();
            echo json_encode(['success' => true, 'transaction_ids' => $transactionIds]);
            exit;
        } catch (Throwable $e) {
            if ($db->inTransaction()) $db->rollBack();
            error_log('Statement import apply failed: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['success' => false, 'error' => 'Não foi possível confirmar a importação.']);
            exit;
        }
    }

    // 4.3 Importação de extrato: descartar lote pendente
    if ($method === 'POST' && preg_match('#^/imports/([0-9a-fA-F-]{36})/discard$#', $uri, $matches)) {
        $batchId = $matches[1];
        $ownerId = $sessionUser['id'];

        try {
            $db->beginTransaction();

            $stmt = $db->prepare("SELECT id, workspace_id, owner_id, status
                FROM transaction_import_batches
                WHERE id = ? AND owner_id = ?
                FOR UPDATE");
            $stmt->execute([$batchId, $ownerId]);
            $batch = $stmt->fetch();

            if (!$batch) {
                $db->rollBack();
                http_response_code(404);
                echo json_encode(['success' => false, 'error' => 'Lote de importação não encontrado.']);
                exit;
            }

            requireWorkspaceAccess($db, $ownerId, $batch['workspace_id']);

            if ($batch['status'] === 'discarded') {
                $db->commit();
                echo json_encode(['success' => true, 'already_discarded' => true]);
                exit;
            }

            if ($batch['status'] !== 'pending') {
                $db->rollBack();
                http_response_code(409);
                echo json_encode(['success' => false, 'error' => 'Somente lotes pendentes podem ser descartados.']);
                exit;
            }

            $deleteItems = $db->prepare("DELETE FROM transaction_import_items
                WHERE batch_id = ? AND workspace_id = ? AND owner_id = ?");
            $deleteItems->execute([$batchId, $batch['workspace_id'], $ownerId]);

            $discard = $db->prepare("UPDATE transaction_import_batches
                SET status = 'discarded', discarded_at = NOW(), applied_at = NULL
                WHERE id = ? AND workspace_id = ? AND owner_id = ? AND status = 'pending'");
            $discard->execute([$batchId, $batch['workspace_id'], $ownerId]);

            $db->commit();
            echo json_encode(['success' => true]);
            exit;
        } catch (Throwable $e) {
            if ($db->inTransaction()) $db->rollBack();
            error_log('Statement import discard failed: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['success' => false, 'error' => 'Não foi possível descartar a importação.']);
            exit;
        }
    }

    // 5. Data: Create Transaction
    if ($uri === '/transactions' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $description = trim($body['description'] ?? '');
        $amount = (float)($body['amount'] ?? 0);
        $type = $body['type'] ?? 'expense';
        $competenceDate = $body['competence_date'] ?? date('Y-m-d');
        $accountId = $body['account_id'] ?? null;
        $destinationAccountId = $body['destination_account_id'] ?? null;
        $categoryId = $body['category_id'] ?? null;
        $contextId = $body['context_id'] ?? null;
        $interestAmount = (float)($body['interest_amount'] ?? 0);
        $status = $body['status'] ?? 'paid';

        if (!$workspaceId || empty($description) || $amount <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Dados de transação incompletos']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        // If no account provided, pick the first available
        if (!$accountId) {
            $stmt = $db->prepare("SELECT id FROM accounts WHERE workspace_id = ? AND active = true LIMIT 1");
            $stmt->execute([$workspaceId]);
            $accountId = $stmt->fetchColumn();
        }

        if (!$accountId || requireResourceWorkspaceAccess($db, $sessionUser['id'], 'accounts', $accountId) !== $workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'A conta não pertence ao espaço financeiro informado.']);
            exit;
        }
        if ($destinationAccountId && requireResourceWorkspaceAccess($db, $sessionUser['id'], 'accounts', $destinationAccountId) !== $workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'A conta de destino não pertence ao mesmo espaço financeiro.']);
            exit;
        }
        if ($categoryId && requireResourceWorkspaceAccess($db, $sessionUser['id'], 'categories', $categoryId) !== $workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'A categoria não pertence ao mesmo espaço financeiro.']);
            exit;
        }
        if ($contextId && requireResourceWorkspaceAccess($db, $sessionUser['id'], 'financial_contexts', $contextId) !== $workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'O contexto financeiro não pertence ao mesmo espaço financeiro.']);
            exit;
        }

        $installments = max(1, (int)($body['installments'] ?? 1));

        if ($installments > 1 && $type !== 'transfer') {
            $instAmount = round($amount / $installments, 2);
            $diff = round($amount - ($instAmount * $installments), 2);
            $baseDate = new DateTime($competenceDate);
            $inserted = [];

            for ($i = 1; $i <= $installments; $i++) {
                $curDate = clone $baseDate;
                if ($i > 1) {
                    $curDate->modify('+' . ($i - 1) . ' month');
                }
                $compDateStr = $curDate->format('Y-m-d');
                $curAmount = ($i === 1) ? ($instAmount + $diff) : $instAmount;
                $curDesc = $description . " ($i/$installments)";

                $stmt = $db->prepare("INSERT INTO transactions 
                    (workspace_id, owner_id, account_id, destination_account_id, category_id, context_id, type, description, amount, interest_amount, competence_date, paid_at, status, installment_current, installment_total)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING *");
                $stmt->execute([$workspaceId, $ownerId, $accountId, $destinationAccountId, $categoryId, $contextId, $type, $curDesc, $curAmount, $interestAmount, $compDateStr, $compDateStr, $status, $i, $installments]);
                $inserted[] = $stmt->fetch();
            }

            echo json_encode(['success' => true, 'transactions' => $inserted, 'installments' => $installments]);
            exit;
        }

        $stmt = $db->prepare("INSERT INTO transactions 
            (workspace_id, owner_id, account_id, destination_account_id, category_id, context_id, type, description, amount, interest_amount, competence_date, paid_at, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $accountId, $destinationAccountId, $categoryId, $contextId, $type, $description, $amount, $interestAmount, $competenceDate, $competenceDate, $status]);
        $tx = $stmt->fetch();

        echo json_encode(['success' => true, 'transaction' => $tx]);
        exit;
    }

    // 5.1 Dispositivos autorizados para Atalhos/Siri
    if ($uri === '/shortcut-devices' && $method === 'GET') {
        ensureShortcutSchema($db);
        $user = requireSessionUser($db);
        $stmt = $db->prepare("SELECT id, workspace_id, name, token_hint, default_account_id, default_category_id, active, last_used_at, created_at
                              FROM shortcut_devices WHERE owner_id = ? ORDER BY created_at DESC");
        $stmt->execute([$user['id']]);
        echo json_encode(['success' => true, 'devices' => $stmt->fetchAll()]);
        exit;
    }

    if ($uri === '/shortcut-devices' && $method === 'POST') {
        ensureShortcutSchema($db);
        $user = requireSessionUser($db);
        $name = trim($body['name'] ?? 'iPhone');
        $workspaceId = $body['workspace_id'] ?? null;
        $accountId = !empty($body['default_account_id']) ? $body['default_account_id'] : null;
        $categoryId = !empty($body['default_category_id']) ? $body['default_category_id'] : null;

        if (!$workspaceId) {
            $stmt = $db->prepare("SELECT id FROM workspaces WHERE owner_id = ? ORDER BY created_at ASC LIMIT 1");
            $stmt->execute([$user['id']]);
            $workspaceId = $stmt->fetchColumn() ?: null;
        }
        $stmt = $db->prepare("SELECT id FROM workspaces WHERE id = ? AND owner_id = ? LIMIT 1");
        $stmt->execute([$workspaceId, $user['id']]);
        if (!$stmt->fetchColumn()) {
            http_response_code(403);
            echo json_encode(['success' => false, 'error' => 'Workspace não pertence ao usuário autenticado.']);
            exit;
        }

        if ($accountId) {
            $stmt = $db->prepare("SELECT id FROM accounts WHERE id = ? AND workspace_id = ? AND owner_id = ? AND active = true");
            $stmt->execute([$accountId, $workspaceId, $user['id']]);
            if (!$stmt->fetchColumn()) $accountId = null;
        }
        if (!$accountId) {
            $stmt = $db->prepare("SELECT COALESCE(
                (SELECT default_cash_account_id FROM workspace_preferences WHERE workspace_id = ? AND owner_id = ? LIMIT 1),
                (SELECT id FROM accounts WHERE workspace_id = ? AND owner_id = ? AND active = true AND is_system = false ORDER BY created_at ASC LIMIT 1)
            )");
            $stmt->execute([$workspaceId, $user['id'], $workspaceId, $user['id']]);
            $accountId = $stmt->fetchColumn() ?: null;
        }
        if (!$accountId) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Cadastre ou selecione uma conta padrão antes de criar o atalho.']);
            exit;
        }

        $rawToken = 'bsf_sk_' . base64UrlEncode(random_bytes(32));
        $tokenHash = hash('sha256', $rawToken);
        $tokenHint = substr($rawToken, -8);
        $stmt = $db->prepare("INSERT INTO shortcut_devices
            (owner_id, workspace_id, name, token_hash, token_hint, default_account_id, default_category_id)
            VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING id, workspace_id, name, token_hint, default_account_id, default_category_id, active, created_at");
        $stmt->execute([$user['id'], $workspaceId, $name ?: 'iPhone', $tokenHash, $tokenHint, $accountId, $categoryId]);
        echo json_encode(['success' => true, 'device' => $stmt->fetch(), 'token' => $rawToken]);
        exit;
    }

    if ($uri === '/shortcut-devices' && $method === 'DELETE') {
        ensureShortcutSchema($db);
        $user = requireSessionUser($db);
        $deviceId = $_GET['id'] ?? $body['id'] ?? null;
        if (!$deviceId) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'ID do dispositivo é obrigatório.']);
            exit;
        }
        $stmt = $db->prepare("DELETE FROM shortcut_devices WHERE id = ? AND owner_id = ?");
        $stmt->execute([$deviceId, $user['id']]);
        echo json_encode(['success' => true]);
        exit;
    }

    // 5.2 Registro rápido via dispositivo autorizado
    if ($uri === '/shortcuts' && $method === 'POST') {
        ensureShortcutSchema($db);
        $providedToken = shortcutBearerToken() ?: ($_GET['token'] ?? ($body['token'] ?? null));
        if (!$providedToken) {
            http_response_code(401);
            echo json_encode(['success' => false, 'error' => 'Token do dispositivo ausente.']);
            exit;
        }

        $stmt = $db->prepare("SELECT id, owner_id, workspace_id, default_account_id, default_category_id
                              FROM shortcut_devices
                              WHERE token_hash = ? AND active = true
                              LIMIT 1");
        $stmt->execute([hash('sha256', $providedToken)]);
        $device = $stmt->fetch();
        if (!$device) {
            http_response_code(401);
            echo json_encode(['success' => false, 'error' => 'Dispositivo não autorizado ou token revogado.']);
            exit;
        }

        $amount = (float)($body['amount'] ?? 0);
        $description = trim($body['description'] ?? '');
        $type = ($body['type'] ?? 'expense') === 'income' ? 'income' : 'expense';
        $installments = max(1, min(60, (int)($body['installments'] ?? 1)));
        $startDate = $body['date'] ?? date('Y-m-d');
        $workspaceId = $device['workspace_id'];
        $ownerId = $device['owner_id'];
        $accountId = $device['default_account_id'];
        $categoryId = !empty($body['category_id']) ? $body['category_id'] : $device['default_category_id'];
        $requestKey = trim($_SERVER['HTTP_X_IDEMPOTENCY_KEY'] ?? ($body['request_id'] ?? ''));

        if ($requestKey !== '') {
            $stmt = $db->prepare("SELECT response_json FROM shortcut_request_log WHERE device_id = ? AND request_key = ? LIMIT 1");
            $stmt->execute([$device['id'], $requestKey]);
            $existing = $stmt->fetchColumn();
            if ($existing) {
                echo $existing;
                exit;
            }
        }

        if (isset($body['amount']) && is_string($body['amount'])) {
            $cleaned = preg_replace('/[^\d,.]/', '', $body['amount']);
            if (str_contains($cleaned, ',') && str_contains($cleaned, '.')) {
                $cleaned = str_replace('.', '', $cleaned);
            }
            $cleaned = str_replace(',', '.', $cleaned);
            $amount = (float)$cleaned;
        }

        if ($amount <= 0 || empty($description)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Valor e descrição válidos são obrigatórios.']);
            exit;
        }

        $stmt = $db->prepare("SELECT id FROM accounts WHERE id = ? AND workspace_id = ? AND owner_id = ? AND active = true LIMIT 1");
        $stmt->execute([$accountId, $workspaceId, $ownerId]);
        if (!$stmt->fetchColumn()) {
            http_response_code(409);
            echo json_encode(['success' => false, 'error' => 'A conta padrão deste dispositivo não está mais disponível.']);
            exit;
        }

        if ($categoryId) {
            $stmt = $db->prepare("SELECT id FROM categories WHERE id = ? AND workspace_id = ? AND owner_id = ? AND kind = ? LIMIT 1");
            $stmt->execute([$categoryId, $workspaceId, $ownerId, $type]);
            if (!$stmt->fetchColumn()) $categoryId = null;
        }

        if (!$categoryId) {
            $descLower = mb_strtolower($description, 'UTF-8');
            $stmt = $db->prepare("SELECT id, name FROM categories WHERE workspace_id = ? AND owner_id = ? AND kind = ?");
            $stmt->execute([$workspaceId, $ownerId, $type]);
            foreach ($stmt->fetchAll() as $category) {
                $catLower = mb_strtolower($category['name'], 'UTF-8');
                if (strpos($descLower, $catLower) !== false || strpos($catLower, $descLower) !== false) {
                    $categoryId = $category['id'];
                    break;
                }
            }
        }

        $db->beginTransaction();
        $stmt = $db->prepare("INSERT INTO transactions
            (workspace_id, owner_id, account_id, destination_account_id, category_id, type, description, amount, interest_amount,
             competence_date, paid_at, status, installment_current, installment_total)
            VALUES (?, ?, ?, NULL, ?, ?, ?, ?, 0, ?, ?, 'paid', ?, ?) RETURNING id");

        $insertedIds = [];
        $installmentAmount = round($amount / $installments, 2);
        $centsDiff = round($amount - ($installmentAmount * $installments), 2);
        for ($i = 1; $i <= $installments; $i++) {
            $curAmount = ($i === 1) ? ($installmentAmount + $centsDiff) : $installmentAmount;
            $curDesc = ($installments > 1) ? "{$description} ({$i}/{$installments})" : $description;
            $curDate = $i === 1 ? $startDate : date('Y-m-d', strtotime($startDate . " +" . ($i - 1) . " month"));
            $stmt->execute([$workspaceId, $ownerId, $accountId, $categoryId, $type, $curDesc, $curAmount, $curDate, $curDate, $i, $installments]);
            $insertedIds[] = $stmt->fetchColumn();
        }

        $db->prepare("UPDATE shortcut_devices SET last_used_at = NOW() WHERE id = ?")->execute([$device['id']]);
        $response = [
            'success' => true,
            'count' => count($insertedIds),
            'transaction_ids' => $insertedIds,
            'amount' => $amount,
            'installments' => $installments,
            'message' => $installments > 1
                ? "{$installments} parcelas de {$description} registradas com sucesso!"
                : "{$description} de R$ " . number_format($amount, 2, ',', '.') . " registrado com sucesso!"
        ];

        if ($requestKey !== '') {
            $stmt = $db->prepare("INSERT INTO shortcut_request_log (device_id, request_key, response_json)
                                  VALUES (?, ?, ?::jsonb)
                                  ON CONFLICT (device_id, request_key) DO NOTHING");
            $stmt->execute([$device['id'], $requestKey, json_encode($response, JSON_UNESCAPED_UNICODE)]);
        }
        $db->commit();

        echo json_encode($response, JSON_UNESCAPED_UNICODE);
        exit;
    }

    if ($uri === '/transactions' && $method === 'DELETE') {
        $id = $_GET['id'] ?? $body['id'] ?? null;
        if (!$id) {
            http_response_code(400);
            echo json_encode(['error' => 'ID da transação é obrigatório']);
            exit;
        }
        requireResourceWorkspaceAccess($db, $sessionUser['id'], 'transactions', $id);
        $stmt = $db->prepare("DELETE FROM transactions WHERE id = ?");
        $stmt->execute([$id]);
        echo json_encode(['success' => true]);
        exit;
    }

    // 6. Data: Create Category
    if ($uri === '/categories' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $name = trim($body['name'] ?? '');
        $kind = $body['kind'] ?? 'expense';
        $color = $body['color'] ?? '#8b5cf6';
        $budgetLimit = (float)($body['budget_limit'] ?? 0);

        if (!$workspaceId || empty($name)) {
            http_response_code(400);
            echo json_encode(['error' => 'Nome da categoria é obrigatório']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        $stmt = $db->prepare("INSERT INTO categories (workspace_id, owner_id, name, kind, color, budget_limit) VALUES (?, ?, ?, ?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $name, $kind, $color, $budgetLimit]);
        $cat = $stmt->fetch();

        echo json_encode(['success' => true, 'category' => $cat]);
        exit;
    }

    // 7. Data: Create Account
    if ($uri === '/accounts' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $name = trim($body['name'] ?? '');
        $type = $body['type'] ?? 'checking';
        $initialBalance = (float)($body['initial_balance'] ?? 0);
        $isShared = !empty($body['is_shared']) ? true : false;

        if (!$workspaceId || empty($name)) {
            http_response_code(400);
            echo json_encode(['error' => 'Nome da conta é obrigatório']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        $stmt = $db->prepare("INSERT INTO accounts (workspace_id, owner_id, name, type, initial_balance, is_shared) VALUES (?, ?, ?, ?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $name, $type, $initialBalance, $isShared ? 'true' : 'false']);
        $acc = $stmt->fetch();

        echo json_encode(['success' => true, 'account' => $acc]);
        exit;
    }

    // 8. Data: Create Goal
    if ($uri === '/goals' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $name = trim($body['name'] ?? '');
        $targetAmount = (float)($body['target_amount'] ?? 0);
        $currentAmount = (float)($body['current_amount'] ?? 0);
        $deadline = $body['deadline'] ?? null;

        if (!$workspaceId || empty($name) || $targetAmount <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Nome e valor alvo da meta são obrigatórios']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        $stmt = $db->prepare("INSERT INTO financial_goals (workspace_id, owner_id, name, target_amount, current_amount, deadline, status) VALUES (?, ?, ?, ?, ?, ?, 'active') RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $name, $targetAmount, $currentAmount, $deadline]);
        $goal = $stmt->fetch();

        echo json_encode(['success' => true, 'goal' => $goal]);
        exit;
    }

    // 9. Data: Create / Update Budget
    if ($uri === '/budgets' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $categoryId = $body['category_id'] ?? null;
        $month = $body['month'] ?? date('Y-m');
        $amount = (float)($body['amount'] ?? 0);

        if (!$workspaceId || !$categoryId || $amount <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Categoria e valor são obrigatórios']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        $stmt = $db->prepare("INSERT INTO monthly_budgets (workspace_id, owner_id, category_id, month, amount) 
            VALUES (?, ?, ?, ?, ?) 
            ON CONFLICT (workspace_id, category_id, month) DO UPDATE SET amount = EXCLUDED.amount RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $categoryId, $month, $amount]);
        $b = $stmt->fetch();

        echo json_encode(['success' => true, 'budget' => $b]);
        exit;
    }

    // 10. Data: Create Card
    if ($uri === '/cards' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $name = trim($body['name'] ?? '');
        $brand = !empty($body['brand']) ? $body['brand'] : 'mastercard';
        $lastFour = !empty($body['last_four']) ? trim($body['last_four']) : null;
        $creditLimit = (float)($body['credit_limit'] ?? 0);
        $closingDay = max(1, min(31, (int)($body['closing_day'] ?? 1)));
        $dueDay = max(1, min(31, (int)($body['due_day'] ?? 10)));

        if (!$workspaceId || empty($name)) {
            http_response_code(400);
            echo json_encode(['error' => 'Nome do cartão é obrigatório']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT id FROM users LIMIT 1");
            $stmt->execute();
            $ownerId = $stmt->fetchColumn();
        }

        // 1. Criar a conta técnica vinculada ao cartão de crédito
        $stmtAcc = $db->prepare("INSERT INTO accounts (workspace_id, owner_id, name, type, initial_balance, is_system, active) 
            VALUES (?, ?, ?, 'credit_card', 0, true, true) RETURNING id");
        $stmtAcc->execute([$workspaceId, $ownerId, 'Cartão ' . $name]);
        $accountId = $stmtAcc->fetchColumn();

        // 2. Criar o registro do cartão com os campos de limite sincronizados
        $stmt = $db->prepare("INSERT INTO credit_cards (workspace_id, owner_id, account_id, name, brand, last_four, limit_amount, credit_limit, closing_day, due_day) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING id, account_id, name, brand, last_four, closing_day, due_day, credit_limit");
        $stmt->execute([$workspaceId, $ownerId, $accountId, $name, $brand, $lastFour, $creditLimit, $creditLimit, $closingDay, $dueDay]);
        $card = $stmt->fetch();

        echo json_encode(['success' => true, 'card' => $card]);
        exit;
    }

    // 10.1 Data: Update Card
    if (($uri === '/cards/update' || $uri === '/cards') && ($method === 'PUT' || $method === 'POST') && !empty($body['id'])) {
        $cardId = $body['id'];
        requireResourceWorkspaceAccess($db, $sessionUser['id'], 'credit_cards', $cardId);
        $name = trim($body['name'] ?? '');
        $brand = !empty($body['brand']) ? $body['brand'] : null;
        $lastFour = !empty($body['last_four']) ? trim($body['last_four']) : null;
        $creditLimit = (float)($body['credit_limit'] ?? 0);
        $closingDay = max(1, min(31, (int)($body['closing_day'] ?? 1)));
        $dueDay = max(1, min(31, (int)($body['due_day'] ?? 10)));

        $stmt = $db->prepare("UPDATE credit_cards SET 
            name = COALESCE(NULLIF(?, ''), name),
            brand = COALESCE(?, brand),
            last_four = ?,
            limit_amount = ?,
            credit_limit = ?,
            closing_day = ?,
            due_day = ?
            WHERE id = ? RETURNING id, account_id, name, brand, last_four, closing_day, due_day, credit_limit");
        $stmt->execute([$name, $brand, $lastFour, $creditLimit, $creditLimit, $closingDay, $dueDay, $cardId]);
        $card = $stmt->fetch();

        echo json_encode(['success' => true, 'card' => $card]);
        exit;
    }

    // 10.2 Data: Delete Card
    if ($uri === '/cards/delete' && $method === 'POST') {
        $cardId = $body['id'] ?? null;
        if ($cardId) {
            requireResourceWorkspaceAccess($db, $sessionUser['id'], 'credit_cards', $cardId);
            $stmt = $db->prepare("DELETE FROM credit_cards WHERE id = ?");
            $stmt->execute([$cardId]);
        }
        echo json_encode(['success' => true]);
        exit;
    }

    // 10.3 Data: Pay Credit Card Invoice
    if ($uri === '/cards/pay-invoice' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $invoiceId = $body['invoice_id'] ?? null;
        $accountId = $body['account_id'] ?? null; // Bank checking account paying the invoice
        $amount = (float)($body['amount'] ?? 0);
        $paidAt = $body['paid_at'] ?? date('Y-m-d');

        if (!$workspaceId || !$invoiceId || !$accountId) {
            http_response_code(400);
            echo json_encode(['error' => 'ID da fatura, workspace e conta pagadora são obrigatórios']);
            exit;
        }

        $accountWorkspaceId = requireResourceWorkspaceAccess($db, $sessionUser['id'], 'accounts', $accountId);
        if ($accountWorkspaceId !== $workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'A conta pagadora não pertence ao mesmo espaço financeiro.']);
            exit;
        }

        $stmt = $db->prepare("SELECT i.*, c.name as card_name, c.account_id as card_account_id 
                              FROM credit_card_invoices i 
                              LEFT JOIN credit_cards c ON c.id = i.credit_card_id 
                              WHERE i.id = ? AND i.workspace_id = ?");
        $stmt->execute([$invoiceId, $workspaceId]);
        $inv = $stmt->fetch();

        if (!$inv) {
            http_response_code(404);
            echo json_encode(['error' => 'Fatura não encontrada']);
            exit;
        }

        $ownerId = $inv['owner_id'];
        $payAmount = ($amount > 0) ? $amount : (float)$inv['total_amount'];
        $cardName = $inv['card_name'] ?: 'Cartão';
        $monthStr = str_pad($inv['month'], 2, '0', STR_PAD_LEFT) . '/' . $inv['year'];

        $db->beginTransaction();

        // 1. Mark invoice as paid
        $stmtUpdate = $db->prepare("UPDATE credit_card_invoices SET status = 'paid', paid_at = ? WHERE id = ?");
        $stmtUpdate->execute([$paidAt, $invoiceId]);

        // 2. Create payment transaction on the paying bank account
        $desc = "Pagamento fatura " . $cardName . " (" . $monthStr . ")";
        $stmtTx = $db->prepare("INSERT INTO transactions 
            (workspace_id, owner_id, account_id, destination_account_id, category_id, type, description, amount, interest_amount, competence_date, paid_at, status, invoice_id)
            VALUES (?, ?, ?, NULL, NULL, 'expense', ?, ?, 0, ?, ?, 'paid', ?) RETURNING *");
        $stmtTx->execute([$workspaceId, $ownerId, $accountId, $desc, $payAmount, $paidAt, $paidAt, $invoiceId]);
        $tx = $stmtTx->fetch();

        $db->commit();

        echo json_encode([
            'success' => true,
            'message' => 'Fatura liquidada com sucesso',
            'invoice_id' => $invoiceId,
            'transaction' => $tx
        ]);
        exit;
    }

    // 11. Data: Categorize Transaction
    if ($uri === '/transactions/categorize' && $method === 'POST') {
        $transactionId = $body['transaction_id'] ?? null;
        $categoryId = $body['category_id'] ?? null;

        if (!$transactionId || !$categoryId) {
            http_response_code(400);
            echo json_encode(['error' => 'Transação e categoria são obrigatórios']);
            exit;
        }

        $txWorkspaceId = requireResourceWorkspaceAccess($db, $sessionUser['id'], 'transactions', $transactionId);
        $categoryWorkspaceId = requireResourceWorkspaceAccess($db, $sessionUser['id'], 'categories', $categoryId);
        if ($txWorkspaceId !== $categoryWorkspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'A categoria não pertence ao mesmo espaço financeiro da transação.']);
            exit;
        }

        $stmt = $db->prepare("UPDATE transactions SET category_id = ? WHERE id = ? RETURNING *");
        $stmt->execute([$categoryId, $transactionId]);
        $tx = $stmt->fetch();

        echo json_encode(['success' => true, 'transaction' => $tx]);
        exit;
    }

    // 12. Data: Create & Delete Debt
    if ($uri === '/debts' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $name = trim($body['name'] ?? '');
        $totalAmount = (float)($body['total_amount'] ?? 0);
        $outstandingBalance = (float)($body['outstanding_balance'] ?? $totalAmount);
        $interestRate = (float)($body['interest_rate_percent_monthly'] ?? 0);
        $dueDateDay = (int)($body['due_date_day'] ?? 10);
        $monthlyInstallment = (float)($body['monthly_installment'] ?? 0);
        $type = $body['type'] ?? 'other';

        if (!$workspaceId || empty($name) || $totalAmount <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Nome e valor total da dívida são obrigatórios']);
            exit;
        }

        $stmt = $db->prepare("INSERT INTO debts 
            (workspace_id, name, total_amount, outstanding_balance, interest_rate_percent_monthly, due_date_day, monthly_installment, type)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $name, $totalAmount, $outstandingBalance, $interestRate, $dueDateDay, $monthlyInstallment, $type]);
        $debt = $stmt->fetch();

        echo json_encode(['success' => true, 'debt' => $debt]);
        exit;
    }

    if ($uri === '/debts' && $method === 'DELETE') {
        $id = $_GET['id'] ?? $body['id'] ?? null;
        if (!$id) {
            http_response_code(400);
            echo json_encode(['error' => 'ID da dívida é obrigatório']);
            exit;
        }
        requireResourceWorkspaceAccess($db, $sessionUser['id'], 'debts', $id);
        $stmt = $db->prepare("DELETE FROM debts WHERE id = ?");
        $stmt->execute([$id]);
        echo json_encode(['success' => true]);
        exit;
    }

    // 13. Data: Create, Delete & Pay Fixed Commitments
    if ($uri === '/commitments' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $description = trim($body['description'] ?? '');
        $amount = (float)($body['amount'] ?? 0);
        $dueDay = (int)($body['due_day'] ?? 1);
        $accountId = !empty($body['account_id']) ? $body['account_id'] : null;
        $categoryId = !empty($body['category_id']) ? $body['category_id'] : null;

        if (!$workspaceId || empty($description) || $amount <= 0 || $dueDay < 1 || $dueDay > 31) {
            http_response_code(400);
            echo json_encode(['error' => 'Descrição, valor e dia de vencimento válidos são obrigatórios']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        $stmt = $db->prepare("INSERT INTO fixed_commitments (workspace_id, owner_id, account_id, category_id, description, amount, due_day, active) 
            VALUES (?, ?, ?, ?, ?, ?, ?, true) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $accountId, $categoryId, $description, $amount, $dueDay]);
        $commitment = $stmt->fetch();

        $currentMonthDate = date('Y-m-01');
        $stmtOcc = $db->prepare("INSERT INTO fixed_commitment_occurrences (commitment_id, workspace_id, owner_id, month_date, status) 
            VALUES (?, ?, ?, ?, 'pending') RETURNING *");
        $stmtOcc->execute([$commitment['id'], $workspaceId, $ownerId, $currentMonthDate]);
        $occurrence = $stmtOcc->fetch();

        echo json_encode(['success' => true, 'commitment' => $commitment, 'occurrence' => $occurrence]);
        exit;
    }

    if ($uri === '/commitments' && $method === 'DELETE') {
        $id = $_GET['id'] ?? $body['id'] ?? null;
        if (!$id) {
            http_response_code(400);
            echo json_encode(['error' => 'ID do compromisso é obrigatório']);
            exit;
        }
        requireResourceWorkspaceAccess($db, $sessionUser['id'], 'fixed_commitments', $id);
        $stmt = $db->prepare("UPDATE fixed_commitments SET active = false WHERE id = ?");
        $stmt->execute([$id]);
        $stmtDelOcc = $db->prepare("DELETE FROM fixed_commitment_occurrences WHERE commitment_id = ? AND status = 'pending'");
        $stmtDelOcc->execute([$id]);
        echo json_encode(['success' => true]);
        exit;
    }

    if ($uri === '/commitments/pay' && $method === 'POST') {
        $occurrenceId = $body['occurrence_id'] ?? null;
        $accountId = $body['account_id'] ?? null;
        $paidOn = $body['paid_on'] ?? date('Y-m-d');

        if (!$occurrenceId || !$accountId) {
            http_response_code(400);
            echo json_encode(['error' => 'Ocorrência e conta de pagamento são obrigatórias']);
            exit;
        }

        $stmt = $db->prepare("SELECT o.*, c.description, c.amount, c.category_id, c.workspace_id, c.owner_id 
            FROM fixed_commitment_occurrences o 
            JOIN fixed_commitments c ON c.id = o.commitment_id 
            WHERE o.id = ?");
        $stmt->execute([$occurrenceId]);
        $occ = $stmt->fetch();

        if (!$occ) {
            http_response_code(404);
            echo json_encode(['error' => 'Compromisso não encontrado']);
            exit;
        }
        requireWorkspaceAccess($db, $sessionUser['id'], (string)$occ['workspace_id']);
        $accountWorkspaceId = requireResourceWorkspaceAccess($db, $sessionUser['id'], 'accounts', $accountId);
        if ($accountWorkspaceId !== (string)$occ['workspace_id']) {
            http_response_code(400);
            echo json_encode(['error' => 'A conta de pagamento não pertence ao mesmo espaço financeiro.']);
            exit;
        }

        if ($occ['status'] === 'paid') {
            echo json_encode(['success' => true, 'already_paid' => true, 'transaction_id' => $occ['transaction_id']]);
            exit;
        }

        $stmtTx = $db->prepare("INSERT INTO transactions 
            (workspace_id, owner_id, account_id, category_id, type, description, amount, interest_amount, competence_date, paid_at, status)
            VALUES (?, ?, ?, ?, 'expense', ?, ?, 0, ?, ?, 'paid') RETURNING id");
        $stmtTx->execute([
            $occ['workspace_id'],
            $occ['owner_id'],
            $accountId,
            $occ['category_id'],
            $occ['description'],
            $occ['amount'],
            $paidOn,
            $paidOn
        ]);
        $txId = $stmtTx->fetchColumn();

        $stmtUp = $db->prepare("UPDATE fixed_commitment_occurrences SET status = 'paid', transaction_id = ? WHERE id = ?");
        $stmtUp->execute([$txId, $occurrenceId]);

        echo json_encode(['success' => true, 'transaction_id' => $txId]);
        exit;
    }

    // 14. Data: Patients
    if ($uri === '/patients' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $name = trim($body['name'] ?? $body['full_name'] ?? '');
        $sessionPrice = (float)($body['session_price'] ?? 0);
        $status = $body['status'] ?? 'active';
        $paymentDay = !empty($body['payment_day']) ? (int)$body['payment_day'] : null;
        $notes = $body['notes'] ?? null;

        if (!$workspaceId || empty($name)) {
            http_response_code(400);
            echo json_encode(['error' => 'Nome do paciente é obrigatório']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        $stmt = $db->prepare("INSERT INTO patients (workspace_id, owner_id, name, session_price, status, payment_day, notes) 
            VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $name, $sessionPrice, $status, $paymentDay, $notes]);
        $patient = $stmt->fetch();

        echo json_encode(['success' => true, 'patient' => $patient]);
        exit;
    }

    // Helper: Market Quotes (Yahoo Finance + BACEN)
    function fetchMarketQuote($ticker) {
        $symbol = strtoupper(trim($ticker));
        if (empty($symbol)) return null;

        // Auto-append .SA for Brazilian stock/FII tickers (e.g. MXRF11, HGLG11, PETR4, VALE3)
        if (!str_contains($symbol, '.') && !str_contains($symbol, '-') && !str_contains($symbol, '^')) {
            if (preg_match('/^[A-Z]{4}[0-9]{1,2}$/', $symbol)) {
                $symbol .= '.SA';
            }
        }

        $url = 'https://query1.finance.yahoo.com/v8/finance/chart/' . urlencode($symbol) . '?interval=1d&range=1d';
        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_TIMEOUT => 5,
            CURLOPT_HTTPHEADER => [
                'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept: application/json'
            ]
        ]);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode !== 200 || !$response) return null;
        $data = json_decode($response, true);
        $result = $data['chart']['result'][0] ?? null;
        if (!$result) return null;

        $meta = $result['meta'] ?? [];
        $price = $meta['regularMarketPrice'] ?? null;
        if ($price === null) {
            $quotes = $result['indicators']['quote'][0]['close'] ?? [];
            $price = end($quotes);
        }
        if (!$price || !is_numeric($price)) return null;

        $prevClose = $meta['chartPreviousClose'] ?? $price;
        $changePct = $meta['regularMarketChangePercent'] ?? ($prevClose > 0 ? (($price - $prevClose) / $prevClose) * 100 : 0);

        return [
            'symbol' => $symbol,
            'clean_ticker' => str_replace('.SA', '', $symbol),
            'price' => round((float)$price, 2),
            'previous_close' => round((float)$prevClose, 2),
            'change_pct' => round((float)$changePct, 2),
            'day_high' => isset($meta['regularMarketDayHigh']) ? round((float)$meta['regularMarketDayHigh'], 2) : null,
            'day_low' => isset($meta['regularMarketDayLow']) ? round((float)$meta['regularMarketDayLow'], 2) : null,
            'long_name' => $meta['longName'] ?? $meta['shortName'] ?? null,
            'currency' => $meta['currency'] ?? 'BRL',
        ];
    }

    function fetchMarketBenchmarks() {
        $selic = 14.0;
        try {
            $ch = curl_init('https://api.bcb.gov.br/dados/serie/bcdata.sgs.432/dados/ultimos/1?formato=json');
            curl_setopt_array($ch, [
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_TIMEOUT => 3,
                CURLOPT_HTTPHEADER => ['Accept: application/json']
            ]);
            $res = curl_exec($ch);
            curl_close($ch);
            $data = json_decode($res, true);
            if (!empty($data[0]['valor'])) {
                $selic = (float)$data[0]['valor'];
            }
        } catch (Exception $e) {}

        $cdi = max(0, $selic - 0.10);
        $ibov = fetchMarketQuote('^BVSP');
        $ifix = fetchMarketQuote('IFIX.SA');

        return [
            'selic' => $selic,
            'cdi' => round($cdi, 2),
            'ibovespa' => $ibov ? $ibov['price'] : null,
            'ibovespa_change' => $ibov ? $ibov['change_pct'] : null,
            'ifix' => $ifix ? $ifix['price'] : null,
            'ifix_change' => $ifix ? $ifix['change_pct'] : null,
            'updated_at' => date('c')
        ];
    }

    // Sync Quotes from external API for all assets in a workspace
    if (($uri === '/investments/sync-quotes' || $uri === '/investments/quotes/sync') && ($method === 'POST' || $method === 'GET')) {
        $workspaceId = $_GET['workspace_id'] ?? $body['workspace_id'] ?? null;
        if (!$workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'workspace_id obrigatório']);
            exit;
        }

        $stmt = $db->prepare("SELECT id, ticker, name, type, broker FROM investment_assets WHERE workspace_id = ? AND active = true");
        $stmt->execute([$workspaceId]);
        $assets = $stmt->fetchAll();

        $today = date('Y-m-d');
        $synced = [];

        foreach ($assets as $a) {
            $tickerToFetch = trim($a['ticker']);
            if (empty($tickerToFetch) || in_array(strtoupper($tickerToFetch), ['RICO', 'XP', 'INTER', 'ITAU', 'SANTANDER'])) {
                $tickerToFetch = trim($a['name']);
            }

            if ($a['type'] === 'real_estate') continue;

            $q = fetchMarketQuote($tickerToFetch);
            if ($q) {
                $del = $db->prepare("DELETE FROM investment_quotes WHERE asset_id = ? AND quote_date = ?");
                $del->execute([$a['id'], $today]);

                $stmtOwner = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
                $stmtOwner->execute([$workspaceId]);
                $ownerId = $stmtOwner->fetchColumn();

                $ins = $db->prepare("INSERT INTO investment_quotes (workspace_id, owner_id, asset_id, unit_price, quote_date) VALUES (?, ?, ?, ?, ?)");
                $ins->execute([$workspaceId, $ownerId, $a['id'], $q['price'], $today]);

                if (empty($a['ticker']) || $a['ticker'] !== $q['clean_ticker']) {
                    $upd = $db->prepare("UPDATE investment_assets SET ticker = ? WHERE id = ?");
                    $upd->execute([$q['clean_ticker'], $a['id']]);
                }

                $synced[] = [
                    'asset_id' => $a['id'],
                    'ticker' => $q['clean_ticker'],
                    'name' => $a['name'],
                    'price' => $q['price'],
                    'previous_close' => $q['previous_close'],
                    'change_pct' => $q['change_pct'],
                    'day_high' => $q['day_high'],
                    'day_low' => $q['day_low'],
                    'quote_date' => $today
                ];
            }
        }

        $benchmarks = fetchMarketBenchmarks();

        echo json_encode([
            'success' => true,
            'synced_count' => count($synced),
            'quotes' => $synced,
            'benchmarks' => $benchmarks
        ]);
        exit;
    }

    // Market Benchmarks (Selic, CDI, Ibovespa, IFIX)
    if ($uri === '/investments/benchmarks' && $method === 'GET') {
        $benchmarks = fetchMarketBenchmarks();
        echo json_encode(['success' => true, 'benchmarks' => $benchmarks]);
        exit;
    }

    // Market Search for Assets (Auto-complete)
    if ($uri === '/investments/search' && $method === 'GET') {
        $q = trim($_GET['q'] ?? '');
        if (empty($q)) {
            echo json_encode(['success' => true, 'results' => []]);
            exit;
        }

        $url = 'https://query1.finance.yahoo.com/v1/finance/search?q=' . urlencode($q) . '&quotesCount=8&newsCount=0';
        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 4,
            CURLOPT_HTTPHEADER => [
                'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept: application/json'
            ]
        ]);
        $res = curl_exec($ch);
        curl_close($ch);

        $results = [];
        if ($res) {
            $data = json_decode($res, true);
            foreach ($data['quotes'] ?? [] as $item) {
                $sym = $item['symbol'] ?? '';
                if (!$sym) continue;
                $isReit = (isset($item['industry']) && str_contains($item['industry'], 'REIT')) || preg_match('/11(\.SA)?$/', $sym);
                $type = $isReit ? 'reit' : (($item['quoteType'] ?? '') === 'EQUITY' ? 'stock' : (($item['quoteType'] ?? '') === 'ETF' ? 'fund' : 'stock'));
                $results[] = [
                    'ticker' => str_replace('.SA', '', $sym),
                    'symbol' => $sym,
                    'name' => $item['longname'] ?? $item['shortname'] ?? $sym,
                    'type' => $type,
                    'exchange' => $item['exchDisp'] ?? $item['exchange'] ?? 'B3'
                ];
            }
        }

        echo json_encode(['success' => true, 'results' => $results]);
        exit;
    }

    // Single Asset Quote
    if ($uri === '/investments/quote' && $method === 'GET') {
        $ticker = trim($_GET['ticker'] ?? '');
        if (empty($ticker)) {
            http_response_code(400);
            echo json_encode(['error' => 'ticker obrigatório']);
            exit;
        }
        $quote = fetchMarketQuote($ticker);
        if ($quote) {
            echo json_encode(['success' => true, 'quote' => $quote]);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Cotação não encontrada']);
        }
        exit;
    }

    // 17. Data: Investments (Assets, Operations, Quotes)
    if ($uri === '/investments/assets' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $name = trim($body['name'] ?? '');
        $ticker = strtoupper(trim($body['ticker'] ?? $name));
        $broker = trim($body['broker'] ?? $body['exchange'] ?? 'Rico');
        $type = $body['type'] ?? 'stock';
        $isShared = !empty($body['is_shared']) ? true : false;

        if (!in_array($type, ['stock','reit','fund','cdb','treasury','crypto','fixed_income','real_estate'], true)
            || strlen($ticker) > 30 || strlen($broker) > 100 || strlen($name) > 100) {
            http_response_code(400);
            echo json_encode(['error' => 'Dados do ativo inválidos.']);
            exit;
        }

        if (!$workspaceId || empty($name)) {
            http_response_code(400);
            echo json_encode(['error' => 'Nome do ativo é obrigatório']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        $stmt = $db->prepare("INSERT INTO investment_assets (workspace_id, owner_id, ticker, name, broker, type, is_shared, active) 
            VALUES (?, ?, ?, ?, ?, ?, ?, true) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $ticker, $name, $broker, $type, $isShared ? 'true' : 'false']);
        $asset = $stmt->fetch();

        // Fetch initial market quote if valid ticker
        $quoteData = fetchMarketQuote($ticker);
        if ($quoteData) {
            $today = date('Y-m-d');
            $del = $db->prepare("DELETE FROM investment_quotes WHERE asset_id = ? AND quote_date = ?");
            $del->execute([$asset['id'], $today]);
            $ins = $db->prepare("INSERT INTO investment_quotes (workspace_id, owner_id, asset_id, unit_price, quote_date) VALUES (?, ?, ?, ?, ?)");
            $ins->execute([$workspaceId, $ownerId, $asset['id'], $quoteData['price'], $today]);
        }

        echo json_encode(['success' => true, 'asset' => $asset]);
        exit;
    }

    if ($uri === '/investments/operations' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $assetId = $body['asset_id'] ?? null;
        $accountId = $body['account_id'] ?? null;
        $opType = $body['operation_type'] ?? $body['type'] ?? 'buy';
        if (!is_numeric($body['quantity'] ?? null) || !is_numeric($body['unit_price'] ?? null)
            || !is_finite((float)$body['quantity']) || !is_finite((float)$body['unit_price'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Quantidade e preço devem ser numéricos.']);
            exit;
        }
        $quantity = (float)$body['quantity'];
        $unitPrice = (float)$body['unit_price'];
        if ($quantity > 99999999.999999 || $unitPrice > 9999999999.9999 || $quantity * $unitPrice > 999999999999.99) {
            http_response_code(400);
            echo json_encode(['error' => 'Valor da operação excede o limite permitido.']);
            exit;
        }
        $opDate = earningsDate($body['operation_date'] ?? date('Y-m-d'));
        $notes = $body['notes'] ?? null;

        if (!in_array($opType, ['buy', 'sell', 'dividend', 'yield'], true)) {
            http_response_code(400);
            echo json_encode(['error' => 'Tipo de operação inválido.']);
            exit;
        }
        if (!$workspaceId || !$assetId || $quantity <= 0 || $unitPrice <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Ativo, quantidade e preço válidos são obrigatórios']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        $stmtAsset = $db->prepare("SELECT name, ticker FROM investment_assets WHERE id = ? AND workspace_id = ?");
        $stmtAsset->execute([$assetId, $workspaceId]);
        $asset = $stmtAsset->fetch();
        if (!$asset) {
            http_response_code(404);
            echo json_encode(['error' => 'Ativo não encontrado neste espaço financeiro.']);
            exit;
        }
        if ($accountId && requireResourceWorkspaceAccess($db, $sessionUser['id'], 'accounts', $accountId) !== $workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'A conta não pertence ao mesmo espaço financeiro.']);
            exit;
        }

        $receipt = beginIdempotentMutation($db, $sessionUser['id'], $uri, $body);
        $stmt = $db->prepare("INSERT INTO investment_operations (workspace_id, owner_id, asset_id, operation_type, quantity, unit_price, operation_date, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $assetId, $opType, $quantity, $unitPrice, $opDate, $notes]);
        $operation = $stmt->fetch();

        $txId = null;
        if ($accountId) {
            $totalAmount = round($quantity * $unitPrice, 2);
            $txType = ($opType === 'buy') ? 'expense' : 'income';
            $desc = ($opType === 'buy' ? 'Compra de ativo' : 'Venda de ativo') . ' - ' . ($asset['name'] ?? $asset['ticker'] ?? '');
            $stmtTx = $db->prepare("INSERT INTO transactions 
                (workspace_id, owner_id, account_id, type, description, amount, interest_amount, competence_date, paid_at, status) 
                VALUES (?, ?, ?, ?, ?, ?, 0, ?, ?, 'paid') RETURNING id");
            $stmtTx->execute([$workspaceId, $ownerId, $accountId, $txType, $desc, $totalAmount, $opDate, $opDate]);
            $txId = $stmtTx->fetchColumn();
            $db->prepare('UPDATE investment_operations SET transaction_id = ? WHERE id = ?')->execute([$txId, $operation['id']]);
            $operation['transaction_id'] = $txId;
        }

        commitIdempotentMutation($db, $receipt, ['success' => true, 'operation' => $operation, 'transaction_id' => $txId]);
        exit;
    }

    if ($uri === '/investments/quotes' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $assetId = $body['asset_id'] ?? null;
        $unitPrice = earningsAmount($body['unit_price'] ?? null);
        $quoteDate = earningsDate($body['quote_date'] ?? date('Y-m-d'));

        if (!$workspaceId || !$assetId || $unitPrice <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Ativo e cotação válida são obrigatórios']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        $assetCheck = $db->prepare('SELECT id FROM investment_assets WHERE id = ? AND workspace_id = ?');
        $assetCheck->execute([$assetId, $workspaceId]);
        if (!$assetCheck->fetchColumn()) {
            http_response_code(404);
            echo json_encode(['error' => 'Ativo não encontrado neste espaço financeiro.']);
            exit;
        }

        $stmt = $db->prepare("INSERT INTO investment_quotes (workspace_id, owner_id, asset_id, unit_price, quote_date) 
            VALUES (?, ?, ?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $assetId, $unitPrice, $quoteDate]);
        $quote = $stmt->fetch();

        echo json_encode(['success' => true, 'quote' => $quote]);
        exit;
    }

    // 18. Data: Credit Card Purchase (Installments)
    if ($uri === '/cards/purchase' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $cardId = $body['credit_card_id'] ?? null;
        $description = trim($body['description'] ?? '');
        $totalAmount = (float)($body['total_amount'] ?? 0);
        $purchasedOn = $body['purchased_on'] ?? date('Y-m-d');
        $installments = max(1, (int)($body['installment_count'] ?? 1));
        $categoryId = !empty($body['category_id']) ? $body['category_id'] : null;
        $notes = $body['notes'] ?? null;

        if (!$workspaceId || !$cardId || empty($description) || $totalAmount <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Cartão, descrição e valor total válidos são obrigatórios']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        $stmtCard = $db->prepare("SELECT id, account_id, closing_day, due_day, name FROM credit_cards WHERE workspace_id = ? AND (id = ? OR account_id = ?)");
        $stmtCard->execute([$workspaceId, $cardId, $cardId]);
        $card = $stmtCard->fetch();
        if ($card) {
            $cardId = $card['id'];
        }

        $accountId = $card['account_id'] ?? null;
        if (!$accountId) {
            $stmtAcc = $db->prepare("SELECT id FROM accounts WHERE workspace_id = ? LIMIT 1");
            $stmtAcc->execute([$workspaceId]);
            $accountId = $stmtAcc->fetchColumn();
        }

        $closingDay = (int)($card['closing_day'] ?? 10);
        $dueDay = (int)($card['due_day'] ?? 17);

        $db->beginTransaction();

        // 1. Insert into credit_card_purchases
        $stmtPurch = $db->prepare("INSERT INTO credit_card_purchases 
            (workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING id");
        $stmtPurch->execute([$workspaceId, $ownerId, $cardId, $categoryId, $description, $totalAmount, $purchasedOn, $installments, $notes]);
        $purchaseId = $stmtPurch->fetchColumn();

        $instAmount = round($totalAmount / $installments, 2);
        $diff = round($totalAmount - ($instAmount * $installments), 2);
        $startDate = new DateTime($purchasedOn);
        $pDay = (int)$startDate->format('d');

        // Determine base invoice month
        $baseDate = clone $startDate;
        if ($pDay > $closingDay) {
            $baseDate->modify('+1 month');
        }

        $affectedInvoices = [];

        for ($i = 1; $i <= $installments; $i++) {
            $targetDate = clone $baseDate;
            if ($i > 1) {
                $targetDate->modify('+' . ($i - 1) . ' month');
            }

            $tMonth = (int)$targetDate->format('m');
            $tYear = (int)$targetDate->format('Y');
            $compDateStr = $targetDate->format('Y-m-01');

            // Find or create invoice
            $stmtInv = $db->prepare("SELECT id FROM credit_card_invoices WHERE credit_card_id = ? AND month = ? AND year = ?");
            $stmtInv->execute([$cardId, $tMonth, $tYear]);
            $invoiceId = $stmtInv->fetchColumn();

            if (!$invoiceId) {
                $closeDateStr = sprintf('%04d-%02d-%02d', $tYear, $tMonth, min(28, $closingDay));
                $dueDateStr = sprintf('%04d-%02d-%02d', $tYear, $tMonth, min(28, $dueDay));

                $stmtNewInv = $db->prepare("INSERT INTO credit_card_invoices 
                    (account_id, workspace_id, owner_id, credit_card_id, month, year, status, total_amount, closing_date, due_date)
                    VALUES (?, ?, ?, ?, ?, ?, 'open', 0, ?, ?) RETURNING id");
                $stmtNewInv->execute([$accountId, $workspaceId, $ownerId, $cardId, $tMonth, $tYear, $closeDateStr, $dueDateStr]);
                $invoiceId = $stmtNewInv->fetchColumn();
            }

            $affectedInvoices[$invoiceId] = true;
            $curAmount = ($i === 1) ? ($instAmount + $diff) : $instAmount;
            $desc = $description . ($installments > 1 ? " ($i/$installments)" : '');

            // 2. Insert into credit_card_installments
            $stmtInst = $db->prepare("INSERT INTO credit_card_installments 
                (workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            $stmtInst->execute([$workspaceId, $ownerId, $cardId, $purchaseId, $invoiceId, $i, $curAmount, $compDateStr]);

            // 3. Insert into transactions
            $stmtTx = $db->prepare("INSERT INTO transactions 
                (workspace_id, owner_id, account_id, category_id, type, description, amount, interest_amount, competence_date, due_date, status, installment_current, installment_total, notes, invoice_id) 
                VALUES (?, ?, ?, ?, 'expense', ?, ?, 0, ?, ?, 'pending', ?, ?, ?, ?)");
            $stmtTx->execute([
                $workspaceId, $ownerId, $accountId, $categoryId, $desc, $curAmount, $compDateStr, $compDateStr, $i, $installments, $notes, $invoiceId
            ]);
        }

        // 4. Update total_amount for all affected invoices
        foreach (array_keys($affectedInvoices) as $invId) {
            $db->prepare("UPDATE credit_card_invoices 
                          SET total_amount = (SELECT COALESCE(SUM(amount), 0) FROM credit_card_installments WHERE invoice_id = ?) 
                          WHERE id = ?")->execute([$invId, $invId]);
        }

        $db->commit();

        echo json_encode(['success' => true, 'purchase_id' => $purchaseId, 'installments' => $installments]);
        exit;
    }

    // 18.1 Data: Single Invoice Items (On-Demand)
    if ($uri === '/cards/invoice-items' && $method === 'GET') {
        $invoiceId = $_GET['invoice_id'] ?? null;
        if (!$invoiceId) {
            http_response_code(400);
            echo json_encode(['error' => 'invoice_id is required']);
            exit;
        }
        requireResourceWorkspaceAccess($db, $sessionUser['id'], 'credit_card_invoices', $invoiceId);
        $stmt = $db->prepare("
            SELECT i.id, i.invoice_id, i.installment_number, i.amount, i.competence_date,
                   p.description, p.installment_count
            FROM credit_card_installments i
            JOIN credit_card_purchases p ON p.id = i.purchase_id
            WHERE i.invoice_id = ?
            ORDER BY i.competence_date ASC, i.installment_number ASC
        ");
        $stmt->execute([$invoiceId]);
        $rows = $stmt->fetchAll();
        $items = [];
        foreach ($rows as $inst) {
            $items[] = [
                'id' => $inst['id'],
                'installment_number' => (int)$inst['installment_number'],
                'amount' => (float)$inst['amount'],
                'competence_date' => $inst['competence_date'],
                'credit_card_purchases' => [
                    'description' => $inst['description'],
                    'installment_count' => (int)$inst['installment_count']
                ]
            ];
        }
        echo json_encode(['success' => true, 'items' => $items]);
        exit;
    }

    // 19. Data: Goal Contributions
    if ($uri === '/goals/contributions' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $goalId = $body['financial_goal_id'] ?? null;
        $amount = (float)($body['amount'] ?? 0);
        $note = $body['note'] ?? 'Aporte';

        if (!$workspaceId || !$goalId || $amount <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Meta e valor válido são obrigatórios']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        if (requireResourceWorkspaceAccess($db, $sessionUser['id'], 'financial_goals', $goalId) !== $workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'A meta não pertence ao espaço financeiro informado.']);
            exit;
        }

        $stmt = $db->prepare("INSERT INTO goal_contributions (workspace_id, owner_id, financial_goal_id, amount, note) 
            VALUES (?, ?, ?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $goalId, $amount, $note]);
        $contrib = $stmt->fetch();

        $stmtUp = $db->prepare("UPDATE financial_goals SET current_amount = current_amount + ? WHERE id = ?");
        $stmtUp->execute([$amount, $goalId]);

        echo json_encode(['success' => true, 'contribution' => $contrib]);
        exit;
    }

    // 20. Data: Preferences & Invites
    if ($uri === '/preferences' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $sessionUser['id'];

        if (!$workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'workspace_id é obrigatório']);
            exit;
        }

        if (isset($body['alert_preferences']) && is_array($body['alert_preferences'])) {
            $ap = $body['alert_preferences'];
            $db->prepare("INSERT INTO alert_preferences (workspace_id, owner_id)
                VALUES (?, ?)
                ON CONFLICT (workspace_id, owner_id) DO NOTHING")
                ->execute([$workspaceId, $ownerId]);

            $alertColumns = [
                'budget_alerts',
                'goal_alerts',
                'fixed_commitment_alerts',
                'credit_card_alerts',
                'low_balance_alerts',
                'weekly_digest',
                'budget_warning_percent',
                'low_balance_amount',
                'weekly_digest_day',
                'interest_alerts',
                'invoice_closing_alerts',
                'subscription_alerts',
            ];
            $sets = [];
            $values = [];
            foreach ($alertColumns as $column) {
                if (!array_key_exists($column, $ap)) continue;
                $value = $ap[$column];
                if (in_array($column, [
                    'budget_alerts',
                    'goal_alerts',
                    'fixed_commitment_alerts',
                    'credit_card_alerts',
                    'low_balance_alerts',
                    'weekly_digest',
                    'interest_alerts',
                    'invoice_closing_alerts',
                    'subscription_alerts',
                ], true)) {
                    $value = !empty($value);
                }
                if ($column === 'budget_warning_percent') {
                    $value = max(1, min(100, (int)$value));
                } elseif ($column === 'weekly_digest_day') {
                    $value = max(0, min(6, (int)$value));
                } elseif ($column === 'low_balance_amount') {
                    $value = max(0, (float)$value);
                }
                $sets[] = "{$column} = ?";
                $values[] = $value;
            }
            if ($sets) {
                $values[] = $workspaceId;
                $values[] = $ownerId;
                $stmt = $db->prepare(
                    "UPDATE alert_preferences SET " . implode(', ', $sets) .
                    " WHERE workspace_id = ? AND owner_id = ?"
                );
                $stmt->execute($values);
            }
        }

        if (isset($body['workspace_preferences']) && is_array($body['workspace_preferences'])) {
            $wp = $body['workspace_preferences'];

            foreach ([
                'default_cash_account_id' => 'accounts',
                'default_context_id' => 'financial_contexts',
                'default_category_id' => 'categories',
            ] as $field => $table) {
                $resourceId = $wp[$field] ?? null;
                if ($resourceId && requireResourceWorkspaceAccess(
                    $db,
                    $sessionUser['id'],
                    $table,
                    (string)$resourceId
                ) !== $workspaceId) {
                    http_response_code(400);
                    echo json_encode(['error' => 'Preferência referencia recurso de outro espaço financeiro.']);
                    exit;
                }
            }

            if (isset($wp['default_period']) && !in_array(
                $wp['default_period'],
                ['current_month', 'last_month', 'current_year', 'all_time'],
                true
            )) {
                http_response_code(400);
                echo json_encode(['error' => 'Período padrão inválido.']);
                exit;
            }

            foreach (['personal_color', 'clinic_color', 'primary_color'] as $colorField) {
                if (!empty($wp[$colorField]) && !preg_match('/^#[0-9a-fA-F]{6}$/', (string)$wp[$colorField])) {
                    http_response_code(400);
                    echo json_encode(['error' => 'Cor de preferência inválida.']);
                    exit;
                }
            }

            $db->prepare("INSERT INTO workspace_preferences (workspace_id, owner_id)
                VALUES (?, ?)
                ON CONFLICT (workspace_id, owner_id) DO NOTHING")
                ->execute([$workspaceId, $ownerId]);

            $preferenceColumns = [
                'default_cash_account_id',
                'primary_color',
                'default_context_id',
                'default_period',
                'hide_values',
                'compact_mode',
                'personal_color',
                'clinic_color',
                'default_category_id',
                'default_appointment_value',
                'default_billing_deadline_days',
                'alert_overdue_earnings',
                'alert_stale_quotes',
            ];
            $sets = [];
            $values = [];
            foreach ($preferenceColumns as $column) {
                if (!array_key_exists($column, $wp)) continue;
                $value = $wp[$column];
                if (in_array($column, [
                    'hide_values',
                    'compact_mode',
                    'alert_overdue_earnings',
                    'alert_stale_quotes',
                ], true)) {
                    $value = !empty($value);
                } elseif ($column === 'default_appointment_value') {
                    $value = max(0, (float)$value);
                } elseif ($column === 'default_billing_deadline_days') {
                    $value = max(1, min(365, (int)$value));
                }
                $sets[] = "{$column} = ?";
                $values[] = $value === '' ? null : $value;
            }
            if ($sets) {
                $values[] = $workspaceId;
                $values[] = $ownerId;
                $stmt = $db->prepare(
                    "UPDATE workspace_preferences SET " . implode(', ', $sets) .
                    " WHERE workspace_id = ? AND owner_id = ?"
                );
                $stmt->execute($values);
            }
        }

        echo json_encode(['success' => true]);
        exit;
    }

    if ($uri === '/invites' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $role = $body['role'] ?? 'editor';
        $token = bin2hex(random_bytes(24));

        if (!$workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'workspace_id é obrigatório']);
            exit;
        }
        if (!canManageWorkspace($db, $sessionUser['id'], $workspaceId)) {
            http_response_code(403);
            echo json_encode(['error' => 'Somente gestores podem administrar convites.']);
            exit;
        }
        if (!in_array($role, ['admin', 'editor', 'viewer'], true)) {
            http_response_code(400);
            echo json_encode(['error' => 'Perfil do convite inválido.']);
            exit;
        }

        $stmt = $db->prepare("INSERT INTO workspace_invites (workspace_id, role, token) VALUES (?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $role, $token]);
        $inv = $stmt->fetch();

        echo json_encode(['success' => true, 'invite' => $inv, 'token' => $token]);
        exit;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Rota não encontrada']);

} catch (Throwable $e) {
    if (isset($db) && $db->inTransaction()) $db->rollBack();
    error_log('BS Financeiro API error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Ocorreu um erro interno. Tente novamente.']);
}
