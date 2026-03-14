#!/usr/bin/env bash
set -euo pipefail

binary="$1"
output="$(${binary})"

if [[ ${output} != "compiled-cli" ]]; then
  echo "Unexpected output from compiled binary ${binary}: ${output}" >&2
  exit 1
fi
