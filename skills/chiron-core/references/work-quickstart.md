# Work Integration Quick Start Guide

Quick reference for using your work integration with Basecamp, Outline, and Teams.

## 🚀 First-Time Setup

### 1. Customize Your Projects

The 10 projects in `01-projects/work/` are placeholders. Customize them:

```bash
# Option A: Fetch from Basecamp (when MCP is ready)
"Show my Basecamp projects" → Get actual project names

# Option B: Manual customization
cd ~/CODEX/01-projects/work
# Rename folders to match your actual Basecamp projects
# Update each _index.md with:
#   - Correct project name
#   - Actual Basecamp project ID
#   - Real deadline
#   - Actual status
```

### 2. Set Up Outline MCP

```bash
# Install Outline MCP server
pip install mcp-outline

# Configure in your Opencode/MCP client
# See: https://github.com/Vortiago/mcp-outline
# Set OUTLINE_API_KEY and OUTLINE_API_URL
```

### 3. Test Basecamp Connection

```bash
# Test Basecamp MCP
"Show my Basecamp projects"

# Should list your actual projects
# If successful, ready to use
```

---

## 📅 Daily Work Workflow

### Morning Planning

```
"Start day" or "/chiron-start"
```

**What happens**:
1. Checks yesterday's completed tasks
2. Fetches today's Basecamp todos
3. Searches Outline for relevant wiki docs
4. Creates integrated morning plan

**Output includes**:
- Work priorities (from Basecamp)
- Personal priorities (from PARA areas)
- Meeting schedule
- Deep work blocks protected

### During Work Day

**Check Basecamp status**:
```bash
"What's in API Integration Platform?"
"Show my Basecamp todos due today"
"Search Basecamp for OAuth2"
```

**Search wiki for context**:
```bash
"Search Outline for authentication best practices"
"Search Outline for API rate limiting"
```

**Quick capture**:
```bash
"Capture: OAuth2 needs refresh token logic"
# → Saved to 00-inbox/work/
```

**Process meeting transcript**:
```bash
"Process transcript: api-design-review.docx"
# → Creates meeting note
# → Extracts action items
# → Optionally syncs to Basecamp
```

### Evening Reflection

```
"End day" or "/chiron-end"
```

**What happens**:
1. Reviews completed Basecamp tasks
2. Captures work wins and learnings
3. Checks project progress
4. Plans tomorrow's work priorities
5. Updates work metrics

---

## 📊 Weekly Work Review

```
"Weekly review" or "/chiron-review"
```

**What happens**:
1. Checks all Basecamp project status (completion %, overdue items)
2. Reviews work area health
3. Identifies at-risk projects
4. Plans next week's work priorities
5. Processes work inbox

**Output includes**:
- Work metrics (tasks completed, projects progressed)
- Work wins and challenges
- Project status overview (on track, behind, at risk)
- Work area health review
- Next week's priorities

---

## 🔧 Tool-Specific Commands

### Basecamp (Project Management)

**List all projects**:
```bash
"Show my Basecamp projects"
```

**Check project status**:
```bash
"What's in API Integration Platform?"
"What's status of Customer Portal Redesign?"
```

**Create todos**:
```bash
"Add todos to API Integration Platform"
# → Prompts for: project, todo list, tasks with due dates
```

**Search content**:
```bash
"Search Basecamp for OAuth2"
```

### Outline (Wiki Knowledge)

**Search wiki**:
```bash
"Search Outline for API authentication"
"Ask Outline: How do we handle rate limiting?"
```

**Read document**:
```bash
"Show me OAuth2 Setup Guide"
```

**Export to Obsidian**:
```bash
"Export OAuth2 Setup Guide to Obsidian"
# → Saves to 03-resources/work/wiki-mirror/
# → Adds frontmatter with outline source
# → Links to related projects/areas
```

**Create wiki document**:
```bash
"Create Outline doc: API Authentication Decision"
# → Creates in Outline with provided content
# → Adds to appropriate collection
```

### Teams (Meetings)

**Process transcript**:
```bash
"Process transcript: [filename.docx]"
```

**Workflow**:
1. Upload transcript file
2. Extract text from DOCX
3. AI analysis extracts: attendees, topics, decisions, action items
4. Creates meeting note in Obsidian
5. Optionally syncs action items to Basecamp

**Manual steps** (see `skills/meeting-notes/references/teams-transcript-workflow.md`):
```bash
# Step 1: Download transcript from Teams
# Step 2: Extract text
python extract_transcript.py transcript.docx

# Step 3: Ask AI to analyze
# (Paste transcript into AI prompt from workflow guide)

# Step 4: Create meeting note using meeting-notes skill

# Step 5 (Optional): Sync action items to Basecamp
```

---

## 🎯 Quick Reference

