# GitHub Project Orchestrator Acceptance Criteria

**Skill**: `gh-project-orchestrator`

**Purpose**: Produce GitHub Projects V2 management that accurately creates projects, links items, and tracks integration progress.

**Focus**: Project creation, item management, status tracking, cross-linking, workflow automation.

---

## 1. Project Creation

### 1.1 ✅ CORRECT: Project Created with Structure

**Example**:
```
@gh-project-orchestrator Create project for "Stripe Payment Integration"

Output:
✅ Created project #7 - Stripe Payment Integration
URL: https://github.com/OWNER/REPO/projects/7

Structure:
- Project Board: Created with Status field
- Ready for: Issues, PRs, Draft items
```

**Verification**:
- Project exists in GitHub ✓
- Title matches input ✓
- URL accessible ✓

### 1.2 ✅ CORRECT: Integration Project with Full Setup

**Example**:
```
@gh-project-orchestrator Setup complete project for integration "Google Calendar"

Output:
✅ Project Created Successfully

Project: #5 - Google Calendar Integration
URL: https://github.com/OWNER/REPO/projects/5

Components:
- Epic Issue: #456 (Google Calendar Integration Epic)
- Draft Tasks: 6 created
- Status Fields: Todo, In Progress, Review, Done

Links Created:
- Epic → Project ✓
- Tasks → Project ✓
- Ready for PR linking
```

### 1.3 ❌ INCORRECT: Project Created Without Links

**Scenario**:
```
@gh-project-orchestrator Create project for "Integration"

Output: "Created project #8" ✅

Problem: No epic issue, no tasks, no structure ❌
```

---

## 2. Item Management

### 2.1 ✅ CORRECT: Issue Added to Project

**Example**:
```
@gh-project-orchestrator Add issues #42, #43 to project "Stripe Payment"

Actions:
1. Found project #7: Stripe Payment
2. Added issue #42 to project ✓
3. Added issue #43 to project ✓

Output: "✅ Added issues #42, #43 to project #7"
```

### 2.2 ✅ CORRECT: PR Linked to Project

**Example**:
```
@gh-project-orchestrator Link PR #123 to project "Stripe Payment"

Actions:
1. Found project #7: Stripe Payment
2. Found PR #123
3. Added PR #123 to project ✓
4. Updated epic with PR reference ✓

Output: "✅ Added PR #123 to project #7"
```

### 2.3 ❌ INCORRECT: Items Not Actually Added

**Scenario**:
```
@gh-project-orchestrator Add issue #42 to project

Output: "Added to project" ✅

Verification: Issue #42 not in project board ❌
```

---

## 3. Status Tracking

### 3.1 ✅ CORRECT: Project Status Updated

**Example**:
```
@gh-project-orchestrator Set project item #42 to "In Progress"

Actions:
1. Found project item #42
2. Updated Status field to "In Progress" ✓
3. Verified update ✓

Output: "✅ Item #42 status updated to 'In Progress'"
```

### 3.2 ✅ CORRECT: Project Dashboard Shows Status

**Example**:
```
@gh-project-orchestrator Show status for project "Stripe Payment"

Output:
📊 Project Status: Stripe Payment Integration

Items: 8 total
┌──────────────┬──────────────────────────────┐
│ Status       │ Count │ Items                  │
├──────────────┼───────┼────────────────────────┤
│ Todo         │   3   │ Setup, Auth, Core      │
│ In Progress  │   2   │ Sync endpoint, Webhook │
│ Review       │   1   │ PR #234                │
│ Done         │   2   │ Planning, Config       │
└──────────────┴──────────────────────────────┘

Progress: 25% (2/8 items complete)
```

### 3.3 ❌ INCORRECT: Status Not Persisted

**Scenario**:
```
@gh-project-orchestrator Set item #42 to "Done"

Output: "Status updated" ✅

Reality: Item still shows "In Progress" in GitHub ❌
```

---

## 4. Cross-Linking

### 4.1 ✅ CORRECT: Bidirectional Links Created

**Example**:
```
@gh-project-orchestrator Setup integration "Payment"

Links Created:
- Epic Issue #500 → Project #7 ✓
- Tasks → Project #7 ✓
- Epic references Project URL ✓
- Project items linked to Issues/PRs ✓
```

