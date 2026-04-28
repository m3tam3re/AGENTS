---
name: basecamp-project
description: "Use when: (1) setting up a new Basecamp project, (2) turning an idea or plan into a reviewed project launch package, (3) creating Basecamp task lists, kickoff messages, project briefs, check-ins, or launch structure, (4) stress-testing project scope, timeline, roles, risks, and feasibility before Basecamp launch. Triggers: create Basecamp project, setup project in Basecamp, project kickoff, project plan to Basecamp, launch project."
compatibility: opencode
---

# Basecamp Project

## Overview

Turn an idea or plan into a reviewed Project Launch Package and, after explicit approval, create a new Basecamp project or adapt an existing one.

## Non-Negotiable Rules

- **Self-contained subagent rule:** Do not rely on named personal agents. Use the prompts in `references/subagent-prompts/`; if a subagent tool is unavailable, emulate the roles sequentially in the main session.
- **Approval gate rule:** Do not create, adapt, publish, notify, or otherwise change Basecamp content until the relevant approval gate has explicit user approval.
- **Organization template recommendation rule:** For new projects, recommend starting from the organization template before offering other approaches.
- **Blank project fallback rule:** If the organization template is unavailable or rejected, offer a blank project fallback and explain what must be recreated manually.
- **Language rule:** Ask for and preserve the project language across briefs, task lists, kickoff writing, check-ins, and user-facing Basecamp content.
- **Missing `Vorlagen` rule:** If `Docs & Files → Vorlagen` is missing, report it and ask the user to choose exactly one path before proceeding: stop and fix the template or project structure, use a generic fallback communication template suitable for the project type and target language, or use a template supplied directly by the user.
- **External visibility rule:** Confirm what clients, partners, or other external people can see before drafting or applying content.
- **Tiered review rule:** Run review in tiers: feasibility first, plan and structure second, launch content and execution readiness last.
- **Hybrid assignment rule:** For hybrid teams, make task ownership explicit across internal and external assignees and avoid unclear shared responsibility.
- **Hybrid due-date rule:** For hybrid teams, use due dates that reflect dependency handoffs, external review windows, and timezone or availability constraints.
- **Notification rule:** Treat notifications as a separate launch decision; state who will be notified, when, and why before sending or triggering updates.
- **Cautious execution rule:** Execute Basecamp changes in small verified batches, stop on ambiguity or API/tool errors, and preserve a recoverable creation log.
- **Existing project inspection rule:** In Existing Project Mode, inspect the current project structure and content before proposing or applying changes.

## Workflow Spine

1. Select mode: Discovery Mode, Plan Mode, or Existing Project Mode.
2. Ask project language.
3. Ask external/client visibility questions.
4. Run Discovery Coach.
5. Run Scope Realist.
6. Resolve Red feasibility trade-offs before final planning.
7. Run Project Planner.
8. Run Task Architect.
9. Ask whether to save a local Project Launch Package.
10. Approval Gate 1: project creation/adaptation.
11. For new projects, recommend organization template; allow blank fallback.
12. If using template, construct project with `basecamp templates construct`.
13. Inspect created/existing project.
14. If `Docs & Files → Vorlagen` exists, run Template Librarian.
15. Run Kickoff Writer using project language and template findings.
16. Run Project Reviewer.
17. Approval Gate 2: apply launch content and notification plan.
18. Execute Basecamp changes in verified batches.
19. Report links, creation log, warnings, and resume instructions if needed.

## Reference Loading Map

| Reference | Load when |
| --- | --- |
| `references/organization-template.md` | Recommending, constructing, or falling back from the organization template. |
| `references/discovery-loop.md` | Running Discovery Mode or converting an unclear idea into usable inputs. |
| `references/planning-model.md` | Building the Project Launch Package and feasibility-reviewed plan. |
| `references/tasklist-rules.md` | Designing task lists, assignments, due dates, and hybrid team structure. |
| `references/kickoff-patterns.md` | Drafting kickoff messages, briefs, check-ins, and launch communications. |
| `references/basecamp-mapping.md` | Mapping launch package elements to Basecamp tools and project structure. |
| `references/status-tracking.md` | Designing check-ins, status updates, reporting rhythm, and follow-up tracking. |
| `references/review-checklists.md` | Running feasibility, planning, content, and execution reviews. |
| `references/execution-recovery.md` | Applying changes safely, logging batches, recovering from errors, and resuming. |
| `references/subagent-prompts/discovery-coach.md` | Running or emulating Discovery Coach. |
| `references/subagent-prompts/scope-realist.md` | Running or emulating Scope Realist. |
| `references/subagent-prompts/project-planner.md` | Running or emulating Project Planner. |
| `references/subagent-prompts/task-architect.md` | Running or emulating Task Architect. |
| `references/subagent-prompts/template-librarian.md` | Running or emulating Template Librarian. |
| `references/subagent-prompts/kickoff-writer.md` | Running or emulating Kickoff Writer. |
| `references/subagent-prompts/project-reviewer.md` | Running or emulating Project Reviewer. |
| `references/subagent-prompts/basecamp-operator.md` | Running or emulating Basecamp Operator for approved execution batches. |
