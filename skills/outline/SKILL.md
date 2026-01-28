---
name: outline
description: "Search, read, and manage Outline wiki documentation via MCP. Use when: (1) searching Outline wiki, (2) reading/exporting Outline documents, (3) creating/updating Outline docs, (4) managing collections, (5) finding wiki content. Triggers: outline, wiki, search outline, find in wiki, export document."
compatibility: opencode
---

# Outline Wiki Integration

MCP server integration for Outline wiki documentation - search, read, create, and manage wiki content.

## Quick Reference

| Action          | Command Pattern                        |
| --------------- | -------------------------------------- |
| Search wiki     | "Search Outline for [topic]"             |
| Read document   | "Show me [document name]"               |
| Export to vault  | "Export [document] to Obsidian"         |
| Create doc      | "Create Outline doc: [title]"            |
| List collections | "Show Outline collections"                 |

## Core Workflows

### 1. Search Wiki

**When user says**: "Search Outline for X", "Find in wiki about X", "Outline wiki: X"

**Steps**:
```
1. search_documents(query, collection_id?, limit?, offset?)
   - If collection_id provided → search in specific collection
   - If no collection_id → search all collections
   - Default limit: 20 results
2. Present results:
   - Document titles
   - Collection names
   - Relevance (if available)
3. Offer actions:
   - "Read specific document"
   - "Export to Obsidian"
   - "Find related documents"
```

**Example output**:
```
Found 5 documents matching "API authentication":

📄 Authentication Best Practices (Collection: Engineering)
📄 OAuth2 Setup Guide (Collection: Security)
📄 API Key Management (Collection: DevOps)
📄 Common Auth Errors (Collection: Troubleshooting)

Read any document or export to Obsidian?
```

### 2. Read Document

**When user says**: "Show me [document]", "What's in [document]", "Read [doc from Outline]"

**Steps**:
```
1. get_document_id_from_title(query, collection_id?)
   - Search by exact title
   - Return document ID
2. read_document(document_id)
   - Get full markdown content
3. Present content:
   - Title and metadata
   - Document content (formatted)
   - Collection location
   - Tags (if available)
4. Offer follow-up:
   - "Export to Obsidian?"
   - "Find related documents?"
   - "Add to project?"
```

**Example output**:
```markdown
# Authentication Best Practices
**Collection**: Engineering
**Last updated**: 2026-01-25

## OAuth2 Flow
[Document content...]

## API Keys
[Document content...]

---

📂 Export to Obsidian | 🔗 Find related | ➕ Add to project
```

### 3. Export to Obsidian

**When user says**: "Export [document] to Obsidian", "Save [wiki page] to vault"

**Steps**:
```
1. export_document(document_id)
   - Get markdown content
2. Determine Obsidian location:
   - If for project: `01-projects/work/[project]/notes/[doc-name].md`
   - If general: `03-resources/work/wiki-mirror/[doc-name].md`
3. Add frontmatter:
   ---
   title: "[Document Title]"
   source: outline
   document_id: [ID]
   collection: "[Collection Name]"
   tags: [work, wiki, outline]
   ---
4. Create file in vault
5. Link to context:
   - Project: [[Project Name]]
   - Related resources
6. Confirm: "Exported [document] to [location]"
```

**File naming**:
- Convert to kebab-case: `Authentication Best Practices` → `authentication-best-practices.md`
- Preserve collection hierarchy: `[collection-name]/[doc-name].md`

### 4. Create Document

**When user says**: "Create Outline doc: [title]", "Add wiki page: [title]"

**Steps**:
```
1. Ask for details:
   - Collection (list available if needed)
   - Content (markdown text)
   - Parent document (if hierarchical)
   - Publish immediately?

2. create_document(title, collection_id, text?, parent_document_id?, publish?)
3. Confirm creation:
   - Document ID
   - URL (if Outline has web UI)
4. Offer actions:
   - "Add backlink?"
   - "Create in Obsidian too?"
   - "Link to project?"
```

### 5. Document Discovery

