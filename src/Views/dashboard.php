<aside class="app-nav">
    <div class="nav-brand-row">
        <a href="/" class="nav-brand">
            <span>BS</span>
            <strong>Financeiro</strong>
        </a>
    </div>
    <nav>
        <a href="/" class="active">Painel</a>
        <a href="/logout">Sair</a>
    </nav>
</aside>

<!-- O CSS original usa padding no main container para dar espaco pro sidebar -->
<main style="padding: 2rem; margin-left: var(--sidebar); min-height: 100vh;">
    
    <div class="management-header">
        <div>
            <p class="eyebrow muted">Visão Geral</p>
            <h1>Dashboard</h1>
        </div>
        <button class="btn btn-primary" onclick="document.getElementById('modal-transaction').style.display='flex'">+ Nova Movimentação</button>
    </div>

    <!-- Insight de Inteligencia/Comparativo -->
    <?php if (isset($expenseComparePercent)): ?>
        <div style="margin-bottom: 2rem; padding: 1rem 1.5rem; background: <?= $expenseComparePercent > 0 ? 'rgba(239, 68, 68, 0.1)' : 'rgba(16, 185, 129, 0.1)' ?>; border: 1px solid <?= $expenseComparePercent > 0 ? 'var(--destructive)' : 'var(--positive)' ?>; border-radius: 8px; display: flex; align-items: center; gap: 1rem;">
            <div style="font-size: 1.5rem;">
                <?= $expenseComparePercent > 0 ? '⚠️' : '🎉' ?>
            </div>
            <div>
                <strong style="color: <?= $expenseComparePercent > 0 ? 'var(--destructive)' : 'var(--positive)' ?>; display: block; margin-bottom: 0.2rem;">
                    Insight do Mês
                </strong>
                <span style="color: var(--text); font-size: 0.95rem;">
                    <?php if ($expenseComparePercent > 0): ?>
                        Atenção: Seus gastos estão <strong><?= $expenseComparePercent ?>% maiores</strong> que o mês passado neste mesmo período.
                    <?php elseif ($expenseComparePercent < 0): ?>
                        Parabéns! Seus gastos estão <strong><?= abs($expenseComparePercent) ?>% menores</strong> que o mês passado. Continue assim!
                    <?php else: ?>
                        Seus gastos estão iguais aos do mês passado.
                    <?php endif; ?>
                </span>
            </div>
        </div>
    <?php endif; ?>

    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1rem; margin-bottom: 2rem;">
        
        <div class="card" style="padding: 1.5rem; background: var(--surface); border: 1px solid var(--border); border-radius: 12px;">
            <div style="color: var(--muted); font-size: 0.9rem; margin-bottom: 0.5rem;">Saldo Disponível (Livre)</div>
            <div style="font-size: 2rem; font-weight: 700; color: var(--text);">R$ <?= $balance ?></div>
            <?php if ($reservedBalance > 0): ?>
                <div style="font-size: 0.85rem; color: var(--muted); margin-top: 0.5rem;">
                    + R$ <?= $reservedBalance ?> guardado em Metas<br>
                    (Saldo Total: R$ <?= $totalBalance ?>)
                </div>
            <?php endif; ?>
        </div>

        <div class="card" style="padding: 1.5rem; background: var(--surface); border: 1px solid var(--border); border-radius: 12px; border-left: 4px solid var(--positive);">
            <div style="color: var(--muted); font-size: 0.9rem; margin-bottom: 0.5rem;">Receitas (Mês)</div>
            <div style="font-size: 1.5rem; font-weight: 700; color: var(--positive);">+ R$ <?= $income ?></div>
        </div>

        <div class="card" style="padding: 1.5rem; background: var(--surface); border: 1px solid var(--border); border-radius: 12px; border-left: 4px solid var(--destructive);">
            <div style="color: var(--muted); font-size: 0.9rem; margin-bottom: 0.5rem;">Despesas (Mês)</div>
            <div style="font-size: 1.5rem; font-weight: 700; color: var(--destructive);">- R$ <?= $expense ?></div>
        </div>

        <div class="card" style="padding: 1.5rem; background: var(--surface); border: 1px solid var(--border); border-radius: 12px;">
            <div style="color: var(--muted); font-size: 0.9rem; margin-bottom: 0.5rem;">Fluxo de Caixa / Saúde</div>
            <div style="font-size: 1.5rem; font-weight: 700; color: <?= $remaining >= 0 ? 'var(--positive)' : 'var(--destructive)' ?>;">
                R$ <?= $remaining ?> <span style="font-size: 0.9rem; font-weight: normal; color: var(--muted);">(<?= $healthRate ?>%)</span>
            </div>
            <div style="width: 100%; height: 6px; background: var(--surface-2); border-radius: 3px; margin-top: 10px; overflow: hidden;">
                <div style="height: 100%; width: <?= min(max($healthRate, 0), 100) ?>%; background: <?= $healthRate >= 20 ? 'var(--positive)' : ($healthRate > 0 ? 'var(--warning)' : 'var(--destructive)') ?>;"></div>
            </div>
        </div>

    </div>
    
    <div style="display: grid; grid-template-columns: 1fr 350px; gap: 2rem; align-items: start;">
        
        <!-- Coluna Principal: Movimentacoes -->
        <div>
            <!-- Alertas de Pendencias -->
            <?php if (!empty($pendingTransactions)): ?>
            <div style="margin-bottom: 2rem; border: 1px solid var(--warning); border-radius: 12px; background: rgba(245, 158, 11, 0.05); overflow: hidden;">
                <div style="padding: 1rem 1.5rem; background: rgba(245, 158, 11, 0.1); border-bottom: 1px solid var(--warning); font-weight: 600; color: var(--text); display: flex; align-items: center; gap: 0.5rem;">
                    ⏰ Lembrete de Vencimentos (Contas a Pagar/Receber)
                </div>
                <div style="padding: 1rem;">
                    <?php foreach ($pendingTransactions as $p): ?>
                        <div style="display: flex; justify-content: space-between; align-items: center; padding: 0.5rem 0; border-bottom: 1px dashed var(--border);">
                            <div>
                                <strong style="display: block; color: var(--text);"><?= htmlspecialchars($p['description']) ?> <?= $p['installment_info'] ? "({$p['installment_info']})" : '' ?></strong>
                                <span style="font-size: 0.85rem; color: var(--muted);">Vencimento: <?= date('d/m/Y', strtotime($p['date'])) ?></span>
                            </div>
                            <div style="display: flex; align-items: center; gap: 1rem;">
                                <strong style="color: <?= $p['type'] === 'income' ? 'var(--positive)' : 'var(--destructive)' ?>;">
                                    <?= $p['type'] === 'income' ? '+' : '-' ?> R$ <?= number_format($p['amount'], 2, ',', '.') ?>
                                </strong>
                                <form method="POST" action="/transactions/pay-pending" style="margin: 0;">
                                    <input type="hidden" name="transaction_id" value="<?= $p['id'] ?>">
                                    <button type="submit" class="btn btn-primary" style="padding: 0.3rem 0.8rem; font-size: 0.8rem; border-radius: 4px;">Dar Baixa</button>
                                </form>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>
            <?php endif; ?>

            <h2 style="font-size: 1.2rem; margin-bottom: 1rem;">Movimentações Recentes</h2>
            <div class="table-container" style="background: var(--surface); border: 1px solid var(--border); border-radius: 12px; overflow: hidden;">
                <?php if (empty($transactions)): ?>
                    <p style="padding: 2rem; color: var(--muted); text-align: center;">Nenhuma movimentação lançada.</p>
                <?php else: ?>
                    <table style="width: 100%; border-collapse: collapse; text-align: left;">
                        <thead style="background: var(--surface-2); border-bottom: 1px solid var(--border);">
                            <tr>
                                <th style="padding: 1rem; color: var(--muted); font-weight: 500;">Data</th>
                                <th style="padding: 1rem; color: var(--muted); font-weight: 500;">Descrição</th>
                                <th style="padding: 1rem; color: var(--muted); font-weight: 500;">Conta</th>
                                <th style="padding: 1rem; color: var(--muted); font-weight: 500; text-align: right;">Valor</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($transactions as $t): ?>
                                <tr style="border-bottom: 1px solid var(--border);">
                                    <td style="padding: 1rem; color: var(--muted);"><?= date('d/m', strtotime($t['date'])) ?></td>
                                    <td style="padding: 1rem; font-weight: 500;"><?= htmlspecialchars($t['description']) ?></td>
                                    <td style="padding: 1rem;">
                                        <span style="background: var(--surface-2); padding: 0.25rem 0.5rem; border-radius: 6px; font-size: 0.85rem; border: 1px solid var(--border);">
                                            <?= htmlspecialchars($t['account_name'] ?? 'Carteira') ?>
                                        </span>
                                    </td>
                                    <td style="padding: 1rem; text-align: right; font-weight: 600; color: <?= $t['type'] === 'income' ? 'var(--positive)' : 'var(--text)' ?>;">
                                        <?= $t['type'] === 'income' ? '+' : '-' ?> R$ <?= number_format($t['amount'], 2, ',', '.') ?>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php endif; ?>
            </div>
        </div>

        <!-- Coluna Lateral: Auxilio Tomada de Decisao -->
        <div>
            <!-- Bloco de Metas (Cofrinhos) -->
            <?php if (!empty($goals)): ?>
                <h2 style="font-size: 1.2rem; margin-bottom: 1rem;">Meus Objetivos (Cofrinhos)</h2>
                <div class="card" style="background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 1.5rem; margin-bottom: 2rem;">
                    <?php foreach ($goals as $goal): ?>
                        <div style="margin-bottom: 1rem;">
                            <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.9rem;">
                                <strong style="color: var(--text);"><?= htmlspecialchars($goal['name']) ?></strong>
                                <span style="color: var(--text);">R$ <?= number_format($goal['current_amount'], 2, ',', '.') ?> / R$ <?= number_format($goal['target_amount'], 2, ',', '.') ?></span>
                            </div>
                            <?php 
                                $pct = min(($goal['current_amount'] / $goal['target_amount']) * 100, 100);
                            ?>
                            <div style="width: 100%; height: 6px; background: var(--surface-2); border-radius: 3px; margin-top: 5px; overflow: hidden;">
                                <div style="height: 100%; width: <?= $pct ?>%; background: <?= $goal['color'] ?>;"></div>
                            </div>
                            <?php if ($goal['deadline']): ?>
                                <div style="font-size: 0.75rem; color: var(--muted); margin-top: 3px;">Prazo: <?= date('d/m/Y', strtotime($goal['deadline'])) ?></div>
                            <?php endif; ?>
                        </div>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>

            <h2 style="font-size: 1.2rem; margin-bottom: 1rem;">Onde você está gastando?</h2>
            <div class="card" style="background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 1.5rem;">
                
                <?php if (empty($expensesByCategory)): ?>
                    <p style="color: var(--muted); text-align: center; font-size: 0.9rem;">Lance suas despesas para ver a análise.</p>
                <?php else: ?>
                    <div style="position: relative; height: 250px;">
                        <canvas id="expensesChart"></canvas>
                    </div>
                    <div style="margin-top: 1.5rem; display: grid; gap: 0.5rem;">
                        <?php foreach ($expensesByCategory as $cat): ?>
                            <div style="margin-bottom: 1rem;">
                                <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.9rem;">
                                    <div style="display: flex; align-items: center; gap: 0.5rem;">
                                        <div style="width: 10px; height: 10px; border-radius: 50%; background: <?= $cat['category_color'] ?>;"></div>
                                        <span style="color: var(--text);"><?= htmlspecialchars($cat['category_name']) ?></span>
                                    </div>
                                    <strong style="color: var(--text);">R$ <?= number_format($cat['total'], 2, ',', '.') ?></strong>
                                </div>
                                <?php if ($cat['budget_limit'] > 0): ?>
                                    <?php 
                                        $limit = (float) $cat['budget_limit'];
                                        $spent = (float) $cat['total'];
                                        $pct = min(($spent / $limit) * 100, 100);
                                        $barColor = $pct >= 100 ? 'var(--destructive)' : ($pct >= 80 ? 'var(--warning)' : 'var(--positive)');
                                    ?>
                                    <div style="display: flex; align-items: center; gap: 10px; margin-top: 5px;">
                                        <div style="flex: 1; height: 4px; background: var(--surface-2); border-radius: 2px; overflow: hidden;">
                                            <div style="height: 100%; width: <?= $pct ?>%; background: <?= $barColor ?>;"></div>
                                        </div>
                                        <span style="font-size: 0.75rem; color: var(--muted);">Meta: R$ <?= number_format($limit, 2, ',', '.') ?></span>
                                    </div>
                                <?php endif; ?>
                            </div>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>
        </div>

    </div>
