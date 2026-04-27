---
title: Discovery Questions Framework
description: Guided project definition workflow for Basecamp projects - 8 phases covering vision, success criteria, timeline, team, communication, tools, risks, and review
type: reference
version: 1.0
last_updated: 2025-04-27
---

# Discovery Questions Framework

Leitet User durch 8 Phasen der Projekt-Definition, ähnlich dem brainstorming Skill. Jede Phase kann übersprungen werden; Multiple-Choice-Fragen haben "Anderes"-Fallback.

---

## Phase 1: Vision & Goals

```yaml
phase:
  id: 1
  name: "Vision & Goals"
  description: "Kläre das Ziel und den Zweck des Projekts"
  skippable: true
  questions:
    - id: "project_goal"
      text: "Was ist das Ziel dieses Projekts?"
      type: "freetext"
      required: true
      prompt: "Beschreibe in einem Satz, was wir erreichen wollen"
      
    - id: "problem_solved"
      text: "Welches Problem löst dieses Projekt?"
      type: "freetext"
      required: false
      placeholder: "Welchen Schmerzpunkt oder welches Bedürfnis adressieren wir?"
```

### Beispiel-Prompts

**Frage:** Was ist das Ziel dieses Projekts?
**Prompt:** Beschreibe in einem Satz, was wir erreichen wollen.

**Antwort-Beispiel:** "Wir wollen die interne Dokumentation von Prozessen verbessern, damit new Joiner schneller produktiv werden."

---

## Phase 2: Success Criteria

```yaml
phase:
  id: 2
  name: "Success Criteria"
  description: "Definiere messbare Kriterien für Projekterfolg"
  skippable: true
  questions:
    - id: "success_indicators"
      text: "Woran erkennen wir, dass das Projekt erfolgreich war?"
      type: "multiple_choice_checkbox"
      required: false
      options:
        - label: "Funktional fertig"
          description: "Alle geplanten Features wurden implementiert"
          value: "functional_complete"
        - label: "Zeitnah geliefert"
          description: "Deadline wurde eingehalten"
          value: "on_time"
        - label: "Qualitätsziele erreicht"
          description: "Tests, Reviews und QA bestanden"
          value: "quality_met"
        - label: "Stakeholder zufrieden"
          description: "Feedback von Auftraggebern eingeholt und positiv"
          value: "stakeholder_happy"
        - label: "Budget eingehalten"
          description: "Kosten blieben im geplanten Rahmen"
          value: "on_budget"
        - label: "Andere"
          description: "Eigene Erfolgskriterien definieren"
          value: "other"
          freetext: true
          freetext_label: "Andere Erfolgskriterien:"
          freetext_placeholder: "z.B. 95% Adoption Rate nach Launch"
          
    - id: "kpis"
      text: "Welche messbaren KPIs definieren Erfolg?"
      type: "freetext"
      required: false
      multiline: true
      placeholder: "z.B. Response Time < 200ms, Coverage > 80%, NPS > 50"
```

### UI-Darstellung

```
Woran erkennen wir, dass das Projekt erfolgreich war?
☐ Funktional fertig (alle Features implementiert)
☐ Zeitnah geliefert (Deadline eingehalten)
☐ Qualitätsziele erreicht (Tests, Reviews bestanden)
☐ Stakeholder zufrieden (Feedback eingeholt)
☐ Budget eingehalten
☑ Andere: ___95% Adoption Rate nach Launch___
```

---

## Phase 3: Timeline & Milestones

```yaml
phase:
  id: 3
  name: "Timeline & Milestones"
  description: "Definiere Start, Ende und wichtige Zwischenmeilensteine"
  skippable: true
  questions:
    - id: "start_date"
      text: "Wann soll das Projekt starten?"
      type: "date"
      required: true
      parse_natural: true
      examples:
        - "nächsten Montag"
        - "2025-06-01"
        - "Mitte Juni"
        - "sofort"
        
    - id: "end_date"
      text: "Wann soll das Projekt abgeschlossen sein?"
      type: "date"
      required: true
      parse_natural: true
      examples:
        - "Ende Q2"
        - "2025-08-15"
        - "in 3 Monaten"
        
    - id: "milestones"
      text: "Welche wichtigen Zwischenmeilensteine gibt es?"
      type: "dynamic_list"
      required: false
      item_template:
        - id: "name"
          type: "freetext"
          placeholder: "Meilenstein Name"
        - id: "date"
          type: "date"
          required: false
          parse_natural: true
          placeholder: "Datum (optional)"
      add_button: "+ Meilenstein hinzufügen"
      min_items: 0
      max_items: 10
```

