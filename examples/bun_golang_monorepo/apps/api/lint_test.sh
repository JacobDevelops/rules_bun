#!/usr/bin/env bash
# Run golangci-lint via `go tool` in a clean directory with dereferenced symlinks.
#
# Two problems this script solves:
#
#   1. Bazel symlinks: Bazel stages runfiles as a symlink farm.
#      `//go:embed` directives reject non-regular (symlinked) files, causing
#      golangci-lint to fail before it can analyse any code.  cp -rL copies the
#      tree with all symlinks dereferenced into actual files.
#
#   2. CGo: We disable CGo explicitly even though .bazelrc sets pure=true
#      globally, because this script runs outside Bazel's action sandbox (it is
#      an sh_test), so the flag doesn't propagate.
set -euo pipefail

# Resolve RUNFILES_DIR using the standard Bazel fallback chain.
if [[ -n "${TEST_SRCDIR:-}" ]]; then
  RUNFILES_DIR="${TEST_SRCDIR}"
elif [[ -d "${BASH_SOURCE[0]}.runfiles" ]]; then
  RUNFILES_DIR="${BASH_SOURCE[0]}.runfiles"
elif [[ -n "${RUNFILES_MANIFEST_FILE:-}" ]]; then
  RUNFILES_DIR="${RUNFILES_MANIFEST_FILE%/MANIFEST}"
fi

MODULE_SRC="${RUNFILES_DIR}/_main/apps/api"
MODULE_DIR=$(mktemp -d)
trap 'rm -rf "$MODULE_DIR"' EXIT

cp -rL "$MODULE_SRC/." "$MODULE_DIR/"
cd "$MODULE_DIR"

export CGO_ENABLED=0
exec go tool golangci-lint run ./...
