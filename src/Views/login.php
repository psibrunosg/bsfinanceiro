<div class="auth-page">
    <div class="auth-panel">
        <div class="auth-brand">
            <strong>BS Financeiro</strong>
        </div>

        <div>
            <h1 style="margin: 0 0 10px; font-size: 1.8rem;">Entrar</h1>
            <p style="margin: 0 0 25px; opacity: 0.7;">Gerencie suas finanças em um só lugar.</p>
        </div>

        <?php if (isset($error)): ?>
            <div class="form-error"><?= htmlspecialchars($error) ?></div>
        <?php endif; ?>

        <form method="POST" action="/login" class="auth-form">
            <label for="email">E-mail</label>
            <input type="email" id="email" name="email" required autofocus placeholder="seu@email.com">

            <div style="display: flex; justify-content: space-between; align-items: baseline;">
                <label for="password" style="margin:0;">Senha</label>
                <a href="/recover" style="font-size: 0.85rem; color: var(--muted); text-decoration: none;">Esqueceu?</a>
            </div>
            <input type="password" id="password" name="password" required>

            <div class="cf-turnstile" data-sitekey="1x00000000000000000000AA" data-theme="dark" style="margin-top: 15px; margin-bottom: 15px;"></div>

            <button type="submit">Entrar no painel</button>
        </form>

        <p class="auth-switch" style="margin-top: 20px;">
            Ainda não tem conta? <a href="/register">Cadastre-se</a>
        </p>
    </div>

    <div class="auth-aside">
        <blockquote>Controle de verdade é ver para onde o dinheiro está indo.</blockquote>
        <p>BS Financeiro &copy; <?= date('Y') ?></p>
    </div>
</div>
