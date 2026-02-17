# Git Workflow Rules

## Conventional Commits

Format: `<type>(<scope>): <subject>`

### Commit Types

- **feat**: New feature
  - `feat(auth): add OAuth2 login flow`
  - `feat(api): expose user endpoints`

- **fix**: Bug fix
  - `fix(payment): resolve timeout on Stripe calls`
  - `fix(ui): button not clickable on mobile`

- **refactor**: Code refactoring (no behavior change)
  - `refactor(utils): extract date helpers`
  - `refactor(api): simplify error handling`

- **docs**: Documentation only
  - `docs(readme): update installation steps`
  - `docs(api): add endpoint examples`

- **chore**: Maintenance tasks
  - `chore(deps): update Node to 20`
  - `chore(ci): add GitHub actions workflow`

- **test**: Tests only
  - `test(auth): add unit tests for login`
  - `test(e2e): add checkout flow tests`

- **style**: Formatting, no logic change
  - `style: sort imports alphabetically`

### Commit Rules

- Subject max 72 chars
- Imperative mood ("add", not "added")
- No period at end
- Reference issues: `Closes #123`

## Branch Naming

Pattern: `<type>/<short-description>`

### Branch Types

- `feature/add-user-dashboard`
- `feature/enable-dark-mode`
- `fix/login-redirect-loop`
- `fix/payment-timeout-error`
- `refactor/extract-user-service`
- `refactor/simplify-auth-flow`
- `hotfix/security-vulnerability`

### Branch Rules

- Lowercase and hyphens
- Max 50 chars
- Delete after merge

## Pull Requests

### PR Title

Follow Conventional Commit format:
- `feat: add user dashboard`
- `fix: resolve login redirect loop`

### PR Description

```markdown
## What
Brief description

## Why
Reason for change

## How
Implementation approach

## Testing
Steps performed

## Checklist
- [ ] Tests pass
- [ ] Code reviewed
- [ ] Docs updated
```

## Merge Strategy

### Squash Merge

- Many small commits
- One cohesive feature
- Clean history

### Merge Commit

- Preserve commit history
- Distinct milestones
- Detailed history preferred

### When to Rebase

- Before opening PR
- Resolving conflicts
- Keeping current with main

## General Rules

- Pull latest from main before starting
- Write atomic commits
- Run tests before pushing
- Request peer review before merge
- Never force push to main/master
