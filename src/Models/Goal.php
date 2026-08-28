<?php
namespace App\Models;

use PDO;

class Goal {
    public static function create($userId, $name, $targetAmount, $deadline, $color) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("INSERT INTO goals (user_id, name, target_amount, current_amount, deadline, color) VALUES (?, ?, ?, 0, ?, ?)");
        return $stmt->execute([$userId, $name, $targetAmount, $deadline, $color]);
    }

    public static function getByUser($userId) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("SELECT * FROM goals WHERE user_id = ? ORDER BY deadline ASC");
        $stmt->execute([$userId]);
        return $stmt->fetchAll();
    }

    public static function addAmount($goalId, $userId, $amount) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("UPDATE goals SET current_amount = current_amount + ? WHERE id = ? AND user_id = ?");
        return $stmt->execute([$amount, $goalId, $userId]);
    }

    public static function getTotalReservedByUser($userId) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("SELECT SUM(current_amount) as total FROM goals WHERE user_id = ?");
        $stmt->execute([$userId]);
        $row = $stmt->fetch();
        return (float) ($row['total'] ?? 0.00);
    }
}
