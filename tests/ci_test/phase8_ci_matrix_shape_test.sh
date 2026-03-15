#!/usr/bin/env bash
set -euo pipefail

workflow_file="$1"
if [ -z "${workflow_file}" ]; then
  echo "Error: workflow file path required as first argument" >&2
  exit 1
fi

check_pattern() {
  local pattern="$1"
  local message="$2"
  if ! grep -Eq "${pattern}" "${workflow_file}"; then
    echo "Error: ${message}" >&2
    exit 1
  fi
}

check_pattern '^name:[[:space:]]+CI$' "missing workflow name CI"
check_pattern 'USE_BAZEL_VERSION:[[:space:]]+9\.0\.1' "missing Bazel 9.0.1 pin"
check_pattern 'os:[[:space:]]+ubuntu-latest' "missing ubuntu matrix entry"
check_pattern 'phase8_target:[[:space:]]+linux-x64' "missing linux-x64 matrix target"
check_pattern 'os:[[:space:]]+macos-14' "missing macos matrix entry"
check_pattern 'phase8_target:[[:space:]]+darwin-arm64' "missing darwin-arm64 matrix target"

has_windows_os=0
has_windows_target=0
if grep -Eq 'os:[[:space:]]+windows-latest' "${workflow_file}"; then
  has_windows_os=1
fi
if grep -Eq 'phase8_target:[[:space:]]+windows' "${workflow_file}"; then
  has_windows_target=1
fi
if [[ ${has_windows_os} -ne ${has_windows_target} ]]; then
  echo "Error: windows matrix entry and windows phase8 target must be added or removed together" >&2
  exit 1
fi
echo "CI matrix shape checks passed"
