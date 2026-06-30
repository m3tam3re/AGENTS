# Knowledge Management Landscape Research (2026-06-29)

Research conducted when designing the m3ta-brain vault. Condensed for future reference.

## 1. Karpathy LLM Wiki Pattern (April 2026)

Andrej Karpathy published a "pattern gist" for LLM-maintained personal knowledge bases.

**Core idea**: Instead of RAG (re-derive from raw docs every query), the LLM builds and maintains a **persistent, compounding wiki** — cross-references already there, contradictions already flagged, synthesis already done.

**Three layers**:
- Raw sources (`raw/`) — original articles, papers, transcripts
- LLM Wiki (`wiki/`) — entity pages, concepts, comparisons, synthesis (LLM writes ALL of this)
- Schema (`CLAUDE.md` / `AGENTS.md`) — tells the LLM how the wiki is structured

**Key quote**: *"Obsidian is the IDE, the LLM is the programmer, the wiki is the codebase."*

**What we adopted**: AGENTS.md as schema, structured directories, LLM-maintained notes, Obsidian as viewer.
**What we extended**: Added project state, decisions, people, learnings — not just research concepts.

Source: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

## 2. Daniel Miessler PAI / Personal AI Infrastructure (v5.0, May 2026)

PAI ("Life Operating System") is the most comprehensive personal AI system design.

**7 Architecture Components**: Intelligence, Context (Memory), Personality, Tools, Security, Orchestration, Interface.

**Key insight — Scaffolding > Model**: "When Kai gives me a result I don't want, it's almost never because Claude is dumb. It's because my scaffolding didn't provide the right context."

**Memory System v7.6 — three tiers by PURPOSE, not chronology**:
- `MEMORY/WORK/` — active task tracking, ISAs (Ideal State Artifacts)
- `MEMORY/KNOWLEDGE/` — typed graph (People, Companies, Ideas, Research)
- `MEMORY/LEARNING/` — meta-patterns, signals, failures, corrections
- `MEMORY/RELATIONSHIP/` — DA-Principal relationship notes
- `MEMORY/OBSERVABILITY/` — every tool call, hook firing, satisfaction signal

**Signal capture**: Every interaction generates signals — explicit ratings, implicit sentiment, failure captures (ratings 1-3 trigger full-context saves).

**Principles adopted**: "Text over opaque storage" (if you can't `cat` it, don't store it), filesystem as context (no RAG), memory structured by purpose.

**What we adopted**: Purpose-based directory structure (Telos/Preferences/Projects/Decisions/People/Learning), write policy with review gates, learning patterns and corrections as first-class citizens.
**What we skipped**: ISA/ISC verification system, Pulse dashboard, hooks, voice — too Claude-Code-specific.

Source: https://danielmiessler.com/blog/personal-ai-infrastructure, github.com/danielmiessler/PAI

## 3. qmd — Query Markup Documents (Tobi Lütke, 26K stars)

Fully local CLI search engine for markdown. BM25 + Vector + LLM Reranking, all on-device.

**Three search modes**:
- `qmd search` — BM25 keyword (fast, no LLM)
- `qmd vsearch` — Vector semantic (embeddings)
- `qmd query` — Hybrid: query expansion + parallel retrieval + RRF fusion + LLM reranking

**Key features**: Collections (named indexed directories), Context (human descriptions attached to paths), MCP server mode, multiple output formats (`--json`, `--md`, `--files`).

**Local models** (~2GB total): embeddinggemma-300M, qwen3-reranker-0.6b, qmd-query-expansion-1.7B.

**Our plan**: Install as retrieval layer over m3ta-brain + tech wiki + nemoti wiki. Collections: `brain`, `tech-wiki`, `nemoti-wiki`. Not yet installed (requires Node.js/Bun on server).

Source: github.com/tobi/qmd, npm: `@tobilu/qmd`

## 4. Obsidian MCP Integration Landscape

Multiple MCP servers connect AI agents to Obsidian vaults:

| Server | Transport | Key Feature |
|---|---|---|
| Local REST API plugin | HTTP (localhost:27124) | Built-in MCP at `/mcp/`, the foundation |
| yanxue06/obsidian-mcp | stdio/HTTP | Graph-aware: backlinks, multi-hop, safe rename |
| lstpsche/obsidian-mcp (Rust) | stdio/HTTP | Single binary, filesystem-native, works without Obsidian running |
| Vasallo94/obsidian-mcp-server | stdio | Explicit Hermes support documented |
| cyanheads/obsidian-mcp-server | stdio/HTTP | 14 tools, surgical section editing, read/write path scoping |

**Key limitation for us**: MCP over localhost requires Obsidian on same machine as agent. Hermes runs server-side, Obsidian runs on Sascha's desktop. So Git-sync is Phase 1, MCP is Phase 2 (optional).

## 5. Shared Memory Platforms

| Platform | Architecture | Key Differentiator |
|---|---|---|
| Open Second Brain | Obsidian-native, Hermes-first | Nightly "dream" passes, preferences with confidence bands |
| Agentkeep | Git-backed markdown vault | Content-hash compare-and-swap, safe two-driver editing |
| Noosphere | PostgreSQL + Redis | REST API, scoped access, Obsidian export/import |

**What we adopted from these**: Git as the sync/merge mechanism (Agentkeep), draft-then-review pattern for sensitive notes (Open Second Brain), plain markdown as the substrate (all three).

## Design Decisions Summary

| Decision | Chosen | Rejected | Rationale |
|---|---|---|---|
| Sync mechanism | Git (Gitea) | Syncthing | Versioned, auditable, conflict diffs, Gitea already exists |
| Link format | Standard Markdown links (`[text](relative/path.md)`) | Obsidian-only `[[wikilinks]]` | Works in both Gitea and Obsidian; current vault rules supersede the initial design note |
| Language | German + EN tech | English only | Match how Sascha communicates |
| Agent instructions | `AGENTS.md` | Agent-specific config | Multi-agent compatible (Pi, OpenCode, Claude Code, Hermes) |
| Memory model | Purpose-based dirs | Chronological | Inspired by PAI v7.6 (WORK/KNOWLEDGE/LEARNING pattern) |
| Retrieval | qmd (planned) | RAG/black-box | Local, hybrid search, no cloud dependency |
