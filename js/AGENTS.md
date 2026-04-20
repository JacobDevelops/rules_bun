<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# js

## Purpose
`rules_js`-compatible public API surface backed by Bun. Allows projects that already use `@aspect_rules_js` patterns to adopt `rules_bun` with minimal changes by loading from `@rules_bun//js:defs.bzl` instead of `@aspect_rules_js//js:defs.bzl`. This is a compatibility subset, not a full reimplementation of `rules_js`.

## Key Files

| File | Description |
|------|-------------|
| `defs.bzl` | Re-exports `js_binary`, `js_test`, `js_run_devserver`, `js_library`, `ts_library`, and `JsInfo` from `//internal:js_compat.bzl` |
| `BUILD.bazel` | Package visibility and export declarations |

## For AI Agents

### Working In This Directory
- Do not add symbols here that are not already in `//internal:js_compat.bzl`
- The compatibility guarantee is intentionally narrow: only the most common `rules_js` entrypoints
- Package aliases from `npm_link_all_packages()` use sanitized names like `npm__vite` or `npm__at_types_node`

### Testing Requirements
```bash
bazel test //tests/js_compat_test/...
```

### Common Patterns
```starlark
load("@rules_bun//js:defs.bzl", "js_binary")
load("@npm//:defs.bzl", "npm_link_all_packages")

npm_link_all_packages()

js_binary(
    name = "app",
    entry_point = "src/main.ts",
    node_modules = ":node_modules",
)
```

## Dependencies

### Internal
- `//internal:js_compat.bzl` — all symbols are re-exported from here

<!-- MANUAL: -->
