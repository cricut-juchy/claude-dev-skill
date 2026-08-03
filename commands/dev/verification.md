# Verification — Evidence Before Claims

Used by Worker Agents (before every PR) and QA Agents (before every verdict).
Core rule: **no completion claims without fresh verification evidence.**

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this same working session and read its output, you cannot claim it passes.

## The gate

Before claiming any status (in a PR body, Issue comment, or QA report):

1. **IDENTIFY** — what command proves this claim?
2. **RUN** — execute the full command, fresh (not a cached or earlier run)
3. **READ** — full output, exit code, failure count
4. **VERIFY** — does the output actually confirm the claim? If no, state the real status with evidence. If yes, state the claim **with the evidence attached**.

## What each claim requires

| Claim | Requires | Not sufficient |
|---|---|---|
| Tests pass | Fresh test run output: 0 failures | Previous run, "should pass" |
| Build succeeds | Build command: exit 0 | Linter passing, logs look fine |
| Bug fixed | Original symptom's repro now passes | Code changed, assumed fixed |
| Regression test works | **Red-green verified**: test passes → revert the fix → test FAILS → restore → passes | Test passing once |
| Acceptance criterion met | `[trigger] → [observed behavior]` traced or executed | "Implemented as described" |
| Delegated work done | Diff inspected, changes verified | The agent's own success report |

## Red flags — stop and run the command

"Should", "probably", "seems to" · expressing satisfaction ("Done!", "Perfect!") before verifying · committing or opening a PR without a fresh run · trusting a prior run after new edits · partial verification extrapolated to the whole ("the linter passed so the build is fine").

## In this SOP specifically

- **Workers**: attach the full verification output to the PR body — never just "tests passed". If there's no test framework, the verification script's per-criterion output (`[AC1] ... ✓ PASS`) is the evidence.
- **QA Agents**: label every conclusion as *test execution* (actually ran) or *code analysis* (read statically), and never present the latter as the former.
- **Tech Lead**: a Worker or QA report of success is a claim, not evidence — spot-check the diff and output before merging.
