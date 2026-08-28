<?php
namespace App\Models;

use PDO;

class CreditCard {
    public static function create($userId, $name, $closingDay, $dueDay, $limitAmount) {
        $pdo = Database::getInstance()->getConnection();
        $pdo->beginTransaction();
        try {
            // Cria a conta com tipo 'credit_card'
            $stmt = $pdo->prepare("INSERT INTO accounts (user_id, name, type, balance) VALUES (?, ?, 'credit_card', 0)");
            $stmt->execute([$userId, $name]);
            $accountId = $pdo->lastInsertId();

            // Insere os detalhes do cartao
            $stmt = $pdo->prepare("INSERT INTO credit_cards (account_id, closing_day, due_day, limit_amount) VALUES (?, ?, ?, ?)");
            $stmt->execute([$accountId, $closingDay, $dueDay, $limitAmount]);

            $pdo->commit();
            return $accountId;
        } catch (\Exception $e) {
            $pdo->rollBack();
            return false;
        }
    }

    public static function getByUser($userId) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("
            SELECT a.id as account_id, a.name, c.closing_day, c.due_day, c.limit_amount 
            FROM accounts a
            JOIN credit_cards c ON a.id = c.account_id
            WHERE a.user_id = ? AND a.type = 'credit_card'
        ");
        $stmt->execute([$userId]);
        return $stmt->fetchAll();
    }
}
