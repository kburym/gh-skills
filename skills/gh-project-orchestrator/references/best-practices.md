# GitHub Project Orchestrator Best Practices

Best practices for managing GitHub Projects V2 for large integrations.

---

## 1. Project Structure

### Standard Integration Project

**Required Components**:
1. **Project Board** - GitHub Project V2
2. **Epic Issue** - Master tracking issue
3. **Sub-Tasks** - Draft items or linked issues
4. **Cross-References** - Bidirectional links

**Project Fields**:
| Field | Type | Options |
|-------|------|---------|
| Status | Single Select | Todo, In Progress, Review, Done |
| Priority | Single Select | P0, P1, P2, P3 |
| Type | Single Select | Epic, Task, Bug, PR |
| Assignee | User | Team members |

### Project Naming

**Format**: `[Integration Name] Integration`

**Examples**:
- ✅ `Stripe Payment Integration`
- ✅ `Google Calendar Integration`
- ✅ `QuickBooks Integration`

**Avoid**:
- ❌ `Integration` (too vague)
- ❌ `Payment` (could be confused with feature)
- ❌ `Calendar Stuff` (unprofessional)

---

## 2. Epic Issue Structure

### Epic Template

```markdown
## Overview
Master tracking issue for [Integration Name] implementation.

## Scope
- [ ] Component 1
- [ ] Component 2
- [ ] Component 3
- [ ] Error handling
- [ ] Documentation

## Project
- Project Board: [URL]
- Project #: [Number]

## Related Issues
- List as tasks are created

## Related PRs
- List as PRs are created
```

### Epic Labels

Always add:
- `epic` - Identifies as epic issue
- `integration` - Identifies as integration work
- Priority label (P0/P1/P2) - Based on importance

---

## 3. Sub-Task Breakdown

### Task Granularity

**Good** (1-2 day tasks):
- Setup API credentials
- Implement auth endpoint
- Add webhook handler

**Bad** (too large):
- Build entire integration ❌
- Handle all errors ❌
- Write all documentation ❌

### Standard Task List

For most integrations:
1. **Setup/Configuration**
   - API credentials
   - Environment setup
   - Dependencies

2. **Core Implementation** (3-5 tasks)
   - Authentication flow
   - Main API endpoints
   - Data sync logic

3. **Supporting Work**
   - Error handling
   - Logging/monitoring
   - Rate limiting

4. **Testing**
   - Unit tests
   - Integration tests
   - End-to-end tests

5. **Documentation**
   - API docs
   - Developer guide
   - Runbook

---

## 4. Auto-Routing Rules

### Keyword-Based Routing

```bash
# Detect project by keywords in title/body
route_by_keywords() {
  local content="$1"
  local pr_number="$2"
  
  if echo "$content" | grep -qiE "(payment|stripe|billing)"; then
    project="Stripe Payment Integration"
  elif echo "$content" | grep -qiE "(calendar|google|sync)"; then
    project="Google Calendar Integration"
  elif echo "$content" | grep -qiE "(quickbooks|accounting)"; then
    project="QuickBooks Integration"
  elif echo "$content" | grep -qiE "(location|geo)"; then
    project="Location Management"
  fi
  
  if [ -n "$project" ]; then
    @gh-project-orchestrator Link PR #$pr_number to project "$project"
  fi
}
```

### Label-Based Routing

```bash
# Route by labels
route_by_labels() {
  local labels="$1"
  local issue_number="$2"
  
  if echo "$labels" | grep -q "integration"; then
    # Find matching integration project
    @gh-project-orchestrator Add issue #$issue_number to integration project
  elif echo "$labels" | grep -q "bug"; then
    @gh-project-orchestrator Add issue #$issue_number to "Bug Triage" project
  fi
}
```

---

## 5. Cross-Linking Strategy

### Bidirectional Links

**Required Links**:
1. Epic → Project (in epic body)
2. Project → Epic (epic added as item)
3. Tasks → Project (all tasks in project)
4. PRs → Project (PRs added as items)
5. PRs → Epic (PRs referenced in epic)

