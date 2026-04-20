<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests

## Purpose
Full conformance and integration test suite for `rules_bun`. Organized by rule under test. Most tests are shell scripts that invoke Bazel and assert on output shape, exit codes, or file content. Some subdirectories contain TypeScript test fixtures used by `bun_test` targets.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Top-level test suite aggregation target |
| `nested_bazel_test.sh` | Tests behavior when rules_bun is used within a nested Bazel workspace |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `binary_test/` | Tests for `bun_binary` rule: PATH staging, env, flags, launcher shape (see `binary_test/AGENTS.md`) |
| `bun_test_test/` | Tests for `bun_test` rule: cache behavior, JUnit output, suite configuration (see `bun_test_test/AGENTS.md`) |
| `bundle_test/` | Tests for `bun_bundle`, `bun_build`, `bun_compile`: output shape, sourcemaps, minification (see `bundle_test/AGENTS.md`) |
| `ci_test/` | CI matrix shape and native wrapper validation (see `ci_test/AGENTS.md`) |
| `install_extension_test/` | Tests for `bun_install` Bzlmod extension output shape (see `install_extension_test/AGENTS.md`) |
| `install_test/` | Tests for `bun_install` behavior: determinism, lifecycle scripts, workspace parity (see `install_test/AGENTS.md`) |
| `integration_test/` | End-to-end tests that build and run example projects (see `integration_test/AGENTS.md`) |
| `js_compat_test/` | Tests for the `js` compat layer: js_binary, js_library, devserver (see `js_compat_test/AGENTS.md`) |
| `library_test/` | Tests for `js_library` and `ts_library` rules (see `library_test/AGENTS.md`) |
| `npm_compat_test/` | Tests for `npm_translate_lock` compat extension (see `npm_compat_test/AGENTS.md`) |
| `script_test/` | Tests for `bun_script` rule across Vite apps, monorepos, and workspace scripts (see `script_test/AGENTS.md`) |
| `toolchain_test/` | Tests for toolchain resolution across platforms and versions (see `toolchain_test/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- Shell test scripts follow a consistent `verify_*.sh` naming pattern for shape/output assertions
- Test fixtures (TypeScript files, `package.json`, `bun.lock`) are co-located in each test subdirectory
- Run the full suite: `bazel test //tests/...`
- Tests that modify install state use isolated temp directories — do not rely on host node_modules

### Testing Requirements
```bash
bazel test //tests/...
```

<!-- MANUAL: -->
