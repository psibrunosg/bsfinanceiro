# Roteiro de Ideias (Roadmap de EvoluÃ§Ã£o) - BS Financeiro

Este documento agrupa as principais funcionalidades identificadas durante o Brainstorm, inspiradas nos maiores aplicativos financeiros do mundo (YNAB, Nubank, Organizze, Revolut, Mobills).

O objetivo deste plano Ã© guiar as prÃ³ximas iteraÃ§Ãµes de desenvolvimento do aplicativo (Tickets).

---

## 1. Radar de Juros e Custos Ocultos (O Diferencial)
O usuÃ¡rio brasileiro perde muito dinheiro em "facilidades" bancÃ¡rias. O sistema vai rastrear e jogar luz sobre esse ralo.
- **TransaÃ§Ãµes "Pix no CrÃ©dito":** O app divide automaticamente a transaÃ§Ã£o em "Principal" e "Juros" na hora do lanÃ§amento.
- **Pular ou Adiantar Parcelas:** Simulador interno que calcula o desconto ao adiantar faturas, incentivando o pagamento antecipado.
- **Alerta de EmprÃ©stimos:** Monitor que revela quanto do pagamento mensal Ã© sÃ³ juros.

## 2. Monitor de Investimentos (O Crescimento Patrimonial)
Um usuÃ¡rio com educaÃ§Ã£o financeira nÃ£o sÃ³ poupa, mas investe.
- **Cadastro de Ativos:** Renda Fixa (CDB, Tesouro), Renda VariÃ¡vel (AÃ§Ãµes, FIIs).
- **Rentabilidade CDI:** MÃ©trica comparativa direta (Seu dinheiro estÃ¡ rendendo mais ou menos que a poupanÃ§a?).
- **GrÃ¡fico de EvoluÃ§Ã£o Patrimonial:** Um grÃ¡fico Apple-Style mostrando a soma de Contas + Investimentos - DÃ­vidas.

## 3. GestÃ£o de Assinaturas e RecorrÃªncias
Assinaturas invisÃ­veis corroem o orÃ§amento.
- **Hub de Assinaturas:** Netflix, Spotify, Academia, Amazon Prime.
- **VisÃ£o Anual:** "VocÃª gasta R$ 1.800/ano com assinaturas".
- **Alerta de Vencimento Antecipado:** NotificaÃ§Ã£o 1 dia antes da assinatura debitar no cartÃ£o.

## 4. OrÃ§amento Base Zero (Envelopes)
A regra de ouro do YNAB: "DÃª nome a cada centavo".
- **AlocaÃ§Ã£o Proativa:** Quando o salÃ¡rio entra, o usuÃ¡rio nÃ£o olha para trÃ¡s, mas para frente. Ele divide o dinheiro recebido em "Envelopes" virtuais de gastos permitidos.
- **Trava de Gastos:** O painel fica vermelho se tentar gastar de um envelope vazio.

## 5. GamificaÃ§Ã£o e Engajamento
Aplicativos virais usam ciÃªncia comportamental.
- **Badges (Conquistas):** Ganhar um escudo ao poupar 20% da renda.
- **Streaks (Ofensivas):** "VocÃª estÃ¡ hÃ¡ 15 dias controlando seus gastos sem estourar o orÃ§amento".
- **Modo "SaÃºde Financeira":** Uma nota (Score) de 0 a 1000 baseada na saÃºde do fluxo de caixa do usuÃ¡rio.

## 6. Consultor de IA (A Fronteira Final)
- **Chatbot Integrado:** "Posso comprar um iPhone novo esse mÃªs?" -> A IA lÃª o banco de dados e avisa que comprometeria o envelope de "EmergÃªncias".

## 7. Otimizador de CartÃµes e Rastreador de Parcelas
- **Otimizador de Cashback:** O app indica qual cartÃ£o usar em cada tipo de compra para maximizar pontos.
- **Rastreador de Parcelamentos (Snowball Tracker):** GrÃ¡fico visual mostrando o declÃ­nio das faturas futuras mÃªs a mÃªs, dando clareza de quando o cartÃ£o "ficarÃ¡ livre".

## 8. DossiÃª de Imposto de Renda (IR)
- **Tag "DedutÃ­vel":** O usuÃ¡rio marca despesas mÃ©dicas e de educaÃ§Ã£o ao longo do ano.
- **ExportaÃ§Ã£o com 1 Clique:** Gera um PDF resumido e somado para enviar direto ao contador em marÃ§o.

## 9. Modo Viagem (Sandbox de Gastos)
- **OrÃ§amento Isolado:** Ao viajar, o usuÃ¡rio ativa o modo viagem. Tudo o que gasta abate apenas do orÃ§amento especÃ­fico da viagem, sem estragar as mÃ©tricas e mÃ©dias do custo de vida mensal.

