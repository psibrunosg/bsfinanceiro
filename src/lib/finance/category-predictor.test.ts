import { describe, it, expect } from "vitest";
import { predictCategory, CategoryOption, PastTransaction } from "./category-predictor";

describe("predictCategory", () => {
  const categories: CategoryOption[] = [
    { id: "cat-alim", name: "Alimentação" },
    { id: "cat-trans", name: "Transporte" },
    { id: "cat-saude", name: "Saúde" },
    { id: "cat-morad", name: "Moradia" },
    { id: "cat-lazer", name: "Lazer" },
    { id: "cat-serv", name: "Serviços" },
  ];

  it("retorna null para descrições vazias ou muito curtas", () => {
    expect(predictCategory("", categories)).toBeNull();
    expect(predictCategory("a", categories)).toBeNull();
  });

  it("prediz Alimentação para termos como ifood e carrefour", () => {
    expect(predictCategory("Ifood *Restaurante Sp", categories)).toBe("cat-alim");
    expect(predictCategory("COMPRA CARREFOUR BAIRRO", categories)).toBe("cat-alim");
    expect(predictCategory("pao de acucar", categories)).toBe("cat-alim");
  });

  it("prediz Transporte para uber e postos de combustivel", () => {
    expect(predictCategory("UBER *TRIP HELP", categories)).toBe("cat-trans");
    expect(predictCategory("POSTO SHELL MARGINAL", categories)).toBe("cat-trans");
    expect(predictCategory("99 App corrida", categories)).toBe("cat-trans");
  });

  it("prediz Saúde para farmácias e médicos", () => {
    expect(predictCategory("Droga Raia Paulista", categories)).toBe("cat-saude");
    expect(predictCategory("Drogasil medicamentos", categories)).toBe("cat-saude");
    expect(predictCategory("Consulta Psiquiatra", categories)).toBe("cat-saude");
  });

  it("prioriza o histórico recente de transações do usuário", () => {
    const customHistory: PastTransaction[] = [
      { description: "Fornecedor Especial X", category_id: "cat-serv" },
    ];

    expect(predictCategory("Fornecedor Especial X", categories, customHistory)).toBe("cat-serv");
  });

  it("retorna null quando nenhuma categoria corresponde", () => {
    expect(predictCategory("Algo totalmente aleatorio 123xyz", categories)).toBeNull();
  });
});
