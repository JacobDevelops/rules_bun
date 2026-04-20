<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests/script_test

## Purpose
Tests for the `bun_script` rule across a variety of project shapes: single Vite app, Vite monorepo, npm workspace with parallel script execution, and Paraglide i18n monorepo. Validates environment variable propagation, launcher flag forwarding, and monorepo script isolation.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Test target declarations |
| `hello.ts` | Simple TypeScript entry point for basic script tests |
| `env.ts` | Entry point that prints env — validates env propagation |
| `package.json` | Root workspace manifest for script test fixtures |
| `run_script.sh` | Runs a basic `bun_script` target |
| `run_env_script.sh` | Runs env script and validates environment |
| `run_vite_app.sh` | Runs the Vite single-app script |
| `run_vite_monorepo_apps.sh` | Runs both apps in the Vite monorepo |
| `run_workspace_script.sh` | Runs a script in a workspace package |
| `run_workspace_parallel.sh` | Runs workspace scripts in parallel via `rules_multirun` |
| `run_paraglide_monorepo_builds.sh` | Builds Paraglide i18n monorepo packages |
| `verify_launcher_flags.sh` | Asserts that launcher flags are forwarded |
| `verify_monorepo_launcher_shape.sh` | Validates launcher structure for monorepo setups |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `vite_app/` | Single Vite app fixture with `bun.lock` |
| `vite_monorepo/` | Two-app Vite monorepo fixture with `bun.lock` |
| `workspace_run/` | npm workspace fixture with pkg-a and pkg-b |
| `paraglide_monorepo/` | Paraglide i18n monorepo fixture with build scripts |

## For AI Agents

### Working In This Directory
- Each fixture subdirectory has its own `bun.lock` — update with `bun install` when changing `package.json`
- Node_modules for these fixtures are managed via `script_test_*_node_modules` repos in root `MODULE.bazel`
- When modifying `//internal:bun_script.bzl`, run this entire suite

### Testing Requirements
```bash
bazel test //tests/script_test/...
```

<!-- MANUAL: -->
