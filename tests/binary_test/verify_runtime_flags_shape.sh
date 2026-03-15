#!/usr/bin/env bash
set -euo pipefail

binary="$1"

grep -Fq -- '--no-install' "${binary}"
grep -Fq -- '--preload' "${binary}"
grep -Fq -- '--env-file' "${binary}"
