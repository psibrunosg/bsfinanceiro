# Prevenção de envio duplicado em formulários

## Objetivo

Impedir submissões duplicadas nos formulários financeiros compartilhados e deixar o estado de processamento claro para todas as pessoas usuárias.

## Escopo

Alterar somente `src/app/components/SimpleForm.tsx` e seu teste associado. Enquanto uma submissão assíncrona estiver pendente, todos os controles descendentes do formulário devem ficar indisponíveis e o controle de envio deve indicar processamento de forma acessível.

## Fora de escopo

- Mudar ações de persistência, validação ou regras financeiras.
- Redesenhar os formulários ou alterar seus campos.
- Alterar formulários que não usam `SimpleForm`.
- Adicionar dependências.

## Design

`SimpleForm` será a única fronteira de controle do estado de submissão para seus consumidores atuais. O conteúdo recebido por `children` ficará dentro de um `fieldset` que usa `disabled={pending}`. O botão de envio existente em cada formulário continuará sendo a ação primária; durante o processamento, ele ficará desabilitado pelo fieldset e exibirá uma indicação textual de carregamento fornecida pelo componente.

O estado será anunciado com uma região de status acessível, sem depender de cor ou animação. Ao resolver ou rejeitar a promessa de `onSubmit`, o componente sempre restabelecerá o estado de interação. O tratamento de erro existente nos consumidores permanece responsável pela mensagem de negócio.

## Critérios de aceite

1. Durante `pending`, campos e botões dentro de `SimpleForm` ficam desabilitados.
2. Clique, Enter ou toque adicional não inicia uma segunda submissão durante `pending`.
3. A pessoa usuária recebe indicação textual de processamento, disponível a tecnologias assistivas.
4. Os controles são reativados ao término, tanto em sucesso quanto em erro.
5. O comportamento dos consumidores fora de `pending` não muda.
6. Um teste automatizado cobre bloqueio durante a promessa pendente e reativação após resolução.

## Riscos e mitigação

- Controles renderizados fora do `fieldset` não serão cobertos; esta mudança se restringe aos filhos atuais de `SimpleForm`.
- Uma promessa rejeitada não pode manter a interface bloqueada; a liberação ocorrerá em `finally`.
- Feedback somente visual seria inacessível; o estado terá texto e semântica de status.

## Verificação

TERRA executará o teste específico, `npm test`, `npm run lint` e `npm run build` quando a implementação estiver pronta. LUA revisará o diff e as evidências antes de qualquer aceite.

## Fluxo de papéis

- SOL definiu este brief e os critérios de aceite.
- TERRA implementará somente o escopo aprovado.
- LUA revisará a implementação e decidirá `ACCEPTED` ou `CHANGES_REQUESTED`.
- Sem LUA disponível, o estado final é `WAITING_FOR_LUA`; SOL e TERRA não podem substituir esse papel.
