<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests/npm_compat_test

## Purpose
Tests for the `npm_translate_lock` Bzlmod extension in `//npm:extensions.bzl`. Validates that the compat wrapper correctly delegates to `bun_install_repository` and produces the expected external repo structure.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Test target declarations |
| `npm_translate_lock_workspace_test.sh` | Validates the workspace shape produced by `npm_translate_lock` |

## For AI Agents

### Working In This Directory
- Run when modifying `//npm:extensions.bzl`

### Testing Requirements
```bash
bazel test //tests/npm_compat_test/...
```

<!-- MANUAL: -->
