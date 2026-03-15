#!/usr/bin/env bash
set -euo pipefail

rule_file="$1"
build_file="$2"

grep -Eq 'extra_files = ctx\.files\.data \+ ctx\.files\.preload \+ ctx\.files\.env_files \+ \[bun_bin\]' "${rule_file}"
grep -Eq 'name = "hello_js_with_data_bin"' "${build_file}"
grep -Eq 'data = \["payload\.txt"\]' "${build_file}"