**When user says**: "Show Outline collections", "Browse wiki", "What's in [collection]?"

**Steps**:
```
1. list_collections()
   - Get all collections with metadata
2. Present hierarchy:
   - Collection names
   - Document counts
   - Colors (if set)
3. User selects collection
4. get_collection_structure(collection_id)
   - Show document tree
   - Hierarchical view
```

**Example output**:
```
Outline Wiki Collections:

📁 Engineering (15 docs)
  ├─ API Documentation (8 docs)
  └─ System Design (7 docs)

📁 Product (12 docs)
  ├─ Features (6 docs)
  └─ User Guides (6 docs)

📁 Security (8 docs)

Browse which collection?
```

### 6. AI-Powered Search

**When user says**: "Ask Outline about X", "What does Outline say about X?"

**Steps**:
```
1. ask_ai_about_documents(question, collection_id?, document_id?)
   - Natural language query
   - AI searches across documents
2. Present AI answer:
   - Summary of findings
   - Source documents referenced
   - Confidence (if available)
3. Offer:
   - "Read source documents"
   - "Export to Obsidian"
```

**Example output**:
```
🤖 Answer from Outline wiki:

Based on 12 documents, here's what I found about API authentication:

**Summary**:
- OAuth2 is preferred over API keys
- Tokens expire after 30 days
- Refresh tokens allow seamless re-authentication

**Key Sources**:
1. OAuth2 Setup Guide (Engineering/Security)
2. Authentication Best Practices (Engineering)
3. Token Management (DevOps)

Read any source document?
```

## Tool Reference

### Search & Discovery

- `search_documents(query, collection_id?, limit?, offset?)`
  - Full-text search across wiki
  - Optional: Scope to specific collection
  - Pagination support

- `list_collections()`
  - Get all collections with metadata
  - Names, descriptions, colors, doc counts

- `get_collection_structure(collection_id)`
  - Hierarchical document tree
  - Parent-child relationships

- `get_document_id_from_title(query, collection_id?)`
  - Find document by title
  - Exact or fuzzy match

### Document Reading

- `read_document(document_id)`
  - Full document content
  - Markdown format
  - Metadata included

- `export_document(document_id)`
  - Export as markdown
  - Same content as read_document
  - Designed for exports

### Document Management

- `create_document(title, collection_id, text?, parent_document_id?, publish?)`
  - Create new wiki page
  - Support for hierarchical docs
  - Draft or published

- `update_document(document_id, title?, text?, append?)`
  - Update existing document
  - Append mode for additions
  - Preserve history

- `move_document(document_id, collection_id?, parent_document_id?)`
  - Move between collections
  - Reorganize hierarchy

### Document Lifecycle

- `archive_document(document_id)`
  - Archive (not delete)
  - Can be restored

- `unarchive_document(document_id)`
  - Restore from archive

- `delete_document(document_id, permanent?)`
  - Move to trash or permanent delete
  - Requires careful confirmation

### Comments & Collaboration

- `add_comment(document_id, text, parent_comment_id?)`
  - Add threaded comments
  - Support for replies

- `list_document_comments(document_id, include_anchor_text?, limit?, offset?)`
  - View discussion on document
  - Threaded view

- `get_document_backlinks(document_id)`
  - Find documents linking here
  - Useful for context

### Collection Management

- `create_collection(name, description?, color?)`
  - Create new collection
  - For organizing docs

- `update_collection(collection_id, name?, description?, color?)`
  - Edit collection metadata

- `delete_collection(collection_id)`
  - Remove collection
  - Affects all documents in it

- `export_collection(collection_id, format?)`
  - Export entire collection
  - Default: outline-markdown

- `export_all_collections(format?)`
  - Export all wiki content
  - Full backup

### Batch Operations

- `batch_create_documents(documents)`
  - Create multiple docs at once
  - For bulk imports

- `batch_update_documents(updates)`
  - Update multiple docs
  - For maintenance

- `batch_move_documents(document_ids, collection_id?, parent_document_id?)`
  - Move multiple docs
  - Reorganization

