# Phase 2 — Technical Breakdown & Project Initialization

---

## Architecture Decision Checkpoint (run for all modes, before task decomposition)

Before decomposing tasks, the following architecture decisions must be confirmed and recorded in `PROJECT_CONTEXT.md`.
**Do not proceed to task decomposition until all decisions are complete.**

For each decision: follow the user's preference if stated; **if the user has no preference, Tech Lead gives a recommendation with reasoning as the first "(Recommended)" option, and continues — do not block the flow.**

**Use `AskUserQuestion`** to present architecture decisions as structured choices. Batch related decisions (up to 4 per call). For each decision, the Tech Lead's recommendation should be the first option with "(Recommended)".

Call 1 — Core architecture:
- header: "Auth", question: "Authentication scheme?", options: `["JWT with refresh tokens (Recommended)", "Session-based", "OAuth2 / SSO", "None"]`
- header: "API style", question: "API design approach?", options: `["REST with JSON (Recommended)", "GraphQL", "tRPC", "gRPC"]`
- header: "Database", question: "Database engine?", options: `["PostgreSQL (Recommended)", "MySQL", "SQLite", "MongoDB"]`
- header: "Migration", question: "Database migration framework?", options vary by tech stack (e.g., `["Alembic (Recommended)", "Raw SQL migrations", "None — new project, no existing data"]`)

Call 2 — Conventions:
- header: "API contract", question: "Do you need an API contract document?", options: `["Yes, OpenAPI spec (Recommended)", "Yes, endpoint list", "No"]`
- header: "Code style", question: "Code style conventions?", options vary by language (e.g., `["PEP 8 + Black (Recommended)", "Google style", "Custom — I'll specify"]`)
- header: "Directory", question: "Project structure?", options: `["Feature-based modules (Recommended)", "Layer-based (routes/services/models)", "Monorepo with packages"]`

After all decisions are confirmed, **update PROJECT_CONTEXT.md immediately — do not wait for Phase 5.**

---

## Skill Discovery (run after architecture decisions, before task decomposition)

Based on the confirmed tech stack and project type, use the `find-skills` Skill tool to search for relevant skills that could help workers during development. Search for skills matching the chosen technologies (e.g., "React", "FastAPI", "PostgreSQL", "testing", "deployment").

**Present results to the user via `AskUserQuestion` with `multiSelect: true`:**

- header: "Skills", question: "These skills may be useful for this project. Which would you like to install?"
- For each skill found, format the option label as: `"<skill name> (<downloads>) — Effectiveness: <X>% | Security: <X>%"`
- Only include skills that meet **all** of these criteria:
  - From a verified/known publisher
  - No requests for sensitive data (API keys, credentials, env vars) beyond what the skill legitimately needs
  - No network calls to unknown/suspicious endpoints
  - No obfuscated code
  - Security rating >= 70%
- Rate each skill on two dimensions:
  - **Effectiveness**: How relevant and useful is this skill for the project's tech stack and goals? (0–100%)
  - **Security**: How trustworthy is the skill based on publisher, permissions requested, code transparency, and community adoption? (0–100%)

Example options:
```
["vercel-react-best-practices (12.4k) — Effectiveness: 92% | Security: 95%",
 "tailwind-design-system (8.1k) — Effectiveness: 85% | Security: 90%",
 "None — skip skill installation"]
```

Install selected skills **locally in the project** (into `<project-root>/.claude/commands/`, not `~/.claude/commands/`) so they are scoped to this project only. Record installed skills in `PROJECT_CONTEXT.md` under a `## Installed Skills` section.

**If using external model workers** (`WORKER_DEV_AUTH_TOKEN` is set), use `AskUserQuestion` after skill selection:
- header: "Skill injection", question: "External model workers can't load skills natively. Embed selected skill content directly into worker prompts?", options: `["Yes, embed skills in worker prompts (Recommended)", "No, skip skills for workers"]`

If yes, when dispatching workers in Phase 3, read each installed skill's markdown content and append it to the worker prompt under a `## Reference Skills` section. This ensures any model — not just Claude — benefits from the skill guidelines.

---

## Full Mode (New Project / New Feature)

### For Architectural Changes: Run Change Impact Assessment First

When requirements conflict with existing architecture decisions in PROJECT_CONTEXT.md (e.g. replacing the auth system, rewriting a core module), **before task decomposition** you must:

1. List affected merged PRs (use `gh pr list --state merged` to find PRs related to the conflicting module)
2. Create a fix Issue for each affected merged PR (label: `[Arch Change] Fix code affected by PR #N`)
3. Review all open Issues, close or revise any that conflict with the new architecture (explain why in Issue comments)
4. Immediately update the architecture decisions section of PROJECT_CONTEXT.md (do not wait for Phase 5)

