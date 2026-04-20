<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# bun

## Purpose
Public API layer for `rules_bun`. This directory is the only surface users load from — `@rules_bun//bun:defs.bzl` re-exports every public rule from `//internal`. Also owns the Bzlmod extensions (`bun` for toolchain repos, `bun_install` for node_modules repos), the toolchain definition, and per-platform version/sha256 metadata.

## Key Files

| File | Description |
|------|-------------|
| `defs.bzl` | **Main entrypoint** — re-exports all public rules and providers from `//internal` |
| `extensions.bzl` | Bzlmod extensions: `bun` (downloads platform binaries) and `bun_install` (runs `bun install` into an external repo) |
| `toolchain.bzl` | `BunToolchainInfo` provider + `bun_toolchain` rule definition |
| `version.bzl` | `BUN_VERSION` constant used by both `extensions.bzl` and `BUILD.bazel` toolchain targets |
| `repositories.bzl` | Legacy WORKSPACE macro `bun_register_toolchains` for non-Bzlmod consumers |
| `BUILD.bazel` | Declares toolchain targets for all supported platforms and `bzl_library` targets for Stardoc |

## For AI Agents

### Working In This Directory
- Only add symbols to `defs.bzl` when they belong in the public API; implementation goes in `//internal`
- `extensions.bzl` contains the SHA-256 hashes for each Bun release asset — update all entries together when bumping `version.bzl`
- `BUILD.bazel` registers toolchains for: `linux_x64`, `linux_aarch64`, `darwin_x64`, `darwin_aarch64`, `windows_x64`
- The `bun_install` tag class in `extensions.bzl` mirrors `bun_install_repository` attrs in `//internal:bun_install.bzl`

### Testing Requirements
```bash
bazel test //tests/toolchain_test/...
bazel test //tests/install_extension_test/...
```

### Common Patterns
```starlark
# Bzlmod consumer usage
bun_ext = use_extension("@rules_bun//bun:extensions.bzl", "bun")
use_repo(bun_ext, "bun_darwin_aarch64", ...)
register_toolchains("@rules_bun//bun:darwin_aarch64_toolchain", ...)
```

## Dependencies

### Internal
- `//internal:bun_install.bzl` — `bun_install_repository` repository rule used by `extensions.bzl`
- All `//internal:*_bzl` bzl_library targets — consumed by `defs_bzl` for Stardoc

### External
- `@bazel_skylib//:bzl_library.bzl` — bzl_library rule for documentation targets
- `@bun_<platform>//:bun` — hermetic Bun binary fetched by `extensions.bzl`

<!-- MANUAL: -->
