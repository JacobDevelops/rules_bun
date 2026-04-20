<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# examples/basic

## Purpose
Minimal example showing a single `bun_binary` target that runs a TypeScript entry point. Demonstrates the simplest possible `rules_bun` integration with no workspace packages or bundling.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Declares a `bun_binary` target pointing at `main.ts` |
| `main.ts` | TypeScript entry point — simple hello-world program |
| `README.md` | Example-specific usage instructions |

## For AI Agents

### Working In This Directory
- Keep this example minimal — it is the "getting started" reference
- The example is tested by `//tests/integration_test:examples_basic_e2e_build_test` and `examples_basic_run_e2e_test`

### Testing Requirements
```bash
bazel test //tests/integration_test:examples_basic_e2e_build_test
bazel test //tests/integration_test:examples_basic_run_e2e_test
```

<!-- MANUAL: -->
