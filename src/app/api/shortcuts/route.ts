import { NextResponse, type NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/client";
import { parseBankNotification } from "@/lib/finance/bank-notification-parser";
import { todayInSaoPaulo, addMonthsToDate } from "@/lib/finance/local-date";
import { predictCategory } from "@/lib/finance/category-predictor";

const DEFAULT_SECRET_TOKEN = process.env.SHORTCUTS_API_KEY || "bsf_shortcut_token_2026";

export async function POST(req: NextRequest) {
  try {
    let body: any = {}; // eslint-disable-line @typescript-eslint/no-explicit-any
    try {
      body = await req.json();
    } catch {
      body = {};
    }

    // 1. Validar autenticação (Token via header Bearer, X-Shortcut-Token, query param ?token= ou body.token)
    const authHeader = req.headers.get("Authorization");
    const bearerToken = authHeader?.startsWith("Bearer ") ? authHeader.substring(7).trim() : null;
    const headerToken = req.headers.get("X-Shortcut-Token");
    const queryToken = req.nextUrl.searchParams.get("token");
    const providedToken = bearerToken || headerToken || queryToken || body.token;

    const validTokens = [
      DEFAULT_SECRET_TOKEN,
      process.env.NEXT_PUBLIC_SHORTCUTS_API_KEY,
    ].filter(Boolean);

    if (!providedToken || !validTokens.includes(providedToken)) {
      return NextResponse.json(
        {
          success: false,
          error: "Token de autorização inválido ou ausente. Verifique a chave configurada no seu Atalho.",
        },
        { status: 401 }
      );
    }

    // 2. Extrair dados da requisição
    let amount = Number(body.amount);
    let description = String(body.description || "").trim();
    let type = (body.type === "income" ? "income" : "expense") as "income" | "expense";
    let suggestedCategory = body.category ? String(body.category).trim() : "";

    // Se vier 'notif' ou 'rawText', usar o parser de notificações
    const rawNotif = body.notif || body.rawText || body.text;
    if (rawNotif && typeof rawNotif === "string") {
      const parsed = parseBankNotification(rawNotif);
      if (parsed.amount > 0) {
        amount = parsed.amount;
        description = parsed.description;
        type = parsed.type;
        suggestedCategory = parsed.suggestedCategory;
      }
    }

    // Se amount veio como string (ex: "150,00" ou "150.00")
    if (typeof body.amount === "string") {
      const cleaned = body.amount.replace(/\s*R\$\s*/i, "").replace(/\./g, "").replace(",", ".");
      const parsedNum = parseFloat(cleaned);
      if (!isNaN(parsedNum)) amount = parsedNum;
    }

    if (!amount || isNaN(amount) || amount <= 0 || !description) {
      return NextResponse.json(
        {
          success: false,
          error: "Valor e descrição válidos são obrigatórios.",
        },
        { status: 400 }
      );
    }

    const installments = Math.max(1, Math.min(60, parseInt(String(body.installments || 1), 10) || 1));
    const startDate = body.date || todayInSaoPaulo();

    // 3. Inicializar cliente Supabase
    const supabase = createClient();

    // Obter ou autenticar usuário
    let userId = body.owner_id;
    if (!userId) {
      const { data: userData } = await supabase.auth.getUser();
      userId = userData?.user?.id;
    }

    // Obter workspace padrão se não fornecido
    let workspaceId = body.workspace_id;
    if (!workspaceId) {
      const { data: wsData } = await supabase.from("workspaces").select("id").limit(1).single();
      workspaceId = wsData?.id;
    }

    // Obter conta padrão se não fornecida
    let accountId = body.account_id;
    if (!accountId && workspaceId) {
      const { data: accData } = await supabase.from("accounts").select("id").limit(1);
      accountId = accData?.[0]?.id || null;
    }

    // Obter categorias para resolução de ID
    let categoryId = body.category_id || null;
    if (!categoryId && workspaceId) {
      const { data: catList } = await supabase.from("categories").select("id, name, kind");
      if (catList && catList.length > 0) {
        if (suggestedCategory) {
          const match = catList.find((c: any) => c.name.toLowerCase() === suggestedCategory.toLowerCase()); // eslint-disable-line @typescript-eslint/no-explicit-any
          if (match) categoryId = match.id;
        }
        if (!categoryId) {
          const predicted = predictCategory(description, catList as any, []); // eslint-disable-line @typescript-eslint/no-explicit-any
          if (predicted) categoryId = predicted;
        }
      }
    }

    // 4. Montar lançamentos (suporte a parcelamento)
    const transactionsToInsert = [];
    const installmentAmount = Math.round((amount / installments) * 100) / 100;
    // Ajustar centavos na primeira parcela para que a soma feche exata
    const centsDifference = Math.round((amount - installmentAmount * installments) * 100) / 100;

    for (let i = 1; i <= installments; i++) {
      const currentAmount = i === 1 ? installmentAmount + centsDifference : installmentAmount;
      const currentDesc = installments > 1 ? `${description} (${i}/${installments})` : description;
      const currentDate = i === 1 ? startDate : addMonthsToDate(startDate, i - 1);

      transactionsToInsert.push({
        workspace_id: workspaceId,
        owner_id: userId,
        account_id: accountId,
        category_id: categoryId,
        destination_account_id: null,
        type,
        amount: currentAmount,
        description: currentDesc,
        competence_date: currentDate,
        paid_at: currentDate,
        status: "paid",
        idempotency_key: crypto.randomUUID(),
      });
    }

    const { error } = await supabase.from("transactions").insert(transactionsToInsert);

    if (error) {
      return NextResponse.json(
        {
          success: false,
          error: "Erro ao salvar transação no banco de dados.",
          details: error.message,
        },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      count: transactionsToInsert.length,
      amount,
      installments,
      message: installments > 1
        ? `${installments} parcelas de ${description} registradas com sucesso!`
        : `${description} de R$ ${amount.toFixed(2)} registrado com sucesso!`,
    });
  } catch (err: any) { // eslint-disable-line @typescript-eslint/no-explicit-any
    return NextResponse.json(
      {
        success: false,
        error: "Erro interno no processamento do atalho.",
        details: err?.message,
      },
      { status: 500 }
    );
  }
}
