# Phase 3 — Multi-Agent Parallel Development (Execution Rules)

---

## Execution Rules

- For parallelizable tasks, use the Agent tool to **launch multiple Worker Agents simultaneously**
- Each Worker Agent uses `isolation: "worktree"` to work in an isolated environment
- **Even with only one task, a Worker Agent must be dispatched — never write code directly in the main conversation**
- **Per-dispatch model announcement (mandatory)**: Immediately before each Worker Agent dispatch tool call (Bash subprocess for Option A, Agent tool for Option B), print a one-line banner naming the Issue, the model, and the dispatch method. Format:

  ```
  → Dispatching Issue #<N> [<title>] via <Model> (<dispatch method>)
  ```

  Example lines:
  - `→ Dispatching Issue #3 [User profile API] via MiniMax-M2.7 (subprocess, dev worker 1)`
  - `→ Dispatching Issue #4 [JWT refresh rotation] via Opus (native Agent, worktree)`
  - `→ Forced to Opus: Issue #5 [<title>] — WORKER_DEV_AUTH_TOKEN unset, fallback active`

  This banner must appear in the user-visible text channel, not only in tool arguments. The user relies on it to confirm the routing decision before the agent starts working.

- Progress reporting: **report at key milestones only**
  - Before launching: print the per-dispatch banners (one per Issue) as described above
  - After all agents are launched, output the **Task Board** (see format below) once
  - After each agent creates a PR, update the Task Board and re-output it
- Users may view the code at any time; do not proactively interrupt

## Task Board Format

Output after all agents are launched, and re-output (full board) after each PR is created. The **Model** column makes the routing decision visible for the entire agent lifecycle — keep it in every refresh:

```
## Agent Task Board

| # | Branch | Issue | Model | Status |
|---|--------|-------|-------|--------|
| 1 | feat/auth | #3 User login | Opus (native) | ⏳ In progress |
| 2 | feat/user-api | #4 User profile API | MiniMax-M2.7 (subprocess, worker 1) | ⏳ In progress |
| 3 | feat/db-schema | #5 Database schema | MiniMax-M2.7 (subprocess, worker 1) | ⏳ In progress |
```

Model column values:
- `Opus (native)` — dispatched via Option B (Agent tool, model: "opus")
- `MiniMax-M2.7 (subprocess, worker N)` — dispatched via Option A; suffix the worker index when multiple `WORKER_DEV_*` proxies are configured
- `Opus (forced fallback)` — Issue had `routing: minimax` but `WORKER_DEV_AUTH_TOKEN` was unset, so it ran on Opus

Status values:
- `⏳ In progress` — agent is running
- `✓ PR #N created` — PR submitted, waiting for review
- `❌ Blocked: [reason]` — agent encountered a blocker, Tech Lead action needed

## Dispatching Worker Agents

Select the correct prompt file based on task type, replacing `[N]` with the actual Issue number:

- New feature: read `~/.claude/commands/dev/worker-new.md`
- Fix / improvement: read `~/.claude/commands/dev/worker-fix.md`

### Dispatch Method

**Per-task routing.** Selection happens **per Issue**, driven by the `routing` field set in Phase 2 (see `phase2.md` step 2). Read the routing value from each Issue body before dispatching:

```
For each Issue in the current parallel batch:
  if Issue.routing == "minimax" and WORKER_DEV_AUTH_TOKEN is set:
      → Option A (External model proxy, below)
  elif Issue.routing == "opus":
      → Option B (Native Agent with model: "opus", below)
  elif Issue.routing == "ask":
      → Option C (Surface AskUserQuestion, below)
  elif Issue.routing == "minimax" and WORKER_DEV_AUTH_TOKEN is NOT set:
      → fall back to Option B with a one-line note in the launch summary
        ("MiniMax routed task forced to Opus — WORKER_DEV_AUTH_TOKEN unset")
```

Mixed batches are expected and supported — different Issues in the same parallel batch can use different dispatch methods. Print the chosen method per Issue in the launch announcement, e.g.:

```
Launching batch:
  Issue #3 [User profile API]      → MiniMax-M2.7 (subprocess, dev worker 1)
  Issue #4 [JWT refresh rotation]  → Opus (native Agent, worktree)
  Issue #5 [Refactor token utils]  → ask user (Option C)
```

#### Option A: External model proxy (`WORKER_DEV_AUTH_TOKEN` is set)

Used for Issues with `routing: minimax`. Discover all available dev workers by checking env vars in order:
1. `WORKER_DEV_AUTH_TOKEN` (or `WORKER_DEV_AUTH_TOKEN_1`) — first worker
2. `WORKER_DEV_AUTH_TOKEN_2` — second worker
3. `WORKER_DEV_AUTH_TOKEN_3`, etc. — stop at the first missing number

Assign **MiniMax-routed tasks only** round-robin across available dev workers (Opus-routed tasks do not consume a slot in this rotation):
- MiniMax task 1 → dev worker 1
- MiniMax task 2 → dev worker 2 (if exists, otherwise back to 1)
- MiniMax task 3 → dev worker 1
- ...

