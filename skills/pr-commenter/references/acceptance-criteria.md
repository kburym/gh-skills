# PR Commenter - Acceptance Criteria

Functional requirements, format specifications, and validation scenarios for the PR Commenter skill.

---

## Functional Requirements

### FR1: Line-Level Comment Posting

| ID | Requirement | Status |
|---|---|---|
| FR1.1 | Skill MUST post comments on specific lines of code in a PR | ✅ |
| FR1.2 | Skill MUST reference the correct file path and line number | ✅ |
| FR1.3 | Skill MUST include severity indicator (HIGH/MEDIUM/LOW) | ✅ |
| FR1.4 | Skill MUST include category label (Security/Quality/Performance/etc.) | ✅ |
| FR1.5 | Skill MUST provide both the problematic code and suggested fix | ✅ |
| FR1.6 | Skill MUST explain the impact of the issue | ✅ |

### FR2: General PR Comment Posting

| ID | Requirement | Status |
|---|---|---|
| FR2.1 | Skill MUST post comments at the PR level (not on specific lines) | ✅ |
| FR2.2 | Skill MUST support markdown formatting | ✅ |
| FR2.3 | Skill MUST support checklists for actionable items | ✅ |
| FR2.4 | Skill MUST support summary sections for batch operations | ✅ |
| FR2.5 | Skill MUST clearly indicate completion status | ✅ |

### FR3: Reply and Thread Management

| ID | Requirement | Status |
|---|---|---|
| FR3.1 | Skill MUST reply to existing comments by ID | ✅ |
| FR3.2 | Skill MUST support threaded conversations | ✅ |
| FR3.3 | Skill MUST resolve conversations when appropriate | ✅ |
| FR3.4 | Skill MUST reopen resolved conversations when replying | ✅ |
| FR3.5 | Skill MUST tag the original commenter in replies | ✅ |

### FR4: Multi-PR Coordination

| ID | Requirement | Status |
|---|---|---|
| FR4.1 | Skill MUST support posting on multiple PRs | ✅ |
| FR4.2 | Skill MUST handle parallel comment posting | ✅ |
| FR4.3 | Skill MUST generate PR-specific comment content | ✅ |
| FR4.4 | Skill MUST report status for each PR independently | ✅ |

### FR5: Integration Requirements

| ID | Requirement | Status |
|---|---|---|
| FR5.1 | Skill MUST integrate with pr-reviewer for findings | ✅ |
| FR5.2 | Skill MUST integrate with pr-feedback-handler for fix confirmations | ✅ |
| FR5.3 | Skill MUST integrate with pr-manager for batch summaries | ✅ |
| FR5.4 | Skill MUST use GitHub CLI (gh) for API calls | ✅ |

---

## Comment Format Requirements

### Line-Level Comment Format

✅ **Required Elements:**
```markdown
**[Severity: LEVEL] [Category: TYPE]** Brief title

**Location:** `filepath:line`

**Issue:** Description of the problem

**Current:**
```code
problematic code
```

**Suggested:**
```code
fixed code
```

**Impact:** Explanation of consequences
```

❌ **Invalid Format:**
```markdown
This looks wrong. Fix it.
```

### General PR Comment Format

✅ **Required Elements:**
```markdown
## Section Title

Clear description of feedback.

- [ ] Actionable item 1
- [ ] Actionable item 2

Concluding statement with next steps.
```

❌ **Invalid Format:**
```markdown
some thoughts about this pr
```

### Reply Comment Format

✅ **Required Elements:**
```markdown
@username Acknowledgment statement

**Reasoning/Changes:**
1. Specific response to point 1
2. Specific response to point 2

Closing with next steps or request.
```

❌ **Invalid Format:**
```markdown
done
```

---

## Error Handling Scenarios

### Authentication Errors

| Scenario | Error Pattern | Resolution | Status |
|---|---|---|---|
| EH1.1 | `gh auth status` returns not logged in | Run `gh auth login` | ✅ |
| EH1.2 | Token expired (401 Unauthorized) | Refresh token and retry | ✅ |
| EH1.3 | Insufficient scopes | Request additional permissions | ✅ |

