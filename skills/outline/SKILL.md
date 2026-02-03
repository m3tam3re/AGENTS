---
name: outline
description: "Outline wiki integration for knowledge management and documentation workflows. Use when Opencode needs to interact with Outline for: (1) Creating and editing documents, (2) Searching and retrieving knowledge base content, (3) Managing document collections and hierarchies, (4) Handling document sharing and permissions, (5) Collaborative features like comments. Triggers: 'Outline', 'wiki', 'knowledge base', 'documentation', 'team docs', 'document in Outline', 'search Outline', 'Outline collection'."
compatibility: opencode
---

# Outline Wiki Integration

Outline is a team knowledge base and wiki platform. This skill provides guidance for Outline API operations and knowledge management workflows.

## Core Capabilities

### Document Operations

- **Create**: Create new documents with markdown content
- **Read**: Retrieve document content, metadata, and revisions
- **Update**: Edit existing documents, update titles and content
- **Delete**: Remove documents (with appropriate permissions)

### Collection Management

- **Organize**: Structure documents in collections and nested collections
- **Hierarchies**: Create parent-child relationships
- **Access Control**: Set permissions at collection level

### Search and Discovery

- **Full-text search**: Find documents by content
- **Metadata filters**: Search by collection, author, date
- **Advanced queries**: Combine multiple filters

### Sharing and Permissions

- **Public links**: Generate shareable document URLs
- **Team access**: Manage member permissions
- **Guest access**: Control external sharing

### Collaboration

- **Comments**: Add threaded discussions to documents
- **Revisions**: Track document history and changes
- **Notifications**: Stay updated on document activity

## Workflows

### Creating a New Document

1. Determine target collection
2. Create document with title and initial content
3. Set appropriate permissions
4. Share with relevant team members if needed

### Searching Knowledge Base

1. Formulate search query
2. Apply relevant filters (collection, date, author)
3. Review search results
4. Retrieve full document content when needed

### Organizing Documents

1. Review existing collection structure
2. Identify appropriate parent collection
3. Create or update documents in hierarchy
4. Update collection metadata if needed

### Document Collaboration

1. Add comments for feedback or discussion
2. Track revision history for changes
3. Notify stakeholders when needed
4. Resolve comments when addressed

## Integration Patterns

### Knowledge Capture

When capturing information from conversations or research:
- Create document in appropriate collection
- Use clear, descriptive titles
- Structure content with headers for readability
- Add tags for discoverability

### Documentation Updates

When updating existing documentation:
- Retrieve current document revision
- Make targeted, minimal changes
- Add comments explaining significant updates
- Share updates with relevant stakeholders

### Knowledge Retrieval

When searching for information:
- Start with broad search terms
- Refine with collection and metadata filters
- Review multiple relevant documents
- Cross-reference linked documents for context

## Common Use Cases

| Use Case | Recommended Approach |
|----------|---------------------|
| Project documentation | Create collection per project, organize by phase |
| Team guidelines | Use dedicated collection, group by topic |
| Meeting notes | Create documents with templates, tag by team |
| Knowledge capture | Search before creating, link to related docs |
| Onboarding resources | Create structured collection with step-by-step guides |

## Best Practices

- **Consistent naming**: Use clear, descriptive titles
- **Logical organization**: Group related documents in collections
- **Regular maintenance**: Review and update outdated content
- **Access control**: Set appropriate permissions for sensitive content
- **Searchability**: Use tags and metadata effectively
- **Collaboration**: Use comments for discussions, not content changes

## Handoff to Other Skills

| Output | Next Skill | Trigger |
|--------|------------|---------|
| Research findings | knowledge-management | "Organize this research in Outline" |
| Documentation draft | communications | "Share this document via email" |
| Task from document | task-management | "Create tasks from this outline" |
| Project plan | plan-writing | "Create project plan in Outline" |
