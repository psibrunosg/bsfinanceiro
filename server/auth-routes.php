<?php
// Included inside api.php's try block after request parsing. Only authenticated VPS routes.
function authTextLength(string $value): int {
    $length = preg_match_all('/./us', $value);
    return $length === false ? 0 : $length;
}
if ($uri === '/onboarding' && $method === 'POST') {
    $user = requireSessionUser($db);
    $name = is_string($body['display_name'] ?? null) ? trim($body['display_name']) : '';
    $card = is_string($body['card_name'] ?? null) ? trim($body['card_name']) : '';
    $income = $body['monthly_income'] ?? null;
    $balance = $body['current_balance'] ?? null;
    $closing = $body['closing_day'] ?? null;
    $due = $body['due_day'] ?? null;
    $error = null;
    if (authTextLength($name) < 2 || authTextLength($name) > 60) $error = 'invalid display name';
    elseif (!is_numeric($income) || !is_finite((float)$income) || $income <= 0 || $income > 999999999999.99) $error = 'invalid monthly income';
    elseif (!is_numeric($balance) || !is_finite((float)$balance) || abs((float)$balance) > 999999999999.99) $error = 'invalid current balance';
    elseif (authTextLength($card) < 2 || authTextLength($card) > 60) $error = 'invalid card name';
    elseif (!is_int($closing) || !is_int($due) || $closing < 1 || $closing > 31 || $due < 1 || $due > 31) $error = 'invalid card day';
    if ($error) { http_response_code(400); echo json_encode(['error' => $error]); exit; }
    $db->beginTransaction();
    $db->prepare('SELECT id FROM users WHERE id = ? FOR UPDATE')->execute([$user['id']]);
    $stmt = $db->prepare("SELECT * FROM workspaces WHERE owner_id = ? AND kind = 'personal' ORDER BY created_at LIMIT 1");
    $stmt->execute([$user['id']]); $workspace = $stmt->fetch();
    $stmt = $db->prepare('SELECT onboarding_completed_at FROM profiles WHERE id = ?');
    $stmt->execute([$user['id']]); $completed = $stmt->fetchColumn();
    if (!$completed && $workspace) {
        $legacy = $db->prepare('SELECT EXISTS(SELECT 1 FROM transactions WHERE workspace_id = ?) OR EXISTS(SELECT 1 FROM credit_cards WHERE workspace_id = ?)');
        $legacy->execute([$workspace['id'], $workspace['id']]);
        if ($legacy->fetchColumn()) {
            $db->prepare('INSERT INTO profiles (id,display_name,onboarding_completed_at) VALUES (?,?,NOW()) ON CONFLICT(id) DO UPDATE SET onboarding_completed_at=NOW()')->execute([$user['id'], $name]);
            $completed = true;
        }
    }
    if (!$completed || !$workspace) {
        if (!$workspace) {
            $stmt = $db->prepare("INSERT INTO workspaces (owner_id, name, kind) VALUES (?, 'Finanças Pessoais', 'personal') RETURNING *");
            $stmt->execute([$user['id']]); $workspace = $stmt->fetch();
        }
        $wid = $workspace['id']; $uid = $user['id'];
        $stmt = $db->prepare("SELECT id FROM accounts WHERE workspace_id = ? AND owner_id = ? AND type = 'checking' ORDER BY created_at LIMIT 1");
        $stmt->execute([$wid, $uid]); $account = $stmt->fetchColumn();
        if (!$account) {
            $stmt = $db->prepare("INSERT INTO accounts (workspace_id,owner_id,name,type,initial_balance) VALUES (?,?,'Conta Principal','checking',?) RETURNING id");
            $stmt->execute([$wid,$uid,$balance]); $account = $stmt->fetchColumn();
        } else {
            // Registration creates an empty default account; only initialize it before onboarding completes.
            $db->prepare('UPDATE accounts SET initial_balance = ? WHERE id = ? AND NOT EXISTS (SELECT 1 FROM transactions WHERE account_id = ?)')->execute([$balance,$account,$account]);
        }
        $db->prepare('INSERT INTO workspace_preferences (workspace_id,owner_id,default_cash_account_id) VALUES (?,?,?) ON CONFLICT (workspace_id,owner_id) DO UPDATE SET default_cash_account_id=EXCLUDED.default_cash_account_id')->execute([$wid,$uid,$account]);
        $stmt = $db->prepare("SELECT id FROM categories WHERE workspace_id=? AND owner_id=? AND kind='income' ORDER BY created_at LIMIT 1");
        $stmt->execute([$wid,$uid]); $category=$stmt->fetchColumn();
        if (!$category) { $stmt=$db->prepare("INSERT INTO categories (workspace_id,owner_id,name,kind,color) VALUES (?,?,'Salário','income','#087f5b') RETURNING id"); $stmt->execute([$wid,$uid]); $category=$stmt->fetchColumn(); }
        $db->prepare("INSERT INTO transactions (workspace_id,owner_id,account_id,category_id,type,status,description,amount,competence_date,paid_at) VALUES (?,?,?,?,'income','paid','Renda mensal informada no onboarding',?,(NOW() AT TIME ZONE 'America/Sao_Paulo')::date,(NOW() AT TIME ZONE 'America/Sao_Paulo')::date)")->execute([$wid,$uid,$account,$category,$income]);
        $stmt=$db->prepare("INSERT INTO accounts (workspace_id,owner_id,name,type,initial_balance) VALUES (?,?,?,'credit_card',0) RETURNING id"); $stmt->execute([$wid,$uid,$card]); $cardAccount=$stmt->fetchColumn();
        $db->prepare('INSERT INTO credit_cards (workspace_id,owner_id,account_id,name,credit_limit,closing_day,due_day) VALUES (?,?,?,?,0,?,?)')->execute([$wid,$uid,$cardAccount,$card,$closing,$due]);
        $db->prepare('INSERT INTO profiles (id,display_name,onboarding_completed_at) VALUES (?,?,NOW()) ON CONFLICT(id) DO UPDATE SET display_name=EXCLUDED.display_name,onboarding_completed_at=NOW()')->execute([$uid,$name]);
        $db->prepare('UPDATE users SET display_name=? WHERE id=?')->execute([$name,$uid]);
    }
    $db->commit(); echo json_encode(['success'=>true,'workspace'=>$workspace]); exit;
}
if ($uri === '/invites/accept' && $method === 'POST') {
    $user = requireSessionUser($db);
    $token = is_string($body['token'] ?? null) ? $body['token'] : '';
    if (!preg_match('/^[a-f0-9]{32,128}$/i', $token)) { http_response_code(400); echo json_encode(['error'=>'Convite inválido ou expirado.']); exit; }
    $db->beginTransaction();
    $stmt=$db->prepare('SELECT * FROM workspace_invites WHERE token=? AND expires_at>NOW() FOR UPDATE'); $stmt->execute([$token]); $invite=$stmt->fetch();
    if (!$invite || !in_array($invite['role'], ['admin','editor','viewer'], true)) { $db->rollBack(); http_response_code(404); echo json_encode(['error'=>'Convite inválido ou expirado.']); exit; }
    // Keep a consumed invitation receipt for safe retries by the same account.
    if ($invite['accepted_by'] && $invite['accepted_by'] !== $user['id']) { $db->rollBack(); http_response_code(409); echo json_encode(['error'=>'Este convite já foi utilizado.']); exit; }
    $db->prepare('INSERT INTO workspace_users (workspace_id,user_id,role) VALUES (?,?,?) ON CONFLICT (workspace_id,user_id) DO NOTHING')->execute([$invite['workspace_id'],$user['id'],$invite['role']]);
    $db->prepare('UPDATE workspace_invites SET accepted_by=?, accepted_at=COALESCE(accepted_at,NOW()) WHERE id=?')->execute([$user['id'],$invite['id']]);
    $stmt=$db->prepare('SELECT * FROM workspaces WHERE id=?'); $stmt->execute([$invite['workspace_id']]); $workspace=$stmt->fetch();
    $db->commit(); echo json_encode(['success'=>true,'workspace'=>$workspace]); exit;
}
