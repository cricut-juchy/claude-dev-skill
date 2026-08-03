# /dev — AI-Assisted Multi-Agent Development SOP for Claude Code

[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-blue)](https://claude.com/claude-code)
[![Skill Type](https://img.shields.io/badge/type-slash%20command-purple)](https://docs.anthropic.com/en/docs/claude-code/slash-commands)

A custom skill for [Claude Code](https://claude.com/claude-code) that turns Claude into a **Tech Lead** coordinating multiple AI Worker Agents through a complete software development workflow — from requirements alignment to PR merge.

---

## Why /dev?

Most AI coding tools give you a smart autocomplete. `/dev` gives you an **engineering process**.

| Without /dev | With /dev |
|---|---|
| Claude writes code directly in chat | Claude acts as Tech Lead — never writes code itself |
| No structure, easy to lose track | 6-phase SOP from PRD to merge |
| Single-threaded, one thing at a time | Multiple Worker Agents develop in **parallel** worktrees |
| You catch conflicts at merge time | Pre-coding conflict scan catches overlaps before they start |
| Security review is manual | `bandit` + `pip-audit` / `npm audit` run mandatorily before every Review |

---

## How It Works

```
You: /dev I want to build a Todo app with user auth and task management

Claude (Tech Lead)
  │
  ├─ Phase 0 ── Classify request → New Project
  ├─ Phase 1 ── Align on PRD (2-round confirmation)
  ├─ Phase 2 ── Architecture decisions + GitHub Issues
  │
  ├─ Phase 3 ── Spawn Worker Agents (parallel worktrees)
  │              ├─ Worker A: Auth module
  │              ├─ Worker B: Task CRUD API
  │              └─ Worker C: Frontend components
  │
  ├─ Phase 3.5 ── QA Agent static verification
  ├─ Phase 4 ── Code Review + merge (7-item checklist)
  └─ Phase 5 ── Retro + next iteration loop
```

---

## What It Does

`/dev` is a **multi-agent software development SOP** covering:

- **Phase 0** — Request classification & routing (New Project / New Feature / Bug Fix / Emergency Hotfix / Architectural Change / Refactoring)
- **Phase 1** — Product alignment (uses your existing PRD, or generates one in two rounds)
- **Phase 2** — Architecture decisions + task decomposition + GitHub Issue creation
- **Phase 3** — Multiple Worker Agents developing **in parallel** (each in an isolated worktree)
- **Phase 3.5** — QA Agent static verification
- **Phase 4** — Code Review + merge (7-item structured checklist with mandatory veto conditions)
- **Phase 5** — Retro + next iteration loop

### Key Features

- **Tech Lead iron rule**: main conversation never writes code directly — all changes go through Worker Agent → PR → Review
- **6-category counterexample self-check**: Worker Agents must cover Null / Empty / Boundary / External failure / Concurrency / Malicious input before submitting
- **Pre-coding conflict check**: Worker Agents scan other open Issues for file overlap before starting
- **Post-merge PR coordination**: after every merge, scans open PRs and notifies branches that need rebase
- **Security gate**: `bandit` + `pip-audit` / `npm audit` run mandatorily before Review
- **Database migration guard**: direct DDL operations (ALTER TABLE / DROP COLUMN) trigger mandatory veto
- **Git Autonomy Gate**: designed for auto-approved permission modes — push, PR creation, and merge are gated behind explicit in-conversation confirmation by default (`Gated` / `PR auto, merge gated` / `Full auto`, persisted per-project in `PROJECT_CONTEXT.md`)

### Discipline Subskills

Four reusable disciplines are appended to agent prompts at dispatch time:

- **`grilling.md`** — requirements interviewing: look up facts yourself, put every decision to the user; sharpen fuzzy domain terms into a glossary; record only decisions that pass the hard-to-reverse / surprising / real-trade-off test
- **`debugging.md`** — bug-fix rigor: build a red feedback loop before theorizing, minimise the repro, 3–5 ranked falsifiable hypotheses, one variable at a time, three-strikes escalation to Tech Lead, tagged `[DEBUG-...]` instrumentation with mandatory cleanup
- **`code-review-reception.md`** — receiving REQUEST CHANGES: verify feedback against the codebase before implementing, clarify all unclear items first, YAGNI-check "implement properly" suggestions, push back with evidence, no performative agreement
- **`verification.md`** — evidence before claims: no completion claim without fresh command output; regression tests must be red-green verified (pass → revert fix → fail → restore → pass); agent success reports are claims, not evidence

*(Derived from the strongest ideas in [obra/superpowers](https://github.com/obra/superpowers) and [mattpocock/skills](https://github.com/mattpocock/skills), both MIT-licensed, merged and adapted to this SOP's Tech Lead / Worker / QA roles.)*

---

## Requirements

| Tool | Notes |
|------|-------|
| [Claude Code](https://claude.com/claude-code) | Anthropic official CLI, login required |
| [GitHub CLI (`gh`)](https://cli.github.com/) | For Issues, PRs, repos — run `gh auth login` first |
| Git | Version control |

---

## Installation

**Option 1: Script (recommended)**

```bash
# macOS / Linux
bash install.sh
```

**Option 2: Manual**

Copy all files from `commands/` into `~/.claude/commands/`, keeping the directory structure:

```
~/.claude/commands/
  dev.md
  dev/
    phase1.md
    phase2.md
    phase3.md
    phase4.md
    worker-new.md
    worker-fix.md
    qa-agent.md
    grilling.md
    debugging.md
    code-review-reception.md
    verification.md
    PROJECT_CONTEXT_TEMPLATE.md
```

---

## Usage

In Claude Code, type:

```
/dev [optional description]
```

Examples:
```
/dev I want to build a Todo app with user registration and task management
/dev
```

Claude will automatically classify the request type and enter the corresponding flow.

---

## Repository Structure

```
claude-dev-skill/
├── README.md               # This file
├── install.sh              # macOS/Linux installer
├── commands/               # Skill files
│   ├── dev.md
│   └── dev/
│       ├── phase1.md ~ phase4.md
│       ├── worker-new.md
│       ├── worker-fix.md
│       ├── qa-agent.md
│       ├── grilling.md
│       ├── debugging.md
│       ├── code-review-reception.md
│       ├── verification.md
│       └── PROJECT_CONTEXT_TEMPLATE.md
```

---

## Scope

**Best suited for:**
- New small-to-medium web backend / API projects
- Feature modules with an existing PRD that need systematic development
- Parallel multi-feature development where you want to avoid merge conflicts

**Not suited for:**
- Projects requiring production deployment (no DevOps/deployment capability)
- Complex database migrations with large amounts of existing data
- High compliance security requirements (finance, healthcare)

---

## Contributing

Issues and PRs are welcome. If you have ideas for new phases, agent roles, or language support, open an Issue first to discuss.
