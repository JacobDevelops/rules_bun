#!/usr/bin/env bash
set -euo pipefail

module_bazel="$1"
module_lock="$2"
go_work="$3"
readme="$4"

[[ -f ${module_bazel} ]]
[[ -f ${module_lock} ]]
[[ -f ${go_work} ]]
[[ -f ${readme} ]]
grep -Eq 'name = "rules_bun_example_bun_golang_monorepo"' "${module_bazel}"
grep -Eq '^go ' "${go_work}"
