#!/usr/bin/env bash
set -euo pipefail

binary="$1"
shift

for expected in "$@"; do
  if ! grep -Fq -- "${expected}" "${binary}"; then
    echo "Expected ${binary} to contain ${expected}" >&2
    exit 1
  fi
done
