# Execution Recovery Reference

Basecamp changes are not transactional. Do not describe recovery as rollback; use resume, repair, archive, or supersede language instead.

## Cautious Batch Execution

Execute changes in cautious batches so each step can be inspected before dependent objects are created. Capture created object identifiers and links as work proceeds.

## Batch Order

1. Project shell
2. Structure inspection
3. People/access
4. Docs/project brief
5. To-do lists
6. To-dos
7. Schedule
8. Check-ins
9. Kickoff/notification

## Creation Log Format

Record each successful change immediately after creation or update.

```markdown
# Creation Log

## Project
- Project: Name, ID, URL

## Created or updated objects
- Type: Message Board post | To-do list | To-do | Document | Schedule entry | Check-in
  Title: Object title
  ID: Basecamp object ID
  URL: Object URL
  Action: Created | Updated | Reused
  Notes: Relevant context

## Notifications
- Audience: People or group notified
  Method: Basecamp notification type
  Reason: Why notification was sent
```

## Failure Report Format

When a batch fails, stop dependent work and report enough detail to resume safely.

```markdown
# Failure Report

## Failed batch
Batch name and step number

## Operation attempted
Command or Basecamp action

## Error observed
Error message, status code, or unexpected response

## Completed before failure
Links and IDs from the creation log

## Not yet attempted
Remaining planned batches

## Recommended next action
Resume point or repair action
```

## Resume and Repair Workflow

1. Read the creation log and failure report.
2. Inspect the Basecamp project directly before making more changes.
3. Confirm which objects already exist and whether they are complete.
4. Reuse complete objects and repair incomplete objects where possible.
5. Supersede or archive mistaken objects when they should not remain active.
6. Resume from the first incomplete batch in the batch order.
7. Update the creation log with every resumed or repaired action.
8. Send kickoff or notifications only after the structure is inspected and stable.
