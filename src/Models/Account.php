<?php
namespace App\Models;

use PDO;

class Account {
    public static function create($userId, $name, $type, $isMain) {
        $pdo = Database::getInstance()->getConnection();
        
        if ($isMain) {
            // Remove is_main das outras
            $stmt = $pdo->prepare("UPDATE accounts SET is_main = false WHERE user_id = ?");
            $stmt->execute([$userId]);
        }

        $stmt = $pdo->prepare("INSERT INTO accounts (user_id, name, type, is_main) VALUES (?, ?, ?, ?) RETURNING id");
        $stmt->execute([$userId, $name, $type, $isMain ? 'true' : 'false']);
        
        $row = $stmt->fetch();
        return $row['id'] ?? false;
    }

    public static function getAllByUser($userId) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("SELECT * FROM accounts WHERE user_id = ? ORDER BY is_main DESC, name ASC");
        $stmt->execute([$userId]);
        return $stmt->fetchAll();
    }
}
