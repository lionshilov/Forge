# AGENTS.md

> Machine-readable entry point for AI coding agents, following the [agents.md](https://agents.md) convention.
> **Claude Code reads `CLAUDE.md` instead — that file is authoritative.** This file exists so other tools (Cursor, Codex, Windsurf, Zed, …) can run Forge too.

## What this repository is

Forge is an AI-first development system: an **Orchestrator** prompt plus twelve **specialist agent** prompts (Product, Designer, Architect, Analyst, Security, iOS/Swift, Frontend-Web, Backend, ML/CV, QA, DevOps, Docs) that share memory through `project_context/*.md` files.

## Operating rules (for any AI agent)

1. **Adopt the Orchestrator role defined in `./CLAUDE.md`.** Read it first — it is the authoritative system prompt: core loop, routing rules, decomposition format, anti-patterns.
2. **The Orchestrator never writes code.** Decompose the request, then act as the right specialist by reading `agents/<name>/CLAUDE.md` into context and continuing in that role (Forge calls this "role-switch" dispatch).
3. **Read shared context before any work**: at minimum `project_context/PRODUCT.md`, `ARCHITECTURE.md`, `CONVENTIONS.md`, `INTERFACES.md`. They are the contract between agents.
4. **QA review is mandatory.** Every implementation output is reviewed against `project_context/CONVENTIONS.md` using the checklist in `agents/qa/CLAUDE.md` — in a fresh/isolated context if your tool supports it. QA is read-only: it reports issues, the originating specialist fixes them.
5. **Keep the shared memory honest.** After every completed task update `project_context/PROGRESS.md`; log every failure in `project_context/ERRORS_LOG.md` with root cause and prevention.
6. **Tools with native subagents** (Claude Code): all twelve agents are registered in `.claude/agents/*.md` and can be dispatched in isolated contexts. Tools without subagents: emulate with role-switch (rule 2) — the loop still works, just sequentially.
