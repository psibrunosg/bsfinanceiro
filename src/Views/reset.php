<div class="auth-page">
    <div class="auth-panel">
        <div class="auth-brand">
            <strong>BS Financeiro</strong>
        </div>

        <div>
            <h1 style="margin: 0 0 10px; font-size: 1.8rem;">Nova Senha</h1>
            <p style="margin: 0 0 25px; opacity: 0.7;">Digite sua nova senha abaixo.</p>
        </div>

        <?php if (isset($error)): ?>
            <div class="form-error"><?= htmlspecialchars($error) ?></div>
        <?php endif; ?>

        <form method="POST" action="/reset" class="auth-form">
            <input type="hidden" name="token" value="<?= htmlspecialchars($token ?? '') ?>">
            
            <label for="password">Nova Senha</label>
            <input type="password" id="password" name="password" required minlength="6" autofocus placeholder="No mÃ­nimo 6 caracteres">

            <button type="submit">Atualizar Senha</button>
        </form>
    </div>
</div>
