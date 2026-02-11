---
name: doc-translator
description: "Translates external documentation websites to specified language(s) and publishes to Outline wiki. Use when: (1) Translating SaaS/product documentation into German or Czech, (2) Publishing translated docs to Outline wiki, (3) Re-hosting external images to Outline. Triggers: 'translate docs', 'translate documentation', 'translate to German', 'translate to Czech', 'publish to wiki', 'doc translation', 'TEEM translation'."
compatibility: opencode
---

# Doc Translator

Translate external documentation websites to German (DE) and/or Czech (CZ), then publish to the company Outline wiki at `https://wiki.az-gruppe.com`. All images are re-hosted on Outline. UI terms use TEEM format.

## Core Workflow

### 1. Validate Input & Clarify

Before starting, confirm:

1. **URL accessibility** - Check with `curl -sI <URL>` for HTTP 200
2. **Target language(s)** - Always ask explicitly using the `question` tool:

```
question: "Which language(s) should I translate to?"
options: ["German (DE)", "Czech (CZ)", "Both (DE + CZ)"]
```

3. **Scope** - If URL is an index page with multiple sub-pages, ask:

```
question: "This page links to multiple sub-pages. What should I translate?"
options: ["This page only", "This page + all linked sub-pages", "Let me pick specific pages"]
```

4. **Target collection** - Use `Outline_list_collections` to show available collections, then ask which one to publish to

**CRITICAL:** NEVER auto-select collection. Always present collection list to user and wait for explicit selection before proceeding with document creation.

If URL fetch fails, use `question` to ask for an alternative URL or manual content paste.

### 2. Fetch & Parse Content

Use the `webfetch` tool to retrieve page content:

```
webfetch(url="<URL>", format="markdown")
```

From the result:
- Extract main content body (ignore navigation, footers, sidebars, cookie banners)
- Preserve document structure (headings, lists, tables, code blocks)
- Collect all image URLs into a list for Step 3
- Note any embedded videos or interactive elements (these cannot be translated)

For multi-page docs, repeat for each page.

### 3. Download Images

Download all images to a temporary directory:

```bash
mkdir -p /tmp/doc-images

# For each image URL:
curl -sL "IMAGE_URL" -o "/tmp/doc-images/$(basename IMAGE_URL)"
```

Track a mapping of: `original_url -> local_filename -> outline_attachment_url`

If an image download fails, log it and continue. Use a placeholder in the final document:

```markdown
> **[Image unavailable]** Original: IMAGE_URL
```

### 4. Upload Images to Outline

MCP-outline does not support attachment creation. Use the bundled script for image uploads:

```bash
# Upload with optional document association
bash scripts/upload_image_to_outline.sh "/tmp/doc-images/screenshot.png" "$DOCUMENT_ID"

# Upload without document (attach later)
bash scripts/upload_image_to_outline.sh "/tmp/doc-images/screenshot.png"
```

The script handles API key loading from `/run/agenix/outline-key`, content-type detection, the two-step presigned POST flow, and retries. Output is JSON: `{"success": true, "attachment_url": "https://..."}`.

Replace image references in the translated markdown with the returned `attachment_url`:
```markdown
![description](ATTACHMENT_URL)
```

For all other Outline operations (documents, collections, search), use MCP tools (`Outline_*`).

### 5. Translate with TEEM Format

Translate the entire document into each target language. Apply TEEM format to UI elements.

#### Address Form (CRITICAL)

**Always use the informal "you" form** in ALL target languages:
- **German**: Use **"Du"** (informal), NEVER "Sie" (formal)
- **Czech**: Use **"ty"** (informal), NEVER "vy" (formal)
- This applies to all translations — documentation should feel approachable and direct

#### Infobox / Callout Formatting

Source documentation often uses admonitions, callouts, or info boxes (e.g., GitHub-style `> [!NOTE]`, Docusaurus `:::note`, or custom HTML boxes). **Convert ALL such elements** to Outline's callout syntax:

```markdown
:::tip
Tip or best practice content here.

:::

:::info
Informational content here.

:::

:::warning
Warning or caution content here.

:::

:::success
Success message or positive outcome here.

:::
```

**Mapping rules** (source → Outline):
| Source pattern | Outline syntax |
|---|---|
| Note, Info, Information | `:::info` |
| Tip, Hint, Best Practice | `:::tip` |
| Warning, Caution, Danger, Important | `:::warning` |
| Success, Done, Check | `:::success` |

