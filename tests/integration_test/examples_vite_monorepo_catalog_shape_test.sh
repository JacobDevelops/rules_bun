#!/usr/bin/env bash
set -euo pipefail

root_package_json="$1"
app_a_package_json="$2"
app_b_package_json="$3"

grep -Eq '"workspaces"[[:space:]]*:[[:space:]]*\{' "${root_package_json}"
grep -Eq '"packages"[[:space:]]*:[[:space:]]*\[' "${root_package_json}"
grep -Eq '"apps/\*"' "${root_package_json}"
grep -Eq '"catalog"[[:space:]]*:[[:space:]]*\{' "${root_package_json}"
grep -Eq '"vite"[[:space:]]*:[[:space:]]*"5\.4\.14"' "${root_package_json}"
grep -Eq '"catalogs"[[:space:]]*:[[:space:]]*\{' "${root_package_json}"
grep -Eq '"testing"[[:space:]]*:[[:space:]]*\{' "${root_package_json}"
grep -Eq '"vitest"[[:space:]]*:[[:space:]]*"3\.2\.4"' "${root_package_json}"
grep -Eq '"vite"[[:space:]]*:[[:space:]]*"catalog:"' "${app_a_package_json}"
grep -Eq '"vite"[[:space:]]*:[[:space:]]*"catalog:"' "${app_b_package_json}"
grep -Eq '"vitest"[[:space:]]*:[[:space:]]*"catalog:testing"' "${app_b_package_json}"
