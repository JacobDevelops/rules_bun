#!/usr/bin/env bash
set -euo pipefail

binary="$1"

grep -Fq -- 'watch_mode="hot"' "${binary}"
grep -Fq -- 'bun_args+=("--hot")' "${binary}"
grep -Fq -- '--no-clear-screen' "${binary}"
grep -Fq -- 'if [[ 1 -eq 0 ]]; then' "${binary}"
grep -Fq -- 'readarray -t restart_paths' "${binary}"
grep -Fq -- 'examples/basic/README.md' "${binary}"
