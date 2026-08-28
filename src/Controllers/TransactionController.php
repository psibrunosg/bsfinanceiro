<?php
namespace App\Controllers;

use App\Models\Transaction;
use App\Models\Account;
use App\Controllers\Auth;

class TransactionController extends Controller {
    
    public function create() {
        Auth::requireLogin();
        
        $userId = Auth::userId();
        $type = $_POST['type'] ?? 'expense';
        $amount = (float) ($_POST['amount'] ?? 0);
        $description = $_POST['description'] ?? '';
        $date = $_POST['date'] ?? date('Y-m-d');
        $accountId = (int) ($_POST['account_id'] ?? 0);
        $categoryId = !empty($_POST['category_id']) ? (int) $_POST['category_id'] : null;
        $isPaid = isset($_POST['is_paid']) ? (bool) $_POST['is_paid'] : true;
        $installments = isset($_POST['installments']) ? max(1, (int) $_POST['installments']) : 1;

        if ($accountId === 0) {
            $accountId = Account::create($userId, 'Carteira (Auto)', 'checking', true);
        }

        // Verifica se é cartão de crédito
        $pdo = \App\Models\Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("SELECT type FROM accounts WHERE id = ?");
        $stmt->execute([$accountId]);
        $accInfo = $stmt->fetch();
        $isCreditCard = ($accInfo && $accInfo['type'] === 'credit_card');

        if ($amount > 0 && !empty($description) && $accountId) {
            
            $installmentAmount = round($amount / $installments, 2);
            // Ajusta centavos na primeira parcela para bater o valor
            $firstInstallmentDiff = $amount - ($installmentAmount * $installments);
            
            for ($i = 1; $i <= $installments; $i++) {
                $currentAmount = $installmentAmount;
                if ($i === 1) $currentAmount += $firstInstallmentDiff;
                
                // Calcula a data da parcela (adiciona $i-1 meses)
                $currentDate = date('Y-m-d', strtotime("+" . ($i - 1) . " months", strtotime($date)));
                
                $installmentInfo = $installments > 1 ? "$i/$installments" : null;
                $invoiceId = null;
                
                if ($isCreditCard) {
                    $invoiceId = \App\Models\Invoice::resolveInvoiceForDate($accountId, $currentDate);
                    // No cartao, is_paid = true na transacao em si, o controle fica na Fatura
                    $isPaid = true;
                }

                Transaction::create($userId, $accountId, $categoryId, $type, $currentAmount, $description, $currentDate, $isPaid, $invoiceId, $installmentInfo);
            }
        }

        header('Location: /');
        exit;
    }

    public function payPending() {
        Auth::requireLogin();
        $userId = Auth::userId();
        $id = (int) ($_POST['transaction_id'] ?? 0);
        if ($id > 0) {
            Transaction::markAsPaid($id, $userId);
        }
        header('Location: /');
        exit;
    }
}
