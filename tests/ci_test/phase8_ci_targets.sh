#!/usr/bin/env bash
set -euo pipefail

phase8_target="${1:-}"
if [[ -z ${phase8_target} ]]; then
  echo "Error: phase8 target required as first argument" >&2
  exit 1
fi

case "${phase8_target}" in
linux-x64 | darwin-arm64)
  printf '%s\n' "//tests/..."
  ;;
windows)
  printf '%s\n' \
    "//tests/binary_test/..." \
    "//tests/bun_test_test/..." \
    "//tests/ci_test/..." \
    "//tests/js_compat_test/..." \
    "//tests/script_test/..." \
    "//tests/toolchain_test/..."
  ;;
*)
  echo "Error: unsupported phase8 target: ${phase8_target}" >&2
  exit 1
  ;;
esac
