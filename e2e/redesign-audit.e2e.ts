import { expect, test } from "@playwright/test";

// Auditoria das rotas autenticadas contra o sistema visual consolidado
// (bento dark). Cobre o que o redesign quebra com mais facilidade e que
// typecheck/lint nao pegam: scroll horizontal no mobile, conteudo escondido
// atras da sidebar no desktop, card sem regra CSS e erro de console.
//
// Roda nos projects mobile-auth e desktop-auth (ver playwright.config.ts);
// sem E2E_EMAIL/E2E_PASSWORD o setup pula e estes testes nao rodam.
const ROUTES = [
  "/",
  "/contas",
  "/cartoes",
  "/categorias",
  "/planejamento",
  "/movimentacoes",
  "/relatorios",
  "/saude",
  "/configuracoes",
  "/ganhos",
  "/gastos",
  "/investimentos",
  "/mais",
] as const;

// Classes que foram aposentadas na consolidacao. Se alguma voltar a aparecer
// no DOM e porque uma tela regrediu para a folha antiga, que nao existe mais.
const CLASSES_APOSENTADAS = [
  "management-grid",
  "account-list",
  "list--grid",
  "list-card",
  "card-import",
  "empty-state",
  "dashboard-columns",
  "metric-grid",
  "hub-overview",
  "invoice-card",
  "settings-card",
  "preferences-form",
  "planning-grid",
  "commitment-list",
];

for (const route of ROUTES) {
  test(`layout integro em ${route}`, async ({ page }, testInfo) => {
    const erros: string[] = [];
    page.on("console", (msg) => {
      if (msg.type() === "error") erros.push(msg.text());
    });

    await page.goto(route, { waitUntil: "networkidle" });
    await expect(page.getByText("Carregando...")).toHaveCount(0, { timeout: 30_000 });

    // Toda tela e um <main class="dashboard-shell"> unico: e ele quem cria o
    // offset da sidebar. Wrapper extra ou shell duplicado desloca a pagina.
    await expect(page.locator("main.dashboard-shell")).toHaveCount(1);

    const relatorio = await page.evaluate((aposentadas) => {
      const doc = document.documentElement;
      const shell = document.querySelector("main.dashboard-shell") as HTMLElement | null;
      const nav = document.querySelector(".app-nav") as HTMLElement | null;

      // Card sem fundo nem borda = classe sem regra CSS.
      const semEstilo: string[] = [];
      document.querySelectorAll<HTMLElement>(".dashboard-card, .metric-card").forEach((el) => {
        const cs = getComputedStyle(el);
        const semFundo = cs.backgroundColor === "rgba(0, 0, 0, 0)" || cs.backgroundColor === "transparent";
        if (semFundo && cs.borderTopWidth === "0px") semEstilo.push(el.className);
      });

      // Elementos que estouram a viewport. Dois casos legitimos ficam de fora:
      // conteudo dentro de um container que rola no eixo X de proposito
      // (.hub-tabs, .table-scroll) e elementos position:fixed, que se ancoram
      // na viewport e nao no fluxo da pagina (.mobile-nav).
      const rolaNoX = (el: Element) => {
        for (let n: Element | null = el; n && n !== document.body; n = n.parentElement) {
          const ox = getComputedStyle(n).overflowX;
          if (ox === "auto" || ox === "scroll" || ox === "hidden") return true;
          if (getComputedStyle(n).position === "fixed") return true;
        }
        return false;
      };
      const estouram: string[] = [];
      document.querySelectorAll<HTMLElement>("main.dashboard-shell *").forEach((el) => {
        const r = el.getBoundingClientRect();
        const excesso = Math.round(r.right - doc.clientWidth);
        if (r.width > 0 && excesso > 1 && !rolaNoX(el)) {
          const nome = typeof el.className === "string" ? el.className : el.tagName;
          estouram.push(`${el.tagName.toLowerCase()}.${nome} (+${excesso}px)`.slice(0, 90));
        }
      });

      return {
        scrollW: doc.scrollWidth,
        clientW: doc.clientWidth,
        shellLeft: shell ? shell.getBoundingClientRect().left : null,
        navVisivel: nav ? getComputedStyle(nav).display !== "none" : false,
        navLargura: nav ? nav.getBoundingClientRect().width : 0,
        theme: doc.dataset.theme,
        cardsSemEstilo: semEstilo,
        estouram: estouram.slice(0, 5),
        aposentadasNoDom: aposentadas.filter((c) => document.querySelector(`.${c}`) !== null),
      };
    }, CLASSES_APOSENTADAS);

    expect(relatorio.theme, "app deve ser dark-only").toBe("dark");
    expect(relatorio.aposentadasNoDom, "classe aposentada de volta no DOM").toEqual([]);
    expect(relatorio.cardsSemEstilo, "card sem regra CSS").toEqual([]);
    expect(relatorio.estouram, "elemento estourando a viewport").toEqual([]);
    expect(
      relatorio.scrollW,
      `scroll horizontal: documento ${relatorio.scrollW}px numa viewport de ${relatorio.clientW}px`,
    ).toBeLessThanOrEqual(relatorio.clientW);

    // Sidebar visivel (>=901px) nunca pode cobrir o conteudo.
    if (relatorio.navVisivel && relatorio.shellLeft !== null) {
      expect(relatorio.shellLeft, "conteudo atras da sidebar").toBeGreaterThanOrEqual(relatorio.navLargura);
    }

    // Grava em caminho estavel (nao so como anexo do relatorio) para dar para
    // olhar a tela depois sem reabrir o report do Playwright.
    const nome = `${(route.replace(/\//g, "_") || "_raiz").replace(/^_$/, "raiz")}-${testInfo.project.name}.png`;
    const destino = `test-results/redesign/${nome}`;
    await page.screenshot({ path: destino, fullPage: true });
    await testInfo.attach(nome, { path: destino, contentType: "image/png" });

    // Ruido conhecido do dev server e do Supabase sem dados; nao mascara erro de render.
    const relevantes = erros.filter(
      (e) => !/webpack-hmr|Failed to load resource|hydrat|Download the React DevTools/i.test(e),
    );
    expect(relevantes, "erros de console").toEqual([]);
  });
}