For each worker, run via Bash with `run_in_background: true`. **Never inline secrets in commands or log output.**

**Skill injection**: If the user opted to embed skills in worker prompts (see Phase 2 Skill Discovery), read each installed skill from `<project-root>/.claude/commands/` and append the content to the worker prompt under a `## Reference Skills` heading before dispatching.

Step 1: Write a temporary env file (mode 600) with the mapped vars:

```bash
ENV_FILE=$(mktemp /tmp/worker-env-XXXXXX)
chmod 600 "$ENV_FILE"
cat > "$ENV_FILE" <<'ENVEOF'
export ANTHROPIC_AUTH_TOKEN="<value of WORKER_DEV_AUTH_TOKEN>"
export ANTHROPIC_BASE_URL="<value of WORKER_DEV_BASE_URL>"
export ANTHROPIC_MODEL="<value of WORKER_DEV_MODEL, if set>"
export ANTHROPIC_SMALL_FAST_MODEL="<value of WORKER_DEV_SMALL_FAST_MODEL, if set>"
export ANTHROPIC_DEFAULT_SONNET_MODEL="<value of WORKER_DEV_SONNET_MODEL, if set>"
export ANTHROPIC_DEFAULT_OPUS_MODEL="<value of WORKER_DEV_OPUS_MODEL, if set>"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="<value of WORKER_DEV_HAIKU_MODEL, if set>"
export API_TIMEOUT_MS="<value of WORKER_DEV_TIMEOUT_MS, if set>"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="<value of WORKER_DEV_DISABLE_NONESSENTIAL, if set>"
ENVEOF
```

Only include lines for vars that are actually set. For suffixed workers (`_2`, `_3`, ...), use the corresponding suffixed vars.

Step 2: Launch the worker, sourcing the env file and cleaning it up:

```bash
(source "$ENV_FILE" && rm -f "$ENV_FILE" && claude -p "<full worker prompt>" \
  --allowedTools "Read,Write,Edit,Glob,Grep,\
Bash(git *),Bash(gh issue *),Bash(gh pr *),Bash(gh repo *),\
Bash(npm test*),Bash(npm run *),Bash(npm install*),Bash(npm audit*),Bash(npx *),\
Bash(yarn test*),Bash(yarn run *),Bash(yarn install*),Bash(yarn add *),\
Bash(pnpm test*),Bash(pnpm run *),Bash(pnpm install*),Bash(pnpm add *),\
Bash(python -m py_compile *),Bash(python -m pytest*),Bash(python -m pip install*),\
Bash(pip install*),Bash(pip-audit*),\
Bash(node --check *),Bash(node *),Bash(tsc *),\
Bash(bandit *),Bash(flake8 *),Bash(pylint *),Bash(mypy *),Bash(eslint *),\
Bash(mkdir *),Bash(cp *),Bash(mv *),Bash(cat *),Bash(ls *),Bash(touch *),\
Bash(chmod +x *),\
WebSearch,WebFetch") \
  2>&1 | tee /tmp/worker-issue-N.log
```

This allowlist covers all repo development operations:
- **Files**: Read, Write, Edit, Glob, Grep, mkdir, cp, mv, touch, chmod
- **Git**: all git commands, gh issue/pr/repo commands
- **Node.js**: npm/yarn/pnpm (test, run, install, audit), npx, node, tsc
- **Python**: pytest, py_compile, pip install, pip-audit
- **Linters/security**: eslint, flake8, pylint, mypy, bandit
- **Research**: WebSearch, WebFetch for looking up docs/APIs/examples

Workers **cannot** run arbitrary shell commands or modify anything outside the repo.

The env file is deleted before the worker starts, so secrets only exist in process memory — never in logs, command history, or process arguments.

After launching, monitor each worker's log file for PR creation (`gh pr create` output) to update the Task Board.

#### Option B: Native Agent tool with Opus

Used for Issues with `routing: opus`, and for `routing: minimax` Issues when `WORKER_DEV_AUTH_TOKEN` is not set (fallback).

Use the Agent tool with:
- `isolation: "worktree"`
- `model: "opus"` (explicit — pin the worker to Opus regardless of harness defaults)
- `prompt`: the full content of the corresponding worker prompt file (`worker-new.md` or `worker-fix.md`) with the Issue number filled in

If `WORKER_QA_*` env vars are not set, the Phase 3.5 QA Agent also dispatches via this option.

#### Option C: Ask the user (routing: ask)

Used for Issues with `routing: ask`. Before launching the worker, surface `AskUserQuestion`:

- header: `"Worker model"`
- question: `"Issue #N [<title>] — pick worker model:"`
- options:
  - `"MiniMax-M2.7 (fast/cheap)"` — only present if `WORKER_DEV_AUTH_TOKEN` is set
  - `"Opus (more capable)"`
  - `"Skip this Issue for now"` — defers the Issue and removes it from the current batch

After the user picks, dispatch via Option A or Option B accordingly. Do not retroactively cache the choice as a default for similar future Issues — re-classify per Issue in Phase 2.
