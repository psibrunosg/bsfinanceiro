<!DOCTYPE html>
<html lang="pt-BR" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title><?= $title ?? 'BS Financeiro' ?></title>
    
    <!-- Importacao de Fonte Estilo Apple (Inter) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Importacao do CSS Legado (Puro) -->
    <script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
    <link rel="stylesheet" href="/css/globals.css">
    <link rel="stylesheet" href="/css/components.css">
    <link rel="stylesheet" href="/css/dialog.css">
    <link rel="stylesheet" href="/css/auth.css">
    <link rel="stylesheet" href="/css/card.css">
    <link rel="stylesheet" href="/css/management.css">
    <link rel="stylesheet" href="/css/reports.css">
    <link rel="stylesheet" href="/css/transaction.css">
    <link rel="stylesheet" href="/css/onboarding.css">
</head>
<body>
    <?= $content ?? '' ?>
    
    <!-- Script do Chart.js para o painel de analise -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <!-- Script principal para interacoes JS Vanilla -->
    <script src="/js/app.js"></script>
</body>
</html>
