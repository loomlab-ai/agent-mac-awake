#!/usr/bin/env bash
# Install agent-mac-awake on this Mac (wrapper around bin/agent-awake install)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="${ROOT}/bin/agent-awake"

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf 'warning: this toolkit targets macOS; uname=%s\n' "$(uname -s)" >&2
fi

if [[ ! -x "${CLI}" ]]; then
  chmod +x "${CLI}" || true
fi

if [[ ! -f "${CLI}" ]]; then
  printf 'error: missing %s\n' "${CLI}" >&2
  exit 1
fi

exec "${CLI}" install
