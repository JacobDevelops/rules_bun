<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests/install_extension_test

## Purpose
Tests the output shape of the `bun_install` Bzlmod extension and the `npm_translate_lock` compat extension. Validates that the generated external repository has the expected `BUILD.bazel`, `defs.bzl`, and `packages.bzl` structure.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Test target declarations |
| `extension_shape_test.sh` | Validates `bun_install` extension output shape |
| `npm_extension_shape_test.sh` | Validates `npm_translate_lock` extension output shape |

## For AI Agents

### Working In This Directory
- Run when modifying `//internal:bun_install.bzl` rendering functions (`_render_repo_build`, `_render_repo_defs_bzl`, `_render_package_targets_file`)
- Run when modifying `//npm:extensions.bzl`

### Testing Requirements
```bash
bazel test //tests/install_extension_test/...
```

<!-- MANUAL: -->
