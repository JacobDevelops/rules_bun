<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# rules_bun

## Purpose
Bazel ruleset providing rules for running, testing, building, compiling, bundling, and developing JavaScript and TypeScript code with the Bun runtime. The public API entrypoint is `@rules_bun//bun:defs.bzl`. Follows standard Bazel ruleset layout with a sharp separation between the public `bun/` layer and the private `internal/` implementation layer.

## Key Files

| File | Description |
|------|-------------|
| `MODULE.bazel` | Bzlmod module definition: declares dependencies, registers toolchains, wires up `bun_install` for test fixtures |
| `MODULE.bazel.lock` | Lockfile for MODULE.bazel dependency graph |
| `README.md` | User-facing documentation: public API overview, usage examples, hermeticity model |
| `BUILD.bazel` | Root BUILD file |
| `VERSION` | Current ruleset version string |
| `WORKSPACE` | Legacy WORKSPACE stub for non-Bzlmod consumers |
| `flake.nix` | Nix development environment |
| `flake.lock` | Nix flake lockfile |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `bun/` | Public API layer: toolchain, Bzlmod extensions, defs.bzl entrypoint (see `bun/AGENTS.md`) |
| `internal/` | All rule implementations — not loaded directly by users (see `internal/AGENTS.md`) |
| `js/` | rules_js-compatible shim exporting js_binary, js_test, js_library, ts_library, JsInfo (see `js/AGENTS.md`) |
| `npm/` | npm_translate_lock compat extension backed by bun_install (see `npm/AGENTS.md`) |
| `docs/` | Reference documentation, including auto-generated rules.md (see `docs/AGENTS.md`) |
| `examples/` | Usage samples: basic, workspace, vite_monorepo (see `examples/AGENTS.md`) |
| `tests/` | Full conformance and integration test suite (see `tests/AGENTS.md`) |
| `.github/` | GitHub Actions CI workflows (see `.github/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- The user-facing public API lives exclusively in `bun/defs.bzl` — never add public symbols directly to `internal/`
- All rule implementations go in `internal/`; `bun/defs.bzl` re-exports them
- Use `jj` (Jujutsu) for all VCS operations — not git
- Regenerate `docs/rules.md` after changing rule attribute schemas: `bazel build //docs:rules_md && cp bazel-bin/docs/rules.md docs/rules.md`
- Version is in `VERSION` and `bun/version.bzl` — keep them in sync on releases

### Testing Requirements
```bash
bazel test //tests/...
```

### Common Patterns
- Bzlmod extension pattern: `bun` extension (toolchain repos) + `bun_install` extension (node_modules repos)
- Hermeticity tiers: fully hermetic (`bun_build`, `bun_bundle`, `bun_compile`, `bun_test`), runfiles-only (`bun_binary`), non-hermetic fetch (`bun_install`), local helpers (`bun_script`, `bun_dev`, `js_run_devserver`)

## Dependencies

### External
- `bazel_skylib` 1.8.2 — Bazel utility library
- `platforms` 1.0.0 — Platform constraint definitions
- `rules_shell` 0.6.1 — Shell rule support
- `stardoc` 0.7.2 — Starlark documentation generator
- `rules_multirun` 0.9.0 (dev) — Parallel target execution for test harness

<!-- MANUAL: -->
