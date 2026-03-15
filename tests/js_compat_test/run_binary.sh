#!/usr/bin/env bash
set -euo pipefail

binary="$1"
output="$("${binary}")"

if [[ ${output} != "helper:payload-from-lib compat-mode" ]]; then
  echo "unexpected output: ${output}" >&2
  exit 1
fi
