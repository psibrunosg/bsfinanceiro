<?php
$host = 'localhost';
$port = '55432';
$defaultDb = 'postgres'; // Conecta no banco padrao para criar o nosso
$targetDb = 'bsfinanceiro';
$user = 'postgres';
$pass = 'postgres';

try {
    echo "Tentando conectar ao banco padrao ($defaultDb) para verificar se o banco $targetDb existe...\n";
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$defaultDb", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $pdo->query("SELECT 1 FROM pg_database WHERE datname = '$targetDb'");
    if (!$stmt->fetch()) {
        echo "Banco $targetDb nao existe. Criando...\n";
        $pdo->exec("CREATE DATABASE $targetDb");
        echo "Banco $targetDb criado com sucesso.\n";
    } else {
        echo "Banco $targetDb ja existe.\n";
    }
} catch (PDOException $e) {
    die("Erro ao conectar no banco padrao (sua senha de postgres local pode ser diferente): " . $e->getMessage() . "\n");
}

try {
    echo "Conectando ao banco $targetDb para aplicar as tabelas...\n";
    $pdoApp = new PDO("pgsql:host=$host;port=$port;dbname=$targetDb", $user, $pass);
    $pdoApp->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $sql = file_get_contents(__DIR__ . '/schema.sql');
    if (!$sql) {
        die("Nao foi possivel ler o arquivo schema.sql\n");
    }

    $pdoApp->exec($sql);
    echo "Migracoes aplicadas com sucesso!\n";

} catch (PDOException $e) {
    die("Erro ao rodar as migracoes: " . $e->getMessage() . "\n");
}
