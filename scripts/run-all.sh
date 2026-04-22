#!/usr/bin/env bash
# Launch or check all account migrations
# Usage:
#   bash scripts/run-all.sh           # start all accounts
#   bash scripts/run-all.sh status    # check status of all accounts

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ACCOUNT_SCRIPTS=(
  "$ROOT/accounts/user1.sh"
  "$ROOT/accounts/user2.sh"
  "$ROOT/accounts/user3.sh"
)

if [[ "${1:-}" == "status" ]]; then
  echo "=== imapsync session status ==="
  for script in "${ACCOUNT_SCRIPTS[@]}"; do
    [[ -f "$script" ]] && bash "$script" status
    echo ""
  done
  exit 0
fi

for script in "${ACCOUNT_SCRIPTS[@]}"; do
  if [[ -f "$script" ]]; then
    bash "$script" start
  else
    echo "WARN: $script not found, skipping."
  fi
done
