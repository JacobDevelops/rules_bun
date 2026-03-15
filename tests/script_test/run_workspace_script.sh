#!/usr/bin/env bash
set -euo pipefail

script_bin="$1"
output="$(${script_bin})"

if [[ ${output} != *"pkg-a"* ]]; then
  echo "Expected workspace run output to include pkg-a: ${output}" >&2
  exit 1
fi

if [[ ${output} == *"pkg-b"* ]]; then
  echo "Workspace filter unexpectedly included pkg-b: ${output}" >&2
  exit 1
fi
