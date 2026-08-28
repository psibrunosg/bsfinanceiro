<?php
// BS Financeiro - REST API (PostgreSQL na VPS)
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
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
    $pass = getenv('DB_PASSWORD') ?: getenv('DB_PASS') ?: 'eTEklwZkO8dwrbazpVzeQpOXWwVraRcS7x48';

    try {
        $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
        $pdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
        return $pdo;
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
        exit;
    }
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

    // 1. Health Check
    if ($uri === '' || $uri === '/health') {
        echo json_encode(['status' => 'online', 'database' => 'connected', 'timestamp' => date('c')]);
        exit;
    }

    // 2. Auth: Register
    if ($uri === '/auth/register' && $method === 'POST') {
        $email = trim(strtolower($body['email'] ?? ''));
        $password = $body['password'] ?? '';
        $name = trim($body['name'] ?? explode('@', $email)[0]);

        if (empty($email) || empty($password) || strlen($password) < 6) {
            http_response_code(400);
            echo json_encode(['error' => 'E-mail e senha (mínimo 6 caracteres) são obrigatórios.', 'received' => $body, 'raw' => $rawInput]);
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
            'token' => base64_encode(json_encode(['uid' => $userId, 'email' => $email, 'exp' => time() + 86400 * 30]))
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

        echo json_encode([
            'success' => true,
            'user' => [
                'id' => $user['id'],
                'email' => $user['email'],
                'display_name' => $user['display_name']
            ],
            'workspace' => $workspace,
            'token' => base64_encode(json_encode(['uid' => $user['id'], 'email' => $user['email'], 'exp' => time() + 86400 * 30]))
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

        $accounts = $db->prepare("SELECT * FROM accounts WHERE workspace_id = ? AND active = true ORDER BY name ASC");
        $accounts->execute([$workspaceId]);

        $categories = $db->prepare("SELECT * FROM categories WHERE workspace_id = ? ORDER BY name ASC");
        $categories->execute([$workspaceId]);

        $transactions = $db->prepare("SELECT * FROM transactions WHERE workspace_id = ? ORDER BY competence_date DESC, created_at DESC LIMIT 500");
        $transactions->execute([$workspaceId]);

        $budgets = $db->prepare("SELECT * FROM monthly_budgets WHERE workspace_id = ?");
        $budgets->execute([$workspaceId]);

        $goals = $db->prepare("SELECT * FROM financial_goals WHERE workspace_id = ? AND status = 'active'");
        $goals->execute([$workspaceId]);

        $cards = $db->prepare("SELECT * FROM credit_cards WHERE workspace_id = ?");
        $cards->execute([$workspaceId]);

        $investments = $db->prepare("SELECT * FROM investment_assets WHERE workspace_id = ? AND active = true");
        $investments->execute([$workspaceId]);

        echo json_encode([
            'accounts' => $accounts->fetchAll(),
            'categories' => $categories->fetchAll(),
            'transactions' => $transactions->fetchAll(),
            'budgets' => $budgets->fetchAll(),
            'goals' => $goals->fetchAll(),
            'cards' => $cards->fetchAll(),
            'investments' => $investments->fetchAll(),
        ]);
        exit;
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
        $categoryId = $body['category_id'] ?? null;
        $interestAmount = (float)($body['interest_amount'] ?? 0);

        if (!$workspaceId || !$ownerId || empty($description) || $amount <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Dados de transação incompletos']);
            exit;
        }

        // If no account provided, pick the first available
        if (!$accountId) {
            $stmt = $db->prepare("SELECT id FROM accounts WHERE workspace_id = ? LIMIT 1");
            $stmt->execute([$workspaceId]);
            $accountId = $stmt->fetchColumn();
        }

        $stmt = $db->prepare("INSERT INTO transactions 
            (workspace_id, owner_id, account_id, category_id, type, description, amount, interest_amount, competence_date, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'paid') RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $accountId, $categoryId, $type, $description, $amount, $interestAmount, $competenceDate]);
        $tx = $stmt->fetch();

        echo json_encode(['success' => true, 'transaction' => $tx]);
        exit;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Rota não encontrada']);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
