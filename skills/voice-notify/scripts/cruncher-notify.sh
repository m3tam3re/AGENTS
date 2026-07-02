#!/usr/bin/env bash
# cruncher-notify.sh — Wrapper für Jobs mit Voice Notification
# Usage: cruncher-notify.sh "Job Name" -- <command...>
# Example: cruncher-notify.sh "Data Import" -- python3 import.py --input data.csv
set -euo pipefail

JOB_NAME="$1"
shift
[ "$1" = "--" ] && shift || { echo "Usage: $0 \"Job Name\" -- <command...>"; exit 1; }

START_TS=$(date +%s)

echo "▶ $JOB_NAME gestartet: $(date +%H:%M:%S)"

set +e
"$@"
JOB_EXIT=$?
set -e

END_TS=$(date +%s)
DURATION=$(( END_TS - START_TS ))
MIN=$(( DURATION / 60 ))
SEC=$(( DURATION % 60 ))

if [ "$JOB_EXIT" -eq 0 ]; then
  STATUS_TEXT="erfolgreich"
  STATUS_ICON="✅"
else
  STATUS_TEXT="fehlgeschlagen (Code $JOB_EXIT)"
  STATUS_ICON="❌"
fi

echo "$STATUS_ICON $JOB_NAME $STATUS_TEXT in ${MIN}m${SEC}s"

if [ "${VOICE_NOTIFY:-1}" != "0" ] && command -v talk &>/dev/null; then
  talk "$JOB_NAME $STATUS_TEXT. Dauer: $MIN Minuten $SEC Sekunden."
fi

exit "$JOB_EXIT"
