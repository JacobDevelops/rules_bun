<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# tests/bun_test_test

## Purpose
Conformance tests for the `bun_test` rule. Covers cache hit/miss behavior, JUnit XML output shape, test suite configuration, passing/failing test scenarios, and preload script support.

## Key Files

| File | Description |
|------|-------------|
| `BUILD.bazel` | Test target declarations |
| `passing.test.ts` | Fixture: a `bun_test` target that passes |
| `failing.test.ts` | Fixture: a `bun_test` target that fails — used to verify failure handling |
| `preload.ts` | Preload script for testing `--preload` flag forwarding |
| `test.env` | Environment variable fixture for test env tests |
| `cache_hit_shape.sh` | Asserts that a passing test is cached by Bazel on second run |
| `cache_miss_shape.sh` | Asserts that a changed test correctly misses Bazel cache |
| `configured_suite_shape.sh` | Validates test suite configuration options |
| `failing_suite_shape.sh` | Validates that failing suites are reported correctly |
| `junit_shape.sh` | Validates JUnit XML output format and content |

## For AI Agents

### Working In This Directory
- When modifying `//internal:bun_test.bzl`, run this full suite
- JUnit shape tests verify the XML schema — ensure output is compatible with CI systems that consume JUnit reports
- The `failing.test.ts` fixture is intentionally failing; its BUILD target must be tagged appropriately to avoid blocking CI

### Testing Requirements
```bash
bazel test //tests/bun_test_test/...
```

<!-- MANUAL: -->
