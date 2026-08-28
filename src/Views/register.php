<div class="onboarding-page">
    <div class="onboarding-card">
        <div>
            <h1 style="margin: 0 0 10px; font-size: 2rem;">Bem-vindo ao BS Financeiro</h1>
            <p style="margin: 0; opacity: 0.7; line-height: 1.5;">O primeiro passo para o controle da sua vida financeira começa aqui. Crie sua conta para prosseguir.</p>
        </div>

        <?php if (isset($error)): ?>
            <div class="form-error" style="color: var(--destructive); font-weight: bold; padding: 10px; background: rgba(255,0,0,0.1); border-radius: 8px;">
                <?= htmlspecialchars($error) ?>
            </div>
        <?php endif; ?>

        <form method="POST" action="/register" class="onboarding-form">
            <fieldset>
                <label for="email">Seu melhor E-mail</label>
                <input type="email" id="email" name="email" required autofocus placeholder="nome@exemplo.com">
            </fieldset>

            <fieldset>
                <label for="password">Crie uma Senha segura</label>
                <input type="password" id="password" name="password" required minlength="6" placeholder="Pelo menos 6 caracteres">
            </fieldset>

            <div class="cf-turnstile" data-sitekey="1x00000000000000000000AA" data-theme="dark" style="margin-top: 15px; margin-bottom: 15px;"></div>

            <button type="submit" class="onboarding-submit">
                Começar agora
                <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M5 12h14M12 5l7 7-7 7"></path></svg>
            </button>
        </form>

        <p style="text-align: center; margin-top: 10px; font-size: 0.9rem;">
            Já possui uma conta? <a href="/login" style="color: var(--accent); font-weight: bold;">Fazer login</a>
        </p>
    </div>
</div>
