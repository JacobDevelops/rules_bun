#!/usr/bin/env bash
set -euo pipefail

binary="$1"
output="$(${binary})"

expected='{"preloaded":"yes","env":"from-env-file","argv":["one","two"]}'

if [[ ${output} != "${expected}" ]]; then
  echo "Unexpected output from ${binary}: ${output}" >&2
  exit 1
fi
