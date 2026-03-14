#!/usr/bin/env bash
set -euo pipefail

rule_file="$1"

grep -Fq 'reporter_out="${XML_OUTPUT_FILE:-${runtime_workspace}/junit.xml}"' "${rule_file}"
grep -Fq 'bun_args+=("--reporter" "junit" "--reporter-outfile" "${reporter_out}")' "${rule_file}"
