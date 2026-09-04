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

    // 1.1 Backup Status
    if ($uri === '/backup-status' && $method === 'GET') {
        $statusFile = '/opt/backups/bsfinanceiro/latest.json';
        if (file_exists($statusFile)) {
            $data = json_decode(file_get_contents($statusFile), true);
            echo json_encode(array_merge(['configured' => true], is_array($data) ? $data : []));
        } else {
            echo json_encode(['configured' => true, 'status' => 'pending', 'message' => 'Nenhum backup registrado ainda']);
        }
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

        echo json_encode([
            'accounts' => $accounts->fetchAll(),
            'categories' => $categories->fetchAll(),
            'transactions' => $transactions->fetchAll(),
            'budgets' => $budgets->fetchAll(),
            'goals' => $goals->fetchAll(),
            'cards' => $cards->fetchAll(),
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

    // 15. Data: Patient Earnings & Receive
    if ($uri === '/patient-earnings' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $patientId = $body['patient_id'] ?? null;
        $amount = (float)($body['amount'] ?? 0);
        $appointmentDate = $body['appointment_date'] ?? date('Y-m-d');
        $dueDate = $body['due_date'] ?? $appointmentDate;
        $notes = $body['notes'] ?? null;

        if (!$workspaceId || !$patientId || $amount <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Paciente e valor válido são obrigatórios']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        $stmt = $db->prepare("INSERT INTO patient_earnings (workspace_id, owner_id, patient_id, amount, appointment_date, due_date, status, notes) 
            VALUES (?, ?, ?, ?, ?, ?, 'pending', ?) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $patientId, $amount, $appointmentDate, $dueDate, $notes]);
        $earning = $stmt->fetch();

        echo json_encode(['success' => true, 'earning' => $earning]);
        exit;
    }

    if ($uri === '/patient-earnings/receive' && $method === 'POST') {
        $earningId = $body['earning_id'] ?? null;
        $accountId = $body['account_id'] ?? null;
        $receivedDate = $body['received_date'] ?? date('Y-m-d');

        if (!$earningId || !$accountId) {
            http_response_code(400);
            echo json_encode(['error' => 'Atendimento e conta são obrigatórios']);
            exit;
        }

        $stmt = $db->prepare("SELECT e.*, p.name as patient_name FROM patient_earnings e JOIN patients p ON p.id = e.patient_id WHERE e.id = ?");
        $stmt->execute([$earningId]);
        $earning = $stmt->fetch();

        if (!$earning) {
            http_response_code(404);
            echo json_encode(['error' => 'Atendimento não encontrado']);
            exit;
        }

        if ($earning['status'] === 'received') {
            echo json_encode(['success' => true, 'already_received' => true, 'transaction_id' => $earning['transaction_id']]);
            exit;
        }

        $stmtTx = $db->prepare("INSERT INTO transactions 
            (workspace_id, owner_id, account_id, type, description, amount, interest_amount, competence_date, paid_at, status) 
            VALUES (?, ?, ?, 'income', ?, ?, 0, ?, ?, 'paid') RETURNING id");
        $stmtTx->execute([
            $earning['workspace_id'],
            $earning['owner_id'],
            $accountId,
            'Recebimento de paciente - ' . $earning['patient_name'],
            $earning['amount'],
            $receivedDate,
            $receivedDate
        ]);
        $txId = $stmtTx->fetchColumn();

        $stmtUp = $db->prepare("UPDATE patient_earnings SET status = 'received', transaction_id = ? WHERE id = ?");
        $stmtUp->execute([$txId, $earningId]);

        echo json_encode(['success' => true, 'transaction_id' => $txId]);
        exit;
    }

    // 16. Data: Payslips (Holerites)
    if ($uri === '/payslips' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $employer = trim($body['employer'] ?? '');
        $competence = $body['competence'] ?? date('Y-m-01');
        $grossAmount = (float)($body['gross_amount'] ?? 0);
        $discountsAmount = (float)($body['discounts_amount'] ?? 0);
        $netAmount = (float)($body['net_amount'] ?? ($grossAmount - $discountsAmount));
        $receivedDate = $body['received_date'] ?? null;
        $accountId = $body['account_id'] ?? null;
        $notes = $body['notes'] ?? null;

        if (!$workspaceId || empty($employer) || $netAmount < 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Empregador e valor líquido válido são obrigatórios']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        $txId = null;
        if ($accountId && $receivedDate && $netAmount > 0) {
            $stmtTx = $db->prepare("INSERT INTO transactions 
                (workspace_id, owner_id, account_id, type, description, amount, interest_amount, competence_date, paid_at, status) 
                VALUES (?, ?, ?, 'income', ?, ?, 0, ?, ?, 'paid') RETURNING id");
            $stmtTx->execute([$workspaceId, $ownerId, $accountId, 'Contracheque ' . $employer, $netAmount, $receivedDate, $receivedDate]);
            $txId = $stmtTx->fetchColumn();
        }

        $stmt = $db->prepare("INSERT INTO payslips 
            (workspace_id, owner_id, employer, competence, gross_amount, discounts_amount, net_amount, received_date, transaction_id, notes) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $employer, $competence, $grossAmount, $discountsAmount, $netAmount, $receivedDate, $txId, $notes]);
        $payslip = $stmt->fetch();

        echo json_encode(['success' => true, 'payslip' => $payslip, 'transaction_id' => $txId]);
        exit;
    }

    // 17. Data: Investments (Assets, Operations, Quotes)
    if ($uri === '/investments/assets' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $name = trim($body['name'] ?? '');
        $ticker = trim($body['ticker'] ?? $body['exchange'] ?? $name);
        $type = $body['type'] ?? 'stock';
        $isShared = !empty($body['is_shared']) ? true : false;

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

        $stmt = $db->prepare("INSERT INTO investment_assets (workspace_id, owner_id, ticker, name, type, is_shared, active) 
            VALUES (?, ?, ?, ?, ?, ?, true) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $ticker, $name, $type, $isShared ? 'true' : 'false']);
        $asset = $stmt->fetch();

        echo json_encode(['success' => true, 'asset' => $asset]);
        exit;
    }

    if ($uri === '/investments/operations' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $assetId = $body['asset_id'] ?? null;
        $accountId = $body['account_id'] ?? null;
        $opType = $body['operation_type'] ?? $body['type'] ?? 'buy';
        $quantity = (float)($body['quantity'] ?? 0);
        $unitPrice = (float)($body['unit_price'] ?? 0);
        $opDate = $body['operation_date'] ?? date('Y-m-d');
        $notes = $body['notes'] ?? null;

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

        $stmtAsset = $db->prepare("SELECT name, ticker FROM investment_assets WHERE id = ?");
        $stmtAsset->execute([$assetId]);
        $asset = $stmtAsset->fetch();

        $stmt = $db->prepare("INSERT INTO investment_operations (workspace_id, owner_id, asset_id, operation_type, quantity, unit_price, operation_date) 
            VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING *");
        $stmt->execute([$workspaceId, $ownerId, $assetId, $opType, $quantity, $unitPrice, $opDate]);
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
        }

        echo json_encode(['success' => true, 'operation' => $operation, 'transaction_id' => $txId]);
        exit;
    }

    if ($uri === '/investments/quotes' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $ownerId = $body['owner_id'] ?? null;
        $assetId = $body['asset_id'] ?? null;
        $unitPrice = (float)($body['unit_price'] ?? 0);
        $quoteDate = $body['quote_date'] ?? date('Y-m-d');

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

        $stmtCard = $db->prepare("SELECT account_id FROM credit_cards WHERE id = ?");
        $stmtCard->execute([$cardId]);
        $accountId = $stmtCard->fetchColumn();

        if (!$accountId) {
            $stmtAcc = $db->prepare("SELECT id FROM accounts WHERE workspace_id = ? LIMIT 1");
            $stmtAcc->execute([$workspaceId]);
            $accountId = $stmtAcc->fetchColumn();
        }

        $instAmount = round($totalAmount / $installments, 2);
        $startDate = new DateTime($purchasedOn);

        for ($i = 1; $i <= $installments; $i++) {
            $compDate = clone $startDate;
            if ($i > 1) {
                $compDate->modify('+' . ($i - 1) . ' month');
            }
            $compDateStr = $compDate->format('Y-m-d');
            $desc = $description . ($installments > 1 ? " ($i/$installments)" : '');

            $stmtTx = $db->prepare("INSERT INTO transactions 
                (workspace_id, owner_id, account_id, category_id, type, description, amount, interest_amount, competence_date, due_date, status, installment_current, installment_total, notes) 
                VALUES (?, ?, ?, ?, 'expense', ?, ?, 0, ?, ?, 'pending', ?, ?, ?)");
            $stmtTx->execute([
                $workspaceId, $ownerId, $accountId, $categoryId, $desc, $instAmount, $compDateStr, $compDateStr, $i, $installments, $notes
            ]);
        }

        echo json_encode(['success' => true, 'installments' => $installments]);
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
        $ownerId = $body['owner_id'] ?? null;

        if (!$workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'workspace_id é obrigatório']);
            exit;
        }

        if (!$ownerId) {
            $stmt = $db->prepare("SELECT owner_id FROM workspaces WHERE id = ?");
            $stmt->execute([$workspaceId]);
            $ownerId = $stmt->fetchColumn();
        }

        if (isset($body['alert_preferences'])) {
            $ap = $body['alert_preferences'];
            $interest = !empty($ap['interest_alerts']) ? 'true' : 'false';
            $closing = !empty($ap['invoice_closing_alerts']) ? 'true' : 'false';
            $subs = !empty($ap['subscription_alerts']) ? 'true' : 'false';

            $stmt = $db->prepare("INSERT INTO alert_preferences (workspace_id, owner_id, interest_alerts, invoice_closing_alerts, subscription_alerts) 
                VALUES (?, ?, ?, ?, ?) 
                ON CONFLICT (workspace_id, owner_id) DO UPDATE SET 
                    interest_alerts = EXCLUDED.interest_alerts, 
                    invoice_closing_alerts = EXCLUDED.invoice_closing_alerts, 
                    subscription_alerts = EXCLUDED.subscription_alerts");
            $stmt->execute([$workspaceId, $ownerId, $interest, $closing, $subs]);
        }

        if (isset($body['workspace_preferences'])) {
            $wp = $body['workspace_preferences'];
            $cashAcc = !empty($wp['default_cash_account_id']) ? $wp['default_cash_account_id'] : null;
            $color = !empty($wp['primary_color']) ? $wp['primary_color'] : null;

            $stmt = $db->prepare("INSERT INTO workspace_preferences (workspace_id, owner_id, default_cash_account_id, primary_color) 
                VALUES (?, ?, ?, ?) 
                ON CONFLICT (workspace_id, owner_id) DO UPDATE SET 
                    default_cash_account_id = COALESCE(EXCLUDED.default_cash_account_id, workspace_preferences.default_cash_account_id), 
                    primary_color = COALESCE(EXCLUDED.primary_color, workspace_preferences.primary_color)");
            $stmt->execute([$workspaceId, $ownerId, $cashAcc, $color]);
        }

        echo json_encode(['success' => true]);
        exit;
    }

    if ($uri === '/invites' && $method === 'POST') {
        $workspaceId = $body['workspace_id'] ?? null;
        $role = $body['role'] ?? 'editor';
        $token = $body['token'] ?? bin2hex(random_bytes(16));

        if (!$workspaceId) {
            http_response_code(400);
            echo json_encode(['error' => 'workspace_id é obrigatório']);
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

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
