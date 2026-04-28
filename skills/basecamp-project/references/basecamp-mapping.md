# Basecamp Mapping Reference

Use this reference to choose a project construction strategy and map project needs to Basecamp objects without creating duplicates.

## Project Strategies

### Recommended organization template

Use the organization's approved template when it exists and matches the project type. Construct the project from the template rather than recreating standard structure by hand.

```bash
basecamp templates construct
```

After starting construction, poll until the construction is completed. Then inspect the created project, read its dock, find Docs & Files, and recursively inspect the `Vorlagen` folder before adding project-specific content.

### Blank fallback

Use a blank project only when no suitable organization template exists or the template cannot be used. Build the minimum required structure, then add only the objects needed for the current project.

### Existing project mode

Use an existing project when the work is already underway in Basecamp or the requester explicitly names an existing project. Do not assume missing structure should be recreated.

## Existing Project Inspection Rule

Before creating anything in an existing project, inspect the project, read the dock, inspect relevant tools, and search for equivalent content by title, purpose, and date. Prefer updating or linking existing objects over creating new ones.

## Object Mapping

| Need | Basecamp object | Use for |
| --- | --- | --- |
| Kickoff, durable decisions, status updates | Message Board | Initial alignment, decisions that should remain easy to find, recurring project status |
| Planned milestone work | To-dos | Committed work organized by milestone, owner, and due date |
| Project Brief and stable references | Docs & Files | Briefs, source documents, durable reference files, and the `Vorlagen` template folder |
| Milestones and approval gates | Schedule | Key dates, reviews, approvals, launches, and external commitments |
| Lightweight status or focus questions | Automatic Check-ins | Regular prompts that collect short asynchronous responses |
| Reactive or pipeline work only | Card Table | Intake, triage, moving queues, or work that changes state frequently |

## Duplicate Avoidance

Before creating standard project objects, inspect for existing equivalents and reuse them when possible.

- Kickoff: search Message Board for kickoff, launch, start, and project-introduction posts.
- Project Brief: inspect Docs & Files and `Vorlagen` for a brief or source template before creating a new document.
- To-do lists: compare list titles, milestones, and planned phases before adding lists.
- Check-ins: inspect Automatic Check-ins for matching weekly focus or blocker questions before creating new prompts.
- Schedule entries: compare dates, names, and approval gates before adding events.

If a near-duplicate exists, update the existing object or record why a new object is distinct.

## Visibility and Notification Planning

Plan visibility before posting or assigning work.

- Identify who should see the project, who should be notified immediately, and who only needs access for reference.
- Use project-wide announcements only for kickoff, major decisions, and status updates that affect all participants.
- Notify specific people for assigned to-dos, approval gates, and decisions requiring action.
- Avoid over-notifying observers; rely on clear titles, descriptions, and links for discoverability.
