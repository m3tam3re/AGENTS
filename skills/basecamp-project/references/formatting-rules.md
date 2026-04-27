---
name: Basecamp Formatting Rules
description: Referenz für Markdown→HTML Konvertierung in Basecamp
compatibility: basecamp
---

# Basecamp Formatierungsregeln

Diese Datei definiert die Basis-Regeln für Markdown→HTML Konvertierung in Basecamp.
Alle Templates und Draft-Generierung müssen sich an diese Regeln halten.

## Erlaubte HTML-Tags

Basecamp unterstützt folgende HTML-Tags über die API:

- `h1` – Überschriften
- `div` – Container
- `br` – Zeilenumbrüche
- `strong` – Fettdruck
- `em` – Kursiv
- `strike` – Durchgestrichen
- `a` – Links
- `pre` – Code-Blöcke
- `ol` – Geordnete Listen
- `ul` – Ungeordnete Listen
- `li` – Listeneinträge
- `blockquote` – Zitate
- `bc-attachment` – @mentions (spezielles Tag)

## Unterstützte Markdown→HTML Konvertierungen

### Überschriften

```markdown
# Heading
```

Wird konvertiert zu:

```html
<h1>Heading</h1>
```

### Fettdruck

```markdown
**bold text**
```

Wird konvertiert zu:

```html
<strong>bold text</strong>
```

### Kursiv

```markdown
*italic text*
```

Wird konvertiert zu:

```html
<em>italic text</em>
```

### Ungeordnete Listen

```markdown
- Item 1
- Item 2
- Item 3
```

Wird konvertiert zu:

```html
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
  <li>Item 3</li>
</ul>
```

### Geordnete Listen

```markdown
1. First item
2. Second item
3. Third item
```

Wird konvertiert zu:

```html
<ol>
  <li>First item</li>
  <li>Second item</li>
  <li>Third item</li>
</ol>
```

### Code-Blöcke

```markdown
`inline code`
```

Wird konvertiert zu:

```html
<pre>inline code</pre>
```

### Links

```markdown
[Link Text](https://example.com)
```

Wird konvertiert zu:

```html
<a href="https://example.com">Link Text</a>
```

## Nicht unterstützte Features

Die folgenden Markdown-Features werden **NICHT** von Basecamp unterstützt:

### Markdown-Tabellen

```markdown
| Column 1 | Column 2 |
|----------|----------|
| Value 1  | Value 2  |
```

**Status:** NICHT UNTERSTÜTZT

Tabellen werden nicht gerendert und erscheinen als Rohtext.
→ **Workaround:** Als strukturierte Listen formatieren (siehe unten).

### Checkboxen in Messages/Documents

```markdown
- [ ] Unchecked item
- [x] Checked item
```

**Status:** NICHT UNTERSTÜTZT in Messages/Documents/Comments

Checkbox-Syntax wird nicht als interaktive Checkboxen gerendert.
→ **Workaround:** Als Text mit Prefix oder echte To-Dos erstellen.

### Horizontal Rules

```markdown
---
```

**Status:** Inkonsistent

Horizontal Rules werden nicht zuverlässig gerendert.

## Workarounds für nicht-unterstützte Features

### Tabellen als verschachtelte Listen

Statt:

```markdown
| Feld     | Wert          |
|----------|---------------|
| Status   | In Progress   |
| Priority | High          |
```

Verwende:

```markdown
**Projekt-Details:**

Status:
  - Label: In Progress
  - Priority: High
  - Due: 2024-03-15

Team:
  - Lead: @Max
  - Reviewer: @Anna
```

### Checkboxen als Text-Prefix

Für Action Items, die nicht als echte To-Dos erstellt werden müssen:

```markdown
Action Items:
  ☐ Review design mockups
  ☐ Schedule kickoff meeting
  ☐ Set up development environment
```

### Checkboxen als echte To-Dos

Für interaktive Checkboxen in Basecamp:

```bash
# Mit Basecamp CLI
basecamp todo "Review design mockups" --in "Project Name" --list "Action Items"

# Oder über die Basecamp API mit Recording-Typ "todoset"
```

## Trix-Editor Hinweis

Basecamp verwendet intern den **Trix-Editor** für:

- Messages
- Documents
- Comments
- Schedule Entries

Der Content wird als HTML an die API gesendet. Die Konvertierung von Markdown
zu HTML erfolgt **serverseitig** durch Basecamp.

**Wichtig:** Beim Senden von Content an Basecamp kann entweder:
1. **Markdown** gesendet werden (wird von Basecamp konvertiert)
2. **HTML** direkt gesendet werden (z.B. `<h1>`, `<strong>`, etc.)

## Zusammenfassung

| Feature | Status | Workaround |
|---------|--------|------------|
| `# Heading` | ✅ Funktioniert | - |
| `**bold**` | ✅ Funktioniert | - |
| `*italic*` | ✅ Funktioniert | - |
| `- list` | ✅ Funktioniert | - |
| `1. list` | ✅ Funktioniert | - |
| `` `code` `` | ✅ Funktioniert | - |
| `[link](url)` | ✅ Funktioniert | - |
| `\| table \|` | ❌ Nicht unterstützt | Verschachtelte Listen |
| `- [ ] checkbox` | ❌ Nicht unterstützt | Text-Prefix oder echte To-Dos |
| `---` | ⚠️ Inkonsistent | Vermeiden |
