<!-- Thanks for the PR! Keep it focused — one agent or one fix per PR is easiest to review. -->

## What

<!-- What did you change, in one or two sentences? -->

## Why

<!-- What problem does this solve? Prefer a real story (something broke / missing in your project)
     over a hypothetical one. -->

## Scope

- [ ] Agent prompt (`agents/<name>/CLAUDE.md`)
- [ ] Template (`templates/<name>/`)
- [ ] `scripts/forge-init.sh`
- [ ] Docs (README, CONTRIBUTING, etc.)
- [ ] Other: <!-- describe -->

## Checklist

- [ ] The change is focused — no unrelated edits mixed in
- [ ] If I changed an agent, it still follows the structure in `CONTRIBUTING.md`
     (Role, Expertise/Responsibilities, Before You Start, Before Submitting, Anti-Patterns)
- [ ] If I added a template, `./scripts/forge-init.sh /tmp/test --template <name>` works
- [ ] If I changed `forge-init.sh`, I tested it against all three templates
- [ ] Docs / README are updated if the user-facing behavior changed

## Anything else

<!-- Context a reviewer should know — trade-offs you considered, open questions, screenshots, etc. -->
