# Agent-Hub Skill Deployment Notes

Use when making the Shared Brain Vault workflow available to cross-agent tools through the AGENTS/agent-hub repository.

## Target layout

Copy the complete skill directory, not only `SKILL.md`:

```text
/var/lib/hermes/workspace/agent-hub/.agents/skills/shared-brain-vault/
  SKILL.md
  references/
  scripts/
```

Source of the active Hermes-installed skill is usually:

```text
/var/lib/hermes/.hermes/skills/knowledge-management/shared-brain-vault/
```

## Safe deployment sequence

```bash
cd /var/lib/hermes/workspace/agent-hub
mkdir -p .agents/skills/shared-brain-vault
cp -a /var/lib/hermes/.hermes/skills/knowledge-management/shared-brain-vault/. \
  .agents/skills/shared-brain-vault/
chmod +x .agents/skills/shared-brain-vault/scripts/*.py 2>/dev/null || true
```

Then stage only the shared-brain skill files so unrelated dirty Agent-Hub work is not mixed into the commit:

```bash
git add .agents/skills/shared-brain-vault
git diff --cached --stat
git diff --cached --name-status
git commit -m "add shared brain vault skill"
```

## Verification

Run the vault link audit against the actual vault path:

```bash
python3 .agents/skills/shared-brain-vault/scripts/audit-wikilinks.py /var/lib/hermes/m3ta-brain
```

If Agent-Hub has its repo check script, run it too:

```bash
./scripts/check-agent-hub.sh
```

Before claiming success, confirm the committed files and current status:

```bash
git status --short
git log -1 --oneline
```

If `git remote -v` prints nothing, do not claim a push happened; report that the local commit exists and that no remote is configured.

## Pitfalls

- Do not assume a skill installed in `~/.hermes/skills/` is present in Agent-Hub. Check `.agents/skills/<name>/` separately.
- Do not copy only `SKILL.md`; supporting `references/` and `scripts/` carry reusable detail and verification helpers.
- Do not mix pre-existing Agent-Hub changes into the skill commit. Stage the skill path explicitly.
- Keep the active Hermes-installed copy and Agent-Hub copy in sync when patching durable workflow guidance.
