# Task Contract: P3 - Preparar uma primeira liberação

**Task Identifier:** P3-Preparar-Liberacao
**Roadmap Reference:** `ROADMAP.md` -> Fase 3
**Owning Design Reference:** `ROADMAP.md`
**Base SHA:** `683902cf983dbe4bfba59c73d7a627123d8cb7a3`

## Allowed Paths
- `src/**/*.ts`
- `src/**/*.tsx`
- `src/**/*.css`
- `docs/**/*`
- `supabase/**/*`
- `playwright.config.ts`, `vitest.config.ts`, `package.json`

## Acceptance Conditions
1. **Tests Fixed:** `npm test` runs with zero failures (currently 14 baseline failures must be fixed).
2. **Integration Tests:** Integration tests for authentication flow (login, signup, callback) implemented.
3. **Component Tests:** Component tests for critical forms (transaction, card, commitment) implemented.
4. **Types:** `npm run build` and `npx tsc --noEmit` run without errors; `any` and `unknown` types removed where unnecessary.
5. **PWA:** Tested on mobile environments and offline caching working.

## Required Commands
- `npm run lint`
- `npx tsc --noEmit`
- `npm test`
- `npm run build`

## Gates
- Lint, Build, and Tests must be perfectly green.
- No new security vulnerabilities.

## Dependencies & Constraints
- Must resolve the inherited `npm test` failures before implementing new features or tests.

## Next Permitted Step for Verdicts
- **PREFLIGHT -> BASELINE**: Run `npm test`, document failures (Completed).
- **BASELINE -> IMPLEMENTING**: Fix baseline tests.
- **IMPLEMENTING -> VERIFYING**: Run gates and record evidence.
