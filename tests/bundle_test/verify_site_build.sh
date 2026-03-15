#!/usr/bin/env bash
set -euo pipefail

output_dir="$1"

if [[ ! -d ${output_dir} ]]; then
  echo "Expected output directory: ${output_dir}" >&2
  exit 1
fi

if ! find -L "${output_dir}" -type f \( -name '*.js' -o -name '*.css' \) | grep -q .; then
  echo "Expected Bun build assets in ${output_dir}" >&2
  exit 1
fi
