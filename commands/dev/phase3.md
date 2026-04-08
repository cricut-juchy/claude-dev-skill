# Phase 3 — Multi-Agent Parallel Development (Execution Rules)

---

## Execution Rules

- For parallelizable tasks, use the Agent tool to **launch multiple Worker Agents simultaneously**
- Each Worker Agent uses `isolation: "worktree"` to work in an isolated environment
- **Even with only one task, a Worker Agent must be dispatched — never write code directly in the main conversation**
- Progress reporting: **report at key milestones only**
  - After all agents are launched, output the **Task Board** (see format below) once
  - After each agent creates a PR, update the Task Board and re-output it
- Users may view the code at any time; do not proactively interrupt

## Task Board Format

Output after all agents are launched, and re-output (full board) after each PR is created:

```
## Agent Task Board

| # | Branch | Issue | Status |
|---|--------|-------|--------|
| 1 | feat/auth | #3 User login | ⏳ In progress |
| 2 | feat/user-api | #4 User profile API | ⏳ In progress |
| 3 | feat/db-schema | #5 Database schema | ⏳ In progress |
```

Status values:
- `⏳ In progress` — agent is running
- `✓ PR #N created` — PR submitted, waiting for review
- `❌ Blocked: [reason]` — agent encountered a blocker, Tech Lead action needed

## Dispatching Worker Agents

Select the correct prompt file based on task type, replacing `[N]` with the actual Issue number:

- New feature: read `~/.claude/commands/dev/worker-new.md`
- Fix / improvement: read `~/.claude/commands/dev/worker-fix.md`

### Dispatch Method

**Check environment variables first.** The dispatch method depends on whether dev worker configs are present.


#### Option A: External model proxy (`WORKER_DEV_AUTH_TOKEN` is set)

Discover all available dev workers by checking env vars in order:
1. `WORKER_DEV_AUTH_TOKEN` (or `WORKER_DEV_AUTH_TOKEN_1`) — first worker
2. `WORKER_DEV_AUTH_TOKEN_2` — second worker
3. `WORKER_DEV_AUTH_TOKEN_3`, etc. — stop at the first missing number

Assign tasks round-robin across available dev workers:
- Task 1 → dev worker 1
- Task 2 → dev worker 2 (if exists, otherwise back to 1)
- Task 3 → dev worker 1
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

#### Option B: Native Agent tool (default — no `WORKER_DEV_*` env vars set)

Use the Agent tool with `isolation: "worktree"`, passing the full prompt file content as the agent prompt. This is the original behavior.
