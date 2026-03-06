#!/usr/bin/env bash
set -euo pipefail

rule_file="$1"

grep -Eq '\[str\(bun_bin\), "--bun", "install", "--frozen-lockfile", "--no-progress"\]' "${rule_file}"
grep -Eq 'environment[[:space:]]*=[[:space:]]*\{"HOME":[[:space:]]*str\(repository_ctx\.path\("\."\)\)\}' "${rule_file}"
