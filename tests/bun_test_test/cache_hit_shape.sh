#!/usr/bin/env bash
set -euo pipefail

rule_file="$1"

grep -Fq 'launcher_lines = [render_shell_array("bun_args", ["--bun", "test"])]' "${rule_file}"
grep -Fq 'exec "${bun_bin}" "${bun_args[@]}" "$@"' "${rule_file}"
