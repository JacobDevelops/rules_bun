#!/usr/bin/env bash

setup_nested_bazel_cmd() {
  if command -v bazel >/dev/null 2>&1; then
    bazel_cmd=(bazel)
  elif command -v bazelisk >/dev/null 2>&1; then
    bazel_cmd=(bazelisk)
  else
    echo "bazel or bazelisk is required on PATH" >&2
    exit 1
  fi
}

shutdown_nested_bazel_workspace() {
  local workspace_dir="${1:-}"
  if [[ -z ${workspace_dir} || ! -d ${workspace_dir} ]]; then
    return 0
  fi

  (
    cd "${workspace_dir}"
    "${bazel_cmd[@]}" shutdown >/dev/null 2>&1
  ) || true
}
