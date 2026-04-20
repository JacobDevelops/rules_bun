<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests/integration_test

## Purpose
End-to-end integration tests that build and run the example projects in `//examples`. These are the highest-level tests in the suite — they verify that the full user journey (MODULE.bazel → bun_install → bun_script/bun_binary → run) works correctly.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Test target declarations |
| `examples_basic_e2e_build_test.sh` | Builds `//examples/basic` and verifies output |
| `examples_basic_run_e2e_test.sh` | Runs `//examples/basic` binary and checks stdout |
| `examples_basic_hot_restart_shape_test.sh` | Validates hot-restart shape for the basic example |
| `examples_vite_monorepo_e2e_test.sh` | Builds Vite monorepo apps end-to-end |
| `examples_vite_monorepo_catalog_shape_test.sh` | Validates catalog shape for vite_monorepo |
| `examples_workspace_bundle_e2e_test.sh` | Builds and bundles workspace packages |
| `examples_workspace_catalog_shape_test.sh` | Validates catalog shape for workspace example |
| `repo_all_targets_test.sh` | Builds `//...` to verify no target is broken |

## For AI Agents

### Working In This Directory
- These tests are slow — they invoke full Bazel builds inside the test
- `repo_all_targets_test.sh` is the most comprehensive: it builds every target in the repo
- Run after any structural change to `examples/` or to the rule implementations

### Testing Requirements
```bash
bazel test //tests/integration_test/...
```

<!-- MANUAL: -->
