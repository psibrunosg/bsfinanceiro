<?php
require_once __DIR__ . '/../src/Models/Database.php';

try {
    $pdo = \App\Models\Database::getInstance()->getConnection();

    // Pega o primeiro usuario (o que o dev ta usando)
    $stmt = $pdo->prepare("SELECT id FROM users LIMIT 1");
    $stmt->execute();
    $user = $stmt->fetch();
    
    if (!$user) {
        die("Nenhum usuario encontrado.\n");
    }
    $userId = $user['id'];

    // 1. Cria um Cartao de Credito
    require_once __DIR__ . '/../src/Models/CreditCard.php';
    require_once __DIR__ . '/../src/Models/Invoice.php';
    \App\Models\CreditCard::create($userId, 'Cartão Nubank', 25, 5, 2000.00);

    // 2. Cria uma Conta a Pagar Pendente
    $stmt = $pdo->prepare("SELECT id FROM accounts WHERE user_id = ? AND type != 'credit_card' LIMIT 1");
    $stmt->execute([$userId]);
    $account = $stmt->fetch();
    if ($account) {
        require_once __DIR__ . '/../src/Models/Transaction.php';
        // Uma despesa pendente
        \App\Models\Transaction::create($userId, $account['id'], null, 'expense', 150.00, 'Conta de Luz (A Vencer)', date('Y-m-d', strtotime('+3 days')), false);
    }

    // 3. Cria uma Meta/Cofrinho e deposita R$ 500
    require_once __DIR__ . '/../src/Models/Goal.php';
    \App\Models\Goal::create($userId, 'Reserva de Emergência', 5000.00, date('Y-m-d', strtotime('+1 year')), '#3b82f6');
    $goalId = $pdo->lastInsertId();
    \App\Models\Goal::addAmount($goalId, $userId, 500.00);

    echo "Dados de teste da Fase 3 criados com sucesso!\n";
} catch (Exception $e) {
    echo "Erro: " . $e->getMessage() . "\n";
}
