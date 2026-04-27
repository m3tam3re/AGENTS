---
name: git-identity
description: "Use when: (1) committing code to git repositories, (2) pushing changes, (3) verifying git identity. Triggers: git commit, git push, git identity, author."
compatibility: opencode, pi, claude-code
---

# Agent Git Identity

This rule ensures all AI agent commits use a dedicated bot identity instead of personal user credentials.

## How It Works

**Environment variables** are set automatically by Home Manager via `coding.agents.gitIdentity`:
- `GIT_AUTHOR_NAME` = m3ta-chiron
- `GIT_AUTHOR_EMAIL` = m3ta-chiron@agentmail.to
- `GIT_COMMITTER_*` = same
- `GIT_SSH_COMMAND` = ssh with agent SSH key

**Your job as the agent** is to:
1. Verify the identity before committing
2. Use conventional commit format
3. Push with SSH authentication

## Before Committing

Always verify the git identity is correct:

```bash
git var GIT_AUTHOR_IDENT
# Should show: m3ta-chiron <m3ta-chiron@agentmail.to>
```

If the identity is wrong, the environment variables are not set correctly. Report this to the user.

## Commit Format

Use conventional commits for all agent commits:

```bash
git commit -m "feat(scope): add feature"
git commit -m "fix(bug): resolve issue"
git commit -m "refactor(utils): improve code"
git commit -m "docs(readme): update docs"
git commit -m "chore(deps): update dependencies"
git commit -m "test(api): add tests"
```

**Rules**:
- Subject max 72 chars
- Imperative mood ("add", not "added")
- No period at end
- Reference issues: `Closes #123`

## Before Pushing

SSH authentication is configured via `GIT_SSH_COMMAND`. Simply run:

```bash
git push
```

The SSH key configured in `coding.agents.gitIdentity.sshKey` will be used automatically.

## Verification Commands

```bash
# Check author identity
git var GIT_AUTHOR_IDENT

# Check committer identity
git var GIT_COMMITTER_IDENT

# Check SSH command
echo $GIT_SSH_COMMAND

# List all commits by agent
git log --author="m3ta-chiron" --oneline

# Test SSH connectivity
ssh -T git@code.m3ta.dev
```

## Troubleshooting

**Commits show wrong author?**
- Environment variables may not be set
- Check: `echo $GIT_AUTHOR_NAME` should print "m3ta-chiron"
- Report to user if variables are not set

**Push authentication fails?**
- SSH key may not be added to the git hosting
- Check: `ssh -T git@code.m3ta.dev`
- Verify `GIT_SSH_COMMAND` contains correct key path

**Wrong SSH key used?**
- Verify `GIT_SSH_COMMAND` contains the m3ta-chiron key
- Personal SSH keys in `~/.ssh/` should not interfere
