#!/usr/bin/env bash
# Launch or check all account migrations with concurrency control
# Usage:
#   bash scripts/run-all.sh           # start all accounts (max 2 at a time)
#   bash scripts/run-all.sh status    # check status of all accounts

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ACCOUNT_SCRIPTS=(
  "$ROOT/accounts/user1.sh"
  "$ROOT/accounts/user2.sh"
  "$ROOT/accounts/user3.sh"
)

# Max simultaneous imapsync jobs — tune based on server tolerance
MAX_CONCURRENT=2

running_count() {
  tmux ls 2>/dev/null | grep -c '^imap_' || true
}

if [[ "${1:-}" == "status" ]]; then
  echo "=== imapsync session status ==="
  for script in "${ACCOUNT_SCRIPTS[@]}"; do
    [[ -f "$script" ]] && bash "$script" status
    echo ""
  done
  exit 0
fi

for script in "${ACCOUNT_SCRIPTS[@]}"; do
  [[ -f "$script" ]] || { echo "WARN: $script not found, skipping."; continue; }

  while [[ "$(running_count)" -ge "$MAX_CONCURRENT" ]]; do
    echo "Waiting: $MAX_CONCURRENT migrations already running, checking again in 30s..."
    sleep 30
  done

  bash "$script" start
  sleep 10
done
