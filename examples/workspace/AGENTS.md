<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# examples/workspace

## Purpose
npm workspace example with two packages (`pkg-a`, `pkg-b`) managed via a root `bun_install`. Demonstrates how `bun_install` handles workspace package discovery and linking in a multi-package repository.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Bazel targets for the workspace example |
| `package.json` | Root workspace manifest with `workspaces: ["packages/*"]` |
| `README.md` | Usage instructions |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `packages/pkg-a/` | First workspace package |
| `packages/pkg-b/` | Second workspace package, may depend on pkg-a |

## For AI Agents

### Working In This Directory
- Tested by `//tests/integration_test:examples_workspace_bundle_e2e_test` and `examples_workspace_catalog_shape_test`
- Demonstrates the workspace package materialization logic in `//internal:bun_install.bzl`

### Testing Requirements
```bash
bazel test //tests/integration_test:examples_workspace_bundle_e2e_test
bazel test //tests/integration_test:examples_workspace_catalog_shape_test
```

<!-- MANUAL: -->
