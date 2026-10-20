# Large Integration Workflow Guide

Complete workflow for orchestrating large integrations using GitHub Projects, Issues, and PRs.

## Overview

Large integrations (e.g., "Stripe Payment Integration", "Google Calendar Sync") require coordination across:
- Multiple GitHub Projects for tracking
- Multiple Issues for task breakdown
- Multiple PRs for implementation
- Cross-linking between all components

## Integration Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Large Integration                         │
│              (e.g., Stripe Payment Integration)              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  📋 GitHub Project                                           │
│  ├─ Epic Issue (Master tracker)                             │
│  ├─ Task 1 (Draft issue)                                    │
│  ├─ Task 2 (Draft issue)                                      │
│  ├─ Task 3 (Draft issue)                                      │
│  ├─ PR #234 (Linked to Task 1)                              │
│  └─ PR #235 (Linked to Task 2)                              │
│                                                              │
│  📄 Epic Issue                                               │
│  ├─ Full scope description                                   │
│  ├─ Links to all sub-tasks                                   │
│  ├─ Links to all PRs                                         │
│  └─ Project board reference                                    │
│                                                              │
│  🔗 Cross-Links                                              │
│  ├─ Epic ↔ Project                                          │
│  ├─ Tasks ↔ Project                                          │
│  ├─ PRs ↔ Project                                             │
│  └─ PRs ↔ Epic                                                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Complete Workflow

### Phase 1: Setup Integration Structure

```
@issue-to-pr Setup large integration "Stripe Payment"
```

**Actions:**
1. Create GitHub Project
2. Create Epic Issue
3. Link Epic to Project
4. Create Sub-Tasks
5. Set up PR tracking

### Phase 2: Development

As developers work on the integration:

```
@pr-opener Create PR for task/stripe-auth
```

**Automatic workflow:**
1. Detects this is part of "Stripe Payment" integration
2. Creates issue for the PR
3. Creates PR with issue link
4. Links PR to project "Stripe Payment"
5. Updates epic with PR reference

### Phase 3: Tracking

Monitor progress:

```
@gh-project-orchestrator Show status for project "Stripe Payment"
```

**Report:**
- Project board status
- Completed tasks
- In-progress PRs
- Blocked items

### Phase 4: Completion

When integration is done:

```
@gh-project-orchestrator Close integration "Stripe Payment"
```

**Actions:**
1. Verify all tasks complete
2. Verify all PRs merged
3. Close epic issue
4. Close project (optional)
5. Archive integration

## Integration Types

### Type 1: External Service Integration

**Examples:** Stripe, Google Calendar, QuickBooks

**Structure:**
- Epic: Full integration scope
- Tasks: API setup, Auth, Sync, Webhooks, Tests
- Project: Track all components
- Timeline: 1-2 sprints

### Type 2: Feature Enhancement

**Examples:** Payment UI, Reporting Dashboard

**Structure:**
- Epic: Feature scope
- Tasks: UI design, Backend, Frontend, Testing
- Project: Track development phases
- Timeline: 1 sprint

### Type 3: Technical Infrastructure

**Examples:** Database Migration, API V2, Auth Service

**Structure:**
- Epic: Technical scope
- Tasks: Migration scripts, API endpoints, Testing, Rollout
- Project: Track migration phases
- Timeline: 2-4 sprints

## Project Fields Setup

### Standard Integration Project

**Required Fields:**
1. **Status** (Single Select)
   - Todo
   - In Progress
   - Review
   - Done

2. **Priority** (Single Select)
   - Low
   - Medium
   - High
   - Critical

3. **Type** (Single Select)
   - Epic
   - Task
   - Bug
   - PR

4. **Assignee** (Users)
   - Team member assignment

5. **Due Date** (Date)
   - Sprint/milestone dates

### Custom Fields by Integration

**Payment Integration:**
- **Risk Level:** Low, Medium, High
- **Compliance:** PCI, GDPR, None
- **Environment:** Dev, Staging, Prod

**Calendar Integration:**
- **Sync Type:** One-way, Two-way
- **Frequency:** Real-time, Hourly, Daily
- **Provider:** Google, Outlook, Apple

## Automation Rules

### Auto-Update Project Status

When PR state changes:
```
PR Opened → Project Item = "In Progress"
PR Merged → Project Item = "Done"
Issue Closed → Project Item = "Done"
```

### Auto-Link by Keywords

```bash
# Detect integration by keywords in title/body
if [[ "$content" =~ (payment|stripe|billing) ]]; then
  project="Stripe Payment Integration"
elif [[ "$content" =~ (calendar|google) ]]; then
  project="Google Calendar Integration"
fi
```