### Beispiel-Liste

```
Welche wichtigen Zwischenmeilensteine gibt es?

┌─────────────────────────────────────────────────────┐
│ 1. Discovery Phase                                  │
│    Datum: 2025-05-15                                │
├─────────────────────────────────────────────────────┤
│ 2. Design Approval                                  │
│    Datum: Ende Mai                                  │
├─────────────────────────────────────────────────────┤
│ 3. Beta Release                                    │
│    Datum: —                                        │
├─────────────────────────────────────────────────────┤
│ [+ Meilenstein hinzufügen]                          │
└─────────────────────────────────────────────────────┘
```

---

## Phase 4: Team & Roles

```yaml
phase:
  id: 4
  name: "Team & Roles"
  description: "Definiere Team-Mitglieder und Rollen"
  skippable: true
  questions:
    - id: "team_members"
      text: "Wer ist am Projekt beteiligt?"
      type: "basecamp_people_lookup"
      required: false
      source: "basecamp people list --json"
      fallback: "freetext"
      fallback_label: "Person hinzufügen (nicht in Basecamp):"
      
    - id: "roles_needed"
      text: "Welche Rollen brauchen wir?"
      type: "multiple_choice_checkbox"
      required: false
      options:
        - label: "Projektleitung"
          value: "project_lead"
        - label: "Entwicklung"
          value: "development"
        - label: "Design"
          value: "design"
        - label: "QA/Testing"
          value: "qa"
        - label: "Stakeholder/Product Owner"
          value: "stakeholder"
        - label: "Externe Dienstleister"
          value: "external"
        - label: "Andere"
          value: "other"
          freetext: true
          freetext_label: "Andere Rolle:"
          
    - id: "progress_reporting"
      text: "Soll regelmäßig über Fortschritt berichtet werden?"
      type: "yes_no"
      required: false
      default: true
      trigger: "creates_checkins"
```

### Basecamp People Lookup Flow

```
Wer ist am Projekt beteiligt?

[🔍 Basecamp Team durchsuchen...]

Verfügbare Personen:
┌────────────────────────────────────────────────────┐
│ 👤 Alice Müller         Projektleitung              │
│ 👤 Bob Schmidt         Entwicklung                 │
│ 👤 Carol Weber         Design                      │
│ 👤 Dave Fischer        QA                          │
└────────────────────────────────────────────────────┘

[✓] Alice Müller
[✓] Bob Schmidt
[ ] Carol Weber
[ ] Dave Fischer

[+ Person hinzufügen (nicht in Basecamp)]

oder manuell eingeben:
Anderer Name: ___________
```

---

## Phase 5: Communication Preferences

```yaml
phase:
  id: 5
  name: "Communication Preferences"
  description: "Definiere Kommunikationskanäle und -rhythmus"
  skippable: true
  questions:
    - id: "communication_channels"
      text: "Wie soll hauptsächlich kommuniziert werden?"
      type: "multiple_choice_checkbox"
      required: false
      options:
        - label: "Täglicher Standup"
          description: "Kurze tägliche Updates im Chat-Kanal"
          value: "daily_standup"
        - label: "Wöchentliches Sync-Meeting"
          description: "Regelmäßiges Meeting für Fortschritt und Blocker"
          value: "weekly_sync"
        - label: "Ad-hoc bei Bedarf"
          description: "Kommunikation nur wenn nötig"
          value: "ad_hoc"
        - label: "Async-First"
          description: "Primär Messages und Documents, seltene Meetings"
          value: "async_first"
        - label: "Video-Calls für Meetings"
          description: "Meetings per Video-Call statt vor Ort"
          value: "video_calls"
          
    - id: "escalation_mentions"
      text: "Sollen @mentions für Eskalation genutzt werden?"
      type: "yes_no"
      required: false
      default: true
      hint: "Bei @mention wird derjenige sofort benachrichtigt"
```

### UI-Darstellung

```
Wie soll hauptsächlich kommuniziert werden?
☐ Täglicher Standup (Chat-Kanal)
☑ Wöchentliches Sync-Meeting
☑ Async-First (primär Messages/Documents)
☐ Video-Calls für Meetings

Sollen @mentions für Eskalation genutzt werden?
[JA] Nein
```

---

## Phase 6: Tools & Workflows

