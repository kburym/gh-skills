---
name: gh-project-orchestrator
description: |
  Use when creating, managing, or linking GitHub Projects (V2) to issues, PRs, and 
  large integration workflows. Triggers on requests like "manage projects", 
  "create project for integration", "link issue to project", or "orchestrate 
  project workflow". Coordinates with issue-to-pr and pr-manager for complete 
  integration tracking.
---

# GitHub Project Orchestrator

Manage GitHub Projects V2 to track large integrations, coordinate multi-PR work, and maintain visibility across the development lifecycle.

## Overview

**Purpose**: Create structured project boards that link issues, PRs, and tasks for complex multi-step work.

## When to Use

Use this skill when:
- Creating new projects for large integrations
- Adding/linking issues and PRs to projects
- Tracking progress through custom fields
- Maintaining bidirectional links between projects, issues, and PRs
- Automating project status updates based on PR/issue state
- Orchestrating complex multi-step work

## Commands

### 1. List Projects

```
@gh-project-orchestrator List all projects
```

### 2. Create Project for Integration

```
@gh-project-orchestrator Create project for "Integration Name"
```

### 3. Add Items to Project

```
@gh-project-orchestrator Add issues #42, #43 to project "Integration Name"
@gh-project-orchestrator Link PR #123 to project "Integration Name"
```

### 4. Update Item Status

```
@gh-project-orchestrator Set project item #42 to "In Progress"
```

### 5. Setup Complete Integration

```
@gh-project-orchestrator Setup complete project for integration "Google Calendar"
```

**Creates**: Project + Epic issue + 6 sub-tasks + Cross-links

### 6. View Project Status

```
@gh-project-orchestrator Show status for project "Integration Name"
```

## Project Structure

### Standard Integration Project

| Component | Purpose |
|-----------|---------|
| **Project Board** | GitHub Project V2 with Status field |
| **Epic Issue** | Master tracking issue with full scope |
| **Sub-Tasks** | Draft items (6-10 tasks) |
| **Cross-Links** | Bidirectional references |

### Default Task Template

1. Setup/Configuration
2. Core Implementation (3-5 tasks)
3. Testing
4. Documentation

## Examples

### Example 1: Create Integration Project

```
@gh-project-orchestrator Setup integration for "Stripe Payment"

Output:
✅ Project Created Successfully

Project: #7 - Stripe Payment Integration
URL: https://github.com/OWNER/REPO/projects/7

📄 Epic Issue: #500
   Scope: API integration, Auth flow, Data sync, Error handling, Documentation

✅ Tasks Created: 6
   - Setup API credentials
   - Implement payment intent
   - Add webhook handlers
   - Create payment UI
   - Add error handling
   - Write documentation

🔗 Cross-References: Epic ↔ Project ✓
```

### Example 2: Link PRs to Project

```
@gh-project-orchestrator Link all payment PRs to project "Stripe Payment"

Actions:
1. Found project #7: Stripe Payment Integration
2. Discovered 3 payment-related PRs: #234, #235, #236
3. Added all 3 PRs to project
4. Updated epic issue #500 with PR list

Output: "✅ 3 PRs linked to Project #7 and Epic #500"
```

### Example 3: Project Status Dashboard

```
@gh-project-orchestrator Show status for "Stripe Payment"

Output:
📊 Project Status: Stripe Payment Integration

Items: 8 total
┌──────────────┬──────────────────────────────┐
│ Status       │ Count │ Items              │
├──────────────┼───────┼────────────────────┤
│ Todo         │   3   │ Setup, Auth, Core  │
│ In Progress  │   2   │ Sync, Webhook    │
│ Review       │   1   │ PR #234            │
│ Done         │   2   │ Planning, Config │
└──────────────┴───────┴────────────────────┘

Progress: 25% (2/8 items complete)
```

## Authentication

**Required Scopes**: `read:project`, `write:project`

```bash
# Check auth status
gh auth status

# Re-authenticate with project scopes
gh auth login --scopes "repo,read:project,write:project"
```

## Best Practices

1. **One Project Per Integration** - Keep large integrations isolated
2. **Always Create Epic** - Master tracking issue with full scope
3. **Granular Tasks** - Break down into 1-2 day tasks
4. **Link Everything** - Every issue/PR should be in a project
5. **Update Status** - Move items through workflow as they progress
6. **Auto-Route PRs** - Use keywords to automatically link PRs to projects

## Integration

**Called by**:
- issue-to-pr (when creating integration epics)
- pr-manager (for batch PR operations)
- pr-opener (when creating PRs for integrations)
- User (manual project management)

**Calls to**:
- GitHub GraphQL API (for Projects V2)
- GitHub CLI (gh project, gh pr, gh issue)

**Coordinates with**:
- issue-to-pr (creates epic + project together)
- pr-manager (manages multiple project PRs)
- gh-prioritizer (sets priority on project items)

## References

- [Acceptance Criteria](references/acceptance-criteria.md) - Quality standards and ✅/❌ examples
- [Best Practices](references/best-practices.md) - Project management patterns
- [GraphQL Queries](references/graphql-queries.md) - Complete GraphQL reference
- [Workflow Examples](references/workflow-examples.md) - Real-world scenarios
