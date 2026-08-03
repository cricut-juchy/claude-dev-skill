# Debugging Discipline

Used by Worker Agents on any bug fix (`worker-fix.md`) and by the Tech Lead when triaging failures.
Core rule: **no fix without a feedback loop and a root cause.** Symptom patches are failure.

---

## Phase 1 — Build a feedback loop first

This is the skill; everything after it is mechanical. Before reading code to build a theory, construct **one command** that goes red on this exact bug and green when it is fixed.

Try in roughly this order: failing test at whatever seam reaches the bug → curl/HTTP script against a dev server → CLI invocation diffed against known-good output → headless browser script → replay of a captured payload/trace → throwaway harness (one service, mocked deps) → bisection harness (`git bisect run`) if the bug appeared between two known states.

The loop is done when it is:
- **Red-capable** — asserts the user's exact symptom, not "runs without erroring"
- **Deterministic** — same verdict every run (flaky bugs: loop the trigger, add stress, inject sleeps to raise the reproduction rate until it's debuggable)
- **Fast** — seconds, not minutes
- **Agent-runnable** — you can run it unattended

You must have **run it at least once and watched it go red** before proceeding. If you genuinely cannot build a loop, stop and say so on the Issue: list what you tried and what you need (environment access, a captured artifact, permission to instrument). Do not hypothesize without a loop.

## Phase 2 — Reproduce and minimise

Confirm the loop reproduces the failure mode **the reporter described** — not a nearby different failure. Then shrink the repro: cut inputs, callers, config, and steps one at a time, re-running after each cut, until every remaining element is load-bearing. The minimal repro shrinks the hypothesis space and becomes the regression test.

## Phase 3 — Root cause investigation

- **Read the error completely.** Full stack trace, line numbers, error codes — the answer is often in it.
- **Check recent changes.** Git diff, recent commits, new dependencies, config drift.
- **In multi-component systems**, log what enters and exits each component boundary, run once, and let the evidence show WHERE it breaks before theorizing about why.
- **Compare against working examples.** Find similar working code in the same codebase and list every difference — don't assume "that can't matter."
- **Trace bad values backward** to their origin. Fix at the source, not where the symptom surfaced.

## Phase 4 — Hypothesise and test

Generate **3–5 ranked, falsifiable hypotheses** before testing any — single-hypothesis debugging anchors on the first plausible idea. Each must state its prediction: "If X is the cause, changing Y makes the bug disappear."

Post the ranked list as an Issue comment before testing — the Tech Lead or user often re-ranks it instantly ("we just deployed a change to #3"). Don't block on a reply; proceed with your ranking.

Then test **one hypothesis at a time, one variable at a time**, with the smallest possible change. Prefer a debugger/REPL breakpoint over logs; if logging, tag every debug line with a unique prefix (e.g. `[DEBUG-a4f2]`) so cleanup is a single grep. Never "log everything and grep".

**Performance bugs:** logs are usually the wrong tool. Establish a baseline measurement (timing harness, profiler, query plan) first, then bisect. Measure before fixing.

## Phase 5 — Fix with a regression test

1. Turn the minimised repro into a failing test at a seam that exercises the real bug pattern. If no honest seam exists, say so in the PR — a regression test at a too-shallow seam gives false confidence, and the missing seam is itself a finding.
2. Watch it fail. Apply the fix — one change, no "while I'm here" improvements. Watch it pass.
3. Re-run the Phase 1 loop against the original, un-minimised scenario.

## The three-strikes rule

If a fix doesn't work, return to Phase 3 with the new information — don't stack another fix on top. After **3 failed fix attempts, stop**: each fix revealing a new problem in a different place means the architecture is wrong, not the hypothesis. Comment on the Issue and escalate to the Tech Lead before attempting fix #4.

## Cleanup before the PR

- [ ] Phase 1 loop re-run green against the original scenario
- [ ] Regression test in place (or the missing-seam finding documented)
- [ ] All `[DEBUG-...]` instrumentation removed (grep the prefix)
- [ ] The confirmed root cause stated in the PR body — the next debugger learns from it

## Red flags — stop and restart at Phase 1

"Quick fix for now, investigate later" · "Just try changing X and see" · "It's probably X" · proposing fixes before tracing data flow · changing multiple things at once · reading code for a theory before a red loop exists · "one more fix attempt" after two failures.
