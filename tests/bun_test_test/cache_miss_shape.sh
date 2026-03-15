#!/usr/bin/env bash
set -euo pipefail

rule_file="$1"

grep -Fq 'extra_files = ctx.files.srcs + ctx.files.data + ctx.files.preload + ctx.files.env_files + [bun_bin]' "${rule_file}"
grep -Eq '"srcs": attr\.label_list\(' "${rule_file}"
grep -Eq '"coverage": attr\.bool\(' "${rule_file}"
