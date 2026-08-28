<?php
namespace App\Models;

use PDO;

class Transaction {
    public static function create($userId, $accountId, $categoryId, $type, $amount, $description, $date, $isPaid = true, $invoiceId = null, $installmentInfo = null) {
        $pdo = Database::getInstance()->getConnection();
        $pdo->beginTransaction();
        
        try {
            $stmt = $pdo->prepare("INSERT INTO transactions (user_id, account_id, category_id, type, amount, description, date, is_paid, invoice_id, installment_info) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            $isPaidInt = $isPaid ? 1 : 0;
            $stmt->execute([$userId, $accountId, $categoryId, $type, $amount, $description, $date, $isPaidInt, $invoiceId, $installmentInfo]);
            
            // Atualiza saldo da conta apenas se for pago e NÃO for do cartão de crédito (fatura)
            // Se tem invoice_id, é uma compra de cartão, não afeta o saldo da conta corrente agora.
            if ($isPaid && is_null($invoiceId)) {
                $signal = ($type === 'income') ? '+' : '-';
                if ($type === 'transfer') $signal = '-'; 
                
                $stmt = $pdo->prepare("UPDATE accounts SET balance = balance $signal ? WHERE id = ? AND user_id = ?");
                $stmt->execute([$amount, $accountId, $userId]);
            }
            
            $pdo->commit();
            return true;
        } catch (\Exception $e) {
            $pdo->rollBack();
            return false;
        }
    }

    public static function markAsPaid($transactionId, $userId) {
        $pdo = Database::getInstance()->getConnection();
        $pdo->beginTransaction();
        try {
            // Busca os dados da transacao
            $stmt = $pdo->prepare("SELECT * FROM transactions WHERE id = ? AND user_id = ? AND is_paid = false");
            $stmt->execute([$transactionId, $userId]);
            $t = $stmt->fetch();
            
            if ($t) {
                // Marca como paga
                $stmt = $pdo->prepare("UPDATE transactions SET is_paid = true WHERE id = ?");
                $stmt->execute([$transactionId]);

                // Atualiza o saldo se nao for de cartao
                if (is_null($t['invoice_id'])) {
                    $signal = ($t['type'] === 'income') ? '+' : '-';
                    if ($t['type'] === 'transfer') $signal = '-'; 
                    
                    $stmt = $pdo->prepare("UPDATE accounts SET balance = balance $signal ? WHERE id = ?");
                    $stmt->execute([$t['amount'], $t['account_id']]);
                }
                $pdo->commit();
                return true;
            }
            $pdo->rollBack();
            return false;
        } catch (\Exception $e) {
            $pdo->rollBack();
            return false;
        }
    }

    public static function getRecentByUser($userId, $limit = 50) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("
            SELECT t.*, a.name as account_name, c.name as category_name, c.color as category_color 
            FROM transactions t
            LEFT JOIN accounts a ON t.account_id = a.id
            LEFT JOIN categories c ON t.category_id = c.id
            WHERE t.user_id = ? AND t.is_paid = true
            ORDER BY t.date DESC, t.created_at DESC 
            LIMIT ?
        ");
        $stmt->execute([$userId, $limit]);
        return $stmt->fetchAll();
    }

    public static function getPendingByUser($userId) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("
            SELECT t.*, a.name as account_name, c.name as category_name, c.color as category_color 
            FROM transactions t
            LEFT JOIN accounts a ON t.account_id = a.id
            LEFT JOIN categories c ON t.category_id = c.id
            WHERE t.user_id = ? AND t.is_paid = false
            ORDER BY t.date ASC 
        ");
        $stmt->execute([$userId]);
        return $stmt->fetchAll();
    }

    public static function getBalanceByUser($userId) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("SELECT SUM(balance) as total FROM accounts WHERE user_id = ?");
        $stmt->execute([$userId]);
        $row = $stmt->fetch();
        return $row['total'] ?? 0.00;
    }

    public static function getMonthlySummary($userId, $year, $month) {
        $pdo = Database::getInstance()->getConnection();
        
        $startDate = "$year-$month-01";
        $endDate = date("Y-m-t", strtotime($startDate));

        $stmt = $pdo->prepare("
            SELECT 
                COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) as total_income,
                COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) as total_expense
            FROM transactions 
            WHERE user_id = ? AND date >= ? AND date <= ?
        ");
        $stmt->execute([$userId, $startDate, $endDate]);
        return $stmt->fetch();
    }

    public static function getExpensesByCategory($userId, $year, $month) {
        $pdo = Database::getInstance()->getConnection();
        
        $startDate = "$year-$month-01";
        $endDate = date("Y-m-t", strtotime($startDate));

        $stmt = $pdo->prepare("
            SELECT 
                c.id as category_id,
                COALESCE(c.name, 'Outros') as category_name,
                COALESCE(c.color, '#666666') as category_color,
                COALESCE(c.budget_limit, 0) as budget_limit,
                SUM(t.amount) as total
            FROM transactions t
            LEFT JOIN categories c ON t.category_id = c.id
            WHERE t.user_id = ? AND t.type = 'expense' AND t.date >= ? AND t.date <= ?
            GROUP BY c.id, c.name, c.color, c.budget_limit
            ORDER BY total DESC
        ");
        $stmt->execute([$userId, $startDate, $endDate]);
        return $stmt->fetchAll();
    }
}