```yaml
phase:
  id: 6
  name: "Tools & Workflows"
  description: "Wähle Basecamp-Tools und Workflow-Konfiguration"
  skippable: true
  questions:
    - id: "basecamp_tools"
      text: "Welche Basecamp-Tools sollen aktiv genutzt werden?"
      type: "multiple_choice_checkbox"
      required: false
      default_checked:
        - "message_board"
        - "todos"
        - "chat"
        - "checkins"
        - "documents"
      options:
        - label: "Message Board"
          description: "Kickoff-Nachrichten, Entscheidungen, Updates"
          value: "message_board"
        - label: "To-Dos"
          description: "Aufgaben und Meilensteine"
          value: "todos"
        - label: "Schedule"
          description: "Kalender-Events für Meilensteine"
          value: "schedule"
        - label: "Chat"
          description: "Kommunikation und Standups"
          value: "chat"
        - label: "Cards/Kanban"
          description: "Visuelles Task-Board (Alternative zu To-Dos)"
          value: "cards"
        - label: "Check-ins"
          description: "Automatische Abfragen zu Fortschritt"
          value: "checkins"
        - label: "Documents"
          description: "Specs, Referenzen, Entscheidungen"
          value: "documents"
        - label: "Gauges"
          description: "Fortschritts-Indikatoren"
          value: "gauges"
        - label: "Files"
          description: "Dateien und Anhänge"
          value: "files"
          
    - id: "progress_gauge"
      text: "Soll ein Gauge mit Fortschritts-Indikator erstellt werden?"
      type: "yes_no"
      required: false
      conditional_on: "basecamp_tools includes 'gauges'"
      default: false
```

### UI-Darstellung mit Vorauswahl

```
Welche Basecamp-Tools sollen aktiv genutzt werden?

☑ Message Board (Kickoff, Entscheidungen)
☑ To-Dos (Aufgaben, Meilensteine)
☐ Schedule (Kalender-Events)
☑ Chat (Kommunikation, Standups)
☐ Cards/Kanban (Alternative zu To-Dos)
☑ Check-ins (Automatische Abfragen)
☑ Documents (Specs, Referenzen)
☐ Gauges (Fortschritts-Tracking)
☐ Files (Dateien, Anhänge)

Soll ein Gauge mit Fortschritts-Indikator erstellt werden?
[Ja] Nein
```

---

## Phase 7: Risks & Dependencies

```yaml
phase:
  id: 7
  name: "Risks & Dependencies"
  description: "Identifiziere Risiken und Abhängigkeiten"
  skippable: true
  questions:
    - id: "known_risks"
      text: "Gibt es bekannte Risiken?"
      type: "freetext"
      required: false
      multiline: true
      placeholder: "z.B. Abhängigkeit von externem API, limitierte Testumgebung, kritische Abhängigkeit von Key Person"
      
    - id: "dependencies"
      text: "Welche Abhängigkeiten gibt es?"
      type: "freetext"
      required: false
      multiline: true
      placeholder: "z.B. Wartet auf Approval von Legal, Abhängig von Datenbank-Migration, Braucht Zugang zu Prod-System"
      
    - id: "external_stakeholders"
      text: "Wer sind externe Stakeholder?"
      type: "freetext"
      required: false
      multiline: true
      placeholder: "z.B. Externe Agentur für Design, Kunde für Feedback, Vendor für Integration"
```

---

## Phase 8: Review

```yaml
phase:
  id: 8
  name: "Review"
  description: "Zusammenfassung aller Antworten zur Bestätigung"
  skippable: false
  questions:
    - id: "summary"
      type: "review_summary"
      sections:
        - "vision_goals"
        - "success_criteria"
        - "timeline"
        - "team"
        - "communication"
        - "tools"
        - "risks"
      actions:
        - label: "Alles korrekt"
          value: "confirm"
          next: "create_project"
        - label: "Bearbeiten"
          value: "edit"
          next: "phase_picker"
```

### Review-Darstellung

