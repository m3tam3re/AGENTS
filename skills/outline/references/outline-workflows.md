# Outline Workflows

This reference provides detailed examples and patterns for Outline wiki integration with Obsidian.

## Table of Contents
1. [Export Decision to Wiki](#export-decision-to-wiki)
2. [Project Documentation Sync](#project-documentation-sync)
3. [Knowledge Discovery](#knowledge-discovery)
4. [Batch Export](#batch-export)
5. [Wiki Migration](#wiki-migration)

---

## Export Decision to Wiki

### Scenario
After a meeting, you made an important decision about API authentication. You want to preserve it in the company wiki.

### Workflow
```
User: "Export decision: Use OAuth2 for all external APIs"

Outline skill:
1. Create document:
   - Title: "API Authentication Decision"
   - Collection: Engineering/Security
   - Content:
     ---
     title: "API Authentication Decision"
     date: 2026-01-28
     decision_made_by: "[Team Name]"
     tags: [decision, api, security]
     ---

     # Decision
     Use OAuth2 for all external API integrations.

     # Reasoning
     - OAuth2 provides better security (no shared secrets)
     - Token rotation reduces risk exposure
     - Industry standard for API auth
     - Existing libraries available

     # Implementation
     - Use RFC 6749 OAuth2 framework
     - Implement refresh token flow
     - Set 30-day token expiry
     - Document API endpoints in collection

     # Alternatives Considered
     - API Keys: Rejected (security risk)
     - JWT: Rejected (overkill for external APIs)
     - Custom Auth: Rejected (maintenance burden)

     # Related Documents
     - [[OAuth2 Setup Guide]]
     - [[Token Management Policy]]
     - [[API Security Best Practices]]

2. Confirm: "Created API Authentication Decision in Engineering/Security"
3. Offer: "Link to project?"
```

### Obsidian Integration
After creating in Outline, create cross-reference in Obsidian:
```markdown
~/CODEX/01-projects/work/[project]/decisions/api-auth-decision.md
---
title: "API Authentication Decision"
date: 2026-01-28
source: outline
outline_doc_id: [ID]
tags: [work, decision, api]
---

## Decision
Use OAuth2 for all external API integrations.

## Outline Link
📄 [API Authentication Decision](outline://document/abc123)

## Context
- Made during API integration project
- Discussed in [Security Review Meeting]
- Approved by: [Stakeholder names]

## Project Notes
- Update authentication service by Q2
- Train team on OAuth2 flow
```

---

## Project Documentation Sync

### Scenario
You're starting a new project. You want to link project docs with the wiki for context.

### Workflow
```
User: "Start project: Customer Portal Redesign"

outline skill:
1. Search for related docs:
   - "Search Outline for Customer Portal"
   - "Search Outline for UI/UX guidelines"
   - "Search Outline for architecture decisions"

2. Present findings:
   📄 Customer Portal Architecture (Engineering)
   📄 UI Design System (Product/Design)
   📄 Accessibility Guidelines (Engineering/Docs)

3. Create project folder in Obsidian with wiki links
```

### Project MOC with Wiki Links
```markdown
~/CODEX/01-projects/work/customer-portal-redesign/_index.md
---
title: "Customer Portal Redesign"
status: active
deadline: 2026-06-30
priority: high
tags: [work, project]
---

## Overview
Redesign of customer portal with improved UX, performance, and accessibility.

## Wiki Resources

### Architecture
📄 [[Customer Portal Architecture]](outline://document/abc123)
- Backend architecture decisions
- Database schema
- API endpoints

### Design System
📄 [[UI Design System]](outline://document/def456)
- Component library
- Color palette
- Typography

### Guidelines
📄 [[Accessibility Guidelines]](outline://document/ghi789)
- WCAG 2.1 AA compliance
- Testing checklist
- Common patterns

## Notes
<!-- Your project notes here -->

## Tasks
<!-- Tasks linked from Basecamp -->
```

---

## Knowledge Discovery

### Scenario
You need to implement a feature but don't remember the authentication pattern used in the codebase.

### Workflow
```
User: "Ask Outline: How do we handle API authentication?"

outline skill:
1. ask_ai_about_documents(
     question: "How do we handle API authentication?"
     collection_id: "engineering"
   )

2. Present AI answer with sources:
   🤖 **Answer**:
   Based on 12 documents, here's the authentication pattern:

   **Standard Pattern**:
   - OAuth2 with refresh tokens
   - 30-day token expiry
   - Automatic refresh before expiry

   **Implementation**:
   1. Use `/auth/oauth2/token` endpoint
   2. Store refresh token securely
   3. Implement token rotation
   4. Handle 401 Unauthorized with retry

   **Exceptions**:
   - Internal services use API keys (documented separately)
   - Admin portals use session-based auth

   **Key Sources**:
   1. [[OAuth2 Setup Guide]](outline://document/abc123)
   2. [[Token Management Policy]](outline://document/def456)
   3. [[API Security Best Practices]](outline://document/ghi789)

3. Offer:
   - "Read OAuth2 Setup Guide?"
   - "Export to current project?"
```

---

## Batch Export

### Scenario
You're preparing for a job transition or need offline access to critical documentation.

### Workflow
```
User: "Export all Engineering docs to Obsidian"

outline skill:
1. export_collection(collection_id: "engineering_id")
2. Create Obsidian structure:
   ~/CODEX/03-resources/work/wiki-mirror/engineering/
   ├── api-docs/
   │   ├── oauth2-setup-guide.md
   │   ├── token-management.md
   │   └── api-security.md
   ├── architecture/
   │   ├── system-design.md
   │   └── data-flow.md
   └── decisions/
       ├── auth-decision.md
       └── database-choice.md

3. Update wiki index:
   Update ~/CODEX/03-resources/work/wiki-mirror/_wiki-index.md
   with new export metadata

4. Confirm: "Exported 15 Engineering docs to wiki-mirror/engineering/"
```

---

## Wiki Migration

### Scenario
You're switching from a different wiki system to Outline and want to migrate content.

### Workflow (No n8n - Manual Process)
```
Step 1: Export from Old Wiki
- Export all pages as Markdown
- Preserve structure/folders
- Keep metadata (created dates, authors)

Step 2: Batch Import to Outline
outline skill:
1. batch_create_documents(documents):
   [
     {
       "title": "API Documentation",
       "collection_id": "engineering_id",
       "text": "# API Documentation\n\n...",
       "publish": true
     },
     {
       "title": "System Design",
       "collection_id": "engineering_id",
       "text": "# System Design\n\n...",
       "publish": true
     }
   ]
2. Confirm: "Imported 50 documents to Outline"

Step 3: Verify Migration
- Check Outline web UI
- Verify document counts
- Test search functionality
- Fix any formatting issues

Step 4: Archive Old Wiki
- Mark old wiki as read-only
- Add deprecation notice
- Link to new Outline location
```

---

## Cross-Tool Patterns

### Outline ↔ Obsidian

| When | Action | Location |
|------|---------|----------|
| Important decision | Create in Outline + link in Obsidian | Outline: Primary, Obsidian: Reference |
| Project docs | Link wiki docs from project MOC | Obsidian: Primary, Outline: Source |
| Meeting outcome | Export key decisions to Outline | Outline: Persistent, Obsidian: Session context |
| Research | Export findings to Outline | Outline: Knowledge base, Obsidian: Working notes |

### Search Workflow

1. **First**: Search Obsidian vault (personal knowledge)
2. **Then**: Search Outline wiki (team knowledge)
3. **Finally**: Search both with context

```
User: "Find info about OAuth2"

Obsidian search:
- Check ~/CODEX/03-resources/work/wiki-mirror/
- Check project notes
- Return local copies

Outline search:
- search_documents("OAuth2")
- Return live wiki content
- Export if needed for offline access
```

---

## Advanced Workflows

### Decision Audit

Periodically review all decisions to check:
- Relevance (still applicable?)
- Implementation status (actually done?)
- Outdated decisions (need update?)

```bash
# List all decision docs
search_documents("decision")

# For each:
read_document(document_id)
# Check frontmatter:
# - implemented: true/false
# - reviewed_at: date
# - status: active/archived
```

### Knowledge Gap Analysis

Identify missing documentation:

1. List all project areas
2. Search Outline for each area
3. Identify gaps:
   - "No results found for X"
   - "Documentation is outdated"
   - "Information is scattered"

Create follow-up tasks:
```markdown
## Documentation Tasks
- [ ] Write API rate limiting guide (missing)
- [ ] Update OAuth2 examples (outdated)
- [ ] Create testing best practices (scattered)
```

---

## Troubleshooting

### Export Failed
**Problem**: Document exported to wrong location or failed to export

**Solution**:
1. Verify collection hierarchy
2. Check Obsidian vault path
3. Ensure directory exists: `mkdir -p 03-resources/work/wiki-mirror/[collection]/`
4. Check file permissions

### Search No Results
**Problem**: search_documents returns empty results

**Solution**:
1. Try broader query (fewer keywords)
2. Remove collection_id to search everywhere
3. Check if document exists in Outline web UI
4. Use ask_ai_about_documents for semantic search

### Wiki Link Broken
**Problem**: `(outline://document/abc123)` link doesn't work

**Solution**:
1. Verify document_id is correct
2. Check Outline MCP is running
3. Test with `read_document(document_id)`
4. Fallback: Use Outline web UI URL

---

## Best Practices Summary

1. **Export Early, Export Often**: Don't wait until job transition
2. **Link Immediately**: Create Obsidian links when exporting
3. **Index Everything**: Maintain wiki index for easy navigation
4. **AI as Helper**: Use `ask_ai_about_documents` but verify sources
5. **Preserve Hierarchy**: Maintain collection structure in exports
6. **Tag Generously**: Add tags for discoverability
7. **Cross-Reference**: Link related documents in Outline
8. **Decisions Matter**: Export all decisions, not just docs

---

## Automation (Future n8n Workflows)

These will be implemented later with n8n automation:

1. **Daily Wiki Sync**: Export updated Outline docs each night
2. **Decision Auto-Export**: Hook meeting-notes → Outline create
3. **Search Integration**: Combine Obsidian + Outline search
4. **Backup Workflow**: Weekly export_all_collections
