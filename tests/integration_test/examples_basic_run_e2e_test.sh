#!/usr/bin/env bash
set -euo pipefail

binary="$1"
workdir="$(mktemp -d)"
log_file="${workdir}/basic.log"

cleanup() {
  if [[ -n ${server_pid:-} ]] && kill -0 "${server_pid}" 2>/dev/null; then
    kill "${server_pid}" 2>/dev/null || true
    wait "${server_pid}" 2>/dev/null || true
  fi
  rm -rf "${workdir}"
}
trap cleanup EXIT

"${binary}" >"${log_file}" 2>&1 &
server_pid=$!

for _ in {1..20}; do
  if grep -Fq "rules_bun bun_dev example" "${log_file}"; then
    exit 0
  fi

  if ! kill -0 "${server_pid}" 2>/dev/null; then
    cat "${log_file}" >&2
    echo "basic example process exited unexpectedly" >&2
    exit 1
  fi

  sleep 0.5
done

cat "${log_file}" >&2
echo "Timed out waiting for bun_dev example output" >&2
exit 1
