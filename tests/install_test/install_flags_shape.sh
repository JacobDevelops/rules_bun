#!/usr/bin/env bash
set -euo pipefail

rule_file="$1"

grep -Fq 'repository_ctx.attr.production' "${rule_file}"
grep -Fq '"--production"' "${rule_file}"
grep -Fq 'for omit in repository_ctx.attr.omit' "${rule_file}"
grep -Fq '"--omit"' "${rule_file}"
grep -Fq 'repository_ctx.attr.linker' "${rule_file}"
grep -Fq '"--linker"' "${rule_file}"
grep -Fq 'repository_ctx.attr.backend' "${rule_file}"
grep -Fq '"--backend"' "${rule_file}"
grep -Fq 'repository_ctx.attr.ignore_scripts' "${rule_file}"
grep -Fq '"--ignore-scripts"' "${rule_file}"
grep -Fq 'repository_ctx.attr.install_flags' "${rule_file}"
