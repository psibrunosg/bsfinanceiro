<?php
namespace App\Controllers;

use App\Controllers\Auth;

class DashboardController extends Controller {
    
    public function index() {
        Auth::requireLogin();
        
        $userId = Auth::userId();
        
        $balance = \App\Models\Transaction::getBalanceByUser($userId);
        $transactions = \App\Models\Transaction::getRecentByUser($userId, 20);
        $pendingTransactions = \App\Models\Transaction::getPendingByUser($userId);
        
        $accounts = \App\Models\Account::getAllByUser($userId);
        $categories = \App\Models\Category::getAllByUser($userId);
        $goals = \App\Models\Goal::getByUser($userId);
        $reservedBalance = \App\Models\Goal::getTotalReservedByUser($userId);
        
        // Ajusta o saldo para remover o que está reservado
        $availableBalance = $balance - $reservedBalance;
        
        $currentMonth = date('m');
        $currentYear = date('Y');
        
        $prevMonthDate = strtotime("-1 month", strtotime(date('Y-m-01')));
        $prevMonth = date('m', $prevMonthDate);
        $prevYear = date('Y', $prevMonthDate);

        $summary = \App\Models\Transaction::getMonthlySummary($userId, $currentYear, $currentMonth);
        $prevSummary = \App\Models\Transaction::getMonthlySummary($userId, $prevYear, $prevMonth);
        
        $income = (float) $summary['total_income'];
        $expense = (float) $summary['total_expense'];
        $prevExpense = (float) ($prevSummary['total_expense'] ?? 0);
        
        $expenseComparePercent = 0;
        if ($prevExpense > 0) {
            $expenseComparePercent = (($expense - $prevExpense) / $prevExpense) * 100;
        } elseif ($expense > 0) {
            $expenseComparePercent = 100; // Gastou esse mes e nada no passado
        }

        $remaining = $income - $expense;
        $healthRate = $income > 0 ? (($income - $expense) / $income) * 100 : 0;
        
        $expensesByCategory = \App\Models\Transaction::getExpensesByCategory($userId, $currentYear, $currentMonth);

        $data = [
            'title' => 'Dashboard - BS Financeiro',
            'userId' => $userId,
            'balance' => number_format($availableBalance, 2, ',', '.'),
            'totalBalance' => number_format($balance, 2, ',', '.'),
            'reservedBalance' => number_format($reservedBalance, 2, ',', '.'),
            'income' => number_format($income, 2, ',', '.'),
            'expense' => number_format($expense, 2, ',', '.'),
            'remaining' => number_format($remaining, 2, ',', '.'),
            'healthRate' => round($healthRate, 1),
            'expenseComparePercent' => round($expenseComparePercent, 1),
            'expensesByCategory' => $expensesByCategory,
            'transactions' => $transactions,
            'pendingTransactions' => $pendingTransactions,
            'accounts' => $accounts,
            'categories' => $categories,
            'goals' => $goals
        ];

        $this->render('dashboard', $data);
    }
}
