# Brainstorm Anytype Workflow

This document describes how to create and use Brainstorm objects in Anytype.

## Quick Create (API)

```bash
# Create a brainstorm object using Anytype MCP
Anytype_API-create-object
  space_id: bafyreie5sfq7pjfuq56hxsybos545bi4tok3kx7nab3vnb4tnt4i3575p4.yu20gbnjlbxv
  type_key: "brainstorm_v_2"
  name: "NixOS Course Launch Strategy"
  body: "Full brainstorm content here..."
  icon: { format: "emoji", emoji: "💭" }
  properties: [
    { key: "topic", text: "NixOS Course Launch Strategy" },
    { key: "context", text: "Want to launch NixOS course for developers" },
    { key: "outcome", text: "Build long-term audience/community" },
    { key: "constraints", text: "2-4 weeks prep time, solo creator" },
    { key: "options", text: "Option A: Early access... Option B: Free preview..." },
    { key: "decision", text: "Early access with community" },
    { key: "rationale", text: "Builds anticipation while validating content" },
    { key: "next_steps", text: "1. Create landing page, 2. Build email list..." },
    { key: "framework", select: "bafyreigokn5xgdosd4cihehl3tqfsd25mwdaapuhopjgn62tkpvpwn4tmy" },
    { key: "status", select: "bafyreiffiinadpa2fwxw3iylj7pph3yzbnhe63dcyiwr4x24ne4jsgi24" }
  ]
```

## Type Properties

| Property | Type | Purpose |
|----------|------|---------|
| `topic` | text | Short title/summary |
| `context` | text | Situation and trigger |
| `outcome` | text | What success looks like |
| `constraints` | text | Time, resources, boundaries |
| `options` | text | Options explored |
| `decision` | text | Final choice made |
| `rationale` | text | Reasoning behind decision |
| `next_steps` | text/objects | Action items or linked tasks |
| `framework` | select | Thinking framework used |
| `status` | select | Draft → Final → Archived |
| `tags` | multi_select | Categorization |
| `linked_projects` | objects | Related projects |
| `linked_tasks` | objects | Related tasks |

## Framework Tag IDs

| Framework | Tag ID |
|-----------|--------|
| None | `bafyreiatkdbwq53shngaje6wuw752wxnwqlk3uhy6nicamdr56jpvji34i` |
| Pros/Cons | `bafyreiaizrndgxmzbbzo6lurkgi7fc6evemoc5tivswrdu57ngkizy4b3u` |
| SWOT | `bafyreiaym5zkajnsrklivpjkizkuyhy3v5fzo62aaeobdlqzhq47clv6lm` |
| 5 Whys | `bafyreihgfpsjeyuu7p46ejzd5jce5kmgfsuxy7r5kl4fqdhuq7jqoggtgq` |
| How-Now-Wow | `bafyreieublfraypplrr5mmnksnytksv4iyh7frspyn64gixaodwmnhmosu` |
| Starbursting | `bafyreieyz6xjpt3zxad7h643m24oloajcae3ocnma3ttqfqykmggrsksk4` |
| Constraint Mapping | `bafyreigokn5xgdosd4cihehl3tqfsd25mwdaapuhopjgn62tkpvpwn4tmy` |

## Status Tag IDs

| Status | Tag ID |
|--------|--------|
| Draft | `bafyreig5um57baws2dnntaxsi4smxtrzftpe57a7wyhfextvcq56kdkllq` |
| Final | `bafyreiffiinadpa2fwxw3iylj7pph3yzbnhe63dcyiwr4x24ne4jsgi24` |
| Archived | `bafyreihk6dlpwh3nljrxcqqe3v6tl52bxuvmx3rcgyzyom6yjmtdegu4ja` |

## Template Setup (Recommended)

For a better editing experience, create a template in Anytype:

1. Open Anytype desktop app → Chiron space
2. Go to Content Model → Object Types → Brainstorm v2
3. Click Templates (top right) → Click + to create template
4. Configure with:
   - **Name**: "Brainstorm Session"
   - **Icon**: 💭
   - **Default Status**: Draft
   - **Pre-filled structure**: Leave body empty for dynamic content
   - **Property defaults**: Set framework to "None" as default

5. Save the template

Now when creating brainstorms, select this template for a guided experience.

## Linking to Other Objects

After creating a brainstorm, link it to related objects:

```bash
# Link to a project
Anytype_API-update-object
  object_id: <brainstorm_id>
  space_id: <chiron_space_id>
  properties: [
    { key: "linked_projects", objects: ["<project_id>"] }
  ]

# Link to tasks
Anytype_API-update-object
  object_id: <brainstorm_id>
  space_id: <chiron_space_id>
  properties: [
    { key: "linked_tasks", objects: ["<task_id_1>", "<task_id_2>"] }
  ]
```

## Searching Brainstorms

Find brainstorms by topic, status, or tags:

```bash
Anytype_API-search-space
  space_id: bafyreie5sfq7pjfuq56hxsybos545bi4tok3kx7nab3vnb4tnt4i3575p4.yu20gbnjlbxv
  query: "NixOS"
  types: ["brainstorm_v_2"]
```

Or list all brainstorms:

```bash
Anytype_API-list-objects
  space_id: bafyreie5sfq7pjfuq56hxsybos545bi4tok3kx7nab3vnb4tnt4i3575p4.yu20gbnjlbxv
  type_id: bafyreifjneoy2bdxuwwai2e3mdn7zovudpzbjyflth7k3dj3o7tmhqdlw4
```

## Best Practices

1. **Create brainstorms for any significant decision** - Capture reasoning while fresh
2. **Mark as Final when complete** - Helps with search and review
3. **Link to related objects** - Creates context web
4. **Use frameworks selectively** - Not every brainstorm needs structure
5. **Review periodically** - Brainstorms can inform future decisions
