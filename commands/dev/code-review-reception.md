# Receiving Review Feedback

Used by Worker Agents after a REQUEST CHANGES rating or a QA "Needs Fix" report.
Core rule: **verify before implementing; technical correctness over social comfort.**

---

## The response pattern

1. **READ** the complete feedback without reacting
2. **UNDERSTAND** — restate each item as a technical requirement in your own words
3. **VERIFY** — check each claim against the actual codebase before touching anything
4. **EVALUATE** — is the suggestion technically sound for THIS codebase?
5. **RESPOND** — technical acknowledgment, clarifying question, or reasoned pushback
6. **IMPLEMENT** — one item at a time, testing each

## Unclear items block everything

If any feedback item is unclear, do not implement the clear ones first — items are often related, and partial understanding produces wrong implementations. Reply on the PR listing what you understood and what needs clarification (consistent with the SOP's max-1-round rule: if no reply comes, record your interpretation as an assumption and proceed).

## Verify before implementing

Before acting on any suggestion:
- Is it technically correct for this codebase and stack?
- Would it break existing functionality? (Check callers, run the relevant tests.)
- Is there a reason the current implementation is the way it is? (Legacy constraint, platform compat, recorded decision in `PROJECT_CONTEXT.md`.)
- **YAGNI check**: if asked to "implement X properly," grep for actual usage first. If nothing calls it, propose removal instead of gold-plating.

If a suggestion conflicts with an architecture decision in `PROJECT_CONTEXT.md`, stop and raise it on the PR — don't silently override a recorded decision.

## Push back when warranted — with evidence

Push back when the suggestion breaks existing functionality, the reviewer lacks context, it violates YAGNI, or it's technically wrong for this stack. Use technical reasoning and reference specific code, tests, or decisions — never defensiveness. If you can't verify a claim, say so plainly: "I can't verify this without X — investigate, or proceed as suggested?"

If you pushed back and were wrong, state the correction factually and move on: "Verified — you're correct, my understanding of X was wrong. Fixing." No long apology, no defense of the original pushback.

## No performative agreement

Never reply "You're absolutely right!", "Great point!", or any gratitude filler. When feedback is correct, the fix itself is the acknowledgment:

- ✅ "Fixed — [what changed, where]."
- ✅ "Good catch: [specific issue]. Fixed in [file]."
- ❌ "You're absolutely right! Thanks for catching that!"

## Implementation order

1. Clarify anything unclear (see above)
2. Blocking issues first (breakage, security)
3. Simple fixes (typos, imports)
4. Complex fixes (refactoring, logic)
5. Test each fix individually; run the full suite before re-requesting review

Reply to inline review comments in their thread (`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`), not as top-level PR comments, so the reviewer can resolve each conversation.