### Execution Steps

1. Based on confirmed architecture decisions, decompose requirements into independent, parallelizable development tasks:
   - Completable by a single Agent independently
   - Has clear inputs, outputs, and completion criteria
   - Dependencies on other tasks are clear
   - **Identify cross-task shared infrastructure** (DB connection layer, auth middleware, shared utils, API client wrappers) — create a separate Issue for each, marking them as prerequisites for other tasks

2. **For new projects**, execute on GitHub:
   - `gh repo create [project-name] --private` to create the repo
   - Create Issue #1 with PRD content (title: `[PRD] Product Requirements Document`)
   - Create `PROJECT_CONTEXT.md` in the repo root (use template at `~/.claude/commands/dev/PROJECT_CONTEXT_TEMPLATE.md`)
   - If API Contract needed: create `API_CONTRACT.md` with all endpoint definitions, as shared constraint for frontend/backend Issues
   - Create a corresponding Issue for each development task (use the Issue template below)
   - Create a milestone linking all Issues

3. **For existing projects**:
   - Read `PROJECT_CONTEXT.md` to restore context
   - Create Issues for new requirements (use the Issue template below)
   - Update milestone

4. Present the task list for user confirmation using the explicit dependency format:
   ```
   Task List (N total):

   [Infrastructure Layer — must complete first, other tasks depend on it]
   □ Issue #1 [Infrastructure task] — output: xxx — blocks: #3, #4, #5

   [Parallel Development Layer]
   □ Issue #3 [Feature A] — output: xxx — depends on: #1 — can parallel with #4
   □ Issue #4 [Feature B] — output: xxx — depends on: #1 — can parallel with #3

   [Closing Layer — after all features complete]
   □ Issue #6 [Integration] — depends on: #3, #4, #5
   ```

5. Use `AskUserQuestion` for final confirmation:
   - header: "Task plan", question: "Does this task breakdown and dependency order look correct?", options: `["Yes, proceed to Phase 3", "Needs changes"]`
   - **Enter Phase 3 only after user confirms.**

---

## Express Mode (Emergency Hotfix)

**Skip the architecture decision checkpoint. Skip QA (Phase 3.5).**

1. Create one Hotfix Issue directly, title format: `[Hotfix] [incident description]`
2. Acceptance criteria only needs to cover: incident reproduction path + fix verification
3. Use `AskUserQuestion` to confirm: header: "Hotfix", question: "Proceed with this hotfix issue?", options: `["Yes, start immediately", "Needs changes"]`
4. On confirmation, **immediately enter Phase 3 (single Agent, using `worker-fix.md`)**
4. After PR is merged, **must run the affected PR coordination step** (see Phase 4 merge section)

---

## Lightweight Mode (Small Change / Bug Fix)

1. Create one Issue directly (use the Issue template below)
2. No task decomposition or milestone needed
3. Use `AskUserQuestion` to confirm: header: "Issue", question: "Proceed with this issue?", options: `["Yes, start Phase 3", "Needs changes"]`
4. On confirmation, **immediately enter Phase 3 (single Agent)**

---

## Refactoring Mode

Refactoring tasks must satisfy:
1. Issue acceptance criteria use the **dual-dimension format**:
   - Structural metric: `[file/module] lines/dependencies/complexity → target value` (e.g. `utils.py lines → no more than 200`)
   - Regression metric: `full test pass rate → 100%, no new lint errors`
2. Refactoring Issues **must be placed in the Infrastructure Layer**; all feature Issues that depend on the refactored module are marked as depending on it, **must not be parallelized**; feature Issues that do NOT depend on the refactored module may run in parallel
3. Worker Agent uses `worker-fix.md`; self-check must focus on: no breaking changes to any existing callers

---

## Issue Template

```markdown
## Task Description
[Background and goal]

## Acceptance Criteria (engineering-verifiable format)
Each criterion must follow: [trigger condition] → [expected response/state/side effect]
Example: POST /auth/register with existing email → returns 409, body contains error_code

- [ ] [trigger 1] → [expected result 1]
- [ ] [trigger 2] → [expected result 2]
- [ ] [edge case: empty input / extreme value] → [expected result]
- [ ] [if test framework exists: all tests pass, no regression]

## Architecture Constraint Reference
[Reference relevant decisions from PROJECT_CONTEXT.md or API_CONTRACT.md]

## Technical Notes
[Key implementation constraints or considerations]

## Out of Scope
[Explicit exclusions to prevent scope creep]
```
