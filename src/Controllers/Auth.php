<?php
namespace App\Controllers;

use App\Models\Database;
use PDO;

class Auth {
    public static function startSession() {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
    }

    public static function login($email, $password) {
        self::startSession();
        $pdo = Database::getInstance()->getConnection();
        
        $stmt = $pdo->prepare("SELECT id, password_hash FROM users WHERE email = :email");
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch();

        if ($user && password_verify($password, $user['password_hash'])) {
            $_SESSION['user_id'] = $user['id'];
            return true;
        }
        return false;
    }

    public static function logout() {
        self::startSession();
        session_destroy();
        unset($_SESSION['user_id']);
    }

    public static function check() {
        self::startSession();
        return isset($_SESSION['user_id']);
    }

    public static function requireLogin() {
        if (!self::check()) {
            header('Location: /login');
            exit;
        }
    }
    
    public static function userId() {
        self::startSession();
        return $_SESSION['user_id'] ?? null;
    }
}
