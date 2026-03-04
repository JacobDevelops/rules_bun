#!/usr/bin/env bash
set -euo pipefail

binary="$1"
output="$(${binary})"

if [[ ${output} != "from-parent-dotenv" ]]; then
  echo "Expected .env value from parent directory, got: ${output}" >&2
  exit 1
fi
