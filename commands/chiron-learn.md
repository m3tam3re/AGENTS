---
name: chiron-learn
description: "Capture learning - record insights, discoveries, and knowledge"
---

# Capture Learning

Capture learnings and insights for the knowledge base.

## Steps

1. **Parse learning request**:
   - Topic (if short)
   - Content (if long description provided)
2. **If topic provided**:
   - Search for existing notes on this topic in `~/CODEX/03-resources/`
   - Present what's already captured
   - Ask if user wants to add to existing or create new
3. **Create learning note**:
   - Location: `~/CODEX/03-resources/[topic]/[topic].md`
   - Or `~/CODEX/00-inbox/learnings/learning-[topic]-YYYYMMDD.md` (if quick capture)
   - Use frontmatter with tags `#learning` and topic
   - Include: what was learned, context, applications
4. **Link to related notes** (find and wiki-link)
5. **Confirm** creation

## Expected Output

Learning note created with:
- Proper frontmatter (tags, created date, topic)
- What was learned
- Context or source
- Applications or how to use this knowledge
- Links to related notes
- Confirmation of creation

## Related Skills

- `quick-capture` - Quick capture workflow
- `chiron-core` - PARA methodology for resource placement
- `obsidian-management` - File operations and linking
