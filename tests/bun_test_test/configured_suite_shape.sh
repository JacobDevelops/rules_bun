#!/usr/bin/env bash
set -euo pipefail

launcher="$1"

grep -Fq -- '--no-install' "${launcher}"
grep -Fq -- '--preload' "${launcher}"
grep -Fq -- '--env-file' "${launcher}"
grep -Fq -- '--no-env-file' "${launcher}"
grep -Fq -- '--timeout' "${launcher}"
grep -Fq -- '--update-snapshots' "${launcher}"
grep -Fq -- '--rerun-each' "${launcher}"
grep -Fq -- '--retry' "${launcher}"
grep -Fq -- '--concurrent' "${launcher}"
grep -Fq -- '--randomize' "${launcher}"
grep -Fq -- '--seed' "${launcher}"
grep -Fq -- '--bail' "${launcher}"
grep -Fq -- '--max-concurrency' "${launcher}"
grep -Fq -- '--reporter' "${launcher}"
grep -Fq -- '--reporter-outfile' "${launcher}"
grep -Fq -- '--coverage' "${launcher}"
grep -Fq -- '--coverage-dir' "${launcher}"
grep -Fq -- '--coverage-reporter' "${launcher}"
