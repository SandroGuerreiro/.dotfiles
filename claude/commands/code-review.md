# Code Review

Comprehensive security and quality review of code changes using multi-agent analysis.

**HARD RULE: NEVER post comments on GitHub. No `gh pr comment`, no inline comments, no `mcp__github_inline_comment__create_inline_comment`. All output stays in the terminal.**

## Input Detection

- **No arguments**: Review local uncommitted changes (`git diff HEAD`)
- **PR number** (e.g. `123`): Review pull request via `gh pr diff 123`
- **PR URL** (e.g. `https://github.com/owner/repo/pull/123`): Extract PR number from URL, review via `gh pr diff`

## Steps

### 1. Get the diff

- **Local mode**: `git diff --name-only HEAD` to list changed files, `git diff HEAD` for full diff
- **PR mode**: `gh pr view <PR> --json state,isDraft,title,body` + `gh pr diff <PR>`

If in PR mode, check eligibility first:
- Skip if PR is closed or is a draft
- Skip if it's an automated PR that is trivially correct
- Still review Claude-generated PRs

### 2. Gather CLAUDE.md files (Haiku agent)

Return file paths (not contents) of relevant CLAUDE.md files:
- Root CLAUDE.md if it exists
- Any CLAUDE.md files in directories containing modified files

### 3. PR-only: Summary and previous comments (Haiku agents, parallel)

Only when reviewing a PR, launch 2 Haiku agents in parallel:
- **Agent A**: Return a summary of the PR (title, description, intent)
- **Agent B**: Read previous PRs that touched these files (`gh pr list --state merged`), check for comments that may also apply to the current PR

### 4. Parallel review agents

Launch 4 agents in parallel. Each returns a list of issues with description and reason flagged.

**Agent 1 + 2: CLAUDE.md compliance (Sonnet agents)**
Audit changes for CLAUDE.md compliance in parallel. Only consider CLAUDE.md files scoped to the file or its parents.

**Agent 3: Bug and security scan (Opus agent)**
Scan the diff for:

*Security Issues (CRITICAL):*
- Hardcoded credentials, API keys, tokens
- SQL injection vulnerabilities
- XSS vulnerabilities
- Missing input validation
- Insecure dependencies
- Path traversal risks

*Bug Detection:*
- Clear logic errors that will produce wrong results
- Syntax errors, type errors, missing imports, unresolved references
- Code that will fail to compile or parse

Focus only on the diff. Do not read extra context beyond the changes.

**Agent 4: Code quality and patterns (Opus agent)**
Scan the diff for:

*Code Quality (HIGH):*
- Functions > 50 lines
- Files > 800 lines
- Nesting depth > 4 levels
- Missing error handling
- console.log / debug statements left in
- TODO/FIXME comments

*Best Practices (MEDIUM):*
- Mutation patterns (should use immutable)
- Missing tests for new code
- Accessibility issues (a11y)

Provide the PR title/description (if PR mode) or commit context (if local mode) to all agents so they understand the author's intent.

### 5. Validate each issue (parallel subagents)

For each issue found in step 4, launch a validation subagent:
- **Opus subagents** for bugs and security issues
- **Sonnet subagents** for CLAUDE.md violations and code quality

Each validator receives the issue description and relevant context. Their job is to confirm the issue is real with high confidence. For CLAUDE.md issues, verify the rule is scoped to the file and is actually violated.

**Consumption-path validation (mandatory):** For any issue about "missing X" (missing export, missing type, missing test, missing import), the validator MUST trace how the thing is actually consumed downstream. If the absence doesn't break any consumer — e.g. types are inferred from a registry, schemas are resolved at runtime, imports are re-exported elsewhere — the issue is invalid. Never flag something as missing based solely on what neighbouring code does (pattern-matching). Verify the actual consumption path.

### 6. Filter

Remove any issues that failed validation. Only keep high-signal confirmed issues.

**Do NOT flag (false positives):**
- Pre-existing issues not introduced by this change
- Something that looks like a bug but is correct
- Pedantic nitpicks a senior engineer wouldn't flag
- Issues a linter, typechecker, or compiler would catch
- General code quality concerns unless explicitly required in CLAUDE.md
- Issues silenced in code (e.g. lint ignore comments)
- Intentional functionality changes related to the broader change
- Issues on lines not modified in this change
- "Missing" exports/types/tests where the thing is consumed through a different mechanism (e.g. type inferred from a schema registry, re-exported elsewhere). Trace the consumption path before flagging.

### 7. Output report

**MANDATORY FORMAT: You MUST output results as a markdown table. No exceptions. Do not use bullet lists, numbered lists, or prose. Always a table.**

If reviewing a PR, start with:

**PR #123**: <title> - <one-line summary of intent>

If previous PR comments were found (step 3), add:

**Recurring feedback from previous PRs:**
- <comment summary> (from PR #<N>)

Then output the results table:

## Code Review Results

| Severity | File:Line | Issue | Suggested Fix |
|----------|-----------|-------|---------------|
| CRITICAL | src/auth.ts:42 | Hardcoded API key | Move to env variable |
| HIGH | src/utils.ts:15-89 | Function exceeds 50 lines | Extract helper functions |
| MEDIUM | src/api.ts:23 | Mutation of input parameter | Return new object instead |

Every issue MUST be a row in this table. Do not explain issues outside the table. The table IS the report.

If no issues found, output:

## Code Review Results

No issues found. Checked for security vulnerabilities, bugs, CLAUDE.md compliance, and code quality.

**REMINDER: Output to terminal ONLY. Never post to GitHub. Never use gh pr comment. Never use inline comment tools.**
