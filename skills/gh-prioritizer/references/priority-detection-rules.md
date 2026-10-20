# Priority Detection Rules

Detailed reference for priority detection algorithms and rule definitions.

---

## Detection Logic

```javascript
const priorityRules = {
  "P0-Critical": [
    // Regex patterns in title/body
    /critical|urgent|hotfix|security|data loss|production down|outage|blocking|emergency/i,
    
    // Label-based detection
    label => ["hotfix", "critical", "security", "production-down"].includes(label),
    
    // File path detection (security-critical files)
    files => files.some(f => 
      f.includes("auth") || 
      f.includes("payment") || 
      f.includes("security") ||
      f.includes("encryption") ||
      f.includes("credential")
    ),
    
    // Branch name detection
    branch => /^hotfix\//.test(branch),
    
    // Impact labels
    labels => labels.includes("impact/production") || labels.includes("impact/security")
  ],
  
  "P1-High": [
    /bug|fix|user-facing|error|404|500|crash|broken|not working/i,
    
    label => ["bug", "feature", "OKR", "user-facing"].includes(label),
    
    files => files.some(f => 
      f.includes("api") || 
      f.includes("auth") || 
      f.includes("payment") ||
      f.includes("frontend")
    ),
    
    // Large PRs need priority review
    size => size > 500,
    
    // Status indicators
    labels => labels.includes("status/blocked") || labels.includes("impact/users")
  ],
  
  "P2-Medium": [
    /enhancement|improve|refactor|update|optimize|feature/i,
    
    label => ["enhancement", "refactor", "performance"].includes(label),
    
    files => files.some(f => 
      f.includes("service") || 
      f.includes("api") || 
      f.includes("backend")
    ),
    
    size => size >= 100 && size <= 500,
    
    labels => labels.includes("type/feature") && !labels.includes("impact/users")
  ],
  
  "P3-Low": [
    /docs|documentation|test|chore|style|typo|readme/i,
    
    label => ["documentation", "testing", "dependencies", "chore"].includes(label),
    
    files => files.some(f => 
      f.includes(".md") || 
      f.includes("test") || 
      f.includes("spec") ||
      f.includes("__tests__")
    ),
    
    size => size < 100,
    
    // Small PRs with only doc/test changes
    (files, labels) => size < 100 && 
      (labels.includes("documentation") || files.every(f => f.includes("test")))
  ]
}
```

---

## Priority Override Rules

### Standard Overrides

```javascript
// Priority ranking (highest to lowest)
const priorityRank = {
  "P0-Critical": 4,
  "P1-High": 3,
  "P2-Medium": 2,
  "P3-Low": 1
}

// Override logic
function determinePriority(title, body, labels, files, size, branch) {
  // Special overrides first
  if (labels.includes("DO-NOT-MERGE")) return null;      // Skip
  if (labels.includes("WIP")) return "P3-Low";          // Work in progress
  if (branch && branch.startsWith("hotfix/")) return "P0-Critical";  // Always hotfix
  if (labels.includes("security")) return "P0-Critical"; // Always security
  
  // Check all rules
  let detectedPriority = null;
  let highestRank = 0;
  
  for (const [priority, rules] of Object.entries(priorityRules)) {
    const rank = priorityRank[priority];
    
    for (const rule of rules) {
      let matches = false;
      
      if (rule instanceof RegExp) {
        matches = rule.test(title) || rule.test(body);
      } else if (typeof rule === "function") {
        if (rule.length === 1) {
          matches = labels.some(label => rule(label)) || 
                    files.some(file => rule(file)) ||
                    rule(size) ||
                    (branch && rule(branch));
        } else {
          matches = rule(files, labels);
        }
      }
      
      if (matches && rank > highestRank) {
        highestRank = rank;
        detectedPriority = priority;
      }
    }
  }
  
  return detectedPriority || "P2-Medium";  // Default
}
```

---

## Size Thresholds

```javascript
const SIZE_THRESHOLDS = {
  XS: 50,
  S: 100,
  M: 300,
  L: 500,
  XL: Infinity
}

function getSizeLabel(size) {
  if (size < 50) return "XS";
  if (size < 100) return "S";
  if (size < 300) return "M";
  if (size < 500) return "L";
  return "XL";
}

// Size calculation
function calculateSize(prData) {
  return prData.additions + prData.deletions;
}
```

---

## Critical File Patterns

```javascript
const CRITICAL_PATHS = [
  "**/auth/**",
  "**/authentication/**",
  "**/payment/**",
  "**/billing/**",
  "**/security/**",
  "**/encryption/**",
  "**/credential/**",
  "**/token/**"
]

const USER_FACING_PATHS = [
  "**/api/**",
  "**/auth/**",
  "**/payment/**",
  "**/frontend/**",
  "**/*.tsx",
  "**/*.jsx"
]

function matchesCriticalPath(files) {
  return files.some(file => 
    CRITICAL_PATHS.some(pattern => 
      minimatch(file, pattern)
    )
  )
}
```

---

## Priority Constants

```javascript
const PRIORITIES = {
  P0_CRITICAL: {
    name: "P0-Critical",
    color: "#B60205",  // Red
    description: "Production blocker, security issue, hotfix",
    sla: "4 hours"
  },
  P1_HIGH: {
    name: "P1-High",
    color: "#D93F0B",  // Orange
    description: "User-facing bug, major feature, OKR",
    sla: "1-2 days"
  },
  P2_MEDIUM: {
    name: "P2-Medium",
    color: "#FBCA04",  // Yellow
    description: "Enhancement, non-blocking feature",
    sla: "1 week"
  },
  P3_LOW: {
    name: "P3-Low",
    color: "#0E8A16",  // Green
    description: "Documentation, testing, tech debt",
    sla: "As convenient"
  }
}
```
