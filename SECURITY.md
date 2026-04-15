# Security Policy

## Supported Versions

Forge is a collection of prompts and shell scripts — there's no long-lived
runtime to version. The `main` branch is the only actively maintained line.

| Version | Supported |
|---|---|
| `main`  | ✅ |
| Forks / snapshots | Not supported — open an issue on this repo instead |

## Reporting a Vulnerability

If you find a security issue, **please do not open a public GitHub issue**.

Use one of these private channels:

- GitHub's [private vulnerability reporting](https://github.com/lionshilov/Forge/security/advisories/new) (preferred)
- Or open a draft security advisory and invite `@lionshilov`

Please include:

- Where the issue is (file, line, or behavior)
- What an attacker could do with it
- A reproduction path, if you have one

We'll acknowledge within 5 days and aim to issue a fix (or a public advisory
with mitigation guidance) within 30 days.

## Scope

Things we treat as security issues:

- `scripts/forge-init.sh` — shell injection, path traversal, overwrite of
  unintended files, privilege escalation via template payloads
- Template files that ship code — unsafe defaults (e.g., secrets in the
  repo, insecure auth patterns, SQL-injection-prone snippets)
- Agent prompts that would instruct Claude to perform clearly malicious
  actions (e.g., "exfiltrate env vars", "disable CI security checks")
- Malicious pull requests (supply-chain attempts, typosquat templates, etc.)

Things that are **not** security issues:

- A bad suggestion from Claude Code while using Forge — that's a prompt quality
  issue; open a regular issue so we can improve the relevant agent's anti-patterns.
- General reliability bugs in the init script — open a regular issue.

## Defensive posture

- Forge has **zero runtime dependencies**. Templates pin their own deps and
  get Dependabot bumps via `.github/dependabot.yml`.
- CI runs ShellCheck on `scripts/` and smoke-tests every template on each PR.
- Secrets should never appear in templates — only `.env.example` files with
  placeholder values.

Thanks for helping keep Forge and its users safe.
