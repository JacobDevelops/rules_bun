#!/usr/bin/env bash
set -euo pipefail

workflow_file="$1"

grep -Fq './tests/ci_test/phase8_ci_targets.sh "${{ matrix.phase8_target }}"' "${workflow_file}"
grep -Fq 'targets="$(./tests/ci_test/phase8_ci_targets.sh "${{ matrix.phase8_target }}")"' "${workflow_file}"
grep -Fq 'bazel test ${targets}' "${workflow_file}"
