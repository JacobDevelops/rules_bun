<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests/install_test

## Purpose
Behavioral tests for `bun_install_repository`: determinism across repeated runs, workspace package parity, lifecycle script handling, lockfile staleness detection, install flag forwarding, and workspace catalog support.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Test target declarations |
| `clean_install.sh` | Validates a clean install produces the expected node_modules layout |
| `determinism.sh` | Runs install twice and asserts identical output (no non-determinism) |
| `environment_shape.sh` | Validates the install environment (HOME isolation, PATH) |
| `install_flags_shape.sh` | Validates that `install_flags` attribute is forwarded correctly |
| `lifecycle_scripts.sh` | Tests `ignore_scripts = False` behavior |
| `repeatability.sh` | Asserts that re-running install with the same inputs is idempotent |
| `stale_lockfile.sh` | Validates that a modified lockfile triggers a reinstall |
| `workspace_parity.sh` | Asserts workspace package discovery matches `bun install` behavior |
| `workspaces.sh` | Tests workspace package linking |
| `workspaces_catalog.sh` | Tests catalog version resolution in workspace manifests |

## For AI Agents

### Working In This Directory
- Tests here exercise the repository rule in `//internal:bun_install.bzl`
- `determinism.sh` and `repeatability.sh` are the most important: any non-determinism breaks remote caching
- When modifying `_materialize_workspace_packages` or `_workspace_patterns`, run `workspace_parity.sh` and `workspaces.sh`

### Testing Requirements
```bash
bazel test //tests/install_test/...
```

<!-- MANUAL: -->
