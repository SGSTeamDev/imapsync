#!/usr/bin/env bash
# Email notification via SMTP (uses curl — no mail server needed)
# Usage: bash scripts/notify.sh "subject" "body"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[notify] ERROR: .env file not found at $ENV_FILE"
  exit 1
fi
# shellcheck disable=SC1090
source "$ENV_FILE"

SUBJECT="${1:-imapsync job finished}"
BODY="${2:-A migration job has completed.}"
DATE=$(date -R)

# Determine correct protocol based on port
if [[ "$SMTP_PORT" == "465" ]]; then
  SMTP_URL="smtps://${SMTP_HOST}:${SMTP_PORT}"
  SSL_FLAG=""
else
  SMTP_URL="smtp://${SMTP_HOST}:${SMTP_PORT}"
  SSL_FLAG="--ssl-reqd"
fi

curl --show-error --fail \
  --connect-timeout 10 --max-time 30 \
  --url "$SMTP_URL" \
  $SSL_FLAG \
  --mail-from "${SMTP_FROM:-$SMTP_USER}" \
  --mail-rcpt "$NOTIFY_TO" \
  --user "${SMTP_USER}:${SMTP_PASS}" \
  -T <(printf "From: imapsync <%s>\r\nTo: %s\r\nSubject: %s\r\nDate: %s\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n%s\r\n" \
    "${SMTP_FROM:-$SMTP_USER}" "$NOTIFY_TO" "$SUBJECT" "$DATE" "$BODY") \
  && echo "[notify] Email sent: $SUBJECT" \
  || echo "[notify] Failed to send email."
