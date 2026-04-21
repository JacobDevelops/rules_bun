# bun_golang_monorepo example

A minimal but realistic reference for running `rules_bun` and `rules_go` together
in a single Bzlmod workspace, with a Nix-pinned Bun toolchain and a shared Bun
workspace for all TypeScript packages.

All patterns here were validated in a real production monorepo.

---

## Prerequisites

| Tool | Source | Notes |
|------|--------|-------|
| Nix | [nixos.org](https://nixos.org/download) | Required for `nix develop` |
| Bazelisk | via Nix devshell | `bazelisk` wraps Bazel version management |
| Go | via Nix devshell | Local development only; Bazel downloads its own SDK |
| Bun | via Nix devshell | Pinned by `flake.lock`; same binary used by Bazel |

Enter the dev shell:

```bash
nix develop
```

---

## Setup

### 1. Pin rules_bun

Replace the placeholder in `MODULE.bazel` with the full 40-character commit SHA:

```python
git_override(
    module_name = "rules_bun",
    commit = "YOUR_ACTUAL_40_CHAR_SHA_HERE",
    remote = "https://github.com/JacobDevelops/rules_bun.git",
)
```

For local iteration against a checkout of rules_bun, comment out `git_override`
and uncomment `local_path_override`:

```python
# local_path_override(
#     module_name = "rules_bun",
#     path = "../..",
# )
```

### 2. Install npm packages

```bash
bun install
```

This generates `bun.lock`.

### 3. Generate the Bazel module lock

```bash
bazel mod lock
```

---

## Build & test

```bash
# Build everything
bazel build //...

# Test everything
bazel test //...

# Go API only
bazel build //apps/api/cmd/server
bazel test //apps/api/internal/handler:handler_test

# TypeScript web app only
bazel test //apps/web:test
```

---

## Key patterns demonstrated

### Go SDK — Bazel-managed, not Nix

`rules_go` downloads its own hermetic Go SDK.  **Do not** add `rules_nixpkgs_go`
to `MODULE.bazel` — it is incompatible with `rules_go` v0.60+.  The Nix devshell
provides Go for running tools locally (e.g. `go tool golangci-lint`), but Bazel
uses its own download.

### CGo disabled globally

```ini
build --@rules_go//go/config:pure=true
```

The Nix-wrapped clang cannot resolve macOS's `-lresolv` system library, which CGo
links against for DNS.  Disabling CGo globally avoids the linker error with no
runtime impact for typical HTTP services.  Opt individual targets back in with
`pure = "off"` on their `go_binary` / `go_test` rule.

### Toolchain registration in MODULE.bazel

The `register_toolchains("//:nix_bun_toolchain")` call lives in `MODULE.bazel`,
not in `extension.bzl`.  Bazel 9 visibility rules prevent repositories created by
module extensions from referencing targets in other external repositories (such as
`@rules_bun//bun:toolchain_type`).

### Single @npm for the whole monorepo

One `bun_install_repository` serves all TypeScript packages from the root
`bun.lock`.  No per-package lockfiles needed.

### bun_test naming pitfall — never name a target "test" if a test/ directory exists

Bazel places `DefaultInfo.executable` at `_main/{pkg}/{target_name}` in runfiles.
A target named `test` in a package that also has a `test/` source directory causes
a runfiles collision: the executable wrapper shadows the source directory, and Bun
cannot resolve the test files.

**Fix**: name the target something other than `test` — e.g. `suite`.

```python
# apps/web/test/BUILD.bazel
bun_test(
    name = "suite",   # NOT "test" — would collide with the test/ directory
    srcs = glob(["*.test.ts"]),
    data = ["//apps/web:src"],
    node_modules = "@npm//:node_modules",
)
```

This pitfall is why `apps/web/test/BUILD.bazel` uses `suite`, while
`apps/web/BUILD.bazel` (which has no `test/` sibling directory at that level) can
safely use `test`.

### golangci-lint via go tool (Go 1.25+)

```
# apps/api/go.mod
tool github.com/golangci/golangci-lint/v2/cmd/golangci-lint
```

Using `go tool` ties the linter version to the same Go toolchain that compiled the
code.  The Nix golangci-lint binary panics on `go 1.26` modules.

### cp -rL for go:embed in Bazel lint targets

Bazel runfiles are a symlink farm.  `//go:embed` rejects non-regular files.  The
`lint_test.sh` wrapper dereferences symlinks before running:

```bash
MODULE_SRC="${RUNFILES_DIR}/_main/apps/api"
MODULE_DIR=$(mktemp -d)
trap 'rm -rf "$MODULE_DIR"' EXIT
cp -rL "$MODULE_SRC/." "$MODULE_DIR/"
cd "$MODULE_DIR"
```

---

## Directory layout

```
.
├── MODULE.bazel          # rules_bun + rules_go + Nix extensions
├── BUILD.bazel           # nix_host platform + bun_toolchain registration
├── .bazelrc              # pure=true + nix_host + keep_going
├── extension.bzl         # nix_toolchains + bun_packages extensions
├── flake.nix             # devShell: bazelisk, go, bun
├── go.work               # Go workspace covering apps/api
├── package.json          # workspace root listing all TS packages
├── bun.lock              # single lockfile for the whole monorepo
├── apps/
│   ├── api/              # Go HTTP service
│   │   ├── go.mod        # module github.com/example/api, go 1.26
│   │   ├── lint_test.sh  # cp -rL + go tool golangci-lint
│   │   ├── cmd/server/   # go_binary entrypoint
│   │   └── internal/
│   │       ├── handler/  # HTTP handler + handler_test
│   │       └── config/   # environment config
│   └── web/              # TypeScript/Bun app
│       ├── src/index.ts  # library code
│       └── test/         # test/ dir — target named "suite" not "test"
└── README.md
```

---

## Further reading

- [rules_bun README](../../README.md) — toolchain setup, full API reference
- [rules_go](https://github.com/bazel-contrib/rules_go)
- [rules_nixpkgs](https://github.com/tweag/rules_nixpkgs)