## 10. MÃ³dulo EMPRESA (AutÃ´nomos / ClÃ­nicas)
- **SeparaÃ§Ã£o Total:** Um "workspace" isolado do financeiro pessoal.
- **Pagamentos Cruzados (EmprÃ©stimo do SÃ³cio):** Quando vocÃª paga uma conta da empresa (ex: Aluguel da ClÃ­nica no dia 8) usando dinheiro da sua conta Pessoal (porque os pacientes sÃ³ pagam dia 15). O app registra a despesa na Empresa, mas cria automaticamente uma dÃ­vida da "Empresa" com o "Bruno Pessoal".
- **Fluxo de Reembolso:** Quando os pacientes pagam dia 15, a Empresa recebe, e vocÃª aperta um botÃ£o "Reembolsar SÃ³cio" para devolver o dinheiro Ã  sua conta pessoal, deixando os grÃ¡ficos de ambos os lados 100% corretos.
- **Lucro Real vs PrÃ³ Labore:** O app identifica automaticamente transferÃªncias do Workspace Empresa para o Workspace Pessoal e tagueia como "PrÃ³ Labore/DistribuiÃ§Ã£o de Lucros".
- **Contas a Receber (InadimplÃªncia):** Radar de pacientes/clientes que estÃ£o devendo. Vencimentos atrasados ficam em vermelho.
- **Gerador de Recibos:** Ao registrar uma entrada, botÃ£o mÃ¡gico para "Exportar Recibo em PDF" com a logo da clÃ­nica, pronto para o WhatsApp do paciente.

## 11. MÃ³dulo CASAL (FinanÃ§as Compartilhadas / Multiplayer)
- **VÃ­nculo de Contas:** Envio de convite via link para o(a) parceiro(a).
- **Rastreamento Total (TransaÃ§Ãµes Espelhadas):** Quando vocÃª lanÃ§a no Workspace Casal que "pagaram separados" (ex: conta de R$ 200, onde vocÃª pagou R$ 100 no seu Nubank), o app faz o rastreamento duplo:
  1. No relatÃ³rio do **Casal**, aparece a despesa cheia de R$ 200 (para vocÃªs saberem o custo de vida juntos).
  2. No seu relatÃ³rio **Pessoal**, os R$ 100 sÃ£o deduzidos automaticamente da sua conta bancÃ¡ria, mantendo o seu fluxo de caixa individual perfeito e rastreÃ¡vel (vocÃª sabe exatamente de que conta saiu o dinheiro).
- **TermÃ´metro de EquilÃ­brio (Quem pagou mais?):** Um grÃ¡fico visual que resolve as brigas financeiras.
- **LÃ³gica "Eu paguei por NÃ³s":** Quando alguÃ©m passa o cartÃ£o pessoal para uma despesa do casal (ex: pagou a conta inteira do restaurante), o app registra o gasto total no relatÃ³rio do casal e cria uma compensaÃ§Ã£o automÃ¡tica (Splitwise interno), calculando que o outro deve 50% do jantar.
- **Metas Conjuntas com Avatares:** Cofrinhos (ex: "Viagem pra ItÃ¡lia") onde a barra de progresso mostra a foto dos dois correndo. "Bruno jÃ¡ guardou R$ 2 mil, Parceira guardou R$ 1.500".
- **Notas / Chat na TransaÃ§Ã£o:** AlguÃ©m passou R$ 300 no cartÃ£o e nÃ£o avisou? O outro pode deixar um comentÃ¡rio na prÃ³pria despesa: "Amor, o que foi essa compra na farmÃ¡cia?".
- **DivisÃ£o Proporcional:** O app pode calcular quem paga o que baseado no peso da renda de cada um, gerando justiÃ§a financeira na relaÃ§Ã£o.

## 12. Cofre de Garantias e Notas Fiscais
- **Armazenamento de NFs:** Tirar foto da nota fiscal atrelada Ã  transaÃ§Ã£o.
- **Alerta de Vencimento de Garantia:** O app manda um aviso 15 dias antes da garantia de um bem caro vencer, lembrando o usuÃ¡rio de acionar a assistÃªncia caso haja algum defeito.

## 13. Modo Kids / Mesada (EducaÃ§Ã£o Financeira)
- **Workspace Simplificado:** Login e visÃ£o exclusiva para filhos(as), gamificada para ensinar educaÃ§Ã£o financeira.
- **Controle Parental:** Os pais transferem a "mesada" e conseguem monitorar (apenas visualizar) como o filho aloca e gasta o dinheiro, dando "Badges" virtuais por metas atingidas.

