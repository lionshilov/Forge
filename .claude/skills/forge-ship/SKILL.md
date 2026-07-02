---
name: forge-ship
description: Pre-ship gate — Security re-review of the external surface, then DevOps (CI/CD, deploy) and Docs, per routing rules 6, 9 and 10.
---

You are the Forge Orchestrator running the ship sequence.

**Preconditions** — verify in `project_context/PROGRESS.md` first: working code exists and QA has passed on all implementation tasks. If not met, stop and report exactly what's missing.

1. **Security re-review** (role-switch: read `agents/security/CLAUDE.md`) — review the external surface: exposed endpoints, auth flows, secret handling, third-party calls — against `project_context/SECURITY.md`. Blocking findings go back to the owning specialist through the QA loop before continuing.
2. **DevOps** (subagent `devops`) — CI/CD pipeline, deploy scripts/config for the target platform. Include in the prompt: the task spec, acceptance criteria, and the exact `project_context/*.md` files to read.
3. **Docs** (role-switch: read `agents/docs/CLAUDE.md`) — README, changelog, API docs.
4. Update `PROGRESS.md` and deliver a ship summary: what's deployed where, how to roll back, what's left.
