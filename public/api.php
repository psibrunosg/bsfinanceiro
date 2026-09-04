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

    // 3.1. Auth: Change Password
    if ($uri === '/auth/change-password' && $method === 'POST') {
        $userId = $body['user_id'] ?? null;
        $currentPassword = $body['current_password'] ?? '';
        $newPassword = $body['new_password'] ?? '';

        if (!$userId || empty($currentPassword) || empty($newPassword) || strlen($newPassword) < 6) {
            http_response_code(400);
            echo json_encode(['error' => 'Preencha a senha atual e a nova senha (mínimo 6 caracteres).']);
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
        $userId = $_GET['user_id'] ?? null;
        if (!$userId) {
            http_response_code(400);
            echo json_encode(['error' => 'user_id is required']);
            exit;
        }

        $stmt = $db->prepare("SELECT u.id, u.email, u.display_name, p.age, p.birth_date, p.profession, p.phone, p.avatar_color, p.theme_preference 
                              FROM users u LEFT JOIN profiles p ON p.id = u.id WHERE u.id = ?");
        $stmt->execute([$userId]);
        $profile = $stmt->fetch();

        echo json_encode(['profile' => $profile]);
        exit;
    }

    if ($uri === '/profile/update' && $method === 'POST') {
        $userId = $body['user_id'] ?? null;
        $displayName = trim($body['display_name'] ?? '');
        $age = !empty($body['age']) ? (int)$body['age'] : null;
        $profession = trim($body['profession'] ?? '');
        $phone = trim($body['phone'] ?? '');
        $avatarColor = trim($body['avatar_color'] ?? '#8b5cf6');

        if (!$userId) {
            http_response_code(400);
            echo json_encode(['error' => 'user_id is required']);
            exit;
        }

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

        $transactions = $db->prepare("SELECT id, account_id, destination_account_id, type, status, description, amount, competence_date, category_id, paid_at FROM transactions WHERE workspace_id = ? ORDER BY competence_date DESC, created_at DESC LIMIT 500");
        $transactions->execute([$workspaceId]);

        $budgets = $db->prepare("SELECT id, category_id, amount, month FROM monthly_budgets WHERE workspace_id = ?");
        $budgets->execute([$workspaceId]);

        $goals = $db->prepare("SELECT id, name, target_amount, current_amount, deadline, status FROM financial_goals WHERE workspace_id = ? AND status = 'active'");
        $goals->execute([$workspaceId]);

        $cards = $db->prepare("SELECT id, account_id, name, closing_day, due_day, limit_amount as credit_limit FROM credit_cards WHERE workspace_id = ?");
        $cards->execute([$workspaceId]);

        $investments = $db->prepare("SELECT * FROM investment_assets WHERE workspace_id = ? AND active = true");
        $investments->execute([$workspaceId]);

        $commitments = [];
        try {
            $stmt = $db->prepare("SELECT * FROM fixed_commitments WHERE workspace_id = ? AND active = true");
            $stmt->execute([$workspaceId]);
            $commitments = $stmt->fetchAll();
        } catch (Exception $e) {}

        $occurrences = [];
        try {
            $stmt = $db->prepare("SELECT o.* FROM fixed_commitment_occurrences o JOIN fixed_commitments c ON c.id = o.commitment_id WHERE c.workspace_id = ?");
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

        echo json_encode([
            'accounts' => $accounts->fetchAll(),
            'categories' => $categories->fetchAll(),
            'transactions' => $transactions->fetchAll(),
            'budgets' => $budgets->fetchAll(),
            'goals' => $goals->fetchAll(),
            'cards' => $cards->fetchAll(),
            'investments' => $investments->fetchAll(),
            'commitments' => $commitments,
            'occurrences' => $occurrences,
            'debts' => $debts,
            'workspace_users' => $workspaceUsers,
            'alert_preferences' => $alertPrefs,
            'workspace_preferences' => $workspacePrefs,
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
        $destinationAccountId = $body['destination_account_id'] ?? null;
        $categoryId = $body['category_id'] ?? null;
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
            $stmt = $db->prepare("SELECT id FROM accounts WHERE workspace_id = ? LIMIT 1");
            $stmt->execute([$workspaceId]);
            $accountId = $stmt->fetchColumn();
        }

        $stmt = $db->prepare("INSERT INTO transactions 
            (workspace_id, owner_id, account_id, destination_account_id, category_id, type, description, amount, interest_amount, competence_date, paid_at, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $accountId, $destinationAccountId, $categoryId, $type, $description, $amount, $interestAmount, $competenceDate, $competenceDate, $status]);
        $tx = $stmt->fetch();

        echo json_encode(['success' => true, 'transaction' => $tx]);
        exit;
    }

    if ($uri === '/transactions' && $method === 'DELETE') {
        $id = $_GET['id'] ?? $body['id'] ?? null;
        if (!$id) {
            http_response_code(400);
            echo json_encode(['error' => 'ID da transação é obrigatório']);
            exit;
        }
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
        $brand = $body['brand'] ?? 'mastercard';
        $lastFour = $body['last_four'] ?? null;
        $creditLimit = (float)($body['credit_limit'] ?? 0);
        $closingDay = (int)($body['closing_day'] ?? 1);
        $dueDay = (int)($body['due_day'] ?? 10);

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

        $stmt = $db->prepare("INSERT INTO credit_cards (workspace_id, owner_id, name, brand, last_four, credit_limit, closing_day, due_day) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $name, $brand, $lastFour, $creditLimit, $closingDay, $dueDay]);
        $card = $stmt->fetch();

        echo json_encode(['success' => true, 'card' => $card]);
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
        $stmt = $db->prepare("DELETE FROM debts WHERE id = ?");
        $stmt->execute([$id]);
        echo json_encode(['success' => true]);
        exit;
    }

    http_response_code(404);
    echo json_encode(['error' => 'Rota não encontrada']);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
