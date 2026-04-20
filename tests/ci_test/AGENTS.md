<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests/ci_test

## Purpose
Validates CI-level invariants: the phase-8 CI target matrix shape, native wrapper binary shape, and that CI test targets resolve correctly. These tests guard against accidental changes to the build graph that would break CI.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Test target declarations |
| `phase8_ci_matrix_shape_test.sh` | Validates the CI test matrix configuration shape |
| `phase8_ci_targets.sh` | Enumerates expected CI targets |
| `phase8_ci_targets_test.sh` | Asserts CI targets are present and correctly labeled |
| `verify_native_wrapper_shape.sh` | Validates the native platform wrapper binary structure |

## For AI Agents

### Working In This Directory
- These tests validate build graph invariants — failures here mean a structural change broke CI
- Run before and after any changes to toolchain registration or platform constraints

### Testing Requirements
```bash
bazel test //tests/ci_test/...
```

<!-- MANUAL: -->
