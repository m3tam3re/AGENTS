# Organization Template Reference

## Default Strategy

Use the configured organization project template as the default way to create Basecamp projects. This keeps project structure, communication materials, and Docs & Files organization consistent across projects.

If the organization template cannot be used, a blank Basecamp project is allowed as an explicit fallback after the user confirms that choice.

## Configurable Template State

- Template ID: not-configured
- Template name: organization-project-template
- Source template language: German
- Basecamp account: use active CLI account unless user specifies another

## Template Selection

When the Template ID is `not-configured`, ask the user for one of these decisions before constructing the project:

1. Provide the Basecamp template ID for `organization-project-template`.
2. Confirm that the project should be created as a blank Basecamp project instead.

Use the active Basecamp CLI account unless the user specifies a different Basecamp account.

## Construction Command

`basecamp templates construct` has a bug (v0.7.2) that returns "Bad Request" for all templates. Use the API directly instead:

```bash
basecamp api POST "/templates/<template_id>/project_constructions.json" \
  -d '{"project":{"name":"<project name>","description":"<project description>"}}'
```

**Critical:** The `name` and `description` must be wrapped in a `project` object — this is what the CLI gets wrong.

### Polling

After construction, poll until `status` is `"completed"`:

```bash
basecamp api GET "/templates/<template_id>/project_constructions/<construction_id>.json"
```

When completed, the response includes the full `project` object with `id` and `app_url`.

### CLI Alternative (when fixed)

Once the CLI bug is resolved, the command should be:

```bash
basecamp templates construct <template_id> \
  --name "<project name>" \
  --desc "<project description>" \
  --json
```

The angle-bracket values in the command are argument placeholders to replace at execution time with the selected template ID, project name, and project description.

Use the resulting JSON output as the authoritative source for the created project identifiers and URLs.

## Source Communication Templates

Use `Docs & Files → Vorlagen` in the German source template as the source of project communication templates.

## Target-Language Rule

The source template language is German, but final project content must always be written in the user-selected project language. Translate, adapt, and complete communication materials so the finished project reads naturally in that target language.

## Missing Vorlagen Rule

If `Docs & Files → Vorlagen` is missing or does not contain the needed project communication templates, ask the user to choose exactly one path:

1. Stop project construction and fix the template or project structure before continuing.
2. Use a generic fallback communication template suitable for the project type and target language.
3. Use a template supplied directly by the user.
