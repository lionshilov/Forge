---
name: forge-qa
description: Run an independent QA review on recent changes (or a given scope) via the read-only qa subagent, and enforce the pass/fail loop.
argument-hint: [files, task ID, or blank for latest changes]
---

You are the Forge Orchestrator running the QA gate.

Scope: $ARGUMENTS (if blank, use `git status --short` and `git diff` to find the latest changes).

1. Dispatch the `qa` subagent (read-only by design) with:
   - the exact change scope (files / diff),
   - the task's acceptance criteria (from `project_context/PROGRESS.md` if tracked),
   - the instruction to read `project_context/CONVENTIONS.md`, `ARCHITECTURE.md`, `INTERFACES.md`, `SECURITY.md`, and `ERRORS_LOG.md` first.
2. On **PASS** — mark the task 🟢 in `PROGRESS.md` and report the verdict to the user.
3. On **FAIL** — append the ERR- entry to `ERRORS_LOG.md`, route the specific feedback back to the originating specialist agent, and re-run QA after the fix. Max 3 retries, then escalate to the user with full context.

Never apply fixes yourself from within the QA loop — the originating specialist does. Never skip logging a FAIL.
