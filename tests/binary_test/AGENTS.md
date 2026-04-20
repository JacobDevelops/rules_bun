<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests/binary_test

## Purpose
Conformance tests for the `bun_binary` rule. Verifies that the runtime launcher correctly stages hermetic `bun`/`bunx`/`node` on PATH, that environment variables are propagated correctly, that runtime flags are forwarded, and that the launcher binary shape matches expectations.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Test target declarations |
| `hello.ts` / `hello.js` | Simple entry points for binary smoke tests |
| `env.ts` | Entry point that prints environment variables — used to verify env propagation |
| `flag_probe.ts` | Entry point that probes runtime flags |
| `path_probe.ts` | Entry point that prints PATH entries — verifies hermetic PATH staging |
| `preload.ts` | Preload script fixture |
| `payload.txt` | Data file included as a runfile |
| `runtime.env` | Environment variable fixture file |
| `run_binary.sh` | Invokes a `bun_binary` target and checks output |
| `run_env_binary.sh` | Invokes env-variable binary and asserts env shape |
| `run_flag_binary.sh` | Invokes flag-probe binary and asserts flags |
| `run_path_binary.sh` | Invokes path-probe binary and asserts PATH hermiticity |
| `run_parent_env_binary.sh` | Tests env inheritance from parent processes |
| `verify_configured_launcher_shape.sh` | Asserts the launcher script structure |
| `verify_data_shape.sh` | Asserts runfiles data layout |
| `verify_runtime_flags_shape.sh` | Asserts runtime flag forwarding |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `env_parent/src/` | TypeScript source for parent-env inheritance test case |

## For AI Agents

### Working In This Directory
- Tests here directly validate `//internal:bun_binary.bzl` and `//internal:runtime_launcher.js`
- When modifying PATH-staging behavior in `runtime_launcher.js`, run this entire test suite
- Shell tests follow the pattern: invoke binary → capture output → assert with `grep` or `diff`

### Testing Requirements
```bash
bazel test //tests/binary_test/...
```

<!-- MANUAL: -->
