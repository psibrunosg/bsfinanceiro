<?php
namespace App\Models;

use PDO;

class User {
    public static function create($email, $password) {
        $pdo = Database::getInstance()->getConnection();
        
        // Verifica se o email ja existe
        $stmt = $pdo->prepare("SELECT id FROM users WHERE email = :email");
        $stmt->execute(['email' => $email]);
        if ($stmt->fetch()) {
            return false; // Email ja existe
        }

        $hash = password_hash($password, PASSWORD_DEFAULT);
        
        $stmt = $pdo->prepare("INSERT INTO users (email, password_hash) VALUES (:email, :hash) RETURNING id");
        $stmt->execute(['email' => $email, 'hash' => $hash]);
        $row = $stmt->fetch();
        
        return $row['id'] ?? false;
    }

    public static function findByEmail($email) {
        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("SELECT * FROM users WHERE email = :email");
        $stmt->execute(['email' => $email]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public static function updatePassword($userId, $password) {
        $pdo = Database::getInstance()->getConnection();
        $hash = password_hash($password, PASSWORD_DEFAULT);
        $stmt = $pdo->prepare("UPDATE users SET password_hash = :hash WHERE id = :id");
        return $stmt->execute(['hash' => $hash, 'id' => $userId]);
    }
}
