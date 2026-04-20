<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests/toolchain_test

## Purpose
Tests for Bazel toolchain resolution. Validates that the correct Bun binary is selected for each platform/architecture combination and that the resolved toolchain version matches `BUN_VERSION`.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Test target declarations |
| `toolchain_resolution_matrix.sh` | Tests toolchain resolution across all registered platforms |
| `toolchain_version.sh` | Validates that the resolved toolchain version matches the expected `BUN_VERSION` |

## For AI Agents

### Working In This Directory
- Run when modifying `//bun:toolchain.bzl`, `//bun:extensions.bzl`, or `//bun:version.bzl`
- Run when adding or removing a supported platform

### Testing Requirements
```bash
bazel test //tests/toolchain_test/...
```

<!-- MANUAL: -->
