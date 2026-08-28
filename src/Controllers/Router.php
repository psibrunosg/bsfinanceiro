<?php
namespace App\Controllers;

class Router {
    private $routes = [];

    public function get($path, $callback) {
        $this->routes['GET'][$path] = $callback;
    }

    public function post($path, $callback) {
        $this->routes['POST'][$path] = $callback;
    }

    public function resolve() {
        $method = $_SERVER['REQUEST_METHOD'];
        $path = $_SERVER['REQUEST_URI'];
        
        // Remove query strings do caminho
        if (strpos($path, '?') !== false) {
            $path = explode('?', $path)[0];
        }

        // Se estiver rodando no PHP built-in server ou Apache em pasta raiz, o path ja vem certinho
        // Porem, podemos precisar limpar a barra no final
        if ($path !== '/' && substr($path, -1) === '/') {
            $path = rtrim($path, '/');
        }

        $callback = $this->routes[$method][$path] ?? false;

        if ($callback === false) {
            http_response_code(404);
            echo "<h1>404 - Pagina nao encontrada</h1>";
            exit;
        }

        if (is_array($callback)) {
            // Instancia o controller se for array [Controller::class, 'metodo']
            $controller = new $callback[0]();
            $callback[0] = $controller;
        }

        return call_user_func($callback);
    }
}
