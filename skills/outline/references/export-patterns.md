# Export Patterns

Patterns and examples for exporting Outline wiki content to Obsidian vault.

## Table of Contents
1. [Frontmatter Patterns](#frontmatter-patterns)
2. [Folder Structure](#folder-structure)
3. [Linking Strategies](#linking-strategies)
4. [Index Management](#index-management)
5. [Batch Operations](#batch-operations)

---

## Frontmatter Patterns

### Standard Export Frontmatter

```yaml
---
title: "Document Title"
source: outline
document_id: "abc123def456"
collection: "Engineering/Security"
collection_id: "col_789"
tags: [work, wiki, outline, security]
outline_url: "https://outline.example.com/doc/abc123"
created_at: "2026-01-28"
exported_at: "2026-01-28"
last_updated: "2026-01-25"
---
```

### Decision Document Frontmatter

```yaml
---
title: "API Authentication Decision"
source: outline
type: decision
decision_date: "2026-01-28"
made_by: "Team Name"
decision_status: active | implemented | archived
tags: [work, wiki, decision, api, security]
---

# Decision
Use OAuth2 for all external API integrations.
```

### Process Document Frontmatter

```yaml
---
title: "API Onboarding Process"
source: outline
type: process
version: "2.1"
last_reviewed: "2026-01-28"
tags: [work, wiki, process, onboarding]
---

# API Onboarding Process
Step-by-step guide for new API consumers...
```

### Reference Document Frontmatter

```yaml
---
title: "OAuth2 Setup Guide"
source: outline
type: reference
language: "markdown"
estimated_read_time: "10 min"
difficulty: intermediate
tags: [work, wiki, reference, oauth2, api]
---

# OAuth2 Setup Guide
Complete guide for implementing OAuth2...
```

---

## Folder Structure

### Standard Wiki Mirror Structure

```
~/CODEX/03-resources/work/wiki-mirror/
├── _wiki-index.md                    # Main index
├── engineering/                        # Collection folder
│   ├── security/                      # Subfolder (hierarchy)
│   │   ├── api-auth-decision.md
│   │   └── security-best-practices.md
│   ├── architecture/
│   │   ├── system-design.md
│   │   └── data-flow.md
│   └── api-docs/
│       ├── oauth2-setup.md
│       ├── token-management.md
│       └── api-reference.md
├── product/
│   ├── design-system.md
│   ├── features/
│   └── user-guides/
└── operations/
    ├── deployment/
    ├── monitoring/
    └── incident-response/
```

### Project-Specific Wiki Structure

```
~/CODEX/01-projects/work/[project]/
├── _index.md                       # Project MOC with wiki links
├── notes/
│   ├── requirements.md
│   ├── architecture-notes.md
│   └── implementation-notes.md
├── meetings/
│   └── project-sync-20260128.md
├── decisions/
│   └── tech-stack-decision.md       # Also exported to wiki
└── wiki-exports/                     # Project-specific wiki copies
    ├── api-spec.md                 # Copy from Outline
    └── design-decisions.md          # Copy from Outline
```

---

## Linking Strategies

### Outline Document Link (MCP URI)

```markdown
# Direct MCP Link (Best for Outline)
[OAuth2 Setup Guide](outline://document/abc123def456)
```

**Pros**:
- Direct integration with Outline MCP
- Always points to current version
- Can open in Outline web UI if MCP fails

**Cons**:
- Requires Outline MCP to be active
- Not clickable in external viewers

### Wiki-Link with Reference

```markdown
# Wiki-Link (Best for Obsidian)
📄 [[OAuth2 Setup Guide]]
```

**Frontmatter link**:
```yaml
---
title: "API Authentication Decision"
wiki_link: "[[OAuth2 Setup Guide]]"
wiki_doc_id: "abc123def456"
---
```

### External URL Link (Fallback)

```markdown
# URL Link (Fallback for offline/viewer access)
[OAuth2 Setup Guide](https://outline.example.com/doc/abc123)
```

**In frontmatter**:
```yaml
---
outline_url: "https://outline.example.com/doc/abc123"
---
```

### Combined Strategy (Recommended)

```markdown
---
title: "API Authentication Decision"
source: outline
document_id: "abc123def456"
wiki_link: "[[OAuth2 Setup Guide]]"
outline_url: "https://outline.example.com/doc/abc123"
tags: [work, decision, api]
---

## Decision
Use OAuth2 for all external APIs.

## References

### Primary Source
📄 [[OAuth2 Setup Guide]](outline://document/abc123)

### Related Documents
📄 [[Token Management Policy]](outline://document/def456)
📄 [[API Security Best Practices]](outline://document/ghi789)

### External Links
- [View in Outline Web UI](https://outline.example.com/doc/abc123)
```

---

## Index Management

### Main Wiki Index

```markdown
---
title: "Outline Wiki Index"
source: outline
last_sync: "2026-01-28T18:50:00Z"
total_docs: 45
total_collections: 6
tags: [work, wiki, outline]
---

# Outline Wiki Index

## Collections

### 📁 Engineering (15 docs)
**ID**: col_eng_123
**Description**: Technical documentation, architecture, APIs

**Subfolders**:
- [security](engineering/security/) (3 docs)
- [architecture](engineering/architecture/) (5 docs)
- [api-docs](engineering/api-docs/) (7 docs)

### 📁 Product (12 docs)
**ID**: col_prod_456
**Description**: Product specs, user guides, features

**Subfolders**:
- [design-system](product/design-system.md) (4 docs)
- [features](product/features/) (6 docs)
- [user-guides](product/user-guides/) (2 docs)

### 📁 Security (8 docs)
**ID**: col_sec_789
**Description**: Security policies, incident response, compliance

### 📁 Operations (10 docs)
**ID**: col_ops_012
**Description**: Deployment, monitoring, runbooks

## Recently Exported

| Date | Document | Collection | Tags |
|-------|-----------|------------|-------|
| 2026-01-28 | OAuth2 Setup Guide | Engineering/Security | api, oauth2 |
| 2026-01-27 | System Design | Engineering/Architecture | architecture |
| 2026-01-26 | Deployment Guide | Operations/Deployment | ops, devops |

## Document Types

- 📄 **Reference**: 30 docs
- 🎯 **Decision**: 8 docs
- 📋 **Process**: 5 docs
- 📘 **Guide**: 2 docs

## Search

- 🔍 [Search Outline for](outline://search/) live content
- 🔍 [Search exports](#exported-documents) in vault

---

## Exported Documents

### By Collection

#### Engineering
- [[OAuth2 Setup Guide]]
- [[Token Management Policy]]
- [[API Security Best Practices]]
- [[System Design]]
- [[Data Flow Architecture]]

#### Product
- [[Design System]]
- [[Component Library]]
- [[User Guide]]

#### Security
- [[Incident Response]]
- [[Security Policy]]

### By Tag

#api
- [[OAuth2 Setup Guide]]
- [[API Security Best Practices]]

#security
- [[API Security Best Practices]]
- [[Incident Response]]

#architecture
- [[System Design]]
- [[Data Flow Architecture]]
```

### Collection-Specific Indexes

Create `_index.md` in each collection folder:

```markdown
---
title: "Engineering Wiki"
collection: Engineering
collection_id: col_eng_123
source: outline
tags: [work, wiki, engineering]
---

# Engineering Wiki

## Overview
Technical documentation, architecture decisions, and API references.

## Structure

### Security (3 docs)
📄 [[API Authentication Decision]]
📄 [[Security Best Practices]]
📄 [[Incident Response]]

### Architecture (5 docs)
📄 [[System Design]]
📄 [[Data Flow]]
📄 [[Component Architecture]]
📄 [[Scalability Guide]]
📄 [[Performance Optimization]]

### API Docs (7 docs)
📄 [[OAuth2 Setup Guide]]
📄 [[Token Management]]
📄 [[API Reference]]
📄 [[Rate Limiting]]
📄 [[Error Handling]]
📄 [[Webhooks]]
📄 [[Testing Guide]]

## Quick Links
- 🔍 [Search Outline](outline://collection/col_eng_123)
- 📄 [Export Collection](outline://export/col_eng_123)
- 🌐 [Open in Web UI](https://outline.example.com/c/col_eng_123)
```

---

## Batch Operations

### Export Multiple Documents

```bash
# Pattern for batch export (manual script outline)

documents = [
    {"id": "abc123", "path": "engineering/api/oauth2.md"},
    {"id": "def456", "path": "engineering/api/token.md"},
    {"id": "ghi789", "path": "engineering/security/best-practices.md"},
]

for doc in documents:
    content = export_document(doc["id"])
    write_file(f"wiki-mirror/{doc['path']}", content)
    update_index(doc["id"], doc["path"])
```

### Update Index After Batch

```markdown
---
title: "Batch Export Report"
export_date: 2026-01-28
documents_exported: 45
collections_exported: 6
---

## Export Summary

- Exported 45 documents from 6 collections
- Total size: 2.3 MB
- Processing time: 3.2 minutes

## Collections Updated
- ✅ Engineering: 15 docs
- ✅ Product: 12 docs
- ✅ Security: 8 docs
- ✅ Operations: 10 docs

## Next Steps
- [ ] Verify all exports in Obsidian
- [ ] Test wiki links
- [ ] Update wiki index
```

---

## Naming Conventions

### File Naming

**Rules**:
1. Lowercase only
2. Replace spaces with hyphens
3. Remove special characters
4. Keep meaningful names
5. Avoid dates in names (use frontmatter instead)

**Examples**:
```
OAuth2 Setup Guide → oauth2-setup-guide.md
API Security Best Practices → api-security-best-practices.md
System Design (2026) → system-design.md (use frontmatter for version)
```

### Folder Naming

**Rules**:
1. Use collection names from Outline
2. Preserve hierarchy (subcollections as subfolders)
3. Consistent with project structure

**Examples**:
```
Engineering/Security → engineering/security/
Engineering/API Docs → engineering/api-docs/
Product/Features → product/features/
```

---

## Version Control for Exports

### Git Tracking

```
~/CODEX/03-resources/work/wiki-mirror/
├── .git/                      # Git repo for exports
├── _wiki-index.md
└── engineering/
    └── ...
```

**Benefits**:
- Track changes to exported docs
- Diff between export versions
- Revert to previous exports
- Track when docs were last synced

### Sync Workflow

```bash
# Before export
cd ~/CODEX/03-resources/work/wiki-mirror/
git pull
git add .
git commit -m "Pre-export checkpoint"
git push

# After export
git add .
git commit -m "Exported 45 docs from Outline (2026-01-28)"
git push
```

---

## Troubleshooting

### Duplicate Exports

**Problem**: Same document exported multiple times

**Solution**:
1. Check for existing file before export
2. Add timestamp to duplicates: `doc-name.20260128.md`
3. Or ask user: "Overwrite or create new version?"

### Broken Links After Export

**Problem**: Wiki links don't work in Obsidian

**Solution**:
1. Verify document IDs in frontmatter
2. Check file paths match index
3. Use wiki-links for same-vault docs
4. Use MCP URIs for Outline docs

### Large Exports Timeout

**Problem**: Exporting entire collection fails (too large)

**Solution**:
1. Export in batches (e.g., 20 docs at a time)
2. Use `export_collection` instead of individual docs
3. Implement progress tracking
4. Retry failed documents

---

## Best Practices Summary

1. **Always Include Frontmatter**: Document metadata is crucial
2. **Maintain Hierarchy**: Preserve collection structure
3. **Update Index**: Keep wiki index current
4. **Use Multiple Link Types**: MCP URI + wiki-link + URL
5. **Tag Exports**: Make exported docs discoverable
6. **Track Changes**: Use Git for version control
7. **Regular Exports**: Don't wait for job transition
8. **Verify Links**: Test after every export batch
9. **Organize by Type**: Reference, Decision, Process folders
10. **Document Exports**: Keep export log for reference
