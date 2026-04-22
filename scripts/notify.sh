#!/usr/bin/env bash
# Email notification via SMTP (uses curl — no mail server needed)
# Usage: bash scripts/notify.sh "subject" "body"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[notify] ERROR: .env file not found at $ENV_FILE"
  exit 1
fi
# shellcheck source=../.env.example
source "$ENV_FILE"

SUBJECT="${1:-imapsync job finished}"
BODY="${2:-A migration job has completed.}"
DATE=$(date -R)

curl --silent --url "smtp://${SMTP_HOST}:${SMTP_PORT}" \
  --ssl-reqd \
  --mail-from "$SMTP_USER" \
  --mail-rcpt "$NOTIFY_TO" \
  --user "${SMTP_USER}:${SMTP_PASS}" \
  -T <(printf "From: imapsync <%s>\nTo: %s\nSubject: %s\nDate: %s\n\n%s\n" \
    "$SMTP_USER" "$NOTIFY_TO" "$SUBJECT" "$DATE" "$BODY") \
  && echo "[notify] Email sent: $SUBJECT" \
  || echo "[notify] Failed to send email."
