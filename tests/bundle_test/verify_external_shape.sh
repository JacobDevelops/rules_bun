#!/usr/bin/env bash
set -euo pipefail

rule_file="$1"
build_file="$2"

grep -Eq 'add_bun_build_common_flags\(args, ctx\.attr\)' "${rule_file}"
grep -Eq '"external": attr\.string_list\(' "${rule_file}"
grep -Eq 'name = "external_bundle"' "${build_file}"
grep -Eq 'external = \["left-pad"\]' "${build_file}"
