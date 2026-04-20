<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# npm

## Purpose
`rules_js`-compatible `npm_translate_lock` Bzlmod extension backed by `bun_install_repository`. Allows projects migrating from `rules_js` to use the familiar `npm_translate_lock` extension name while getting Bun-powered installs. The generated external repo produces `@<repo>//:defs.bzl` with `npm_link_all_packages()`.

## Key Files

| File | Description |
|------|-------------|
| `extensions.bzl` | Bzlmod `npm_translate_lock` module extension — thin wrapper around `bun_install_repository` |
| `repositories.bzl` | Legacy WORKSPACE stub (if present) |
| `BUILD.bazel` | Package visibility declarations |

## For AI Agents

### Working In This Directory
- `npm_translate_lock` accepts `name`, `package_json`, `lockfile` (not `bun_lockfile`), `install_inputs`, `isolated_home`
- The `lockfile` attribute maps to `bun_lockfile` in the underlying `bun_install_repository`
- This extension is a compatibility subset — do not add attributes that `bun_install_repository` does not support

### Testing Requirements
```bash
bazel test //tests/npm_compat_test/...
```

### Common Patterns
```starlark
# MODULE.bazel
npm_ext = use_extension("@rules_bun//npm:extensions.bzl", "npm_translate_lock")
npm_ext.translate(
    name = "npm",
    package_json = "//:package.json",
    lockfile = "//:bun.lock",
)
use_repo(npm_ext, "npm")
```

## Dependencies

### Internal
- `//internal:bun_install.bzl` — `bun_install_repository` used directly

<!-- MANUAL: -->
