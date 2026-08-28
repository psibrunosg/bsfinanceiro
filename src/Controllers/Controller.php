<?php
namespace App\Controllers;

class Controller {
    protected function render($view, $data = []) {
        // Extrai variaveis do array para variaveis locais (ex: ['name' => 'Bruno'] vira $name = 'Bruno')
        extract($data);

        // Captura o conteudo da view especifica
        ob_start();
        $viewPath = __DIR__ . '/../Views/' . $view . '.php';
        if (file_exists($viewPath)) {
            require $viewPath;
        } else {
            echo "Erro: View '$view' nao encontrada.";
        }
        $content = ob_get_clean();

        // Insere o conteudo capturado dentro do layout principal
        require __DIR__ . '/../Views/layout.php';
    }
}
