/**
 * Dicionário de termos comuns para predição automática de categorias no Brasil.
 */
const DICTIONARY: Record<string, string[]> = {
  Alimentação: [
    "ifood", "rappi", "uber eats", "supermercado", "mercado", "padaria", "restaurante",
    "pizzaria", "hamburgueria", "carrefour", "pao de acucar", "pão de açúcar", "extra",
    "açougue", "acougue", "hortifruti", "bar", "lanchonete", "burger", "mcdonalds",
    "mc donalds", "subway", "cafe", "café", "starbucks", "cacau show", "churrascaria",
    "delivery", "muffato", "assai", "assaí", "atacadao", "atacadão", "dia%", "bistek"
  ],
  Transporte: [
    "uber", "99", "99app", "99pop", "taxi", "táxi", "combustivel", "combustível", "posto",
    "ipiranga", "shell", "petrobras", "auto posto", "pedagio", "pedágio", "sem parar",
    "conectcar", "estacionamento", "estapar", "ipva", "oficina", "mecanica", "mecânica",
    "pneus", "bilhete unico", "bilhete único", "metro", "metrô", "gasolina", "etanol"
  ],
  Saúde: [
    "farmacia", "farmácia", "droga raia", "drogasil", "drogaria", "pague menos",
    "droga sao paulo", "panvel", "consulta", "medico", "médico", "psicologo", "psicólogo",
    "psiquiatra", "dentista", "odonto", "laboratorio", "laboratório", "fleury", "exame",
    "hospital", "unimed", "bradesco saude", "sulamerica", "remedio", "remédio", "vacina",
    "fisioterapia", "clinica", "clínica", "terapia"
  ],
  Moradia: [
    "aluguel", "condominio", "condomínio", "enel", "sabesp", "cpfl", "eletropaulo",
    "cemig", "copel", "equatorial", "luz", "energia", "agua", "água", "gas", "gás",
    "comgas", "comgás", "iptu", "reforma", "leroy merlin", "telhanorte", "c&c"
  ],
  Educação: [
    "faculdade", "universidade", "escola", "curso", "pos-graduacao", "pós-graduação",
    "mestrado", "doutorado", "livro", "livraria", "udemy", "coursera", "alura", "mensalidade"
  ],
  Lazer: [
    "netflix", "spotify", "amazon prime", "prime video", "hbo", "max", "disney",
    "cinema", "cinemark", "ingresso", "show", "teatro", "steam", "playstation",
    "xbox", "nintendo", "viagem", "hotel", "airbnb", "booking", "decolar"
  ],
  Vestuário: [
    "zara", "renner", "c&a", "cea", "riachuelo", "shein", "centauro", "nike",
    "adidas", "roupas", "sapatos", "arezzzo", "anacapri"
  ],
  Serviços: [
    "internet", "claro", "vivo", "tim", "oi", "celular", "plano celular", "anuidade",
    "tarifa", "iugu", "mercado pago", "asaas", "contabilidade"
  ],
};

function normalize(text: string): string {
  return text
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .trim();
}

export type CategoryOption = {
  id: string;
  name: string;
};

export type PastTransaction = {
  description: string;
  category_id?: string | null;
};

/**
 * Prediz a categoria mais apropriada com base na descrição e categorias cadastradas.
 * 1. Prioriza o histórico pessoal de transações do usuário.
 * 2. Em seguida, usa o dicionário inteligente de padrões comuns do mercado brasileiro.
 */
export function predictCategory(
  description: string,
  categories: CategoryOption[],
  recentTransactions: PastTransaction[] = []
): string | null {
  const normDesc = normalize(description);
  if (!normDesc || normDesc.length < 2 || !categories.length) {
    return null;
  }

  // 1. Procurar no histórico recente do usuário (aprendizado com uso)
  for (const tx of recentTransactions) {
    if (!tx.category_id) continue;
    const pastDesc = normalize(tx.description);
    if (!pastDesc) continue;

    // Correspondência exata ou contém termo significativo
    if (
      pastDesc === normDesc ||
      (pastDesc.length >= 4 && normDesc.includes(pastDesc)) ||
      (normDesc.length >= 4 && pastDesc.includes(normDesc))
    ) {
      const match = categories.find((c) => c.id === tx.category_id);
      if (match) return match.id;
    }
  }

  // 2. Dicionário de termos conhecidos
  for (const [catName, keywords] of Object.entries(DICTIONARY)) {
    for (const kw of keywords) {
      const normKw = normalize(kw);
      if (normDesc.includes(normKw)) {
        // Encontrar na lista de categorias do workspace
        const found = categories.find((c) => normalize(c.name) === normalize(catName));
        if (found) {
          return found.id;
        }
      }
    }
  }

  return null;
}
