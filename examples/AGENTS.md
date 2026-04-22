<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# examples

## Purpose
Usage samples demonstrating common `rules_bun` integration patterns. Each example is a self-contained Bazel package with its own README. These are referenced by integration tests in `//tests/integration_test` to verify they build and run end-to-end.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `basic/` | Minimal single-file Bun binary and TypeScript entry point (see `basic/AGENTS.md`) |
| `vite_monorepo/` | Multi-app Vite monorepo with `bun_install` workspace deps and `bun_script` runners (see `vite_monorepo/AGENTS.md`) |
| `workspace/` | npm workspace example with multiple packages linked via `bun_install` (see `workspace/AGENTS.md`) |
| `bun_golang_monorepo/` | rules_bun + rules_go + Nix toolchains in a single Bzlmod workspace — Go HTTP service, TypeScript/Bun app, shared @npm (see `bun_golang_monorepo/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Each example must stay buildable — integration tests (`//tests/integration_test`) run against them
- Examples intentionally avoid advanced features to stay beginner-readable; keep them simple
- When adding a new example, also add a corresponding integration test in `//tests/integration_test`
- Example `MODULE.bazel` files (if present) are standalone — they have their own lock files

### Testing Requirements
```bash
bazel test //tests/integration_test/...
```

<!-- MANUAL: -->
