---
name: basecamp-project
description: |
  Use when: (1) User wants to create a new Basecamp project,
  (2) User wants to generate a project draft from plan or Discovery,
  (3) User wants to duplicate a Basecamp template.
  Triggers: "create basecamp project", "setup project in basecamp",
  "basecamp draft", "plan to basecamp", "launch project",
  "initialize project in basecamp", "new project"
compatibility: opencode
---

# basecamp-project Skill

## Overview

Erstellt Basecamp-Projekte via strukturiertem Workflow: Discovery → Template → Draft → Review → Create.
Zwei Modi: Discovery-Mode (interaktive Fragen) oder Plan-Mode (aus Markdown-Datei).

## Workflow

### 1. START: Modus wählen

```
User: "Erstelle ein neues Projekt in Basecamp"

→ Zeige Modus-Auswahl:
  [1] 🧭 Discovery Mode (interaktive Fragen)
  [2] 📄 Plan Mode (aus Markdown-Datei)
  [3] 📋 Basecamp Template duplizieren
```

### 2. DISCOVERY MODE

Führe durch die 8 Discovery-Phasen (siehe `references/discovery-questions.md`):

1. **Vision & Goals** - Projektziel definieren
2. **Success Criteria** - Woran erkennen wir Erfolg?
3. **Timeline & Milestones** - Zeitplan mit Meilensteinen
4. **Team & Roles** - Wer ist dabei?
5. **Communication Preferences** - Wie kommunizieren?
6. **Tools & Workflows** - Welche Basecamp-Tools?
7. **Risks & Dependencies** - Risiken und Abhängigkeiten
8. **Review** - Zusammenfassung bestätigen

**Regeln:**
- Jede Phase ist überspringbar
- Multiple Choice mit "Anderes" Freitext-Option
- Vorherige Antworten als Vorschlag ("Vorlage von: ...")
- Natürliche Datumsangaben akzeptieren

### 3. TEMPLATE WAHL

Zeige verfügbare Templates:
```
Verfügbare Vorlagen:
  [1] Feature Launch - Neues Feature entwickeln
  [2] Workshop/Training - Schulung oder Workshop
  [3] Retrospektive - Team-Retro
  [4] Meeting Management - Wiederkehrende Meetings
  [5] Sprint/Iteration - Sprint planen
  [6] Research/MVP - Forschung oder Prototyp
  [7] Eigenes Design - Eigene Struktur
  [8] Basecamp Template - Vorhandenes Template nutzen
```

### 4. DRAFT GENERATION

#### Plan Mode (aus Datei)
1. Liste Dateien in `docs/plans/`
2. User wählt Datei
3. Parse Plan (siehe unten)
4. Fehlende Daten via Discovery-Phasen ergänzen

#### Discovery Mode (aus Fragen)
1. Generiere Draft basierend auf Discovery-Antworten
2. Verwende gewähltes Template als Grundstruktur
3. Fülle mit User-Daten

### 5. PARSE PLAN (für Plan Mode)

Extrahiere aus Markdown:

**Project name:**
- Quelle: `# Title` oder frontmatter `title:`
- Required: Yes

**Description:**
- Quelle: frontmatter `description:` oder erster Absatz
- Required: Yes

**Start date:**
- Quelle: frontmatter `start:`, `starts:`, oder natürliche Erwähnung
- Required: Yes

**End date:**
- Quelle: frontmatter `end:`, `due:`, `deadline:`, oder natürliche Erwähnung
- Required: Yes

**Milestones:**
- Quelle: Sections mit `##` Level
- Required: Yes

**Tasks:**
- Quelle: Listen unter Milestones
- Required: Yes

**Assignees:**
- Quelle: `@person` Modifier oder frontmatter `team:`
- Required: No

**Documents:**
- Quelle: Links `[ref](url)` oder frontmatter `attachments:`
- Required: No

### 6. PROMPT FÜR FEHLENDE DATEN

Reihenfolge:
1. Projektname (wenn fehlt)
2. Start-Datum (natürliche Sprache akzeptiert)
3. End-Datum
4. Team-Mitglieder (`basecamp people list --json`)
5. Assignees
6. Meilenstein-Daten

### 7. DRAFT PRESENTATION

Zeige strukturierten Draft (Basecamp-kompatibles Format, KEINE Tabellen):

```markdown
# Projekt-Vorschlag: {name}

## Übersicht
{description}

## Zeitplan
- **Start:** {start}
- **Ende:** {end}
- **Dauer:** {X Wochen/ Tage}

## Meilensteine

### {Meilenstein 1}
- Datum: {datum}
- Aufgaben:
  1. {aufgabe 1}
  2. {aufgabe 2}
  - Zugewiesen: @{person}

## Team
{liste}

## Basecamp-Struktur
- Message Board: Kickoff + Entscheidungen
- To-Dos: Nach Meilensteinen gruppiert
- Schedule: Kalender-Einträge
- Chat: {falls aktiviert}
- Check-ins: {falls aktiviert}
- Gauge: {falls aktiviert}
```

