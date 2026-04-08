# Phase 1 — Product Alignment

---

## Interactive questioning

**Use `AskUserQuestion` for all user-facing questions in this phase.** Structure choices as selectable options wherever possible. Use `multiSelect: true` when the user can pick multiple items (e.g., features, constraints). Always include an "Other" option implicitly (the tool adds it automatically). Batch related questions into a single `AskUserQuestion` call (up to 4 questions per call).

---

## Situation A: User provides a PRD or requirements document

**Goal: clarify only what is ambiguous, do not rewrite the user's document.**

1. Read the user's document carefully
2. Check against the minimum threshold — only proceed to Phase 2 if **all three** are met:
   - [ ] Core features are listed (not just goals)
   - [ ] At least one user scenario or usage context is described
   - [ ] Technical constraints or exclusions are mentioned
3. If the threshold is not met, use `AskUserQuestion` to clarify (up to 4 questions per call), filtered by engineering impact:
   - Different schema → ask
   - Different UI flow → ask
   - Module existence uncertainty → ask
   - Tech stack selection → ask
   - Wording preference / color / copy → do NOT ask
   
   For each question, provide concrete options inferred from the document or common patterns. Example:
   - header: "Auth method", options: `["JWT with refresh tokens", "Session-based", "OAuth2 / SSO", "None"]`
   - header: "Database", options: `["PostgreSQL", "MySQL", "SQLite", "MongoDB"]`

4. After the user answers, output a **confirmation summary** (3–5 bullet points, your own words), then use `AskUserQuestion` for final confirmation:
   - header: "Scope", question: "Does this summary look correct?", options: `["Yes, proceed to Phase 2", "Needs changes"]`

---

## Situation B: User provides no document

**Goal: generate a PRD in at most 2 rounds of structured questions.**

**Round 1 — use `AskUserQuestion` with up to 4 questions:**
- header: "Problem", question: "What problem does this solve, and who uses it?"
  - Provide common app type options if inferable (e.g., `["Internal tool", "Consumer web app", "API / backend service", "Mobile app"]`)
- header: "Features", question: "What are the most important features?", `multiSelect: true`
  - Provide feature options inferred from the user's description
- header: "Tech stack", question: "Any tech stack preferences?"
  - Provide common options (e.g., `["Python + FastAPI", "Node + Express", "Next.js full-stack", "Go"]`)
- header: "Out of scope", question: "Anything explicitly out of scope?", `multiSelect: true`
  - Provide common exclusions (e.g., `["Mobile app", "Admin dashboard", "Payment processing", "Real-time / websockets"]`)

**Round 2 — only if Round 1 answers are still ambiguous (use `AskUserQuestion`, max 4 questions, strictly necessary).**

After Round 2, output the PRD:

```
## Project Name
## Goal (one sentence)
## Users & Scenarios
## Core Feature List (each independently developable)
## Out of Scope
## Success Criteria
## Technical Constraints
```

4. Use `AskUserQuestion` for final confirmation:
   - header: "PRD", question: "Does this PRD capture your requirements?", options: `["Yes, proceed to Phase 2", "Needs changes"]`
   - **Only enter Phase 2 on explicit confirmation.**

---

## Prohibited behaviors

- Do not enter development before the user confirms scope
- Do not assume any unclear requirements
- Do not rewrite or "improve" the user's existing PRD — only clarify ambiguities
