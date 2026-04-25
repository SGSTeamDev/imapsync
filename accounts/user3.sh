#!/usr/bin/env bash
# Account migration: USER3
# Usage:
#   bash accounts/user3.sh [pass]     # start (pass: 1=30days, 2=365days, 3=all)
#   bash accounts/user3.sh status     # running or not + last 10 log lines
#   bash accounts/user3.sh log        # tail live log (Ctrl+C to exit)
#   bash accounts/user3.sh attach     # attach to live tmux session (Ctrl+B D to detach)
#   bash accounts/user3.sh stop       # kill session

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env file not found at $ENV_FILE"
  exit 1
fi
# shellcheck disable=SC1090
source "$ENV_FILE"

SESSION="imap_user3"
ACCOUNT="$USER3_SRC"
LOG="$HOME/imapsync-logs/${SESSION}.log"
NOTIFY="$ROOT/scripts/notify.sh"
mkdir -p "$HOME/imapsync-logs"

start_job() {
  local PASS="${1:-1}"
  local MAXAGE_FLAG=""
  local PASS_DESC=""

  case "$PASS" in
    1)
      MAXAGE_FLAG="--maxage 30"
      PASS_DESC="Pass 1: Last 30 days (newest)"
      ;;
    2)
      MAXAGE_FLAG="--maxage 365 --minage 30"
      PASS_DESC="Pass 2: 30 days to 1 year"
      ;;
    3)
      MAXAGE_FLAG=""
      PASS_DESC="Pass 3: Full history (all remaining)"
      ;;
    *)
      echo "ERROR: Invalid pass number. Use 1, 2, or 3."
      exit 1
      ;;
  esac

  if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "[$SESSION] Already running. Use 'attach' or 'log' to monitor, 'stop' to kill."
    exit 0
  fi

  echo "[$SESSION] Starting $PASS_DESC..."
  bash "$NOTIFY" "imapsync STARTED: $ACCOUNT ($PASS_DESC)" "Migration for $ACCOUNT has started on $(hostname) at $(date)."

  tmux new-session -d -s "$SESSION" bash -lc "
    imapsync \
      --host1 \"$IMAP_SRC_HOST\" --user1 \"$USER3_SRC\" --password1 \"$USER3_SRC_PASS\" \
      --host2 \"$IMAP_DST_HOST\" --user2 \"$USER3_DST\" --password2 \"$USER3_DST_PASS\" \
      --ssl1 --ssl2 \
      --automap \
      --addheader \
      --syncinternaldates \
      --useuid \
      --fastio2 \
      --nofoldersizes \
      --skipsize \
      --timeout1 120 --timeout2 60 \
      --reconnectretry1 10 --reconnectretry2 5 \
      --errorsmax 1000 \
      $MAXAGE_FLAG \
      2>&1 | tee \"$LOG\"

    EXIT_CODE=\${PIPESTATUS[0]}

    if [ \$EXIT_CODE -eq 0 ]; then
      bash \"$NOTIFY\" \"imapsync DONE: $ACCOUNT\" \"Migration for $ACCOUNT completed successfully on \$(hostname) at \$(date).\"
    else
      bash \"$NOTIFY\" \"imapsync FAILED: $ACCOUNT\" \"Migration for $ACCOUNT exited with code \$EXIT_CODE on \$(hostname) at \$(date). Check the log.\"
    fi
  "

  echo "[$SESSION] Started. Log: $LOG"
  echo "  Watch log:   bash accounts/user3.sh log"
  echo "  Attach tmux: bash accounts/user3.sh attach"
}

case "${1:-1}" in
  1|2|3)
    start_job "$1"
    ;;
  status)
    if tmux has-session -t "$SESSION" 2>/dev/null; then
      echo "[$SESSION] RUNNING"
    else
      echo "[$SESSION] NOT running"
    fi
    if [[ -f "$LOG" ]]; then
      echo "--- last 10 log lines ---"
      tail -10 "$LOG"
    else
      echo "No log file yet."
    fi
    ;;
  log)
    if [[ -f "$LOG" ]]; then
      echo "Tailing $LOG — Ctrl+C to stop"
      tail -f "$LOG"
    else
      echo "No log file yet. Has the job started?"
    fi
    ;;
  attach)
    tmux attach -t "$SESSION"
    ;;
  stop)
    if tmux has-session -t "$SESSION" 2>/dev/null; then
      tmux kill-session -t "$SESSION"
      echo "[$SESSION] Stopped."
    else
      echo "[$SESSION] Not running."
    fi
    ;;
  *)
    echo "Usage: $0 {1|2|3|status|log|attach|stop}"
    echo "  1 = Pass 1: Last 30 days (newest)"
    echo "  2 = Pass 2: 30 days to 1 year"
    echo "  3 = Pass 3: Full history (all remaining)"
    exit 1
    ;;
esac
