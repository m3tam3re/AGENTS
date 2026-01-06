# Anytype Space Setup Guide

Manual setup for the Chiron space in Anytype.

## Step 1: Create Space

1. Open Anytype desktop app
2. Click **+** to create new space
3. Name: **Chiron**
4. Description: *Personal AI Assistant workspace using PARA methodology*

## Step 2: Create Types

Create these object types in the Chiron space:

### Area Type
- **Name**: Area
- **Plural**: Areas
- **Layout**: Basic
- **Icon**: Briefcase (blue)

### Project Type
- **Name**: Project
- **Plural**: Projects
- **Layout**: Basic
- **Icon**: Rocket (purple)

### Task Type
- **Name**: Task
- **Plural**: Tasks
- **Layout**: Action (checkbox)
- **Icon**: Checkbox (blue)

### Resource Type
- **Name**: Resource
- **Plural**: Resources
- **Layout**: Basic
- **Icon**: Book (teal)

## Step 3: Create Properties

Add these properties (relations) to the space:

### Status (Select)
| Tag | Color |
|-----|-------|
| Inbox | Grey |
| Next | Blue |
| Waiting | Yellow |
| Scheduled | Purple |
| Done | Lime |

### Priority (Select)
| Tag | Color |
|-----|-------|
| Critical | Red |
| High | Orange |
| Medium | Yellow |
| Low | Grey |

### Energy (Select)
| Tag | Color |
|-----|-------|
| High | Red |
| Medium | Yellow |
| Low | Blue |

### Context (Multi-select)
| Tag | Color |
|-----|-------|
| Deep Work | Purple |
| Admin | Grey |
| Calls | Blue |
| Errands | Teal |
| Quick Wins | Lime |

### Other Properties
- **Area** (Relation → Area type)
- **Project** (Relation → Project type)
- **Due Date** (Date)
- **Outcome** (Text)
- **Description** (Text)

## Step 4: Link Properties to Types

### Task Type Properties
- Status
- Priority
- Energy
- Context
- Area (relation)
- Project (relation)
- Due Date

### Project Type Properties
- Status
- Priority
- Area (relation)
- Due Date
- Outcome

### Area Type Properties
- Description

## Step 5: Create Initial Areas

Create these Area objects:

1. **CTO Leadership**
   - Description: Team management, technical strategy, architecture decisions, hiring

2. **m3ta.dev**
   - Description: Content creation, courses, coaching, tutoring programs

3. **YouTube @m3tam3re**
   - Description: Technical exploration videos, tutorials, self-hosting guides

4. **Technical Exploration**
   - Description: NixOS, self-hosting, AI agents, automation experiments

5. **Personal Development**
   - Description: Learning, skills growth, reading

6. **Health & Wellness**
   - Description: Exercise, rest, sustainability

7. **Family**
   - Description: Quality time, responsibilities

## Step 6: Create Views (Optional)

Create these Set views for quick access:

### Inbox View
- Filter: Status = Inbox
- Sort: Created date (newest)

### Today's Focus
- Filter: Status = Next AND Due Date <= Today
- Sort: Priority (Critical first)

### By Area
- Group by: Area relation
- Filter: Status != Done

### Weekly Review
- Filter: Status != Done
- Group by: Area
- Sort: Due Date

## Step 7: API Setup (For Automation)

To enable API access for Chiron agent:

1. Go to Anytype settings
2. Find API/Integration settings
3. Generate API key
4. Configure in your environment or MCP settings

Without API access, use manual workflows or n8n integration.

## Verification

After setup, you should have:
- [ ] Chiron space created
- [ ] 4 custom types (Area, Project, Task, Resource)
- [ ] 4 select properties (Status, Priority, Energy, Context)
- [ ] 3 relation properties (Area, Project, Due Date)
- [ ] 7 Area objects created
- [ ] At least one view configured

## Notes

- The Note type is built-in, use it for quick captures
- Archive can be a status tag or separate type (your preference)
- Adjust colors and icons to your preference
