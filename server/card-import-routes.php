<?php
// Included inside api.php's authenticated routing block. No uploaded document is retained.
function cardImportResponse(array $body, int $code = 200): void {
    http_response_code($code); echo json_encode($body, JSON_UNESCAPED_UNICODE); exit;
}
function cardImportDate(string $value): bool {
    $date = DateTimeImmutable::createFromFormat('!Y-m-d', $value);
    return $date && $date->format('Y-m-d') === $value;
}
function cardImportInstallmentCents(int $total, int $count, int $number): int {
    if ($count<1 || $number<1 || $number>$count || intdiv($total,$count)<1) throw new InvalidArgumentException('Total incompatível com a parcela.');
    return $number === $count ? $total - intdiv($total,$count)*($count-1) : intdiv($total,$count);
}
function handleCardImportRoutes(PDO $db, string $uri, string $method): bool {
    if ($uri !== '/card-statement-imports' && !preg_match('#^/card-statement-imports/([a-f0-9-]{36})/(apply|discard)$#', $uri, $match)) return false;
    $user = requireSessionUser($db);
    if ($uri === '/card-statement-imports' && $method === 'GET') {
        $workspace = (string)($_GET['workspace_id'] ?? '');
        requireWorkspaceAccess($db, $user['id'], $workspace);
        $stmt = $db->prepare('SELECT * FROM credit_card_statement_imports WHERE workspace_id = ? ORDER BY created_at DESC LIMIT 50');
        $stmt->execute([$workspace]); $jobs = $stmt->fetchAll();
        foreach ($jobs as &$job) $job['items'] = json_decode($job['items'], true);
        cardImportResponse($jobs);
    }
    if ($method !== 'POST') cardImportResponse(['error' => 'Método não permitido.'], 405);
    if ($uri === '/card-statement-imports') {
        $cardId = (string)($_POST['credit_card_id'] ?? '');
        $workspace = requireResourceWorkspaceAccess($db, $user['id'], 'credit_cards', $cardId);
        $file = $_FILES['statement'] ?? null;
        if (!$file || $file['error'] !== UPLOAD_ERR_OK || !is_uploaded_file($file['tmp_name'])) cardImportResponse(['error' => 'Selecione um arquivo válido.'], 400);
        $size = filesize($file['tmp_name']);
        if (!$size || $size > 5242880) cardImportResponse(['error' => 'O arquivo deve ter no máximo 5 MB.'], 400);
        $sha = hash_file('sha256', $file['tmp_name']);
        $name = basename(str_replace('\\', '/', $file['name']));
        if (strlen($name) > 120 || preg_match('/[\x00-\x1f]/', $name)) cardImportResponse(['error' => 'Nome de arquivo inválido.'], 400);
        $contentType = file_get_contents($file['tmp_name'], false, null, 0, 5) === '%PDF-' ? 'application/pdf' : 'text/plain';
        // timeout and fixed argv prevent shell injection and bound hostile PDF processing.
        $process = proc_open(['timeout', '30', 'node', '--max-old-space-size=256', __DIR__.'/card-statement-worker.mjs', $file['tmp_name'], $contentType], [1=>['pipe','w'], 2=>['file','/dev/null','a']], $pipes);
        if (!is_resource($process)) cardImportResponse(['error' => 'Processador indisponível.'], 503);
        $output = stream_get_contents($pipes[1], 1048576); fclose($pipes[1]); $exitCode = proc_close($process);
        $parsed = json_decode($output, true);
        if (!is_array($parsed)) $parsed = ['error'=>'processing_failed'];
        if ($exitCode !== 0 && !isset($parsed['error'])) $parsed = ['error'=>'processing_failed'];
        $db->beginTransaction();
        try {
            $db->prepare('SELECT id FROM credit_cards WHERE id = ? FOR UPDATE')->execute([$cardId]);
            $existing = $db->prepare('SELECT * FROM credit_card_statement_imports WHERE credit_card_id = ? AND sha256 = ? FOR UPDATE');
            $existing->execute([$cardId, $sha]); $job = $existing->fetch();
            if ($job && $job['status'] !== 'failed') { $db->commit(); $job['items']=json_decode($job['items'],true); cardImportResponse(['success'=>true,'duplicate'=>true,'import'=>$job]); }
            $status = isset($parsed['error']) ? 'failed' : 'pending_review';
            $values = [$workspace,$user['id'],$cardId,$name,$contentType,$size,$sha,$status,$parsed['error']??null,$parsed['closingDate']??null,$parsed['dueDate']??null,$parsed['declaredTotalCents']??null,json_encode($parsed['items']??[])];
            if ($job) {
                $query='UPDATE credit_card_statement_imports SET workspace_id=?,owner_id=?,credit_card_id=?,file_name=?,content_type=?,size_bytes=?,sha256=?,status=?,error_code=?,closing_date=?,due_date=?,declared_total_cents=?,items=? WHERE id=? RETURNING *'; $values[]=$job['id'];
            } else $query='INSERT INTO credit_card_statement_imports(workspace_id,owner_id,credit_card_id,file_name,content_type,size_bytes,sha256,status,error_code,closing_date,due_date,declared_total_cents,items) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?) RETURNING *';
            $stmt=$db->prepare($query); $stmt->execute($values); $job=$stmt->fetch(); $db->commit(); $job['items']=json_decode($job['items'],true);
            cardImportResponse(['success'=>true,'import'=>$job,'status'=>$status,'error'=>$parsed['error']??null]);
        } catch (Throwable $error) { if ($db->inTransaction()) $db->rollBack(); throw $error; }
    }
    $payload=json_decode(file_get_contents('php://input'),true)??[];
    $db->beginTransaction();
    try {
        $stmt=$db->prepare('SELECT * FROM credit_card_statement_imports WHERE id=? FOR UPDATE'); $stmt->execute([$match[1]]); $job=$stmt->fetch();
        if (!$job) { $db->rollBack(); cardImportResponse(['error'=>'Importação não encontrada.'],404); }
        requireWorkspaceAccess($db,$user['id'],$job['workspace_id']);
        if ($match[2]==='discard') {
            if (!in_array($job['status'],['pending_review','discarded'],true)) throw new InvalidArgumentException('Importação não pode ser descartada.');
            $db->prepare("UPDATE credit_card_statement_imports SET status='discarded',completed_at=now() WHERE id=?")->execute([$job['id']]);
            $db->commit(); cardImportResponse(['success'=>true]);
        }
        $items=$payload['items']??[]; $original=json_decode($job['items'],true); $hash=hash('sha256',json_encode($items));
        if ($job['status']==='imported') {
            if (!hash_equals($job['applied_hash']??'', $hash)) throw new InvalidArgumentException('Importação já aplicada com outra revisão.');
            $db->commit(); cardImportResponse(['success'=>true]);
        }
        if ($job['status']!=='pending_review' || count($items)!==count($original) || !count($items)) throw new InvalidArgumentException('Revisão incompleta.');
        $stmt=$db->prepare('SELECT * FROM credit_cards WHERE id=? AND workspace_id=? FOR UPDATE'); $stmt->execute([$job['credit_card_id'],$job['workspace_id']]); $card=$stmt->fetch();
        if (!$card || !$card['account_id']) throw new InvalidArgumentException('Cartão indisponível.');
        $sum=0; $seen=[];
        foreach ($items as $index=>$item) {
            $source=$original[$index];
            foreach (['ordinal','purchasedOn','description','installmentAmountCents','installmentNumber','installmentCount','sourceFingerprint'] as $key) if (($item[$key]??null)!==$source[$key]) throw new InvalidArgumentException('Dados extraídos foram alterados.');
            $total=$item['totalAmountCents']??null;
            if (!is_int($total) || $total<1 || $total>999999999999 || ($source['totalAmountCents']!==null && $total!==$source['totalAmountCents'])) throw new InvalidArgumentException('Confirme o valor total de cada compra.');
            $n=$item['installmentCount']; $current=$item['installmentNumber'];
            if (cardImportInstallmentCents($total,$n,$current) !== $item['installmentAmountCents']) throw new InvalidArgumentException('Total incompatível com a parcela.');
            $sum+=$item['installmentAmountCents'];
            $fingerprint=implode('|',[$item['purchasedOn'],$item['description'],$total,$n]);
            if (isset($seen[$fingerprint])) throw new InvalidArgumentException('Compra duplicada na fatura.'); $seen[$fingerprint]=true;
            $stmt=$db->prepare('SELECT id FROM credit_card_purchases WHERE credit_card_id=? AND purchased_on=? AND upper(trim(description))=upper(trim(?)) AND total_amount=? AND installment_count=?');
            $stmt->execute([$card['id'],$item['purchasedOn'],$item['description'],$total/100,$n]);
            if ($stmt->fetchColumn()) throw new InvalidArgumentException('Uma compra desta fatura já está cadastrada.');
            $stmt=$db->prepare('INSERT INTO credit_card_purchases(workspace_id,owner_id,credit_card_id,description,total_amount,purchased_on,installment_count,notes) VALUES(?,?,?,?,?,?,?,?) RETURNING id');
            $stmt->execute([$job['workspace_id'],$card['owner_id'],$card['id'],$item['description'],$total/100,$item['purchasedOn'],$n,'Importação revisada '.$job['id']]); $purchase=$stmt->fetchColumn();
            // Existing statement installment belongs to its closing month; earlier installments are historical.
            $base=new DateTimeImmutable(substr($job['closing_date'],0,7).'-01');
            for ($number=$current;$number<=$n;$number++) {
                $month=$base->modify('+'.($number-$current).' months'); $year=(int)$month->format('Y'); $m=(int)$month->format('m'); $days=(int)$month->format('t');
                $closing=$month->setDate($year,$m,min($days,(int)$card['closing_day']));
                $due=$month->setDate($year,$m,min($days,(int)$card['due_day']));
                if ($due <= $closing) { $due=$month->modify('+1 month'); $due=$due->setDate((int)$due->format('Y'),(int)$due->format('m'),min((int)$due->format('t'),(int)$card['due_day'])); }
                if ($number===$current) { $closing=new DateTimeImmutable($job['closing_date']); $due=new DateTimeImmutable($job['due_date']); }
                $stmt=$db->prepare('SELECT id,status FROM credit_card_invoices WHERE credit_card_id=? AND month=? AND year=? FOR UPDATE'); $stmt->execute([$card['id'],$m,$year]); $invoice=$stmt->fetch();
                if ($invoice && $invoice['status']==='paid') throw new InvalidArgumentException('Fatura paga não pode receber novas parcelas.');
                if (!$invoice) { $stmt=$db->prepare("INSERT INTO credit_card_invoices(account_id,workspace_id,owner_id,credit_card_id,month,year,status,total_amount,closing_date,due_date) VALUES(?,?,?,?,?,?,'open',0,?,?) RETURNING id"); $stmt->execute([$card['account_id'],$job['workspace_id'],$card['owner_id'],$card['id'],$m,$year,$closing->format('Y-m-d'),$due->format('Y-m-d')]); $invoice=['id'=>$stmt->fetchColumn()]; }
                $cents=cardImportInstallmentCents($total,$n,$number);
                $stmt=$db->prepare('INSERT INTO credit_card_installments(workspace_id,owner_id,credit_card_id,purchase_id,invoice_id,installment_number,amount,competence_date) VALUES(?,?,?,?,?,?,?,?)'); $stmt->execute([$job['workspace_id'],$card['owner_id'],$card['id'],$purchase,$invoice['id'],$number,$cents/100,$month->format('Y-m-d')]);
                $stmt=$db->prepare("INSERT INTO transactions(workspace_id,owner_id,account_id,type,description,amount,competence_date,due_date,status,installment_current,installment_total,invoice_id) VALUES(?,?,?,'expense',?,?,?,?,'pending',?,?,?)"); $stmt->execute([$job['workspace_id'],$card['owner_id'],$card['account_id'],$item['description']." ($number/$n)",$cents/100,$month->format('Y-m-d'),$due->format('Y-m-d'),$number,$n,$invoice['id']]);
                $db->prepare('UPDATE credit_card_invoices SET total_amount=(SELECT coalesce(sum(amount),0) FROM credit_card_installments WHERE invoice_id=?) WHERE id=?')->execute([$invoice['id'],$invoice['id']]);
            }
        }
        if ($sum!==(int)$job['declared_total_cents']) throw new InvalidArgumentException('A soma das parcelas difere do total declarado da fatura.');
        $db->prepare("UPDATE credit_card_statement_imports SET status='imported',applied_hash=?,completed_at=now() WHERE id=?")->execute([$hash,$job['id']]); $db->commit(); cardImportResponse(['success'=>true]);
    } catch (InvalidArgumentException $error) { if($db->inTransaction())$db->rollBack(); cardImportResponse(['error'=>$error->getMessage()],409); }
    catch (Throwable $error) { if($db->inTransaction())$db->rollBack(); throw $error; }
    return true;
}
