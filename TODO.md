# TODO: bun_golang_monorepo example

Add `examples/bun_golang_monorepo/` — a minimal but realistic reference showing `rules_bun` and
`rules_go` coexisting in a single Bzlmod workspace, with Nix-provided toolchains and a shared Bun
workspace. All of the patterns below were validated in a real production monorepo; the example
should exercise each one so users have a working template to copy from.

---

## Repo layout

```
examples/bun_golang_monorepo/
├── MODULE.bazel              # rules_bun + rules_go + Nix extensions
├── MODULE.bazel.lock
├── BUILD.bazel               # nix_host platform + bun_toolchain registration
├── .bazelrc                  # see flags section below
├── extension.bzl             # nix_toolchains + bun_packages extensions
├── flake.nix                 # dev shell: bazelisk, go, bun
├── flake.lock
├── go.work                   # covers apps/api and any other Go modules
├── package.json              # workspace root — lists all TS packages
├── bun.lock                  # single lockfile for entire workspace
├── apps/
│   ├── api/                  # Go HTTP service
│   │   ├── go.mod            # module github.com/example/api, go 1.26
│   │   ├── BUILD.bazel
│   │   ├── cmd/server/
│   │   │   ├── main.go
│   │   │   └── BUILD.bazel
│   │   └── internal/
│   │       ├── handler/
│   │       │   ├── handler.go
│   │       │   ├── handler_test.go
│   │       │   └── BUILD.bazel
│   │       └── config/
│   │           ├── config.go
│   │           └── BUILD.bazel
│   └── web/                  # TypeScript/Bun app
│       ├── package.json      # name: "@example/web"
│       ├── BUILD.bazel
│       ├── src/
│       │   └── index.ts
│       └── test/             # IMPORTANT: directory named "test"
│           ├── index.test.ts
│           └── BUILD.bazel   # bun_test named "suite" NOT "test" — see Pitfall #1
└── README.md
```

---

## MODULE.bazel patterns to demonstrate

### 1. rules_bun via git_override (pinned commit)

```python
bazel_dep(name = "rules_bun", version = "0.0.0")
git_override(
    module_name = "rules_bun",
    commit = "<full-40-char-sha>",
    remote = "https://github.com/JacobDevelops/rules_bun.git",
)
# local_path_override(
#     module_name = "rules_bun",
#     path = "../rules_bun",  # uncomment when iterating locally
# )
```

Show the `local_path_override` pattern commented out alongside `git_override` so users know the
iteration workflow.

### 2. rules_go (Bazel-managed SDK, NOT from Nix)

```python
bazel_dep(name = "rules_go", version = "0.60.0")
```

`rules_nixpkgs_go` is incompatible with rules_go v0.60+. The Go SDK must come from rules_go's own
download, separate from the Nix shell. Document this explicitly.

### 3. Nix toolchains for Bun (not Go)

```python
nix_toolchains = use_extension("//:extension.bzl", "nix_toolchains")
use_repo(nix_toolchains, "nix_bun", "nixpkgs")
```

Bun comes from Nix so the dev shell (`nix develop`) and Bazel use the exact same binary, pinned by
`flake.lock`. Go does not — rules_go handles its own hermetic SDK download.

### 4. Single shared @npm repository

```python
bun_packages = use_extension("//:extension.bzl", "bun_packages")
use_repo(bun_packages, "npm")
```

One `bun_install_repository` from the root `bun.lock` serves all TS packages. No per-package
lockfiles.

### 5. Toolchain registration

```python
register_toolchains("//:nix_bun_toolchain")
```

Explain WHY this lives in MODULE.bazel rather than extension.bzl: Bazel 9 visibility rules prevent
repos created by module extensions from referencing targets in other external repos (e.g.
`@rules_bun//bun:toolchain_type`).

### 6. go_deps via go.work

```python
go_deps = use_extension("@gazelle//:extensions.bzl", "go_deps")
go_deps.from_file(go_work = "//:go.work")
use_repo(go_deps, ...)
```

`go.work` covers all Go modules so Gazelle produces a single unified dependency graph.

---

## .bazelrc flags to demonstrate

```ini
build --host_platform=//:nix_host
build --keep_going
build --show_result=100
build --@rules_go//go/config:pure=true   # disables CGo globally; Nix clang can't resolve -lresolv
test  --keep_going
test  --test_output=streamed
```

`--@rules_go//go/config:pure=true` is the key flag. Document why: the Nix-wrapped clang can't
resolve macOS's `-lresolv`, so CGo must be disabled globally. Any target that explicitly needs CGo
can override with `pure = "off"` in its `go_binary` / `go_test` rule.

