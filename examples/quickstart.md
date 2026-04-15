# Quickstart: idea → MVP in one session

This walkthrough shows what using Forge actually looks like. Pretend you have an idea: **"an app that reminds me to drink water based on how much I've moved today."**

## 1. Bootstrap a project

```bash
./scripts/forge-init.sh ~/code/hydrate "Hydrate"
cd ~/code/hydrate
claude
```

## 2. Drop in your idea

In Claude Code, paste:

> I want to build an iOS app that reminds me to drink water, but the reminders should be smarter when I've been active. MVP should work on my own phone first.

## 3. What the Orchestrator does

Claude (acting as the Orchestrator per root `CLAUDE.md`) will:

1. **Route to Product** — fills in `project_context/PRODUCT.md` with target user, MVP scope, success metrics, open questions. May ask you 2–3 clarifying questions.
2. **Route to Architect** — fills `ARCHITECTURE.md`, `CONVENTIONS.md`, `INTERFACES.md`. Picks the stack (probably SwiftUI + HealthKit for this).
3. **Route to iOS agent** — implements screens, data layer, HealthKit reads.
4. **Route to ML/CV if needed** — not needed for this MVP.
5. **Route to QA** — reviews every agent output against `CONVENTIONS.md`.
6. **Route to DevOps** — adds a Fastlane lane for TestFlight once there's working code.
7. **Route to Docs** — writes the final README.

At every step the Orchestrator updates `project_context/PROGRESS.md` so you can see what's done, what's in review, and what's blocked.

## 4. How the loop feels

You'll mostly be answering product questions (*"should reminders pause during workouts?"*) and approving or rejecting QA verdicts. You're not writing boilerplate — you're making decisions.

## 5. When to step in manually

- Tight deadlines with a narrow cut — override the Orchestrator and call an agent directly
- Design/UX decisions — you're faster than the agents at taste calls
- External integrations with weird auth — do the first call yourself, then hand off

## 6. When Forge breaks down

- If `ERRORS_LOG.md` shows the same error 3× on one task, stop and rethink the task — the agent is probably missing context, not skill
- If the Architect keeps revisiting decisions, your `PRODUCT.md` is probably too vague
- If QA keeps passing garbage, tighten `CONVENTIONS.md` with specific bans

That's the whole loop. The power is the compounding context: every agent's output is input for the next, and `ERRORS_LOG.md` makes the system learn across runs.