**Example Structure**:
```
Epic #500
├── References Project #5 in body
├── Lists all Tasks
├── Lists all PRs
└── Is an item in Project #5

Project #5
├── Contains Epic #500 as item
├── Contains all Tasks as items
└── Contains all PRs as items
```

---

## 6. Status Workflow

### Standard Flow

```
Todo → In Progress → Review → Done
```

**Status Definitions**:
- **Todo**: Ready to start, not assigned
- **In Progress**: Actively being worked
- **Review**: PR created, needs review
- **Done**: Merged/completed

### Auto-Status Updates

```bash
# When PR created → Move to Review
@gh-project-orchestrator Set item to "Review" when PR linked

# When PR merged → Move to Done
@gh-project-orchestrator Set item to "Done" when PR merged
```

---

## 7. Progress Tracking

### Progress Calculation

```bash
# Calculate completion percentage
calculate_progress() {
  local project_id="$1"
  local owner="$2"
  
  items=$(gh project item-list "$project_id" --owner "$owner" --format json)
  total=$(echo "$items" | jq '.items | length')
  done=$(echo "$items" | jq '[.items[] | select(.status == "Done")] | length')
  
  percent=$((done * 100 / total))
  
  echo "Progress: $percent% ($done/$total items complete)"
}
```

### Weekly Reports

```bash
#!/bin/bash
# weekly-project-report.sh

projects=(
  "Google Calendar Integration"
  "Stripe Payment Integration"
  "QuickBooks Integration"
)

echo "Weekly Project Status Report"
echo "============================"

for project in "${projects[@]}"; do
  echo ""
  echo "Project: $project"
  @gh-project-orchestrator Show status for project "$project"
done
```

---

## 8. Error Handling

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| INSUFFICIENT_SCOPES | Missing project scopes | Re-auth with `--scopes 'repo,read:project,write:project'` |
| Project not found | Wrong project number | List projects with `@gh-project-orchestrator List all projects` |
| Item not added | Wrong content ID | Verify issue/PR exists |
| Status not updated | Wrong field ID | List project fields first |

### Rate Limiting

```bash
# Check rate limit
gh api rate_limit --jq '.resources.graphql'

# Add delays for bulk operations
sleep 1  # Between requests
```

---

## 9. Integration Best Practices

### With pr-manager

```
pr-manager uses project priority for orchestration:
1. Get prioritized items from project
2. Review high priority PRs first
3. Update project status after merge
```

### With issue-to-pr

```
issue-to-pr creates issues/PRs and links to projects:
1. Create epic issue
2. Create project
3. Link epic to project
4. As PRs created, auto-link to project
```

### With gh-prioritizer

```
gh-prioritizer sets priority on project items:
1. PR added to project
2. Auto-detect priority
3. Set Priority field
4. pr-manager uses priority for queue
```

---

## 10. Common Mistakes

### Mistake 1: Project Without Epic

**Problem**: Project exists but no master tracking issue

**Impact**: No single source of truth for scope

**Fix**: Always create epic issue with project

### Mistake 2: Tasks Too Large

**Problem**: Single task for entire integration

**Impact**: Can't track progress, overwhelming

**Fix**: Break into 1-2 day tasks

### Mistake 3: No Cross-Linking

**Problem**: Epic doesn't reference project, project doesn't show epic

**Impact**: Can't navigate between them

**Fix**: Always create bidirectional links

### Mistake 4: Forgetting PR Links

**Problem**: PRs merged but not in project

**Impact**: Progress appears incomplete

**Fix**: Auto-route PRs to projects by keywords

---

## 11. Project Templates

### Integration Project Template

**Fields**:
- Status: Todo, In Progress, Review, Done
- Priority: P0, P1, P2, P3
- Type: Epic, Task, Bug, PR
- Size: XS, S, M, L, XL
- Assignee: [team member]

**Default Items**:
1. Epic (master tracker)
2. Setup task
3. 3-5 implementation tasks
4. Testing task
5. Documentation task

### Bug Triage Project Template

**Fields**:
- Status: New, Triaged, In Progress, Testing, Fixed
- Severity: Low, Medium, High, Critical
- Component: Frontend, Backend, API, Database
- Reporter: [username]

**View Filters**:
- By Status
- By Severity
- By Component
