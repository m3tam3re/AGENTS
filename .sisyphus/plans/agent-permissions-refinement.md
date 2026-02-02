# Agent Permissions Refinement

## TL;DR

> **Quick Summary**: Refine OpenCode agent permissions for Chiron (planning) and Chriton-Forge (build) to implement 2025 AI security best practices with principle of least privilege, human-in-the-loop for critical actions, and explicit guardrails against permission bypass.

> **Deliverables**:
> - Updated `agents/agents.json` with refined permissions for Chiron and Chriton-Forge
> - Critical bug fix: Duplicate `external_directory` key in Chiron config
> - Enhanced secret blocking with additional patterns
> - Bash injection prevention rules
> - Git protection against secret commits and repo hijacking

> **Estimated Effort**: Medium
> **Parallel Execution**: NO - sequential changes to single config file
> **Critical Path**: Fix duplicate key → Apply Chiron permissions → Apply Chriton-Forge permissions → Validate

---

## Context

### Original Request
User wants to refine agent permissions for:
- **Chiron**: Planning agent with read-only access, restricted to read-only subagents, no file editing, can create beads issues
- **Chriton-Forge**: Build agent with write access restricted to ~/p/**, git commits allowed but git push asks, package install commands ask
- **General**: Sane defaults that are secure but open enough for autonomous work

### Interview Summary
**Key Discussions**:
- Chiron: Read-only planning, no file editing, bash denied except for `bd *` commands, external_directory ~/p/** only, task permission to restrict subagents to explore/librarian/athena + chiron-forge for handoff
- Chriton-Forge: Write access restricted to ~/p/**, git commits allow / git push ask, package install commands ask, git config deny
- Workspace path: ~/p/** is symlink to ~/projects/personal/** (just replacing path reference)
- Bash security: Block all bash redirect patterns (echo >, cat >, tee, etc.)

**Research Findings**:
- OpenCode supports granular permission rules with wildcards, last-match-wins
- 2025 best practices: Principle of least privilege, tiered permissions (read-only auto, destructive ask, JIT privileges), human-in-the-loop for critical actions
- Security hardening: Block command injection vectors, prevent git secret commits, add comprehensive secret blocking patterns

### Metis Review
**Critical Issues Identified**:
1. **Duplicate `external_directory` key** in Chiron config (lines 8-9 and 27) - second key overrides first, breaking intended behavior
2. **Bash edit bypass**: Even with `edit: deny`, bash can write files via redirection (`echo "x" > file.txt`, `cat >`, `tee`)
3. **Git secret protection**: Agent could commit secrets (read .env, then git commit .env)
4. **Git config hijacking**: Agent could modify .git/config to push to attacker-controlled repo
5. **Command injection**: Malicious content could execute via `$()`, backticks, `eval`, `source`
6. **Secret blocking incomplete**: Missing patterns for `.local/share/*`, `.cache/*`, `*.db`, `*.keychain`, `*.p12`

**Guardrails Applied**:
- Fix duplicate external_directory key (use single object with catch-all `"*": "ask"` after specific rules)
- Add bash file write protection patterns (echo >, cat >, printf >, tee, > operators)
- Add git secret protection (`git add *.env*`: deny, `git commit *.env*`: deny)
- Add git config protection (`git config *`: deny for Chriton-Forge)
- Add bash injection prevention (`$(*`, `` `*``, `eval *`, `source *`)
- Expand secret blocking with additional patterns
- Add /run/agenix/* to read deny list

---

## Work Objectives

### Core Objective
Refine OpenCode agent permissions in `agents/agents.json` to implement security hardening based on 2025 AI agent best practices while maintaining autonomous workflow capabilities.

### Concrete Deliverables
- Updated `agents/agents.json` with:
  - Chiron: Read-only permissions, subagent restrictions, bash denial (except `bd *`), no file editing
  - Chriton-Forge: Write access scoped to ~/p/**, git commit allow / push ask, package install ask, git config deny
  - Both: Enhanced secret blocking, bash injection prevention, git secret protection

### Definition of Done
- [x] Permission configuration updated in `agents/agents.json`
- [x] JSON syntax valid (no duplicate keys, valid structure)
- [x] Workspace path validated (~/p/** exists and is correct)
- [x] Acceptance criteria tests pass (via manual verification)

### Must Have
- Chiron cannot edit files directly
- Chiron cannot write files via bash (redirects blocked)
- Chiron restricted to read-only subagents + chiron-forge for handoff
- Chriton-Forge can only write to ~/p/**
- Chriton-Forge cannot git config
- Both agents block secret file reads
- Both agents prevent command injection
- Git operations cannot commit secrets
- No duplicate keys in permission configuration

### Must NOT Have (Guardrails)
- **Edit bypass via bash**: No bash redirection patterns that allow file writes when `edit: deny`
- **Git secret commits**: No ability to git add/commit .env or credential files
- **Repo hijacking**: No git config modification allowed for Chriton-Forge
- **Command injection**: No `$()`, backticks, `eval`, `source` execution via bash
- **Write scope escape**: Chriton-Forge cannot write outside ~/p/** without asking
- **Secret exfiltration**: No access to .env, .ssh, .gnupg, credentials, secrets, .pem, .key, /run/agenix
- **Unrestricted bash for Chiron**: Only `bd *` commands allowed

---

## Verification Strategy (MANDATORY)

> This is configuration work, not code development. Manual verification is required after deployment.

### Test Decision
- **Infrastructure exists**: YES (home-manager deployment)
- **User wants tests**: NO (Manual-only verification)
- **Framework**: None

### Manual Verification Procedures

Each TODO includes EXECUTABLE verification procedures that users can run to validate changes.

**Verification Commands to Run After Deployment:**

1. **JSON Syntax Validation**:
```bash
# Validate JSON structure and no duplicate keys
jq '.' /home/m3tam3re/p/AI/AGENTS/agents/agents.json > /dev/null 2>&1
# Expected: Exit code 0 (valid JSON)

# Check for duplicate keys (manual review of chiron permission object)
# Expected: Single external_directory key, no other duplicates
```

2. **Workspace Path Validation**:
```bash
ls -la ~/p/ 2>&1
# Expected: Directory exists, shows contents (likely symlink to ~/projects/personal/)
```

3. **After Deployment - Chiron Read-Only Test** (manual):
- Have Chiron attempt to edit a test file
  - Expected: Permission denied with clear error message
- Have Chiron attempt to write via bash (echo "test" > /tmp/test.txt)
  - Expected: Permission denied
- Have Chiron run `bd ready` command
  - Expected: Command succeeds, returns JSON output with issue list
- Have Chiron attempt to invoke build-capable subagent (sisyphus-junior)
  - Expected: Permission denied

4. **After Deployment - Chiron Workspace Access** (manual):
- Have Chiron read file within ~/p/**
  - Expected: Success, returns file contents
- Have Chiron read file outside ~/p/**
  - Expected: Permission denied or ask user
- Have Chiron delegate to explore/librarian/athena
  - Expected: Success, subagent executes

5. **After Deployment - Chriton-Forge Write Access** (manual):
- Have Chriton-Forge write test file in ~/p/** directory
  - Expected: Success, file created
- Have Chriton-Forge attempt to write file to /tmp
  - Expected: Ask user for approval
- Have Chriton-Forge run `git add` and `git commit -m "test"`
  - Expected: Success, commit created without asking
- Have Chriton-Forge attempt `git push`
  - Expected: Ask user for approval
- Have Chriton-Forge attempt `git config`
  - Expected: Permission denied
- Have Chriton-Forge attempt `npm install lodash`
  - Expected: Ask user for approval

6. **After Deployment - Secret Blocking Tests** (manual):
- Attempt to read .env file with both agents
  - Expected: Permission denied
- Attempt to read /run/agenix/ with Chiron
  - Expected: Permission denied
- Attempt to read .env.example (should be allowed)
  - Expected: Success

7. **After Deployment - Bash Injection Prevention** (manual):
- Have agent attempt bash -c "$(cat /malicious)"
  - Expected: Permission denied
- Have agent attempt bash -c "`cat /malicious`"
  - Expected: Permission denied
- Have agent attempt eval command
  - Expected: Permission denied

8. **After Deployment - Git Secret Protection** (manual):
- Have agent attempt `git add .env`
  - Expected: Permission denied
- Have agent attempt `git commit .env`
  - Expected: Permission denied

9. **Deployment Verification**:
```bash
# After home-manager switch, verify config is embedded correctly
cat ~/.config/opencode/config.json | jq '.agent.chiron.permission.external_directory'
# Expected: Shows ~/p/** rule, no duplicate keys

# Verify agents load without errors
# Expected: No startup errors when launching OpenCode
```

---

## Execution Strategy

### Parallel Execution Waves

> Single file sequential changes - no parallelization possible.

```
Single-Threaded Execution:
Task 1: Fix duplicate external_directory key
Task 2: Apply Chiron permission updates
Task 3: Apply Chriton-Forge permission updates
Task 4: Validate configuration
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | 2, 3 | None (must start) |
| 2 | 1 | 4 | 3 |
| 3 | 1 | 4 | 2 |
| 4 | 2, 3 | None | None (validation) |

### Agent Dispatch Summary

| Task | Recommended Agent |
|------|-----------------|
| 1 | delegate_task(category="quick", load_skills=["git-master"]) |
| 2 | delegate_task(category="quick", load_skills=["git-master"]) |
| 3 | delegate_task(category="quick", load_skills=["git-master"]) |
| 4 | User (manual verification) |

---

## TODOs

> Implementation tasks for agent configuration changes. Each task MUST include acceptance criteria with executable verification.

- [x] 1. Fix Duplicate external_directory Key in Chiron Config

  **What to do**:
  - Remove duplicate `external_directory` key from Chiron permission object
  - Consolidate into single object with specific rule + catch-all `"*": "ask"`
  - Replace `~/projects/personal/**` with `~/p/**` (symlink to same directory)

  **Must NOT do**:
  - Leave duplicate keys (second key overrides first, breaks config)
  - Skip workspace path validation (verify ~/p/** exists)

  **Recommended Agent Profile**:
  > **Category**: quick
    - Reason: Simple JSON edit, single file change, no complex logic
  > **Skills**: git-master
    - git-master: Git workflow for committing changes
  > **Skills Evaluated but Omitted**:
    - research: Not needed (no investigation required)
    - librarian: Not needed (no external docs needed)

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: Tasks 2, 3 (depends on clean config)
  - **Blocked By**: None (can start immediately)

  **References** (CRITICAL - Be Exhaustive):

  **Pattern References** (existing code to follow):
  - `agents/agents.json:1-135` - Current agent configuration structure (JSON format, permission object structure)
  - `agents/agents.json:7-29` - Chiron permission object (current state with duplicate key)

  **API/Type References** (contracts to implement against):
  - OpenCode permission schema: `{"permission": {"bash": {...}, "edit": "...", "external_directory": {...}, "task": {...}}`

  **Documentation References** (specs and requirements):
  - Interview draft: `.sisyphus/drafts/agent-permissions-refinement.md` - All user decisions and requirements
  - Metis analysis: Critical issue #1 - Duplicate external_directory key

  **External References** (libraries and frameworks):
  - OpenCode docs: https://opencode.ai/docs/permissions/ - Permission system documentation (allow/ask/deny, wildcards, last-match-wins)
  - OpenCode docs: https://opencode.ai/docs/agents/ - Agent configuration format

  **WHY Each Reference Matters** (explain the relevance):
  - `agents/agents.json` - Target file to modify, shows current structure and duplicate key bug
  - Interview draft - Contains all user decisions (~/p/** path, subagent restrictions, etc.)
  - OpenCode permissions docs - Explains permission system mechanics (last-match-wins critical for rule ordering)
  - Metis analysis - Identifies the duplicate key bug that MUST be fixed

  **Acceptance Criteria**:

  > **CRITICAL: AGENT-EXECUTABLE VERIFICATION ONLY**

  **Automated Verification (config validation)**:
  \`\`\`bash
  # Agent runs:
  jq '.' /home/m3tam3re/p/AI/AGENTS/agents/agents.json > /dev/null 2>&1
  # Assert: Exit code 0 (valid JSON)

  # Verify single external_directory key in chiron permission object
  cat /home/m3tam3re/p/AI/AGENTS/agents/agents.json | jq '.chiron.permission | keys' | grep external_directory | wc -l
  # Assert: Output is "1" (exactly one external_directory key)

  # Verify workspace path exists
  ls -la ~/p/ 2>&1 | head -1
  # Assert: Shows directory listing (not "No such file or directory")
  \`\`\`

  **Evidence to Capture**:
  - [x] jq validation output (exit code 0)
  - [x] external_directory key count output (should be "1")
  - [x] Workspace path ls output (shows directory exists)

  **Commit**: NO (group with Task 2 and 3)

- [x] 2. Apply Chiron Permission Updates

  **What to do**:
  - Set `edit` to `"deny"` (planning agent should not write files)
  - Set `bash` permissions to deny all except `bd *`:
    ```json
    "bash": {
      "*": "deny",
      "bd *": "allow"
    }
    ```
  - Set `external_directory` to `~/p/**` with catch-all ask:
    ```json
    "external_directory": {
      "~/p/**": "allow",
      "*": "ask"
    }
    ```
  - Add `task` permission to restrict subagents:
    ```json
    "task": {
      "*": "deny",
      "explore": "allow",
      "librarian": "allow",
      "athena": "allow",
      "chiron-forge": "allow"
    }
    ```
  - Add `/run/agenix/*` to read deny list
  - Add expanded secret blocking patterns: `.local/share/*`, `.cache/*`, `*.db`, `*.keychain`, `*.p12`

  **Must NOT do**:
  - Allow bash file write operators (echo >, cat >, tee, etc.) - will add in Task 3 for both agents
  - Allow chiron to invoke build-capable subagents beyond chiron-forge
  - Skip webfetch permission (should be "allow" for research capability)

  **Recommended Agent Profile**:
  > **Category**: quick
    - Reason: JSON configuration update, follows clear specifications from draft
  > **Skills**: git-master
    - git-master: Git workflow for committing changes
  > **Skills Evaluated but Omitted**:
    - research: Not needed (all requirements documented in draft)
    - librarian: Not needed (no external docs needed)

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 3)
  - **Blocks**: Task 4
  - **Blocked By**: Task 1

  **References** (CRITICAL - Be Exhaustive):

  **Pattern References** (existing code to follow):
  - `agents/agents.json:11-24` - Current Chiron read permissions with secret blocking patterns
  - `agents/agents.json:114-132` - Athena permission object (read-only subagent reference pattern)

  **API/Type References** (contracts to implement against):
  - OpenCode task permission schema: `{"task": {"agent-name": "allow"}}`

  **Documentation References** (specs and requirements):
  - Interview draft: `.sisyphus/drafts/agent-permissions-refinement.md` - Chiron permission decisions
  - Metis analysis: Guardrails #7, #8 - Secret blocking patterns, task permission implementation

  **External References** (libraries and frameworks):
  - OpenCode docs: https://opencode.ai/docs/agents/#task-permissions - Task permission documentation
  - OpenCode docs: https://opencode.ai/docs/permissions/ - Permission level definitions and pattern matching

  **WHY Each Reference Matters** (explain the relevance):
  - `agents/agents.json:11-24` - Shows current secret blocking patterns to extend
  - `agents/agents.json:114-132` - Shows read-only subagent pattern for reference (athena: deny bash, deny edit)
  - Interview draft - Contains exact user requirements for Chiron permissions
  - OpenCode task docs - Explains how to restrict subagent invocation via task permission

  **Acceptance Criteria**:

  > **CRITICAL: AGENT-EXECUTABLE VERIFICATION ONLY**

  **Automated Verification (config validation)**:
  \`\`\`bash
  # Agent runs:
  jq '.chiron.permission.edit' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  jq '.chiron.permission.bash."*"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  jq '.chiron.permission.bash."bd *"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "allow"

  jq '.chiron.permission.task."*"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  jq '.chiron.permission.task | keys' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Contains ["*", "athena", "chiron-forge", "explore", "librarian"]

  jq '.chiron.permission.external_directory."~/p/**"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "allow"

  jq '.chiron.permission.external_directory."*"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "ask"

  jq '.chiron.permission.read."/run/agenix/*"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"
  \`\`\`

  **Evidence to Capture**:
  - [x] Edit permission value (should be "deny")
  - [x] Bash wildcard permission (should be "deny")
  - [x] Bash bd permission (should be "allow")
  - [x] Task wildcard permission (should be "deny")
  - [x] Task allowlist keys (should show 5 entries)
  - [x] External directory ~/p/** permission (should be "allow")
  - [x] External directory wildcard permission (should be "ask")
  - [x] Read /run/agenix/* permission (should be "deny")

  **Commit**: NO (group with Task 3)

- [x] 3. Apply Chriton-Forge Permission Updates

  **What to do**:
  - Split `git *: "ask"` into granular rules:
    - Allow: `git add *`, `git commit *`, read-only commands (status, log, diff, branch, show, stash, remote)
    - Ask: `git push *`
    - Deny: `git config *`
  - Change package managers from `"ask"` to granular rules:
    - Ask for installs: `npm install *`, `npm i *`, `npx *`, `pip install *`, `pip3 install *`, `uv *`, `bun install *`, `bun i *`, `bunx *`, `yarn install *`, `yarn add *`, `pnpm install *`, `pnpm add *`, `cargo install *`, `go install *`, `make install`
    - Allow other commands implicitly (let them use catch-all rules or existing allow patterns)
  - Set `external_directory` to allow `~/p/**` with catch-all ask:
    ```json
    "external_directory": {
      "~/p/**": "allow",
      "*": "ask"
    }
    ```
  - Add bash file write protection patterns (apply to both agents):
    ```json
    "bash": {
      "echo * > *": "deny",
      "cat * > *": "deny",
      "printf * > *": "deny",
      "tee": "deny",
      "*>*": "deny",
      ">*>*": "deny"
    }
    ```
  - Add bash command injection prevention (apply to both agents):
    ```json
    "bash": {
      "$(*": "deny",
      "`*": "deny",
      "eval *": "deny",
      "source *": "deny"
    }
    ```
  - Add git secret protection patterns (apply to both agents):
    ```json
    "bash": {
      "git add *.env*": "deny",
      "git commit *.env*": "deny",
      "git add *credentials*": "deny",
      "git add *secrets*": "deny"
    }
    ```
  - Add expanded secret blocking patterns to read permission:
    - `.local/share/*`, `.cache/*`, `*.db`, `*.keychain`, `*.p12`

  **Must NOT do**:
  - Remove existing bash deny rules for dangerous commands (dd, mkfs, fdisk, parted, eval, sudo, su, systemctl, etc.)
  - Allow git config modifications
  - Allow bash to write files via any method (must block all redirect patterns)
  - Skip command injection prevention ($(), backticks, eval, source)

  **Recommended Agent Profile**:
  > **Category**: quick
    - Reason: JSON configuration update, follows clear specifications from draft
  > **Skills**: git-master
    - git-master: Git workflow for committing changes
  > **Skills Evaluated but Omitted**:
    - research: Not needed (all requirements documented in draft)
    - librarian: Not needed (no external docs needed)

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 2)
  - **Blocks**: Task 4
  - **Blocked By**: Task 1

  **References** (CRITICAL - Be Exhaustive):

  **Pattern References** (existing code to follow):
  - `agents/agents.json:37-103` - Current Chriton-Forge bash permissions (many explicit allow/ask/deny rules)
  - `agents/agents.json:37-50` - Current Chriton-Forge read permissions with secret blocking

  **API/Type References** (contracts to implement against):
  - OpenCode permission schema: Same as Task 2

  **Documentation References** (specs and requirements):
  - Interview draft: `.sisyphus/drafts/agent-permissions-refinement.md` - Chriton-Forge permission decisions
  - Metis analysis: Guardrails #1-#6 - Bash edit bypass, git secret protection, command injection, git config protection

  **External References** (libraries and frameworks):
  - OpenCode docs: https://opencode.ai/docs/permissions/ - Permission pattern matching (wildcards, last-match-wins)

  **WHY Each Reference Matters** (explain the relevance):
  - `agents/agents.json:37-103` - Shows current bash permission structure (many explicit rules) to extend with new patterns
  - `agents/agents.json:37-50` - Shows current secret blocking to extend with additional patterns
  - Interview draft - Contains exact user requirements for Chriton-Forge permissions
  - Metis analysis - Provides bash injection prevention patterns and git protection rules

  **Acceptance Criteria**:

  > **CRITICAL: AGENT-EXECUTABLE VERIFICATION ONLY**

  **Automated Verification (config validation)**:
  \`\`\`bash
  # Agent runs:

  # Verify git commit is allowed
  jq '.chiron-forge.permission.bash."git commit *"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "allow"

  # Verify git push asks
  jq '.chiron-forge.permission.bash."git push *"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "ask"

  # Verify git config is denied
  jq '.chiron-forge.permission.bash."git config *"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  # Verify npm install asks
  jq '.chiron-forge.permission.bash."npm install *"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "ask"

  # Verify bash file write redirects are blocked
  jq '.chiron-forge.permission.bash."echo * > *"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  jq '.chiron-forge.permission.bash."cat * > *"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  jq '.chiron-forge.permission.bash."tee"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  # Verify command injection is blocked
  jq '.chiron-forge.permission.bash."$(*"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  jq '.chiron-forge.permission.bash."`*"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  # Verify git secret protection
  jq '.chiron-forge.permission.bash."git add *.env*"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  jq '.chiron-forge.permission.bash."git commit *.env*"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  # Verify external_directory scope
  jq '.chiron-forge.permission.external_directory."~/p/**"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "allow"

  jq '.chiron-forge.permission.external_directory."*"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "ask"

  # Verify expanded secret blocking
  jq '.chiron-forge.permission.read.".local/share/*"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  jq '.chiron-forge.permission.read.".cache/*"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"

  jq '.chiron-forge.permission.read."*.db"' /home/m3tam3re/p/AI/AGENTS/agents/agents.json
  # Assert: Output is "deny"
  \`\`\`

  **Evidence to Capture**:
  - [x] Git commit permission (should be "allow")
  - [x] Git push permission (should be "ask")
  - [x] Git config permission (should be "deny")
  - [x] npm install permission (should be "ask")
  - [x] bash redirect echo > permission (should be "deny")
  - [x] bash redirect cat > permission (should be "deny")
  - [x] bash tee permission (should be "deny")
  - [x] bash $() injection permission (should be "deny")
  - [x] bash backtick injection permission (should be "deny")
  - [x] git add *.env* permission (should be "deny")
  - [x] git commit *.env* permission (should be "deny")
  - [x] external_directory ~/p/** permission (should be "allow")
  - [x] external_directory wildcard permission (should be "ask")
  - [x] read .local/share/* permission (should be "deny")
  - [x] read .cache/* permission (should be "deny")
  - [x] read *.db permission (should be "deny")

  **Commit**: YES (groups with Tasks 1, 2, 3)
  - Message: `chore(agents): refine permissions for Chiron and Chriton-Forge with security hardening`
  - Files: `agents/agents.json`
  - Pre-commit: `jq '.' agents/agents.json > /dev/null 2>&1` (validate JSON)

- [x] 4. Validate Configuration (Manual Verification)

  **What to do**:
  - Run JSON syntax validation: `jq '.' agents/agents.json`
  - Verify no duplicate keys in configuration
  - Verify workspace path exists: `ls -la ~/p/`
  - Document manual verification procedure for post-deployment testing

  **Must NOT do**:
  - Skip workspace path validation
  - Skip duplicate key verification
  - Proceed to deployment without validation

  **Recommended Agent Profile**:
  > **Category**: quick
    - Reason: Simple validation commands, documentation task
  > **Skills**: git-master
    - git-master: Git workflow for committing validation script or notes if needed
  > **Skills Evaluated but Omitted**:
    - research: Not needed (validation is straightforward)
    - librarian: Not needed (no external docs needed)

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential
  - **Blocks**: None (final validation task)
  - **Blocked By**: Tasks 2, 3

  **References** (CRITICAL - Be Exhaustive):

  **Pattern References** (existing code to follow):
  - `AGENTS.md` - Repository documentation structure

  **API/Type References** (contracts to implement against):
  - N/A (validation task)

  **Documentation References** (specs and requirements):
  - Interview draft: `.sisyphus/drafts/agent-permissions-refinement.md` - All user requirements
  - Metis analysis: Guardrails #1-#6 - Validation requirements

  **External References** (libraries and frameworks):
  - N/A (validation task)

  **WHY Each Reference Matters** (explain the relevance):
  - Interview draft - Contains all requirements to validate against
  - Metis analysis - Identifies specific validation steps (duplicate keys, workspace path, etc.)

  **Acceptance Criteria**:

  > **CRITICAL: AGENT-EXECUTABLE VERIFICATION ONLY**

  **Automated Verification (config validation)**:
  \`\`\`bash
  # Agent runs:

  # JSON syntax validation
  jq '.' /home/m3tam3re/p/AI/AGENTS/agents/agents.json > /dev/null 2>&1
  # Assert: Exit code 0

  # Verify no duplicate external_directory keys
  cat /home/m3tam3re/p/AI/AGENTS/agents/agents.json | jq '.chiron.permission | keys' | grep external_directory | wc -l
  # Assert: Output is "1"

  cat /home/m3tam3re/p/AI/AGENTS/agents/agents.json | jq '.chiron-forge.permission | keys' | grep external_directory | wc -l
  # Assert: Output is "1"

  # Verify workspace path exists
  ls -la ~/p/ 2>&1 | head -1
  # Assert: Shows directory listing (not "No such file or directory")

  # Verify all permission keys are valid
  cat /home/m3tam3re/p/AI/AGENTS/agents/agents.json | jq '.chiron.permission' > /dev/null 2>&1
  # Assert: Exit code 0

  cat /home/m3tam3re/p/AI/AGENTS/agents/agents.json | jq '.chiron-forge.permission' > /dev/null 2>&1
  # Assert: Exit code 0
  \`\`\`

  **Evidence to Capture**:
  - [x] jq validation output (exit code 0)
  - [x] Chiron external_directory key count (should be "1")
  - [x] Chriton-Forge external_directory key count (should be "1")
  - [x] Workspace path ls output (shows directory exists)
  - [x] Chiron permission object validation (exit code 0)
  - [x] Chriton-Forge permission object validation (exit code 0)

  **Commit**: NO (validation only, no changes)

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1, 2, 3 | `chore(agents): refine permissions for Chiron and Chriton-Forge with security hardening` | agents/agents.json | `jq '.' agents/agents.json > /dev/null` |
| 4 | N/A (validation only) | N/A | N/A |

---

## Success Criteria

### Verification Commands
```bash
# Pre-deployment validation
jq '.' /home/m3tam3re/p/AI/AGENTS/agents/agents.json > /dev/null 2>&1
# Expected: Exit code 0

# Duplicate key check
cat /home/m3tam3re/p/AI/AGENTS/agents/agents.json | jq '.chiron.permission | keys' | grep external_directory | wc -l
# Expected: 1

# Workspace path validation
ls -la ~/p/ 2>&1
# Expected: Directory listing

# Post-deployment (manual)
# Have Chiron attempt file edit → Expected: Permission denied
# Have Chiron run bd ready → Expected: Success
# Have Chriton-Forge git commit → Expected: Success
# Have Chriton-Forge git push → Expected: Ask user
# Have agent read .env → Expected: Permission denied
```

### Final Checklist
- [x] Duplicate `external_directory` key fixed
- [x] Chiron edit set to "deny"
- [x] Chiron bash denied except `bd *`
- [x] Chiron task permission restricts subagents (explore, librarian, athena, chiron-forge)
- [x] Chiron external_directory allows ~/p/** only
- [x] Chriton-Forge git commit allowed, git push asks
- [x] Chriton-Forge git config denied
- [x] Chriton-Forge package install commands ask
- [x] Chriton-Forge external_directory allows ~/p/**, asks others
- [x] Bash file write operators blocked (echo >, cat >, tee, etc.)
- [x] Bash command injection blocked ($(), backticks, eval, source)
- [x] Git secret protection added (git add/commit *.env* deny)
- [x] Expanded secret blocking patterns added (.local/share/*, .cache/*, *.db, *.keychain, *.p12)
- [x] /run/agenix/* blocked in read permissions
- [x] JSON syntax valid (jq validates)
- [x] No duplicate keys in configuration
- [x] Workspace path ~/p/** exists
