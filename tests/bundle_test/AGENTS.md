<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests/bundle_test

## Purpose
Conformance tests for `bun_bundle`, `bun_build`, and `bun_compile` rules. Covers output shape, sourcemaps, minification, external dependency handling, collision detection for duplicate output names, hermetic build isolation, and flag forwarding.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Test target declarations |
| `main.ts` | Primary TypeScript bundle entry point |
| `cli.ts` | Entry point for `bun_compile` (standalone executable) tests |
| `out.js` / `out.js.map` | Expected bundle output fixtures for shape comparison |
| `fake_cross_bun.bin` | Stub binary used to test cross-compilation `compile_executable` path |
| `run_compiled_binary.sh` | Invokes a `bun_compile` output and asserts behavior |
| `verify_bundle.sh` | Asserts bundle output content |
| `verify_collision_outputs.sh` | Validates collision detection for duplicate output names |
| `verify_external_shape.sh` | Validates external dependency handling |
| `verify_flag_aquery.sh` | Uses `bazel aquery` to verify flags are forwarded correctly |
| `verify_hermetic_shape.sh` | Asserts hermetic isolation (no host PATH leakage) |
| `verify_minify.sh` | Validates minification output |
| `verify_site_build.sh` | Validates HTML site build output |
| `verify_site_build_meta.sh` | Validates metafile output for site builds |
| `verify_sourcemap_shape.sh` | Validates sourcemap file shape and content |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `collision_case/a/` | Fixture: first entry point in collision test |
| `collision_case/b/` | Fixture: second entry point with same output name |
| `site/` | HTML + CSS + TS site fixture for `bun_build` HTML entry point test |
| `sourcemap_case/` | TypeScript source fixture for sourcemap tests |

## For AI Agents

### Working In This Directory
- When modifying `//internal:bun_compile.bzl` or `//internal:bun_bundle.bzl`, run this suite
- `verify_flag_aquery.sh` uses `bazel aquery` — it is slower than other tests and requires a full analysis pass
- The `sourcemap_bundle__main.js` and `.map` files are checked-in expected outputs; regenerate them if the bundler output format changes

### Testing Requirements
```bash
bazel test //tests/bundle_test/...
```

<!-- MANUAL: -->