## 14. Dashboard F.I.R.E. (IndependÃªncia Financeira)
- **Calculadora de Aposentadoria:** Cruza o Custo de Vida MÃ©dio com a Taxa de PoupanÃ§a (Investimentos).
- **A Data de Alforria:** Entrega uma estimativa dinÃ¢mica: "Mantendo este ritmo, em MarÃ§o de 2038 seus rendimentos cobrirÃ£o 100% dos seus custos e vocÃª nÃ£o precisarÃ¡ mais trabalhar".

## 15. Benchmarking AnÃ´nimo (InteligÃªncia Social)
- **ComparaÃ§Ã£o de Renda:** O sistema anonimiza os dados de todos os usuÃ¡rios e gera relatÃ³rios comportamentais.
- **Alerta de Anomalia:** "VocÃª gastou 30% a mais com iFood do que outros usuÃ¡rios na sua mesma faixa de renda". Cria gatilhos poderosos de correÃ§Ã£o de rota.

## 16. "Tinder" dos Gastos (RevisÃ£o de Arrependimentos)
- **Swipe Mensal:** Todo fim de mÃªs, o app mostra as compras "extras" uma por uma. O usuÃ¡rio desliza pra direita ("valeu a pena") ou esquerda ("me arrependi").
- **InteligÃªncia Comportamental:** O app aprende os padrÃµes de arrependimento e, no futuro, avisa antes de comprar: "Ei, vocÃª costuma se arrepender de gastos acima de R$ 200 em Baladas. Tem certeza?".

## 17. Calculadora de Impulso (PreÃ§o em Horas de Vida)
- **Conversor de Valor Real:** O usuÃ¡rio digita o preÃ§o de algo que quer comprar. O app cruza com a renda e diz: "Esse celular custa 12 dias do seu trabalho".
- **Cooling-Off de 48h:** O app sugere esperar 48 horas e manda uma notificaÃ§Ã£o lembrando: "Ainda quer comprar aquele celular? Se nÃ£o, vocÃª acabou de economizar R$ 5.000".

## 18. Simulador de CenÃ¡rios (MÃ¡quina do Tempo / What-If)
- **ProjeÃ§Ã£o Futura:** "E se eu assumir a parcela de R$ 1.500 de um carro?" â€" O app simula os prÃ³ximos 24 meses do fluxo de caixa e mostra exatamente em que mÃªs o dinheiro aperta.
- **ComparaÃ§Ã£o A vs B:** "Comprar Ã  vista ou parcelar em 12x?" â€" mostra o custo total de cada cenÃ¡rio com juros.

## 19. Radar de Milhas e Pontos (Cofre InvisÃ­vel)
- **ConsolidaÃ§Ã£o de Programas:** Smiles, Livelo, Latam Pass. Todos num sÃ³ painel.
- **Alerta de Vencimento:** "VocÃª tem 15.000 milhas da Livelo vencendo em 30 dias. Gaste agora ou transfira".

## 20. Mapa de Calor dos Gastos (GeolocalizaÃ§Ã£o)
- **HotSpots de Consumo:** O app marca no mapa da cidade os lugares onde o usuÃ¡rio mais gasta.
- **Insight GeogrÃ¡fico:** "Toda vez que vocÃª vai ao Shopping Iguatemi, gasta em mÃ©dia R$ 450. Nos Ãºltimos 3 meses foram 6 visitas = R$ 2.700." O problema Ã s vezes nÃ£o Ã© O QUE a pessoa compra, mas ONDE ela vai.

## 21. CalendÃ¡rio Financeiro Visual
- **VisÃ£o DiÃ¡ria:** Cada dia do mÃªs mostra o que entrou e saiu. Dias verdes = sobrou. Dias vermelhos = gastou mais do que ganhou.
- **Agendamento de Contas Futuras:** PrÃ©-agendar aluguel dia 10, IPTU dia 15 e ver quando o saldo vai apertar.

## 22. RelatÃ³rio Anual "Wrapped" (O Spotify do Dinheiro)
- **Resumo Animado de Fim de Ano:** "Em 2026, vocÃª gastou R$ 42.000. Sua categoria campeÃ£ foi AlimentaÃ§Ã£o (R$ 12.000). VocÃª economizou R$ 8.000 a mais que no ano passado. ParabÃ©ns! ðŸŽ‰"
- **CompartilhÃ¡vel em Stories:** O resumo vira um card visual bonito para o usuÃ¡rio postar no Instagram/WhatsApp. Marketing viral gratuito.

