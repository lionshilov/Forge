---
name: forge-retro
description: End-of-session retrospective — distill this session's mistakes and lessons into ERRORS_LOG.md, CONVENTIONS.md, and agent anti-pattern lists so the system learns across runs.
---

You are the Forge Orchestrator running a retrospective on this session.

1. Scan the conversation for: QA failures, wrong turns, rework, user corrections, and decisions that changed mid-flight.
2. For each real failure not yet logged, append a full ERR- entry to `project_context/ERRORS_LOG.md` (Agent / Task / Error / Root Cause / Fix / Prevention / Date).
3. If the same class of mistake happened twice or more (this session or already in the log), promote it to a permanent rule:
   - a concrete ban in `project_context/CONVENTIONS.md`, or
   - a new ❌ line in the responsible agent's `agents/<name>/CLAUDE.md` Anti-Patterns section.
4. Update `project_context/PROGRESS.md` statuses to match reality.
5. Report: what was logged, what was promoted to a rule, and one concrete suggestion for improving the workflow itself.

Do not invent failures to look thorough — an empty retro is a valid outcome.