**Optionen:**
```
[1] Draft speichern → `docs/drafts/{slug}-{timestamp}.md`
[2] Projekt erstellen
[3] Abbrechen
```

### 8. PROJECT CREATION

Führe in Reihenfolge aus:

#### 8.1 Project erstellen
```bash
basecamp projects create "{name}" --json
```

#### 8.2 Team hinzufügen
```bash
basecamp people list --jq '.data[] | select(.name == "Name") | .id'
basecamp people add {person_id} --project {project_id}
```

#### 8.3 Kickoff-Message
```bash
basecamp message "Kickoff" "{description}" --in {project_id}
# HTML content verwenden (markdown_to_trix.py)
```

#### 8.4 Discovery Document (optional)
```bash
basecamp files doc create "Project Brief" "{zusammenfassung}" --in {project_id}
```

#### 8.5 To-Do Listen (nach Meilensteinen)
```bash
basecamp todolists create "{Meilenstein}" --in {project_id}
# Dann To-Dos hinzufügen:
basecamp todo "{task}" --in {project_id} --list {list_id} --due {date}
```

#### 8.6 Schedule Entries
```bash
basecamp schedule create "{Meilenstein}" \
  --starts-at "{date}T09:00:00Z" \
  --all-day --in {project_id}
```

#### 8.7 Chat-Kanal (optional)
```bash
basecamp chat post "Willkommen im Projekt!" --in {project_id}
```

#### 8.8 Check-ins (optional)
```bash
# Questionnaire erstellen
basecamp checkins question create "Was hast du diese Woche erreicht?" --frequency every_week
```

#### 8.9 Cards/Kanban (optional)
```bash
basecamp cards list --in {project_id}
# Spalten erstellen wenn nicht vorhanden
```

#### 8.10 Gauge (optional)
```bash
basecamp gauges enable --in {project_id}
basecamp gauges create --position 0 --color green --description "Fortschritt" --in {project_id}
```

### 9. SUCCESS REPORT

```
✅ Projekt erstellt: {name}
🔗 https://3.basecamp.com/{account_id}/buckets/{project_id}

Struktur:
  • Message Board: 1 Nachricht (Kickoff)
  • Project Brief: 1 Dokument
  • To-Dos: {N} Listen, {M} Aufgaben
  • Schedule: {X} Einträge
  • Chat: {falls aktiviert}
  • Check-ins: {falls aktiviert}
  • Gauge: {falls aktiviert}
```

## Integration mit anderen Skills

| Input | Next Skill | Trigger |
|-------|------------|---------|
| Discovery abgeschlossen | basecamp-project | Projekt erstellen |
| Plan nicht gefunden | brainstorming | "Ich brauche erst einen Plan" |
| Meeting-Notizen | basecamp | "Notizen zu Basecamp hinzufügen" |
| Task verfolgen | basecamp | "Todo zu Projekt hinzufügen" |

## Error Handling

| Scenario | Action |
|----------|--------|
| Plan nicht gefunden | Fehler zeigen, Pläne neu listen |
| Basecamp Auth-Fehler | `basecamp auth login` vorschlagen |
| Projekt-Erstellung fehlgeschlagen | Fehler + Basecamp-Limits prüfen |
| Person nicht gefunden | Freitext-Eingabe als Fallback |
| Rate limit (429) | Warten + Retry mit Backoff |
| Ungültige Datums-Eingabe | Mit Format-Hinweis erneut fragen |

## Markdown→Basecamp Konvertierung

Siehe `references/formatting-rules.md`

Kurzfassung:
- ✅ Überschriften, bold, italic, Listen, Code, Links
- ❌ Tabellen → Als strukturierte Listen
- ❌ Checkboxen in Messages → Als nummerierte Listen oder echte To-Dos
- ❌ Horizontal Rules → Entfernen

Verwende `scripts/markdown_to_trix.py` für Konvertierung.

## Discovery Questions Reference

Siehe `references/discovery-questions.md`

## Templates

Siehe `templates/` Verzeichnis.

## Dateien

```
basecamp-project/
├── SKILL.md                          # Diese Datei
├── scripts/
│   ├── markdown_to_trix.py           # Markdown→HTML Konverter
│   └── requirements.txt              # Python dependencies
├── templates/
│   ├── feature-launch.md
│   ├── workshop.md
│   ├── retrospective.md
│   ├── meeting.md
│   ├── sprint.md
│   ├── research-mvp.md
│   └── blank.md
└── references/
    ├── formatting-rules.md           # Basecamp-Formatierung
    └── discovery-questions.md        # Fragen-Katalog
```
