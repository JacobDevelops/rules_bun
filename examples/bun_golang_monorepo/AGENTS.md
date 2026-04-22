<!-- Parent: ../AGENTS.md -->

# examples/bun_golang_monorepo

## Purpose
Reference example showing `rules_bun` and `rules_go` coexisting in a single Bzlmod
workspace, with a Nix-pinned Bun toolchain and a shared `@npm` repository.  Covers
the production patterns most frequently needed in Go+TypeScript monorepos.

## Key Files

| File | Description |
|------|-------------|
| `MODULE.bazel` | Standalone module: git_override for rules_bun, rules_go, Nix extensions, go_deps |
| `BUILD.bazel` | `nix_host` platform + `bun_toolchain` wiring |
| `.bazelrc` | `--host_platform`, `--pure=true`, `--keep_going` |
| `extension.bzl` | `nix_toolchains` and `bun_packages` module extensions |
| `flake.nix` | Nix devShell: bazelisk, go, bun |
| `go.work` | Go workspace covering `apps/api` |
| `package.json` | Bun workspace root listing all TS packages |
| `bun.lock` | Single lockfile for all npm packages |
| `README.md` | Setup guide + pattern explanations |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `apps/api/` | Go HTTP service with handler tests and golangci-lint via `go tool` |
| `apps/web/` | TypeScript/Bun app with shared `@npm`, demonstrating `bun_test` naming pitfall |

## For AI Agents

### Key invariants
- `MODULE.bazel.lock` and `flake.lock` are generated artifacts — regenerate with
  `bazel mod lock` and `nix flake update` respectively after dependency changes
- Do NOT add `rules_nixpkgs_go` to MODULE.bazel — incompatible with rules_go v0.60+
- `register_toolchains` MUST stay in MODULE.bazel, not in `extension.bzl` (Bazel 9
  visibility constraint)
- The `bun_test` target in `apps/web/test/BUILD.bazel` is named `suite`, not `test` —
  changing it to `test` causes a runfiles collision with the `test/` directory

### Testing
```bash
# From within this directory with nix develop active:
bazel test //...
```

<!-- MANUAL: -->
