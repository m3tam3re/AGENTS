---
name: crunch-jobs
description: "Use when: (1) The user asks to be reminded at a specific time, (2) Schedule recurring notifications, (3) Set up AI-powered scheduled jobs (summarize, review, report), (4) Run custom pipeline scripts on a schedule with voice output. Triggers: remind me, erinnere mich, schedule, cron, daily, weekly, täglich, jeden Montag, crunch, talk at, notify me at, voice reminder."
compatibility: opencode
---

# crunch-jobs

Schedule voice-notified reminders and AI crunch jobs on NixOS via `systemd` transient timers. When a timer fires, results are spoken aloud through `talk` (ElevenLabs TTS).

No NixOS rebuild needed — jobs are created at runtime via `systemd-run --user` and survive reboots.

## Prerequisites

- `crunch` and `talk` installed (via `m3ta-nixpkgs`)
- `ELEVENLABS_API_KEY` in environment (or agenix secrets)
- `loginctl enable-linger <username>` — **critical**: without this, user timers stop when the session ends

**Companion skill:** `voice-notify` covers the `talk` TTS script internals.

## Command Reference

```
crunch at <time> <message>                    One-shot (14:30 or "2026-07-03 14:30")
crunch in <duration> <message>                One-shot after delay (30m, 2h, 1h30m)
crunch daily <time> <message>                 Recurring daily
crunch weekly <day> <time> <message>          Recurring weekly (Mon or Montag)
crunch ai <engine> <type> <time> <prompt>     AI crunch (pi|opencode)
crunch script <type> <time> <script.sh> [args]  Custom script → talk
crunch list                                    List active jobs
crunch cancel <name>                           Cancel a job
crunch purge                                   Remove fired one-shot jobs
```

## Decision Flow

### 1. What kind of job?

| User intent | Command |
|---|---|
| "Erinnere mich an X" (just speak a message) | `crunch <type> <time> <message>` |
| "Fasse Y zusammen und sag mir Bescheid" (AI processes data) | `crunch ai <engine> <type> <time> <prompt>` |
| Complex multi-step pipeline (fetch → process → write → speak) | `crunch script <type> <time> <script.sh>` |

### 2. When?

| User says (DE/EN) | Type | Time spec |
|---|---|---|
| "in 30 Minuten" / "in 30m" | `in` | `"30m"` |
| "in 2 Stunden" | `in` | `"2h"` |
| "um 14:30" | `at` | `"14:30"` |
| "morgen um 10:00" | `at` | `"10:00"` (fires next 10:00) |
| "am 3. Juli um 15:00" | `at` | `"2026-07-03 15:00"` |
| "täglich um 9 Uhr" | `daily` | `"09:00"` |
| "jeden Montag um 9" | `weekly` | `"Mon 09:00"` |
| "freitags um 17:00" | `weekly` | `"Fri 17:00"` |

Day names: Mo/Mon/Montag→Mon, Di/Tue→Tue, Mi/Wed→Wed, Do/Thu→Thu, Fr/Fri→Fri, Sa/Sat→Sat, So/Sun→Sun.

### 3. Construct and execute the command.

## Job Types

### Simple Voice Reminders

Just speaks the message at the scheduled time:

```bash
crunch at "14:30" "Müll rausbringen"
crunch in "30m" "Build ist fertig — Ergebnis checken"
crunch daily "09:00" "Guten Morgen! Tagesplanung:"
crunch weekly "Fri 16:00" "Weekly Review nicht vergessen"
```

### AI Crunch Jobs

Runs a prompt through `pi` or `opencode` in print mode (non-interactive). Agent processes data, stdout → `talk`:

```bash
crunch ai pi in "2h" "Lies die neuesten Git-Commits und gib eine 3-Satz Zusammenfassung"
crunch ai opencode daily "07:30" "Check die PostgreSQL-Logs auf Errors der letzten 24h"
crunch ai pi weekly "Mon 09:00" "Generiere Weekly Summary aus git log"
```

The agent has full file-system access. It can call CLI tools, write files, and chain operations. Only the final stdout becomes the voice message.

### Custom Script Jobs

Runs any shell script on schedule. Script stdout → `talk`. Empty stdout = silence (no error).

```bash
crunch script daily "08:00" ~/scripts/basecamp-daily.sh
crunch script weekly "Mon 09:00" ~/scripts/weekly-report.sh arg1 arg2
```

Example script — fetches data, AI summarizes, writes report, speaks summary:

```bash
#!/usr/bin/env bash
# ~/scripts/basecamp-daily.sh
TODOS=$(basecamp todos --today 2>/dev/null) || exit 0
echo "$TODOS" | pi -p "Erstelle strukturierte Summary, speichere als ~/reports/daily.md. Antworte mit Top 3 Prioritäten."
```

## After Scheduling

- crunch outputs `✓ Scheduled: crunch-<name>-<random>`
- Share the job name with the user (needed for cancel)
- List: `crunch list`
- Cancel: `crunch cancel <name>`

## Examples

```
User: "Erinnere mich in 30 Minuten daran, den Build zu checken"
→ crunch in "30m" "Build checken"

User: "Jeden Morgen um 8 will ich meine Basecamp Todos hören"
→ crunch ai pi daily "08:00" "Hole heutige Todos aus Basecamp, antworte mit Top 3 Prioritäten"

User: "Freitags um 16 Uhr will ich ein Weekly Report als Voice"
→ crunch script weekly "Fri 16:00" ~/scripts/weekly-report.sh
```

## Pitfalls

- **Lingering**: Without `loginctl enable-linger <user>`, user systemd timers STOP when the session ends. Verify: `loginctl show-user <username> | grep Linger`
- **No session on servers**: `systemd-run --user` needs an active user session. On headless servers, use system-level timers or Hermes cron instead.
- **Quote messages**: Always quote the message/prompt argument (spaces, special chars).
- **Date format**: Specific dates must be `YYYY-MM-DD` for `crunch at`.
- **Voice toggle**: `VOICE_NOTIFY=0` silences all talk output globally.
