# opencode-memory Deployment Guide

## Installation

### Option 1: Nix (Recommended)

Add to your Nix flake:

```nix
inputs.opencode-memory = {
  url = "git+https://code.m3ta.dev/m3tam3re/opencode-memory";
  flake = false;
};
```

### Option 2: npm

```bash
npm install -g @m3tam3re/opencode-memory
```

## Configuration

Add to `~/.config/opencode/opencode.json`:

```json
{
  "plugins": [
    "opencode-memory"
  ]
}
```

## Environment Variables

- `OPENAI_API_KEY`: Required for embeddings

## Vault Location

Default: `~/CODEX/80-memory/`

Override in plugin config if needed.

## Rebuild Index

```bash
bun run src/cli.ts --rebuild
```

## Verification

1. Start Opencode
2. Call `memory_search` with any query
3. Verify no errors in logs
