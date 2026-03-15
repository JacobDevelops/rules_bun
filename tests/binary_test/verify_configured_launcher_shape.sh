#!/usr/bin/env bash
set -euo pipefail

binary="$1"

grep -Fq -- 'install_metadata="${runfiles_dir}/_main/' "${binary}"
grep -Fq -- 'node_modules/.rules_bun/install.json' "${binary}"
grep -Fq -- "--smol" "${binary}"
grep -Fq -- "--conditions" "${binary}"
grep -Fq -- "'browser'" "${binary}"
grep -Fq -- "'development'" "${binary}"
grep -Fq -- "--install" "${binary}"
grep -Fq -- "'force'" "${binary}"
grep -Fq -- "'--hot'" "${binary}"
grep -Fq -- "'--console-depth'" "${binary}"
grep -Fq -- "'4'" "${binary}"