```
═══════════════════════════════════════════════════════
                    PROJEKT-ZUSAMMENFASSUNG
═══════════════════════════════════════════════════════

📌 VISION & GOALS
   Ziel: Interne Dokumentation verbessern
   Problem: New Joiner brauchen zu lange zur Einarbeitung

🎯 SUCCESS CRITERIA
   ☑ Funktional fertig
   ☑ Zeitnah geliefert
   ☐ Qualitätsziele erreicht
   ☑ Stakeholder zufrieden
   KPI: 95% Adoption Rate nach Launch

📅 TIMELINE
   Start: 2025-06-01
   Ende: 2025-08-15 (11 Wochen)
   Meilensteine:
     • Discovery Phase — 2025-05-15
     • Design Approval — Ende Mai
     • Beta Release — (ohne Datum)

👥 TEAM
   Alice Müller (Projektleitung)
   Bob Schmidt (Entwicklung)
   Carol Weber (Design)
   
   Rollen: Projektleitung, Entwicklung, Design
   ✓ Regelmäßige Fortschrittsberichte

💬 KOMMUNIKATION
   Async-First, wöchentliche Sync-Meetings
   ✓ @mentions für Eskalation aktiviert

🛠 TOOLS (aktiviert)
   Message Board, To-Dos, Chat, Check-ins, Documents

⚠️ RISIKEN & ABHÄNGIGKEITEN
   Risiken: —
   Abhängigkeiten: Wartet auf Approval von Legal
   Externe Stakeholder: Kunde für Feedback

═══════════════════════════════════════════════════════

[ ✅ Alles korrekt — Projekt erstellen ]
[ ✏️ Zurück zu Phase: [Vision ▼] ]
```

---

## Nutzung im Skill Workflow

### Discovery Flow Integration

Der Discovery-Fragen-Katalog wird verwendet wenn:

1. **Kein Plan vorhanden** — User möchte Projekt von Grund auf definieren
2. **Vor dem Drafting** — Als strukturierter Einstieg vor dem eigentlichen Planning
3. **Ergänzung zu bestehendem Plan** — Falls wichtige Felder fehlen

### Flow-Integration

```
User: "Ich will ein neues Projekt in Basecamp erstellen"
  ↓
Skill: "Lass uns das Projekt gemeinsam definieren."
       "Wir gehen durch 8 kurze Phasen."
  ↓
[Phase 1-8 durchlaufen]
  ↓
Zusammenfassung anzeigen
  ↓
User bestätigt → Erstelle Projekt
User möchte ändern → Springe zur Phase
```

### Abspeichern der Answers

```python
# Struktur für gesammelte Answers
discovery_answers = {
    "project_goal": "...",
    "problem_solved": "...",
    "success_indicators": [...],
    "kpis": "...",
    "start_date": "2025-06-01",
    "end_date": "2025-08-15",
    "milestones": [
        {"name": "Discovery", "date": "2025-05-15"},
        {"name": "Design Approval", "date": "..."},
    ],
    "team_members": [
        {"id": "123", "name": "Alice Müller", "role": "project_lead"}
    ],
    "roles_needed": ["project_lead", "development", "design"],
    "progress_reporting": True,
    "communication_channels": ["async_first", "weekly_sync"],
    "escalation_mentions": True,
    "basecamp_tools": ["message_board", "todos", "chat", "checkins", "documents"],
    "progress_gauge": False,
    "known_risks": "...",
    "dependencies": "...",
    "external_stakeholders": "...",
}
```

### Mapping zu Basecamp Structure

| Discovery Field | Basecamp Creation |
|-----------------|-------------------|
| project_goal, problem_solved | Kickoff Message |
| start_date, end_date | Schedule (oder Project Description) |
| milestones | To-Do Lists + Schedule Entries |
| team_members | Project People |
| communication_channels | Chat Channel Topic + PM Setup |
| basecamp_tools | Aktiviert/Deaktiviert im Project |
| progress_gauge | Gauge Creation |
| known_risks, dependencies | Message Board Post |

---

## Natural Language Date Parsing

Der Skill unterstützt flexible Datumsangaben:

| Input | Parsed Output |
|-------|---------------|
| "nächsten Montag" | 2025-05-05 (wenn gerade April) |
| "Ende Q2" | 2025-06-30 |
| "Mitte Juni" | 2025-06-15 |
| "in 3 Wochen" | +21 Tage von heute |
| "2025-06-01" | 2025-06-01 |
| "sofort" | today's date |
| "ASAP" | today's date |

---

## Implementation Notes

1. **Jede Phase ist überspringbar** — User kann "Weiter" oder "Überspringen" sagen
2. **Multiple Choice mit Freitext-Fallback** — "Andere" öffnet Freitext-Eingabe
3. **Datum-Parsing** — Akzeptiere natürliche Sprache mit Fallback auf direkte Eingabe
4. **Basecamp People Lookup** — Nutze `basecamp people list --json` für Team-Auswahl
5. **Review-Phase ist Pflicht** — Zeigt Zusammenfassung vor Projekt-Erstellung
6. **Answers werden gesammelt** — Bis zur Bestätigung in Discovery-Objekt gespeichert