## 23. Caixinha de EmergÃªncia Inteligente
- **Reserva AutomÃ¡tica:** O usuÃ¡rio define uma meta (ex: 6 meses de custo de vida = R$ 24.000). O app calcula mensalmente quanto dÃ¡ pra poupar e "tranca" virtualmente.
- **GuardiÃ£o de Reserva:** Se tentar mexer na caixinha, o app mostra: "VocÃª estÃ¡ prestes a quebrar sua reserva. Sem ela, vocÃª sobreviveria apenas 2,3 meses sem renda. Tem certeza?".

## 24. ROI AcadÃªmico (Retorno sobre Investimento em EducaÃ§Ã£o)
- **Rastreamento de Gastos com FormaÃ§Ã£o:** O usuÃ¡rio registra cursos, pÃ³s-graduaÃ§Ã£o, congressos, supervisÃµes, livros e certificaÃ§Ãµes, informando o custo e a data de conclusÃ£o.
- **CÃ¡lculo de Retorno:** O app cruza a timeline de investimentos acadÃªmicos com a curva de renda. Exemplo: "Antes do curso de TCC (R$ 4.000 em Mar/2025), vocÃª atendia 12 pacientes/mÃªs com ticket mÃ©dio de R$ 200. Depois dele, vocÃª passou a atender 18 pacientes com ticket de R$ 280. O curso se pagou em 2 meses e jÃ¡ gerou R$ 14.000 de retorno lÃ­quido."
- **Painel "EvoluÃ§Ã£o Profissional":** GrÃ¡fico de linha mostrando a renda profissional ao longo dos anos, com marcos visuais de cada curso/certificaÃ§Ã£o concluÃ­da.
- **Simulador de PrÃ³ximo Investimento:** "Estou pensando em fazer uma especializaÃ§Ã£o de R$ 15.000" â€" O app projeta: "Se gerar o mesmo impacto percentual dos seus Ãºltimos cursos, vocÃª recupera o valor em 5 meses".

## 25. Open Finance â€" SincronizaÃ§Ã£o BancÃ¡ria AutomÃ¡tica (via Pluggy)
- **Provedor Escolhido:** [Pluggy](https://pluggy.ai) â€" empresa brasileira, autorizada pelo Banco Central como Iniciadora de TransaÃ§Ã£o de Pagamento (ITP). Sandbox gratuita para desenvolvimento.
- **ConexÃ£o com Todos os Bancos:** Nubank, ItaÃº, Bradesco, BB, XP, Inter, C6, Santander e outros â€" tudo via uma Ãºnica API padronizada.
- **ImportaÃ§Ã£o AutomÃ¡tica de Extratos:** O usuÃ¡rio clica em "Conectar Banco", autoriza via Open Finance, e o app puxa saldos, extratos e movimentaÃ§Ãµes automaticamente. Fim da digitaÃ§Ã£o manual.
- **Fatura do CartÃ£o de CrÃ©dito:** Importa cada lanÃ§amento da fatura, alimentando automaticamente o Radar de Juros e o Rastreador de Parcelamentos.
- **Investimentos em Tempo Real:** Puxa a posiÃ§Ã£o da carteira (CDB, Tesouro, AÃ§Ãµes, FIIs), alimentando o Monitor de Investimentos e o Dashboard F.I.R.E.
- **EmprÃ©stimos e Financiamentos:** Importa dÃ­vidas ativas com juros e parcelas, alimentando o Radar de Juros.
- **Pix Integrado (Futuro):** Possibilidade de iniciar pagamentos Pix direto pelo app.

---

## EstruturaÃ§Ã£o em Tickets (PrÃ³ximos Passos de Desenvolvimento)
Para prosseguirmos com a regra do `superpowers` (to-spec -> to-tickets), cada mÃ³dulo acima se tornarÃ¡ uma Ã‰PICA.

1. **[EPIC-01] MÃºltiplos Workspaces (Base para Empresa e Casal):**
   - (Task) Alterar estrutura do banco de `user_id` para `workspace_id` e criar tabela `workspaces` (Tipo: Personal, Business, Couple).
   - (Task) Criar lÃ³gica de convites para o MÃ³dulo Casal.
   - (Task) Criar lÃ³gica de alternÃ¢ncia ("Mudar para Conta PJ") sem precisar de novo login.

2. **[EPIC-02] Radar de Juros e DÃ­vidas:**
   - (Task) Modificar tabela `transactions` para suportar separador de `interest_amount`.
   - (Task) Criar widget de Radar no Dashboard com total de juros pagos no mÃªs.

3. **[EPIC-03] Monitor de Investimentos:**
   - (Task) Criar modelo `Investment` e tabela `investments`.
   - (Task) Desenhar dashboard de "EvoluÃ§Ã£o Patrimonial".
