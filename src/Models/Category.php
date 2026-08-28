<?php
namespace App\Models;

use PDO;

class Category {
    public static function create($userId, $name, $type, $color) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("INSERT INTO categories (user_id, name, type, color) VALUES (?, ?, ?, ?) RETURNING id");
        $stmt->execute([$userId, $name, $type, $color]);
        $row = $stmt->fetch();
        return $row['id'] ?? false;
    }

    public static function getAllByUser($userId) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("SELECT * FROM categories WHERE user_id = ? ORDER BY type, name ASC");
        $stmt->execute([$userId]);
        return $stmt->fetchAll();
    }
}
