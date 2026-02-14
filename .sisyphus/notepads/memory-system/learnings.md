
## Core Memory Skill Creation (2026-02-12)

**Task**: Create `skills/memory/SKILL.md` - dual-layer memory orchestration skill

**Pattern Identified**:
- Skill structure follows YAML frontmatter with required fields:
  - `name`: skill identifier
  - `description`: Use when (X), triggers (Y) pattern
  - `compatibility`: "opencode"
- Markdown structure: Overview, Prerequisites, Workflows, Error Handling, Integration, Quick Reference, See Also

**Verification Pattern**:
```bash
test -f <path> && echo "File exists"
grep "name: <skill>" <path>
grep "key-term" <path>
```

**Key Design Decision**: 
- Central orchestration skill that references underlying implementation skills (mem0-memory, obsidian)
- 4 core workflows: Store, Recall, Auto-Capture, Auto-Recall
- Error handling with graceful degradation

## Apollo Agent Prompt Update (2026-02-12)

**Task**: Add memory management responsibilities to Apollo agent system prompt

**Edit Pattern**: Multiple targeted edits to single file preserving existing content
- Line number-based edits require precise matching of surrounding context
- Edit order: Core Responsibilities → Quality Standards → Tool Usage → Edge Cases
- Each edit inserts new bullet items without removing existing content

**Key Additions**:
1. Core Responsibilities: "Manage dual-layer memory system (Mem0 + Obsidian CODEX)"
2. Quality Standards: Memory storage, auto-capture, retrieval, categories
3. Tool Usage: Mem0 REST API (localhost:8000), Obsidian MCP integration
4. Edge Cases: Mem0 unavailable, Obsidian unavailable handling

**Verification Pattern**:
```bash
grep -c "memory" ~/p/AI/AGENTS/prompts/apollo.txt  # Count occurrences
grep "Mem0" ~/p/AI/AGENTS/prompts/apollo.txt         # Check specific term
grep -i "auto-capture" ~/p/AI/AGENTS/prompts/apollo.txt  # Case-insensitive
```

**Observation**: grep is case-sensitive by default - use -i for case-insensitive searches
