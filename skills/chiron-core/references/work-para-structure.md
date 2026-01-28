---
title: "Work PARA Structure"
type: index
created: 2026-01-28
---

# Work PARA Structure

## Overview
PARA structure for work-related projects, areas, and resources. Designed for tool-agnostic knowledge management.

## Directory Tree

```
~/CODEX/
├── 01-projects/work/              # Active work projects
│   ├── api-integration-platform/
│   │   ├── _index.md
│   │   ├── meetings/
│   │   ├── decisions/
│   │   └── notes/
│   ├── customer-portal-redesign/
│   │   └── (same structure)
│   ├── marketing-campaign-q1/
│   ├── security-audit-2026/
│   ├── infrastructure-migration/
│   ├── mobile-app-v20/
│   ├── team-onboarding-program/
│   ├── data-analytics-dashboard/
│   ├── documentation-revamp/
│   └── api-gateway-upgrade/
│
├── 02-areas/work/               # Ongoing work responsibilities
│   ├── current-job.md
│   ├── professional-dev.md
│   ├── team-management.md
│   ├── company-knowledge.md
│   └── technical-excellence.md
│
├── 03-resources/work/           # Work reference material
│   └── wiki-mirror/             # Outline wiki exports
│       └── _wiki-index.md
│
└── 04-archive/work/           # Completed work
    ├── projects/              # Finished projects
    └── employment/           # Job transitions
```

## Project Mapping

| Basecamp Project | PARA Path | Type | Status | Deadline |
|----------------|-----------|-------|---------|-----------|
| API Integration Platform | `01-projects/work/api-integration-platform` | Engineering | Active | 2026-03-15 |
| Customer Portal Redesign | `01-projects/work/customer-portal-redesign` | Product/Design | Active | 2026-04-30 |
| Marketing Campaign Q1 | `01-projects/work/marketing-campaign-q1` | Marketing | Active | 2026-02-28 |
| Security Audit 2026 | `01-projects/work/security-audit-2026` | Security | Active | 2026-03-31 |
| Infrastructure Migration | `01-projects/work/infrastructure-migration` | Operations | Active | 2026-06-30 |
| Mobile App v2.0 | `01-projects/work/mobile-app-v20` | Product | On Hold | 2026-05-15 |
| Team Onboarding Program | `01-projects/work/team-onboarding-program` | HR/Operations | Active | 2026-02-15 |
| Data Analytics Dashboard | `01-projects/work/data-analytics-dashboard` | Engineering | Active | 2026-04-15 |
| Documentation Revamp | `01-projects/work/documentation-revamp` | Documentation | Active | 2026-03-30 |
| API Gateway Upgrade | `01-projects/work/api-gateway-upgrade` | Engineering | On Hold | 2026-07-31 |

## Integration Points

### Basecamp Integration
- **Skill**: `basecamp` (MCP)
- **Mapping**: See Basecamp project IDs → PARA paths
- **Sync**: Manual sync via skill or future n8n automation
- **Status Check**: "What's in [project]?" → Basecamp

### Outline Wiki Integration
- **Skill**: `outline` (MCP)
- **Live Search**: "Search Outline for [topic]"
- **Export**: "Export [document] to Obsidian"
- **Location**: `03-resources/work/wiki-mirror/`

### Teams Meeting Integration
- **Skill**: `meeting-notes`
- **Workflow**: DOCX → AI analysis → meeting note → Basecamp sync
- **Location**: `01-projects/work/[project]/meetings/`
- **Guide**: See `skills/meeting-notes/references/teams-transcript-workflow.md`

## Workflows

### Morning Planning with Work Context
```
1. Read yesterday's daily note
2. Check Basecamp: "Show my Basecamp todos due today"
3. Check Outline: "Search Outline for [project topic]"
4. Create integrated morning plan with:
   - Work priorities (from Basecamp)
   - Personal priorities (from PARA)
   - Meeting schedule
   - Deep work blocks
```

### Evening Reflection with Work Context
```
1. Review completed Basecamp tasks
2. Review project progress
3. Capture work learnings
4. Export decisions to Outline (if applicable)
5. Plan tomorrow's work priorities
```

### Weekly Review with Work
```
1. Check all Basecamp project status
2. Review work area health
3. Identify at-risk projects
4. Plan next week's priorities
5. Process work inbox
```

## Job Transition Checklist

When switching jobs:

1. **Archive Current Work**:
   - Move `01-projects/work/` → `04-archive/work/[old-company]/`
   - Move `02-areas/work/` → `04-archive/work/[old-company]/`
   - Keep `03-resources/work/wiki-mirror/` (company knowledge)

2. **Update Tool Configurations**:
   - Basecamp: Remove old projects, add new ones
   - Outline: Update collections (if switching wikis)
   - Keep work structure intact

3. **Create New Work Structure**:
   - Create new `01-projects/work/` folders
   - Update `02-areas/work/` areas
   - Preserve PARA methodology

## Quick Commands

| Action | Command |
|--------|----------|
| Start work day | "/chiron-start" → morning planning with Basecamp |
| End work day | "/chiron-end" → reflection with work metrics |
| Weekly review | "/chiron-review" → work project status review |
| Check Basecamp | "Show my Basecamp projects" or "What's in [project]?" |
| Search wiki | "Search Outline for [topic]" |
| Process meeting | "Process transcript: [file.docx]" |
| Project status | "What's status of [project name]?" |

## Notes

- All work knowledge stored in Obsidian (tool-agnostic)
- Basecamp used for real-time task tracking
- Outline used for live wiki access
- Teams transcripts processed with AI analysis
- n8n automation ready for future implementation

---

**Last updated**: 2026-01-28
