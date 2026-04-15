# Contributing to Forge

Thanks for your interest. Forge is a set of prompts and conventions, not runtime code — but that means prompt quality matters more than usual.

## Ways to contribute

- **Add an agent** — a new specialist (e.g., Android/Kotlin, Data/Analytics, SRE). Follow the format in `agents/*/CLAUDE.md`.
- **Improve an agent** — tighten instructions, add/remove expertise, add anti-patterns learned the hard way.
- **Add a template** — starter project files for a specific stack in `templates/`.
- **Add an example** — a worked walkthrough of Forge building something real, in `examples/`.
- **Fix docs** — README, agent prompts, unclear instructions.

## Agent prompt style

Every agent prompt lives at `agents/<name>/CLAUDE.md` and should have these sections:

- `## Role` — one sentence identity
- `## Expertise` (for specialists) or `## Responsibilities` (for coordinators)
- `## Before You Start` — which `project_context/*.md` files to read
- `## Output Requirements` — what good output looks like
- `## Anti-Patterns` — specific things this agent must not do

Rules for writing prompts:
- **Concrete over abstract.** "No force unwraps without justification" beats "write safe code".
- **Ban patterns, don't describe ideals.** Anti-patterns prevent the common failure modes.
- **Link to context.** Agents should read `ARCHITECTURE.md` / `CONVENTIONS.md` / `INTERFACES.md` before acting.
- **Short.** If a prompt is longer than two screens, it's probably doing too much.

## Pull requests

1. Fork the repo
2. Create a branch: `feat/new-agent-android` or `fix/architect-prompt`
3. Keep PRs focused — one agent or one fix per PR
4. In the PR description, explain *why* the change helps Forge build better MVPs

## Scope

Forge is opinionated by design. We prefer:

- Depth over breadth (a great iOS agent > a mediocre one covering every Apple platform)
- Boring, proven tech in agent expertise lists
- Prompts that ban real failure modes we've seen, not theoretical ones

If you're not sure whether an idea fits, open an issue first.
