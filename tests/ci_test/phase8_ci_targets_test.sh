#!/usr/bin/env bash
set -euo pipefail

resolver="${1:-}"
if [[ -z ${resolver} ]]; then
  echo "Error: resolver path required as first argument" >&2
  exit 1
fi

linux_targets="$("${resolver}" linux-x64)"
if [[ ${linux_targets} != "//tests/..." ]]; then
  echo "Error: linux-x64 should resolve to //tests/..." >&2
  exit 1
fi

darwin_targets="$("${resolver}" darwin-arm64)"
if [[ ${darwin_targets} != "//tests/..." ]]; then
  echo "Error: darwin-arm64 should resolve to //tests/..." >&2
  exit 1
fi

windows_targets="$("${resolver}" windows)"
expected_windows_targets="$(
  cat <<'EOF'
//tests/binary_test/...
//tests/bun_test_test/...
//tests/ci_test/...
//tests/js_compat_test/...
//tests/script_test/...
//tests/toolchain_test/...
EOF
)"
if [[ ${windows_targets} != "${expected_windows_targets}" ]]; then
  echo "Error: unexpected windows targets" >&2
  printf 'Expected:\n%s\nActual:\n%s\n' "${expected_windows_targets}" "${windows_targets}" >&2
  exit 1
fi

if "${resolver}" unsupported >/dev/null 2>&1; then
  echo "Error: unsupported phase8 target should fail" >&2
  exit 1
fi

echo "Phase 8 CI targets resolve correctly"