### AI-Powered

- `ask_ai_about_documents(question, collection_id?, document_id?)`
  - Natural language queries
  - AI-powered search
  - Synthesizes across documents

## Integration with Other Skills

| From Skill | To Outline |
| ----------- | ---------- |
| meeting-notes | Export decisions to wiki |
| project-structures | Link project docs to wiki |
| daily-routines | Capture learnings in wiki |
| brainstorming | Save decisions to wiki |

## Integration with Obsidian

### Export Workflow

**When to export**:
- Important decisions made
- Project documentation needed offline
- Wiki content to reference locally
- Job transition (export all)

**Export locations**:
```
~/CODEX/
├── 01-projects/work/
│   └── [project]/
│       └── notes/
│           └── [exported-doc].md  # Linked to project
└── 03-resources/work/
    └── wiki-mirror/
        ├── [collection-name]/
        │   └── [doc].md          # Exported wiki pages
        └── _wiki-index.md           # Index of all exports
```

**Wiki index structure**:
```markdown
---
title: "Outline Wiki Index"
source: outline
last_sync: YYYY-MM-DD
---

## Collections
- [Engineering](engineering/) - 15 docs
- [Product](product/) - 12 docs
- [Security](security/) - 8 docs

## Recently Exported
- [[OAuth2 Setup Guide]] - 2026-01-25
- [[API Documentation]] - 2026-01-24
- [[System Design]] - 2026-01-23

## Search Wiki
<!-- Use outline MCP for live search -->
"Search Outline for..." → outline skill
```

## Access Control Notes

If Outline MCP is configured with `OUTLINE_READ_ONLY=true`:
- ❌ Cannot create documents
- ❌ Cannot update documents
- ❌ Cannot move/archive/delete
- ✅ Can search and read
- ✅ Can export documents

If `OUTLINE_DISABLE_DELETE=true`:
- ✅ Can create and update
- ❌ Cannot delete (protects against accidental loss)

## Work vs Personal Usage

### Work Wiki (Primary)
- Collections: Engineering, Product, Security, etc.
- Export to: `03-resources/work/wiki-mirror/`
- Projects link to: `[[Engineering/Design Decisions]]`

### Personal Wiki (Optional)
- Collections: Recipes, Travel, Hobbies, etc.
- Export to: `03-resources/personal/wiki/`
- Separate from work content

## Best Practices

### Searching
- Use specific keywords (not "everything about X")
- Use collection_id for focused search
- Check multiple collections if first search is limited

### Exporting
- Export decisions, not just reference docs
- Link exported docs to projects immediately
- Update wiki index after export
- Regular exports for offline access

### Creating Documents
- Use clear, descriptive titles
- Add to appropriate collection
- Link related documents
- Add tags for discoverability

### AI Queries
- Ask specific questions (not "everything about X")
- Use collection_id to scope query
- Verify AI sources by reading docs
- Use AI to synthesize, not replace reading

## Error Handling

### Document Not Found
1. Check title spelling
2. Try fuzzy search
3. Search collection directly

### Collection Not Found
1. List all collections
2. Check collection name
3. Verify access permissions

### Export Failed
1. Check Obsidian vault path
2. Verify disk space
3. Check file permissions
4. Create directories if needed

### Rate Limiting
- Outline MCP handles automatically with retries
- Reduce concurrent operations if persistent errors

## Quick Reference

| Action | Command Pattern |
|--------|-----------------|
| Search wiki | "Search Outline for [topic]" |
| Read document | "Show me [document name]" |
| Export to vault | "Export [document] to Obsidian" |
| Create doc | "Create Outline doc: [title]" |
| List collections | "Show Outline collections" |
| AI query | "Ask Outline about [question]" |
| Browse structure | "Browse wiki" or "Show Outline collections" |

## Resources

- `references/outline-workflows.md` - Detailed workflow examples
- `references/export-patterns.md` - Obsidian integration patterns

**Load references when**:
- Designing complex exports
- Troubleshooting integration issues
- Setting up project-to-wiki links
