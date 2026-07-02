---
name: voice-notify
description: "Use when: (1) A long-running task (build, test, migration, cruncher job) completes, (2) The user asks to be notified audibly, (3) An agent finishes delegated work and should announce results, (4) Important errors or completions need immediate attention. Triggers: talk, voice, notify, audio, abbrechen, notify me, let me know when done, cruncher, job complete."
compatibility: opencode
---

# voice-notify

ElevenLabs TTS voice notifications with a dismissable desktop popup. Audio playback and notification appear simultaneously — click **⛔ Abbrechen** to stop playback.

## Prerequisites

- `talk` binary installed (via `m3ta-nixpkgs pkgs.talk`)
- `ELEVENLABS_API_KEY` set in environment
- Desktop notification daemon (DMS, dunst, mako, etc.)
- Audio playback (`mpv`) and PipeWire/PulseAudio running

## When to Use

- **Task completed** — after builds, tests, migrations, deployments (>30s runtime)
- **Cruncher job finished** — long data processing pipelines
- **Agent delegated work done** — when a subagent finishes and the user should know
- **User requested audio feedback** — "notify me when done", "let me know"
- **Critical errors** — build failures, test crashes, missing dependencies

## When NOT to Use

- Quick responses (< 30s of work)
- `VOICE_NOTIFY=0` is set — respect the toggle, stay silent
- Headless server without audio/desktop
- User is in a meeting/streaming — audio would be disruptive

## Usage

### Basic

```bash
talk "Build abgeschlossen. Alle 247 Tests erfolgreich."
```

### Stdin (Pipe)

```bash
echo "Deployment fertig" | talk
nixos-rebuild build 2>&1 | tail -3 | talk

# AI agent print mode → talk
pi -p "Review diesen Code" | talk
opencode run "Erkläre diese Funktion" -q | talk
```

Argument has priority; if no argument is given, `talk` reads from stdin. This enables piping from any command or AI agent.

### After Task Completion

```bash
# Am Ende eines langen Jobs:
talk "Cruncher Job komplett. 3 Dateien verarbeitet, 0 Fehler."
```

### Disable Temporarily

```bash
export VOICE_NOTIFY=0   # stumm schalten
# ... agent work ...
export VOICE_NOTIFY=1   # wieder an
```

## Integration Patterns

### Pattern 1: Cruncher Job Wrapper

For any long-running job, use the wrapper script at `scripts/cruncher-notify.sh`:

```bash
# Statt direkt:
python3 process_data.py --input data.csv

# Mit Voice Notification:
cruncher-notify.sh "Data Import" -- python3 process_data.py --input data.csv
# → 🔊 "Data Import erfolgreich. Dauer: 3 Minuten 42 Sekunden."
```

On failure: `❌ "Data Import fehlgeschlagen, Code 1"`.

### Pattern 2: Agent Hook

Add to `AGENTS.md` in any project:

```markdown
## Voice Notifications
When `VOICE_NOTIFY != 0` and the task took longer than 30 seconds,
call at the end: `talk "[brief summary]"`
```

### Pattern 3: Post-Build / Post-Test

```bash
# Makefile oder CI script:
test:
    pytest tests/
    talk "Tests durchgelaufen: $$(pytest tests/ -q --tb=no 2>&1 | tail -1)"
```

## Toggle Behaviour

| Value | Effect |
|-------|--------|
| `VOICE_NOTIFY=1` (default) | Notifications active |
| `VOICE_NOTIFY=0` | `talk` exits immediately, no audio, no popup |
| unset | Defaults to enabled |

Set per-shell, per-user, or system-wide via Home-Manager `home.sessionVariables`.

## Pitfalls

- **No audio?** Check `ELEVENLABS_API_KEY` is set and has credits (HTTP 402 = no credits)
- **No popup?** Ensure a notification daemon is running (`notify-send` needs a daemon)
- **Cancel button doesn't stop audio?** Fixed: the poll loop now uses `[ -s ]` (non-empty check) instead of `[ -f ]` (exists). The action file is created as empty by the shell redirect; it's only filled when the user clicks Abbrechen.
- **`pw-play` doesn't work** — it can't decode MP3; `talk` uses `mpv` which handles all formats