**CRITICAL formatting**: The closing `:::` MUST be on its own line with an empty line before it. Content goes directly after the opening line.

#### TEEM Rules

**Format:** `**English UI Term** (Translation)`

**Apply TEEM to:**
- Button labels
- Menu items and navigation tabs
- Form field labels
- Dialog/modal titles
- Toolbar icons with text
- Status messages from the app
- **Headings containing UI terms** (example: "## [Adding a new To-do]" becomes "## [Ein neues **To-do** (Aufgabe) hinzufügen]")

**Translate normally (no TEEM):**
- Your own explanatory text
- Document headings you create (that don't contain UI terms)
- General descriptions and conceptual explanations
- Code blocks and technical identifiers

#### German Examples

```markdown
Click **Settings** (Einstellungen) to open preferences.
Navigate to **Dashboard** (Übersicht) > **Reports** (Berichte).
Press the **Submit** (Absenden) button.
In the **File** (Datei) menu, select **Export** (Exportieren).

# Heading with UI term: Create a new **To-do** (Aufgabe)
## [Adding a new **To-do** (Aufgabe)]
```

#### Czech Examples

```markdown
Click **Settings** (Nastavení) to open preferences.
Navigate to **Dashboard** (Přehled) > **Reports** (Sestavy).
Press the **Submit** (Odeslat) button.
In the **File** (Soubor) menu, select **Export** (Exportovat).

# Heading with UI term: Create a new **To-do** (Úkol)
## [Adding a new **To-do** (Úkol)]
```

#### Ambiguous UI Terms

If a UI term has multiple valid translations depending on context, use the `question` tool:

```
question: "The term 'Board' appears in the UI. Which translation fits this context?"
options: ["Pinnwand (pinboard/bulletin)", "Tafel (whiteboard)", "Gremium (committee)"]
```

### 6. Publish to Outline

Use mcp-outline tools to publish:

1. **Find or create collection:**
   - `Outline_list_collections` to find target collection
   - `Outline_create_collection` if needed

2. **Create document:**
   - `Outline_create_document` with translated markdown content
   - Set `publish: true` for immediate visibility
   - Use `parent_document_id` if nesting under an existing doc

3. **For multi-language:** Create one document per language, clearly titled:
   - `[Product Name] - Dokumentation (DE)`
   - `[Product Name] - Dokumentace (CZ)`

## Error Handling

| Issue | Action |
|-------|--------|
| URL fetch fails | Use `question` to ask for alternative URL or manual paste |
| Image download fails | Continue with placeholder, note in completion report |
| Outline API error (attachments) | Script retries 3x with backoff; on final failure save markdown to `/tmp/doc-translator-backup-TIMESTAMP.md`, report error |
| Outline API error (document) | Save markdown to `/tmp/doc-translator-backup-TIMESTAMP.md`, report error |
| Ambiguous UI term | Use `question` to ask user for correct translation |
| Large document (>5000 words) | Ask user if splitting into multiple docs is preferred |
| Multi-page docs | Ask user about scope before proceeding |
| Rate limiting | Wait and retry with exponential backoff |

If Outline publish fails, always save the translated markdown locally as backup before reporting the error.

## Completion Report

After each translation, output:

```
Translation Complete

Documents Created:
- DE: [Document Title] - ID: [xxx] - URL: https://wiki.az-gruppe.com/doc/[slug]
- CZ: [Document Title] - ID: [xxx] - URL: https://wiki.az-gruppe.com/doc/[slug]

Images Processed: X of Y successfully uploaded

Items Needing Review:
- [Any sections with complex screenshots]
- [Any failed image uploads with original URLs]
- [Any unclear UI terms that were best-guessed]
```

## Language Codes

| Code | Language | Native Name |
|------|----------|-------------|
| DE | German | Deutsch |
| CZ | Czech | Čeština |

## Environment Variables

| Variable | Purpose | Source |
|----------|---------|--------|
| `OUTLINE_API_KEY` | Bearer token for wiki.az-gruppe.com API | Auto-loaded from `/run/agenix/outline-key` by upload script |

## Integration with Other Skills

| Need | Skill | When |
|------|-------|------|
| Wiki document management | outline | Managing existing translated docs |
| Browser-based content extraction | playwright / dev-browser | When webfetch cannot access content (login-required pages) |
