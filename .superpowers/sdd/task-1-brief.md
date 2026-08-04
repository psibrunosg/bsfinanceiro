# Task 1 Brief: Parsing e extração das faturas Claro de G:\Meu Drive\n

## Contexto & Objetivos
Temos 20 arquivos em `G:\Meu Drive\n` contendo faturas em PDF e comprovantes em imagem da Claro para Bruno de Souza Gonçalves.
Precisamos criar um script robusto `scripts/parse-claro-invoices.ts` (ou script em Node.js com `pdf-parse` / `pdf2json` / `pdfjs-dist` ou script auxiliar) para ler todos os arquivos da pasta, extrair os dados e categorizar em dois contratos principais:
1. `Claro Telefone Móvel` (nº 53 99189 8309)
2. `Claro Internet Clínica` (cód. NET 691/398972107)

## Requisitos Específicos
1. Ler os 20 arquivos em `G:\Meu Drive\n`:
   - `Cliente-Vendas (1).pdf`
   - `Cliente-Vendas (2).pdf`
   - `Fatura de abril.pdf`
   - `Fatura de agosto (1).pdf`
   - `Fatura de agosto (2).pdf`
   - `Fatura de fevereiro.pdf`
   - `Fatura de julho.pdf`
   - `Fatura de junho.pdf`
   - `Fatura de maio.pdf`
   - `Fatura de março.pdf`
   - `IMG_5785.PNG`
   - `IMG_5786.PNG`
   - `IMG_5787.PNG`
   - `IMG_5788.PNG`
   - `minha-claro-fatura (4).pdf`
   - `minha-claro-fatura (6).pdf`
   - `minha-claro-fatura (7).pdf`
   - `minha-claro-fatura (8).pdf`
   - `minha-claro-fatura (9).pdf`
   - `minha-claro-fatura.pdf`
2. Para cada PDF/imagem, extrair:
   - Nome do arquivo
   - Contrato/Serviço (`Claro Móvel` vs `Claro Internet Clínica`)
   - Data de vencimento (vencimento real, ex: 12/02/2026, 20/06/2026)
   - Mês de competência (YYYY-MM-01, ex: 2026-02-01)
   - Valor base do plano (ex: R$ 59,90 para celular, R$ 84,11 para internet/combo)
   - Valor total cobrado na fatura do mês (ex: R$ 61,00, R$ 59,93, R$ 34,82, R$ 63,13, etc.)
3. Gerar o arquivo JSON de saída estruturado em `scripts/claro-invoices-parsed.json`.
4. Criar/executar um teste unitário em `src/lib/finance/__tests__/parse-claro-invoices.test.ts` garantindo a corretude dos dados parsed (verificando se todos os 20 arquivos foram processados ou devidamente categorizados e que os meses de fev a ago/2026 estão cobertos).

## Evidência & Relatório
Escrever o relatório final de execução em `.superpowers/sdd/task-1-report.md`.
