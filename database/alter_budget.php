<?php
require_once __DIR__ . '/../src/Models/Database.php';

try {
    $pdo = \App\Models\Database::getInstance()->getConnection();
    $pdo->exec("ALTER TABLE categories ADD COLUMN IF NOT EXISTS budget_limit NUMERIC(10,2) DEFAULT 0;");
    echo "Coluna budget_limit adicionada com sucesso.\n";
} catch (Exception $e) {
    echo "Erro: " . $e->getMessage() . "\n";
}