</main>

<script>
    window.chartData = <?= json_encode($expensesByCategory ?? []) ?>;
</script>

<!-- Modal Overlay e Content (Apple Style) -->
<div id="modal-transaction" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.4); z-index:999; align-items:center; justify-content:center; backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px); animation: fadeIn 0.3s ease;">
    <div style="background: rgba(28, 28, 30, 0.85); width: 100%; max-width: 420px; padding: 32px 28px; border-radius: 28px; border: 1px solid rgba(255,255,255,0.1); box-shadow: 0 24px 64px rgba(0,0,0,0.5); max-height: 90vh; overflow-y: auto; backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);">
        <div style="text-align: center; margin-bottom: 24px;">
            <h2 style="margin: 0; font-size: 1.5rem; font-weight: 700; letter-spacing: -0.03em;">Nova Movimentação</h2>
        </div>
        
        <form method="POST" action="/transactions/create" style="display: grid; gap: 16px;">
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                <div>
                    <label style="font-size: 0.85rem; color: var(--muted); margin-bottom: 6px; display: block;">Tipo</label>
                    <select name="type" style="padding: 14px; border-radius: 14px; border: 0; background: rgba(0,0,0,0.3); color: var(--text); width: 100%; font-weight: 500;">
                        <option value="expense">Despesa</option>
                        <option value="income">Receita</option>
                    </select>
                </div>
                <div>
                    <label style="font-size: 0.85rem; color: var(--muted); margin-bottom: 6px; display: block;">Valor (R$)</label>
                    <input type="number" step="0.01" name="amount" required style="padding: 14px; border-radius: 14px; border: 0; background: rgba(0,0,0,0.3); color: var(--text); width: 100%; font-weight: 600; font-size: 1.1rem; text-align: right;">
                </div>
            </div>

            <div>
                <label style="font-size: 0.85rem; color: var(--muted); margin-bottom: 6px; display: block;">Descrição</label>
                <input type="text" name="description" required placeholder="Ex: Conta de Luz" style="padding: 14px; border-radius: 14px; border: 0; background: rgba(0,0,0,0.3); color: var(--text); width: 100%; font-weight: 500;">
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                <div>
                    <label style="font-size: 0.85rem; color: var(--muted); margin-bottom: 6px; display: block;">Data</label>
                    <input type="date" name="date" value="<?= date('Y-m-d') ?>" required style="padding: 14px; border-radius: 14px; border: 0; background: rgba(0,0,0,0.3); color: var(--text); width: 100%;">
                </div>
                <div>
                    <label style="font-size: 0.85rem; color: var(--muted); margin-bottom: 6px; display: block;">Parcelas</label>
                    <input type="number" name="installments" min="1" value="1" required style="padding: 14px; border-radius: 14px; border: 0; background: rgba(0,0,0,0.3); color: var(--text); width: 100%; text-align: center;">
                </div>
            </div>

            <div>
                <label style="font-size: 0.85rem; color: var(--muted); margin-bottom: 6px; display: block;">Conta / Cartão</label>
                <select name="account_id" required style="padding: 14px; border-radius: 14px; border: 0; background: rgba(0,0,0,0.3); color: var(--text); width: 100%; font-weight: 500;">
                    <?php foreach ($accounts as $acc): ?>
                        <option value="<?= $acc['id'] ?>">
                            <?= htmlspecialchars($acc['name']) ?> <?= $acc['type'] === 'credit_card' ? '(Cartão)' : '' ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
            
            <label style="margin-top: 5px; display: flex; align-items: center; gap: 12px; cursor: pointer; padding: 12px; border-radius: 14px; background: rgba(0,0,0,0.2);">
                <input type="checkbox" name="is_paid" value="1" checked style="width: 20px; height: 20px; accent-color: var(--primary);">
                <span style="font-size: 0.95rem; font-weight: 500;">Já está pago?</span>
            </label>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 16px;">
                <button type="button" onclick="document.getElementById('modal-transaction').style.display='none'" class="btn" style="background: rgba(255,255,255,0.1); color: var(--text);">Cancelar</button>
                <button type="submit" class="btn btn-primary">Salvar</button>
            </div>
        </form>
    </div>
</div>

<style>
@keyframes fadeIn {
    from { opacity: 0; transform: scale(0.95); }
    to { opacity: 1; transform: scale(1); }
}
</style>
