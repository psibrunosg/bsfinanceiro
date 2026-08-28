<div class="auth-page">
    <div class="auth-panel">
        <div class="auth-brand">
            <strong>BS Financeiro</strong>
        </div>

        <div>
            <h1 style="margin: 0 0 10px; font-size: 1.8rem;">Recuperar Senha</h1>
            <p style="margin: 0 0 25px; opacity: 0.7;">Enviaremos um link para vocÃª criar uma nova senha.</p>
        </div>

        <?php if (isset($error)): ?>
            <div class="form-error"><?= htmlspecialchars($error) ?></div>
        <?php endif; ?>
        
        <?php if (isset($success)): ?>
            <div class="form-error" style="background: rgba(48,209,88,0.15); border-left: 4px solid var(--positive); color: #fff; padding: 14px; border-radius: 12px; margin-bottom: 20px;">
                <?= htmlspecialchars($success) ?>
            </div>
        <?php endif; ?>

        <form method="POST" action="/recover" class="auth-form">
            <label for="email">Seu e-mail cadastrado</label>
            <input type="email" id="email" name="email" required autofocus placeholder="seu@email.com">

            <div class="cf-turnstile" data-sitekey="1x00000000000000000000AA" data-theme="dark" style="margin-top: 15px; margin-bottom: 15px;"></div>

            <button type="submit">Enviar link</button>
        </form>

        <p class="auth-switch" style="margin-top: 20px;">
            Lembrou a senha? <a href="/login">Voltar ao Login</a>
        </p>
    </div>

    <div class="auth-aside">
        <blockquote>Controle de verdade Ã© ver para onde o dinheiro estÃ¡ indo.</blockquote>
        <p>BS Financeiro &copy; <?= date('Y') ?></p>
    </div>
</div>
