# Grilling — Requirements Interviewing & Domain Modeling

Used in Phase 1 (Product Alignment) and Phase 2 (Architecture Decision Checkpoint).
Goal: reach a genuine shared understanding before any Issue is written — not a polite nod.

---

## Facts vs Decisions (the core rule)

- **Facts** — anything discoverable from the environment (filesystem, code, git history, existing configs, installed dependencies): **look it up yourself, never ask the user**.
- **Decisions** — trade-offs only the user can make (scope, priorities, UX behavior, tech preferences): **put every one to the user and wait for the answer**.

Asking the user for facts wastes their time and erodes trust. Deciding for the user creates rework.

## Question mechanics

- Use `AskUserQuestion` with structured options. For every question, your recommended answer is the **first option marked "(Recommended)"** with your reasoning in the description.
- **Batch only independent questions** (up to 4 per call). When decision B depends on the answer to decision A, ask A first and let the answer shape B — walk the decision tree branch by branch instead of firing a flat questionnaire.
- Filter by engineering impact: different schema / UI flow / module boundary / tech stack → ask. Wording, colors, copy → do not ask.

## Sharpen the domain language while you interview

Vague terms in requirements become bugs in code. During any requirements or architecture conversation:

1. **Sharpen fuzzy terms.** When the user says an overloaded word ("account", "job", "sync"), propose a precise canonical term: "You said 'account' — do you mean the Customer or the User? Those are different things."
2. **Challenge contradictions.** If a term is used in a way that conflicts with how `PROJECT_CONTEXT.md` defines it, call it out immediately and resolve which meaning wins.
3. **Stress-test with concrete scenarios.** When domain relationships come up, invent edge-case scenarios that force precision: "A customer cancels after partial shipment — is that a Cancellation or a Return in your model?"
4. **Cross-check claims against code.** When the user states how something currently works, verify it in the code. If the code disagrees, surface the contradiction instead of silently picking a side.

## Record what crystallizes

- Resolved terms go into the **Domain Glossary** section of `PROJECT_CONTEXT.md` the moment they are settled — do not batch them for later. The glossary holds terminology only, never implementation details.
- Record a decision in **Architecture Decisions** (with a one-line "why") when all three are true:
  1. **Hard to reverse** — changing it later has real cost
  2. **Surprising without context** — a future reader would ask "why did they do it this way?"
  3. **A real trade-off** — genuine alternatives existed and one was chosen for specific reasons
  If any of the three is missing, don't clutter the record.

## Exit condition

Do not leave the grilling loop until you can restate the requirement in your own words, the user has explicitly confirmed the restatement, and every decision that affects interface design has an answer (or a recorded assumption). Shared understanding is confirmed — not assumed.
