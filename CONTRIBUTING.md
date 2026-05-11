# Contributing to Stellink

Thanks for considering a contribution. Stellink is a small, focused codebase — the goal is to keep it that way.

## Ground rules

- **Pick an issue first.** Open work lives on the [issue tracker](https://github.com/SustainOpen/Stellink/issues). Comment on the one you want to tackle so we can avoid double-up.
- **Keep PRs scoped.** One concern per PR. If a refactor finds a bug, open a separate PR for the fix.
- **Match the existing code style.** TypeScript strict, no `any` unless commented, ESLint passes, Tailwind utility classes only, no emojis in source unless asked.
- **Tests for contract changes.** Anything inside `contracts/` ships with `cargo test` coverage. Frontend has no test harness yet — see [ROADMAP.md](./ROADMAP.md) if you want to lay one down.

## Branch + PR workflow

```bash
# Fork + clone, then:
git checkout -b feat/<short-slug>
# ... make changes ...
npm run lint
npm run build
git commit -m "feat(escrow): handle USDC trustline auto-creation"
git push -u origin feat/<short-slug>
```

Open a PR against `main` with:

- A short summary of **what** changed and **why**.
- A note on testing — what you ran, what you observed.
- Screenshots for any user-visible UI change.

We use **Conventional Commits** for the title (`feat`, `fix`, `chore`, `docs`, `refactor`, `test`).

## Local setup checklist

| Step                                | Command                       |
|-------------------------------------|-------------------------------|
| Install deps                        | `npm install`                 |
| Start PocketBase                    | `npm run pb:setup` *or* `npm run pb:up` |
| Start dev server                    | `npm run dev`                 |
| Build frontend                      | `npm run build`               |
| Lint                                | `npm run lint`                |
| Build Soroban contract              | `npm run contracts:build`     |
| Test Soroban contract               | `npm run contracts:test`      |

## Architecture cheatsheet

| Layer                | Where                                        |
|----------------------|----------------------------------------------|
| Stellar tx builders  | `frontend/src/lib/stellar.ts`                |
| Network config       | `frontend/src/lib/configAddress.ts`          |
| Wallet integration   | `frontend/src/hooks/useStellarWallet.ts` + `frontend/src/lib/walletContext.tsx` |
| PocketBase client    | `frontend/src/lib/pocketbase.ts`             |
| Data access layer    | `frontend/src/lib/linkStore.ts`              |
| PocketBase schema    | `scripts/pocketbase-schema.json`             |
| Soroban contract     | `contracts/stellink-escrow/src/lib.rs`        |

Read [README.md](./README.md#architecture) before deeper changes.

## Reporting bugs

File an issue with:

1. Stellink version / commit hash
2. Browser + Freighter version
3. Network (testnet vs public)
4. Reproduction steps
5. What you expected vs what happened
6. Console logs / screenshots if relevant

## Maintainer responsibilities

A "maintainer" on this project is anyone with merge rights. Maintainers commit to:

- Triage incoming issues within 7 days
- Review PRs within 14 days (LGTM, request changes, or close with rationale)
- Tag releases following [SemVer](https://semver.org/) once we hit `v1.0.0`
- Keep the dependency tree current — quarterly bump cycle

If you'd like to step up to maintainer, open three meaningful PRs and ask in the discussion.

## Code of conduct

Be kind. Be specific. Don't ship code you don't understand. That's it.
