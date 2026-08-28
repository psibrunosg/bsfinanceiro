<?php
require_once __DIR__ . '/../src/Models/Database.php';

try {
    $pdo = \App\Models\Database::getInstance()->getConnection();
    $pdo->beginTransaction();

    // 1. Tabela de Detalhes de Cartoes de Credito (Vinculada a accounts)
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS credit_cards (
            id SERIAL PRIMARY KEY,
            account_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
            closing_day INTEGER NOT NULL,
            due_day INTEGER NOT NULL,
            limit_amount NUMERIC(14,2) DEFAULT 0.00
        );
    ");

    // 2. Tabela de Faturas (Invoices)
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS invoices (
            id SERIAL PRIMARY KEY,
            account_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
            month INTEGER NOT NULL,
            year INTEGER NOT NULL,
            status VARCHAR(20) DEFAULT 'open', -- open, closed, paid
            total_amount NUMERIC(14,2) DEFAULT 0.00,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );
    ");

    // 3. Tabela de Metas (Goals)
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS goals (
            id SERIAL PRIMARY KEY,
            user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            name VARCHAR(100) NOT NULL,
            target_amount NUMERIC(14, 2) NOT NULL,
            current_amount NUMERIC(14, 2) DEFAULT 0.00,
            deadline DATE,
            color VARCHAR(7) DEFAULT '#000000',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );
    ");

    // 4. Alterações na tabela transactions
    $pdo->exec("
        ALTER TABLE transactions 
        ADD COLUMN IF NOT EXISTS invoice_id INTEGER REFERENCES invoices(id) ON DELETE SET NULL,
        ADD COLUMN IF NOT EXISTS installment_info VARCHAR(50);
    ");

    $pdo->commit();
    echo "Migracao da Fase 3 concluida com sucesso!\n";
} catch (Exception $e) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    echo "Erro na migracao: " . $e->getMessage() . "\n";
}