| I Want To... | Command | Tool |
|----------------|----------|-------|
| See today's work | "/chiron-start" | Morning planning |
| Review my day | "/chiron-end" | Evening reflection |
| See project status | "What's in [project]?" | Basecamp |
| Find wiki info | "Search Outline for [topic]" | Outline |
| Process meeting | "Process transcript: [file]" | Teams + AI |
| Weekly review | "/chiron-review" | Weekly review |
| Create wiki doc | "Create Outline doc: [title]" | Outline |
| Export wiki doc | "Export [doc] to Obsidian" | Outline |
| Quick capture | "Capture: [thought]" | Quick capture |

---

## 🔗 Integration Examples

### Example 1: Starting a New Project

```bash
# 1. Create project in PARA (manually or from plan-writing)
# 2. Create project folder in 01-projects/work/
# 3. Link to Basecamp (if project exists there)

User: "What's the status of API Integration Platform in Basecamp?"
→ Gets: 65% complete, next milestone: OAuth2 endpoints

User: "Search Outline for OAuth2 setup guides"
→ Gets: 3 relevant documents

User: "Export OAuth2 Setup Guide to Obsidian"
→ Saves to project/notes/oauth2-setup-guide.md
→ Links from project MOC
```

### Example 2: Processing a Meeting

```bash
User: "Process transcript: api-design-review.docx"

System:
1. Extracts text from DOCX
2. AI analyzes: attendees, topics, decisions, action items
3. Creates meeting note: 01-projects/work/api-integration-platform/meetings/api-design-review-20260128.md
4. Outputs action items:
   - [ ] Create OAuth2 implementation guide #meeting #todo 🔼 👤 @alice 📅 2026-02-05
   - [ ] Document rate limiting policy #meeting #todo 🔼 👤 @bob 📅 2026-02-10

User: "Sync action items to Basecamp?"
→ System creates 2 todos in API Integration Platform project
→ Assigns to Alice and Bob
→ Sets due dates
```

### Example 3: Daily Work Flow

```bash
Morning:
"/chiron-start"
→ Gets: 5 Basecamp todos due today
→ Gets: 2 meetings scheduled
→ Searches Outline: "API authentication patterns"
→ Creates integrated plan:
   - Work: Complete OAuth2 flow (P0)
   - Work: Review dashboard mockups (P1)
   - Meeting: Architecture review (2pm)
   - Deep work: 9-11am (OAuth2)

During work:
"Search Basecamp for OAuth2"
→ Finds: 3 docs, 2 todos

Evening:
"/chiron-end"
→ Reviews: OAuth2 flow complete
→ Captures: Learning about token refresh pattern
→ Checks project: 70% complete now
→ Plans: Tomorrow: Finish API endpoints
```

---

## 💡 Best Practices

### Daily Use
1. **Start with morning plan** - Sets focus for the day
2. **Check Basecamp first** - Prioritize work tasks
3. **Search Outline for context** - Get knowledge before starting
4. **Quick capture interruptions** - Don't break flow, capture and continue
5. **End with evening reflection** - Review and plan tomorrow

### Weekly Use
1. **Dedicated time** - 60-90 minutes for weekly review
2. **Check all projects** - Don't forget any
3. **Review area health** - Balance attention across responsibilities
4. **Process inbox** - Keep 00-inbox/ clean
5. **Plan next week** - Set priorities, don't just review

### Tool Use
1. **Basecamp for tasks** - Live task tracking
2. **Outline for knowledge** - Persistent wiki access
3. **Obsidian for storage** - Tool-agnostic knowledge
4. **Teams transcripts** - Process within 24 hours
5. **AI for analysis** - Extract insights from transcripts/docs

---

## 🔧 Troubleshooting

### Basecamp MCP Not Working
**Check**:
- MCP server running?
- API key configured?
- Connection to Basecamp?

### Outline MCP Not Working
**Check**:
- `pip install mcp-outline` completed?
- OUTLINE_API_KEY set?
- OUTLINE_API_URL correct?

### Project Not Found in Basecamp
**Check**:
- Project name matches exactly?
- Project in correct workspace?

### Wiki Search No Results
**Try**:
- Broader query (fewer keywords)
- Remove collection_id to search everywhere
- Use `ask_ai_about_documents` for semantic search

### Transcript Processing Fails
**Check**:
- DOCX file valid?
- `python-docx` installed?
- AI prompt clear enough?

---

## 📚 Documentation Links

For detailed guides, see:

- **PARA Work Structure**: `skills/chiron-core/references/work-para-structure.md`
- **Basecamp Skill**: `skills/basecamp/SKILL.md`
- **Outline Skill**: `skills/outline/SKILL.md`
- **Daily Routines**: `skills/daily-routines/SKILL.md`
- **Meeting Notes**: `skills/meeting-notes/SKILL.md`
- **Teams Transcript Workflow**: `skills/meeting-notes/references/teams-transcript-workflow.md`
- **Outline Workflows**: `skills/outline/references/outline-workflows.md`
- **Export Patterns**: `skills/outline/references/export-patterns.md`

---

**Last updated**: 2026-01-28
