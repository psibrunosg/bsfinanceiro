<?php
namespace App\Controllers;

use App\Models\Database;
use App\Controllers\Auth;

class AuthController extends Controller {
    
    public function showRegister() {
        if (Auth::check()) {
            header('Location: /');
            exit;
        }
        $this->render('register', ['title' => 'Criar Conta - BS Financeiro']);
    }

    public function processRegister() {
        $email = $_POST['email'] ?? '';
        $password = $_POST['password'] ?? '';

        if (empty($email) || empty($password) || strlen($password) < 6) {
            $this->render('register', [
                'title' => 'Criar Conta - BS Financeiro',
                'error' => 'Preencha todos os campos corretamente. Senha minima 6 caracteres.'
            ]);
            return;
        }

        if (!$this->verifyTurnstile()) {
            $this->render('register', [
                'title' => 'Criar Conta - BS Financeiro',
                'error' => 'Falha na verificacao de seguranca (Captcha).'
            ]);
            return;
        }

        $userId = \App\Models\User::create($email, $password);
        if ($userId) {
            // Loga automaticamente
            if (Auth::login($email, $password)) {
                header('Location: /');
                exit;
            }
        }

        $this->render('register', [
            'title' => 'Criar Conta - BS Financeiro',
            'error' => 'Este e-mail ja esta em uso.'
        ]);
    }

    public function showLogin() {
        if (Auth::check()) {
            header('Location: /');
            exit;
        }
        $this->render('login', ['title' => 'Entrar - BS Financeiro']);
    }

    public function processLogin() {
        $email = $_POST['email'] ?? '';
        $password = $_POST['password'] ?? '';

        if (!$this->verifyTurnstile()) {
            $this->render('login', [
                'title' => 'Entrar - BS Financeiro',
                'error' => 'Falha na verificacao de seguranca (Captcha).'
            ]);
            return;
        }

        if (Auth::login($email, $password)) {
            header('Location: /');
            exit;
        }

        $this->render('login', [
            'title' => 'Entrar - BS Financeiro',
            'error' => 'E-mail ou senha invalidos.'
        ]);
    }
    
    public function logout() {
        Auth::logout();
        header('Location: /login');
        exit;
    }

    public function showRecover() {
        $this->render('recover', ['title' => 'Recuperar Senha - BS Financeiro']);
    }

    public function processRecover() {
        $email = $_POST['email'] ?? '';
        
        if (!$this->verifyTurnstile()) {
            $this->render('recover', ['title' => 'Recuperar Senha', 'error' => 'Falha na verificacao de seguranca (Captcha).']);
            return;
        }

        $user = \App\Models\User::findByEmail($email);
        if ($user) {
            $token = bin2hex(random_bytes(32));
            $pdo = Database::getInstance()->getConnection();
            $pdo->prepare("INSERT INTO password_resets (user_id, token, expires_at) VALUES (?, ?, NOW() + INTERVAL '1 hour')")
                ->execute([$user['id'], $token]);
            
            $link = "http://" . $_SERVER['HTTP_HOST'] . "/reset?token=" . $token;
            
            // Simula envio via Resend (Se no localhost, so joga no error_log)
            $resendKey = getenv('RESEND_API_KEY');
            if (empty($resendKey)) {
                error_log("[RECOVERY LINK] Link de recuperacao gerado para $email: $link");
                $message = "Modo Local: Verifique o console (error_log) para ver o link de recuperacao.";
            } else {
                // Aqui iria a chamada real ao Resend (CURL)
                $message = "Se o e-mail existir, um link de recuperacao foi enviado.";
            }

            $this->render('recover', ['title' => 'Recuperar Senha', 'success' => $message]);
            return;
        }

        $this->render('recover', ['title' => 'Recuperar Senha', 'success' => 'Se o e-mail existir, um link de recuperacao foi enviado.']);
    }

    public function showReset() {
        $token = $_GET['token'] ?? '';
        $this->render('reset', ['title' => 'Redefinir Senha - BS Financeiro', 'token' => $token]);
    }

    public function processReset() {
        $token = $_POST['token'] ?? '';
        $password = $_POST['password'] ?? '';
        
        if (strlen($password) < 6) {
            $this->render('reset', ['title' => 'Redefinir Senha', 'token' => $token, 'error' => 'Senha muito curta (min 6 caracteres).']);
            return;
        }

        $pdo = Database::getInstance()->getConnection();
        $stmt = $pdo->prepare("SELECT user_id FROM password_resets WHERE token = ? AND expires_at > NOW()");
        $stmt->execute([$token]);
        $reset = $stmt->fetch();

        if (!$reset) {
            $this->render('reset', ['title' => 'Redefinir Senha', 'token' => $token, 'error' => 'Token invalido ou expirado.']);
            return;
        }

        \App\Models\User::updatePassword($reset['user_id'], $password);
        
        // Invalida o token apos o uso
        $pdo->prepare("DELETE FROM password_resets WHERE token = ?")->execute([$token]);

        $this->render('login', ['title' => 'Entrar', 'success' => 'Senha atualizada! Faça login com a nova senha.']);
    }

    private function verifyTurnstile() {
        $token = $_POST['cf-turnstile-response'] ?? '';
        if (empty($token)) {
            error_log("Turnstile falhou: Token vazio enviado pelo front-end.");
            return false;
        }

        $secret = '1x0000000000000000000000000000000AA'; // Dummy secret for testing

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'https://challenges.cloudflare.com/turnstile/v0/siteverify');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
            'secret' => $secret,
            'response' => $token
        ]));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        // Fix para problemas de certificado SSL no PHP/Windows local
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); 
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
        
        $response = curl_exec($ch);
        if ($response === false) {
            error_log("Turnstile CURL Error: " . curl_error($ch));
            curl_close($ch);
            return false;
        }
        curl_close($ch);

        $result = json_decode($response, true);
        if (!isset($result['success']) || $result['success'] !== true) {
            error_log("Turnstile rejeitou: " . print_r($result, true));
            return false;
        }
        
        return true;
    }
}
