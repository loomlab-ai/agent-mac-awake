#!/usr/bin/env bash
# Uninstall agent-mac-awake LaunchAgent (+ optional --purge)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="${ROOT}/bin/agent-awake"
PURGE_FLAG="${1:-}"

# Prefer installed copy if present (works even after repo deleted)
INSTALLED="${HOME}/Library/Application Support/agent-mac-awake/bin/agent-awake"
if [[ -x "${INSTALLED}" ]]; then
  CLI="${INSTALLED}"
elif [[ -f "${CLI}" ]]; then
  chmod +x "${CLI}" || true
else
  printf 'error: agent-awake not found at %s or %s\n' "${INSTALLED}" "${CLI}" >&2
  exit 1
fi

if [[ "${PURGE_FLAG}" == "--purge" ]]; then
  exec "${CLI}" uninstall --purge
fi
exec "${CLI}" uninstall
