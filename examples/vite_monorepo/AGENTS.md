<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# examples/vite_monorepo

## Purpose
Monorepo example with two Vite applications (`app-a`, `app-b`) sharing node_modules via a root `bun_install`. Demonstrates `bun_script` for running Vite dev/build scripts and workspace-level dependency installation.

## Key Files

| File | Description |
|------|-------------|
| `MODULE.bazel` | Standalone module definition with `bun_install` for workspace node_modules |
| `MODULE.bazel.lock` | Lockfile for this example's module graph |
| `package.json` | Root workspace manifest with `workspaces` field listing `apps/*` |
| `bun.lock` | Bun lockfile for deterministic installs |
| `BUILD.bazel` | `bun_script` targets for building/running each app |
| `README.md` | Usage instructions |
| `run_vite_monorepo_apps.sh` | Helper script for running both apps simultaneously |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `apps/app-a/` | First Vite application |
| `apps/app-b/` | Second Vite application |

## For AI Agents

### Working In This Directory
- `bun.lock` must be kept in sync with `package.json` — run `bun install` locally to update
- Node_modules for this example are managed via `examples_vite_monorepo_node_modules` in the root `MODULE.bazel`
- Tested by `//tests/integration_test:examples_vite_monorepo_e2e_test`

### Testing Requirements
```bash
bazel test //tests/integration_test:examples_vite_monorepo_e2e_test
bazel test //tests/integration_test:examples_vite_monorepo_catalog_shape_test
```

<!-- MANUAL: -->
