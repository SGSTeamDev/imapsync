#!/usr/bin/env bash
# Launch or check all account migrations with concurrency control
# Usage:
#   bash scripts/run-all.sh [pass]    # start all (pass: 1=30days, 2=365days, 3=all)
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

PASS="${1:-1}"

if [[ ! "$PASS" =~ ^[1-3]$ ]]; then
  echo "Usage: $0 [pass|status]"
  echo "  1 = Pass 1: Last 30 days (newest)"
  echo "  2 = Pass 2: 30 days to 1 year"
  echo "  3 = Pass 3: Full history (all remaining)"
  echo "  status = Check all account statuses"
  exit 1
fi

echo "Starting all accounts with Pass $PASS..."

for script in "${ACCOUNT_SCRIPTS[@]}"; do
  [[ -f "$script" ]] || { echo "WARN: $script not found, skipping."; continue; }

  while [[ "$(running_count)" -ge "$MAX_CONCURRENT" ]]; do
    echo "Waiting: $MAX_CONCURRENT migrations already running, checking again in 30s..."
    sleep 30
  done

  bash "$script" "$PASS"
  sleep 10
done
