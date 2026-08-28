<?php
namespace App\Models;

use PDO;

class Invoice {
    // Retorna a fatura do mês/ano para o cartão, ou cria uma nova se não existir
    public static function getOrCreate($accountId, $month, $year) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("SELECT * FROM invoices WHERE account_id = ? AND month = ? AND year = ?");
        $stmt->execute([$accountId, $month, $year]);
        $invoice = $stmt->fetch();
        
        if ($invoice) return $invoice['id'];

        // Cria nova
        $stmt = $pdo->prepare("INSERT INTO invoices (account_id, month, year, status, total_amount) VALUES (?, ?, ?, 'open', 0)");
        $stmt->execute([$accountId, $month, $year]);
        return $pdo->lastInsertId();
    }

    // Calcula a fatura que uma transação deveria cair baseado no fechamento
    public static function resolveInvoiceForDate($accountId, $transactionDate) {
        $pdo = Database::getInstance()->getConnection();
        
        $stmt = $pdo->prepare("SELECT closing_day FROM credit_cards WHERE account_id = ?");
        $stmt->execute([$accountId]);
        $card = $stmt->fetch();
        
        if (!$card) return null;
        
        $closingDay = (int) $card['closing_day'];
        
        $tDate = new \DateTime($transactionDate);
        $tDay = (int) $tDate->format('d');
        $month = (int) $tDate->format('m');
        $year = (int) $tDate->format('Y');

        // Se comprou no dia do fechamento ou depois, cai no proximo mes
        if ($tDay >= $closingDay) {
            $month++;
            if ($month > 12) {
                $month = 1;
                $year++;
            }
        }
        
        return self::getOrCreate($accountId, $month, $year);
    }
}
