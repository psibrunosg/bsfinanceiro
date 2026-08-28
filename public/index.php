<?php
spl_autoload_register(function ($class) {
    $prefix = 'App\\';
    $base_dir = __DIR__ . '/../src/';
    $len = strlen($prefix);
    if (strncmp($prefix, $class, $len) !== 0) return;
    $relative_class = substr($class, $len);
    $file = $base_dir . str_replace('\\', '/', $relative_class) . '.php';
    if (file_exists($file)) require $file;
});

use App\Controllers\Router;
use App\Controllers\AuthController;
use App\Controllers\DashboardController;

ini_set('display_errors', 1);
error_reporting(E_ALL);

$router = new Router();

// Rotas de Autenticacao
$router->get('/login', [AuthController::class, 'showLogin']);
$router->post('/login', [AuthController::class, 'processLogin']);
$router->get('/register', [AuthController::class, 'showRegister']);
$router->post('/register', [AuthController::class, 'processRegister']);
$router->get('/recover', [AuthController::class, 'showRecover']);
$router->post('/recover', [AuthController::class, 'processRecover']);
$router->get('/reset', [AuthController::class, 'showReset']);
$router->post('/reset', [AuthController::class, 'processReset']);
$router->get('/logout', [AuthController::class, 'logout']);

// Rotas Protegidas (Dashboard)
$router->get('/', [DashboardController::class, 'index']);
$router->get('/logout', [\App\Controllers\AuthController::class, 'logout']);

$router->post('/transactions/create', [\App\Controllers\TransactionController::class, 'create']);
$router->post('/transactions/pay-pending', [\App\Controllers\TransactionController::class, 'payPending']);

// Processa a rota atual
$router->resolve();
