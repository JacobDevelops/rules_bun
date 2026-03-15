#!/usr/bin/env bash
set -euo pipefail

package_json_launcher="$1"
package_dir_hint_launcher="$2"

grep -Fq -- 'package_json="${runfiles_dir}/_main/tests/js_compat_test/app/package.json"' "${package_json_launcher}"
grep -Fq -- 'package_rel_dir_hint="."' "${package_json_launcher}"
grep -Fq -- 'working_dir_mode="package"' "${package_json_launcher}"

grep -Fq -- 'package_json=""' "${package_dir_hint_launcher}"
grep -Fq -- 'package_rel_dir_hint="app"' "${package_dir_hint_launcher}"
grep -Fq -- 'working_dir_mode="package"' "${package_dir_hint_launcher}"
