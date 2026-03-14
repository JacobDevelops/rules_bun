#!/usr/bin/env bash
set -euo pipefail

output_dir=""
meta_json=""
meta_md=""

for path in "$@"; do
  case "${path}" in
  *.meta.json) meta_json="${path}" ;;
  *.meta.md) meta_md="${path}" ;;
  *) output_dir="${path}" ;;
  esac
done

if [[ ! -d ${output_dir} ]]; then
  echo "Expected directory output, got: ${output_dir}" >&2
  exit 1
fi

if [[ ! -f ${meta_json} ]]; then
  echo "Expected JSON metafile output" >&2
  exit 1
fi

if [[ ! -f ${meta_md} ]]; then
  echo "Expected markdown metafile output" >&2
  exit 1
fi