---

## BUILD.bazel (root) patterns to demonstrate

### nix_host platform

```python
platform(
    name = "nix_host",
    parents = ["@local_config_platform//:host"],
    exec_properties = {"OSFamily": ""},
)
```

Needed for Bazel 9 Nix toolchain compatibility (`rules_nixpkgs_cc` is incompatible with Bazel 9).

### bun_toolchain wiring

```python
load("@rules_bun//bun:defs.bzl", "bun_toolchain")

bun_toolchain(
    name = "nix_bun_toolchain_impl",
    bun = "@nix_bun//:bin/bun",
)

toolchain(
    name = "nix_bun_toolchain",
    exec_compatible_with = [...],
    target_compatible_with = [...],
    toolchain = ":nix_bun_toolchain_impl",
    toolchain_type = "@rules_bun//bun:toolchain_type",
)
```

---

## Go app patterns to demonstrate

### go_binary with pure build

The `.bazelrc` `pure=true` flag propagates automatically. No per-target annotation needed unless
overriding.

### golangci-lint via `go tool` directive (Go 1.25+)

In `apps/api/go.mod`:
```
tool github.com/golangci/golangci-lint/v2/cmd/golangci-lint
```

In the lint shell script:
```bash
export CGO_ENABLED=0    # explicit belt-and-suspenders even with pure=true
exec go tool golangci-lint run ./...
```

Why `go tool` instead of the Nix golangci-lint binary: the Nix binary panics on `go 1.26` modules.
Using `go tool` ties the linter to the same Go toolchain that compiled the code.

### cp -rL for //go:embed in Bazel lint targets

Bazel runfiles are a symlink farm. `//go:embed` rejects non-regular files. The lint wrapper must
dereference symlinks before running:

```bash
MODULE_SRC="${RUNFILES_DIR}/_main/apps/api"
MODULE_DIR=$(mktemp -d)
trap 'rm -rf "$MODULE_DIR"' EXIT
cp -rL "$MODULE_SRC/." "$MODULE_DIR/"
cd "$MODULE_DIR"
```

Show this in the example's `lint_test.sh`.

---

## TypeScript/Bun app patterns to demonstrate

### Pitfall #1 — never name a bun_test target "test" if a "test/" directory exists

Bazel places `DefaultInfo.executable` at `_main/{pkg}/{target_name}` in runfiles. A target named
`test` in a package that also has a `test/` source directory causes a runfiles collision: the
executable wrapper shadows the source directory, and Bun can't resolve the test files.

**Fix**: name the target something other than `test` — e.g. `suite` or `tests`.

```python
# apps/web/test/BUILD.bazel
bun_test(
    name = "suite",   # NOT "test" — would collide with the test/ directory
    srcs = glob(["*.test.ts"]),
)
```

Alternatively, expose the target at the package level:
```python
# apps/web/BUILD.bazel
bun_test(
    name = "test",    # safe here — package root has no test/ directory at this level
    srcs = ["//apps/web/test:suite"],
)
```

The `_runner` wrapper suffix in `bun_test.bzl` is the underlying fix that makes this work, but
users still need to know the naming constraint.

### Shared @npm across all TS packages

```python
# apps/web/BUILD.bazel
load("@rules_bun//bun:defs.bzl", "bun_test")

bun_test(
    name = "test",
    srcs = glob(["test/*.test.ts"]),
    node_modules = "@npm//:node_modules",
)
```

One `@npm` for the whole monorepo — no per-package `bun_install`.

---

## README.md for the example

Should cover:
1. Prerequisites: `nix develop` or compatible Bun + Go versions
2. Build all: `bazel build //...`
3. Test all: `bazel test //...`
4. Per-app commands with expected output
5. Explanation of the Go-only vs Bun-only vs shared patterns
6. Link back to the main `rules_bun` README for toolchain setup

---

## Acceptance criteria

- [ ] `bazel test //examples/bun_golang_monorepo/...` passes from a clean build
- [ ] Both Go tests (`//apps/api/internal/handler:handler_test`) and Bun tests (`//apps/web:test`) pass
- [ ] Go lint target runs golangci-lint via `go tool` (not Nix binary)
- [ ] TypeScript typecheck target passes
- [ ] `.bazelrc` `pure=true` flag is present and documented
- [ ] `cp -rL` pattern is present in the lint wrapper
- [ ] `bun_test` target naming pitfall is documented in the example README
- [ ] `local_path_override` commented-out pattern present in MODULE.bazel
- [ ] Clean `bazel build //...` produces no warnings about unused deps or missing files