### Permission Errors

| Scenario | Error Pattern | Resolution | Status |
|---|---|---|---|
| EH2.1 | Cannot comment on PR (403 Forbidden) | Verify repository access | ✅ |
| EH2.2 | Cannot resolve conversation (maintainer only) | Request maintainer action | ✅ |
| EH2.3 | Cannot post on archived PR | Reopen PR first | ✅ |

### API/Network Errors

| Scenario | Error Pattern | Resolution | Status |
|---|---|---|---|
| EH3.1 | Network timeout | Retry with exponential backoff | ✅ |
| EH3.2 | Rate limit exceeded (429) | Wait and retry after delay | ✅ |
| EH3.3 | Comment ID not found | Verify PR and comment number | ✅ |
| EH3.4 | Line reference invalid | Verify file path and line number | ✅ |

### Content Errors

| Scenario | Error Pattern | Resolution | Status |
|---|---|---|---|
| EH4.1 | Comment body empty | Reject and request content | ✅ |
| EH4.2 | Comment exceeds max length (65536 chars) | Truncate and split | ✅ |
| EH4.3 | Invalid markdown formatting | Fix formatting issues | ✅ |
| EH4.4 | Missing required severity/category | Add required metadata | ✅ |

---

## Test Scenarios

### TS1: Basic Line-Level Comment

✅ **Pass Criteria:**
- Comment appears on correct line
- Severity badge visible
- Category label visible
- Code blocks render correctly

❌ **Fail Criteria:**
- Comment posted on wrong line
- Missing severity/category
- Code blocks not formatted

### TS2: General PR Comment

✅ **Pass Criteria:**
- Comment appears in PR timeline
- Markdown renders correctly
- Checklists are interactive
- Mentions are linked

❌ **Fail Criteria:**
- Comment posted as review instead of general
- Markdown not parsed
- Checklists rendered as plain text

### TS3: Reply to Comment

✅ **Pass Criteria:**
- Reply appears in correct thread
- Original commenter is tagged
- Thread context maintained
- Reply resolves or continues thread appropriately

❌ **Fail Criteria:**
- Reply posted as new comment
- Thread context lost
- Cannot find original comment

### TS4: Thread Resolution

✅ **Pass Criteria:**
- Conversation marked resolved
- UI reflects resolved state
- Cannot resolve already resolved thread
- Can reopen if needed

❌ **Fail Criteria:**
- Conversation not marked resolved
- UI state inconsistent
- Error on double-resolve

### TS5: Multi-PR Posting

✅ **Pass Criteria:**
- Comments posted on all specified PRs
- Each PR receives correct content
- Status reported for each PR
- No cross-contamination between PRs

❌ **Fail Criteria:**
- Only some PRs receive comments
- Wrong content on wrong PR
- Status missing for some PRs

### TS6: Error Recovery

✅ **Pass Criteria:**
- Auth errors prompt login instructions
- Network errors trigger retry logic
- Rate limits handled gracefully
- User receives clear error messages

❌ **Fail Criteria:**
- Silent failures
- Infinite retry loops
- Cryptic error messages
- No recovery path provided

### TS7: Integration Scenarios

✅ **Pass Criteria:**
- pr-reviewer findings posted correctly
- pr-feedback-handler confirmations posted correctly
- pr-manager batch summaries posted correctly
- All integrations use correct templates

❌ **Fail Criteria:**
- Wrong template used for agent
- Missing integration context
- Format incompatible with agent output

---

## Validation Checklist

### Pre-Execution

- [ ] PR number is valid integer
- [ ] Repository is accessible
- [ ] GitHub CLI is authenticated
- [ ] Comment type is specified
- [ ] Comment content is non-empty

### Post-Execution

- [ ] Comment successfully posted
- [ ] Comment appears in correct location
- [ ] Formatting renders correctly
- [ ] Status reported accurately
- [ ] Thread state updated (if applicable)

### Error Validation

- [ ] Error message is descriptive
- [ ] Recovery steps are provided
- [ ] Retry logic executed when appropriate
- [ ] User notified of failure
