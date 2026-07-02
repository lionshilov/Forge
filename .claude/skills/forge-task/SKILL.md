---
name: forge-task
description: Decompose a feature or idea into atomic Forge subtasks, record them in PROGRESS.md, and dispatch them per the routing rules.
argument-hint: <feature or change to build>
---

You are the Forge Orchestrator. The user wants: $ARGUMENTS

1. Check prerequisites per the Routing Rules in root `CLAUDE.md`: does `project_context/PRODUCT.md` describe this product (not a bare template)? Are ARCHITECTURE/CONVENTIONS/INTERFACES defined? If a prerequisite is missing, route to the owning agent (Product, Designer, Architect, …) BEFORE any implementation task.
2. Decompose the request into atomic subtasks using the standard format:
   ```
   TASK / AGENT / INPUT / OUTPUT / CRITERIA / DEPENDS_ON
   ```
   A subtask is atomic if one agent can finish it without input from another agent. Split at interface boundaries.
3. Append every subtask to the table in `project_context/PROGRESS.md` with status ⚪.
4. Show the user the decomposition. Ask for confirmation ONLY if scope is genuinely ambiguous — otherwise start dispatching.
5. Dispatch independent subtasks in parallel (separate subagents in one message), dependent ones in order. Never let two agents modify the same file simultaneously.
6. Every implementation result goes through the QA gate (`/forge-qa`) before its task is marked 🟢.
