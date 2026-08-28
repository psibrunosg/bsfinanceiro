<?php
require_once __DIR__ . '/../src/Models/Database.php';

try {
    $pdo = \App\Models\Database::getInstance()->getConnection();
    
    // Atualiza um limite de orçamento aleatorio para categorias que já existem 
    // apenas para fins de demonstrar a feature (se houver categorias)
    $stmt = $pdo->prepare("UPDATE categories SET budget_limit = 500.00 WHERE type = 'expense' AND id IN (SELECT id FROM categories LIMIT 2)");
    $stmt->execute();

    echo "Limites de orcamento de exemplo configurados com sucesso.\n";
} catch (Exception $e) {
    echo "Erro: " . $e->getMessage() . "\n";
}
