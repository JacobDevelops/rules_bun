#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=../nested_bazel_test.sh
source "${script_dir}/../nested_bazel_test.sh"
setup_nested_bazel_cmd

find_workspace_root() {
  local candidate
  local module_path
  local search_dir

  for candidate in \
    "${TEST_SRCDIR:-}/${TEST_WORKSPACE:-}" \
    "${TEST_SRCDIR:-}/_main"; do
    if [[ -n ${candidate} && -f "${candidate}/MODULE.bazel" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done

  if [[ -n ${TEST_SRCDIR:-} ]]; then
    module_path="$(find "${TEST_SRCDIR}" -maxdepth 3 -name MODULE.bazel -print -quit 2>/dev/null || true)"
    if [[ -n ${module_path} ]]; then
      dirname "${module_path}"
      return 0
    fi
  fi

  search_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  candidate="$(cd "${search_dir}/../.." && pwd -P)"
  if [[ -f "${candidate}/MODULE.bazel" ]]; then
    printf '%s\n' "${candidate}"
    return 0
  fi

  echo "Unable to locate rules_bun workspace root" >&2
  exit 1
}

rules_bun_root="$(find_workspace_root)"

cleanup() {
  local status="$1"
  trap - EXIT
  shutdown_nested_bazel_workspace "${rules_bun_root}"
  exit "${status}"
}
trap 'cleanup $?' EXIT

bundle_output="$(
  cd "${rules_bun_root}" &&
    "${bazel_cmd[@]}" aquery 'mnemonic("BunBundle", //tests/bundle_test/sourcemap_case:sourcemap_bundle)' --output=textproto
)"

count="$(grep -Fc 'arguments: "--sourcemap"' <<<"${bundle_output}")"
if [[ ${count} != "1" ]]; then
  echo "Expected bun_bundle(sourcemap = True) to emit exactly one --sourcemap flag, got ${count}" >&2
  exit 1
fi

grep -Fq 'arguments: "--outfile"' <<<"${bundle_output}"
grep -Fq 'arguments: "tests/bundle_test/sourcemap_case/entry.ts"' <<<"${bundle_output}"