## Best Practices

### 1. One Project Per Integration
- Keep integrations isolated
- Clear scope boundaries
- Easy progress tracking

### 2. Epic as Source of Truth
- Full scope in epic description
- Links to all components
- High-level progress view

### 3. Granular Tasks
- 1-2 day tasks maximum
- Clear acceptance criteria
- Single responsibility

### 4. Link Everything
- Every issue/PR in a project
- Bidirectional links
- No orphaned work

### 5. Update Status Regularly
- Daily project board updates
- Blocked items flagged
- Progress visible

### 6. Close When Complete
- All tasks done
- All PRs merged
- Epic closed
- Project archived

## Command Reference

### Create Integration
```
@issue-to-pr Setup large integration "Integration Name"
```

### Add PR to Integration
```
@gh-project-orchestrator Link PR #123 to project "Integration Name"
```

### View Progress
```
@gh-project-orchestrator Show status for project "Integration Name"
```

### Batch Link PRs
```
@pr-manager Link all payment PRs to project "Stripe Payment"
```

### Close Integration
```
@gh-project-orchestrator Close integration "Integration Name"
```

## Example: Complete Stripe Integration

### Step 1: Setup
```
User: Setup integration for Stripe Payment

issue-to-pr:
1. Created project #7 "Stripe Payment Integration"
2. Created epic issue #600 with scope:
   - API integration
   - Authentication flow
   - Webhook handlers
   - Payment UI
   - Error handling
   - Documentation
3. Added epic #600 to project #7
4. Created 6 draft tasks in project:
   - Setup Stripe API credentials
   - Implement payment intent endpoint
   - Add webhook signature verification
   - Create payment form UI
   - Add error handling and retry logic
   - Write integration documentation
5. Cross-linked all components

Report:
✅ Integration structure complete
- Project: #7
- Epic: #600
- Tasks: 6
- Ready for development
```

### Step 2: Development
```
User: Create PR for stripe-auth branch

pr-opener:
1. Detected "stripe" keyword
2. Created issue #601: "Implement Stripe authentication"
3. Created PR #234: "feat: Add Stripe auth flow (Closes #601)"
4. Linked PR #234 to project #7 "Stripe Payment"
5. Updated epic #600 with PR #234 reference
6. Set project item status to "In Progress"

Report:
✅ PR created and linked
- Issue: #601
- PR: #234
- Project: #7
- Epic updated: #600
```

### Step 3: Progress Check
```
User: Show Stripe Payment progress

gh-project-orchestrator:
Project: Stripe Payment Integration (#7)

Status Summary:
┌──────────────┬───────┬────────────────────────┐
│ Status       │ Count │ Items                  │
├──────────────┼───────┼────────────────────────┤
│ Todo         │   2   │ Webhook, Documentation │
│ In Progress  │   3   │ Auth, UI, Error        │
│ Review       │   1   │ PR #234                │
│ Done         │   1   │ API Setup              │
└──────────────┴───────┴────────────────────────┘

Progress: 50% (4/8 items in progress or done)
Epic: #600 (6 of 6 tasks in progress)
```

### Step 4: Completion
```
User: Close Stripe Payment integration

gh-project-orchestrator:
1. Verified all 6 tasks marked "Done"
2. Verified all 4 PRs merged
3. Closed epic issue #600
4. Closed project #7
5. Archived integration

Report:
✅ Integration complete and archived
- Duration: 3 weeks
- Tasks: 6/6 complete
- PRs: 4/4 merged
- Status: Successfully delivered
```

## Integration List

Active and planned integrations:

### Current
1. **Stripe Payment** (#7) - 50% complete
2. **Google Calendar** (#5) - 60% complete
3. **QuickBooks** (#3) - 80% complete

### Planned
4. **iDEAL Mollie** - Q2 2026
5. **Mailchimp** - Q2 2026
6. **Twilio SMS** - Q3 2026

## Troubleshooting

### Project Not Accessible
```
Error: INSUFFICIENT_SCOPES
Solution: gh auth login --scopes "repo,read:project,write:project"
```

### Epic Not Linked to Project
```
Action: Re-run linking
@gh-project-orchestrator Add issue #<epic> to project "<name>"
```

### PR Not Showing in Project
```
Action: Check PR was added
@gh-project-orchestrator Link PR #<pr> to project "<name>"
```

### Tasks Missing
```
Action: Add missing tasks
@gh-project-orchestrator Add draft task "<description>" to project "<name>"
```