### 4.2 ✅ CORRECT: PR Auto-Routed to Project

**Example**:
```bash
# When PR #234 is created with title "feat: Add payment intent"
@gh-project-orchestrator Auto-route PR #234

Detection:
- Title contains "payment"
- Matched project: "Stripe Payment Integration"

Action:
- Added PR #234 to project #7 ✓
- Updated epic #500 with PR reference ✓

Output: "✅ PR #234 linked to Project #7 and Epic #500"
```

### 4.3 ❌ INCORRECT: Links Broken or Missing

**Scenario**:
```
Setup complete for integration

Problem:
- Epic created but not in project ❌
- Project exists but no epic reference ❌
- PRs not linked to project ❌
```

---

## 5. GraphQL Operations

### 5.1 ✅ CORRECT: GraphQL Mutation Successful

**Example**:
```bash
# Add item to project
gh api graphql -f query='
mutation {
  addProjectV2ItemById(input: {
    projectId: "PVT_xxx"
    contentId: "I_xxx"
  }) {
    item {
      id
    }
  }
}'

Response:
{
  "data": {
    "addProjectV2ItemById": {
      "item": {
        "id": "PVTI_xxx"
      }
    }
  }
}
```

### 5.2 ✅ CORRECT: Error Handling for Auth

**Example**:
```
Error: INSUFFICIENT_SCOPES

Action:
1. Report: "GitHub CLI needs project scopes"
2. Provide command: "gh auth login --scopes 'repo,read:project,write:project'"
3. Exit with clear error

Output: "❌ Authentication failed. Run: gh auth login --scopes '...'"
```

### 5.3 ❌ INCORRECT: Silent GraphQL Failures

**Scenario**:
```bash
@gh-project-orchestrator Add issue #42 to project

Output: "Added to project" ✅

Reality: GraphQL returned error, item not added ❌
```

---

## 6. Large Integration Workflow

### 6.1 ✅ CORRECT: Complete Integration Setup

**Example**:
```
@gh-project-orchestrator Setup integration "Google Calendar"

Complete Orchestration:
1. ✅ Create Project: Board to track all work
2. ✅ Create Epic Issue: Master tracking issue with scope
3. ✅ Add to Project: Link epic to project
4. ✅ Create Sub-Tasks: 6 draft items in project
5. ✅ Link Dependencies: Mark task dependencies

Output:
✅ Project Created Successfully
Project: #5 - Google Calendar Integration
URL: https://github.com/OWNER/REPO/projects/5

📄 Epic Issue: #456
   Title: [Google Calendar] Integration Epic
   Scope: API, Auth, Data sync, Error handling, Documentation

✅ Tasks Created: 6
   - Setup API credentials
   - Implement calendar sync endpoint
   - Add webhook handlers
   - Create error handling
   - Write integration tests
   - Document API usage

🔗 Cross-References:
   - Epic → Project ✓
   - Tasks → Project ✓
   - Ready for PR linking
```

### 6.2 ❌ INCORRECT: Incomplete Integration Setup

**Scenario**:
```
@gh-project-orchestrator Setup integration "Google Calendar"

Output: "Integration setup complete" ✅

Reality:
- Project created but no epic ❌
- No tasks created ❌
- No cross-linking ❌
```

---

## 7. Anti-Patterns Summary

| Anti-Pattern | Impact | Fix |
|--------------|--------|-----|
| Project without structure | No tracking | Always create epic + tasks |
| Items not actually added | Think it's tracked | Verify with project view |
| Status not persisted | Wrong visibility | Check GraphQL response |
| Broken links | Can't navigate | Verify bidirectional refs |
| Silent failures | False confidence | Check all API responses |
| No error handling | Confusing failures | Provide clear error messages |

---

## 8. Checklist for GitHub Project Orchestrator

- [ ] Project created with correct title
- [ ] Project URL accessible
- [ ] Items actually added to project (verify in GitHub)
- [ ] Status updates persisted
- [ ] Epic issue created and linked
- [ ] Sub-tasks created as draft items
- [ ] Bidirectional links working
- [ ] PR auto-routing functional
- [ ] GraphQL errors handled
- [ ] Auth failures reported clearly
- [ ] Integration setup complete (project + epic + tasks)
- [ ] Progress tracking accurate
