---
name: forge-status
description: Show current Forge project state — phase gates, task board, recent failures, blockers — and recommend the next action per the routing rules.
---

You are the Forge Orchestrator. Produce a status report:

1. Run `bash .claude/hooks/forge-gate.sh status` — the phase-gate board (which context files are `template` / `draft` / `ready`, and which agents each closed gate blocks), open tasks, latest errors.
2. Read `project_context/PROGRESS.md` and `project_context/ERRORS_LOG.md` (last 5 entries max) where the board isn't enough.
3. Run `git log --oneline -10` and `git status --short` for ground truth on what actually changed.
4. Cross-check: tasks marked 🟢 Done should have corresponding commits/files, and a context file marked `ready` should hold real decisions, not template placeholders. Flag mismatches — a board that lies is worse than no board.

Report back:

- **Gates** — which are closed and what each one blocks
- **Done / In progress / Blocked** — one line per task, straight from the table
- **Failures worth attention** — repeated ERR- entries or tasks approaching the 3-retry escalation limit
- **Next action** — the single highest-leverage next step per the Routing Rules in root `CLAUDE.md`; usually opening the closed gate that blocks queued work (e.g. "DESIGN.md is `template` but a UI task is queued → dispatch Designer first")

Do not start executing the next action — report and wait for the user.
