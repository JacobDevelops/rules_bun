#!/usr/bin/env bash
set -euo pipefail

if command -v bazel >/dev/null 2>&1; then
  bazel_cmd=(bazel)
elif command -v bazelisk >/dev/null 2>&1; then
  bazel_cmd=(bazelisk)
else
  echo "bazel or bazelisk is required on PATH" >&2
  exit 1
fi

find_workspace_root() {
  local candidate
  local module_path
  local script_dir

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

  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  candidate="$(cd "${script_dir}/../.." && pwd -P)"
  if [[ -f "${candidate}/MODULE.bazel" ]]; then
    printf '%s\n' "${candidate}"
    return 0
  fi

  echo "Unable to locate rules_bun workspace root" >&2
  exit 1
}

rules_bun_root="$(find_workspace_root)"

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
