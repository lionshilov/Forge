#!/usr/bin/env bash
# shellcheck disable=SC2317,SC2329
#
# test-forge-gate.sh — behavioral tests for .claude/hooks/forge-gate.sh, run
# against a freshly bootstrapped project. CI runs this; so can you:
#
#   ./scripts/test-forge-gate.sh
#
# (The ShellCheck directive above: test helpers are invoked indirectly,
# through expect_*, which ShellCheck can't see.)

set -euo pipefail
unset FORGE_GATES

FORGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

PROJECT="$WORK/app"
"$FORGE_ROOT/scripts/forge-init.sh" "$PROJECT" "Gate Test" >/dev/null 2>&1
GATE="$PROJECT/.claude/hooks/forge-gate.sh"
CTX="$PROJECT/project_context"

passed=0
failed=0
pass() { passed=$((passed + 1)); echo "✓ $1"; }
fail() { failed=$((failed + 1)); echo "❌ $1"; }

# expect_exit <code> <description> <command...>
expect_exit() {
  local want="$1" desc="$2" got=0
  shift 2
  "$@" >/dev/null 2>&1 || got=$?
  if [[ "$got" == "$want" ]]; then pass "$desc"; else fail "$desc (exit $got, want $want)"; fi
}

# expect_output <ERE> <description> <command...> — matched against stdout+stderr
expect_output() {
  local pattern="$1" desc="$2" out
  shift 2
  out="$("$@" 2>&1)" || true
  if grep -qE -- "$pattern" <<<"$out"; then pass "$desc"; else fail "$desc — no /$pattern/ in:"$'\n'"$out"; fi
}

# expect_no_output <ERE> <description> <command...>
expect_no_output() {
  local pattern="$1" desc="$2" out
  shift 2
  out="$("$@" 2>&1)" || true
  if grep -qE -- "$pattern" <<<"$out"; then fail "$desc — unexpected /$pattern/"; else pass "$desc"; fi
}

gate() { bash "$GATE" "$@"; }

# dispatch <subagent_type> [prompt] — the PreToolUse payload Claude Code sends for the Agent tool
dispatch() {
  printf '{"session_id":"test","hook_event_name":"PreToolUse","tool_name":"Agent","tool_input":{"description":"test","prompt":"%s","subagent_type":"%s"}}' \
    "${2:-Build the thing.}" "$1" | bash "$GATE" hook
}
dispatch_gates_off() {
  printf '{"tool_name":"Agent","tool_input":{"subagent_type":"%s"}}' "$1" | FORGE_GATES=off bash "$GATE" hook
}
hook_raw() { printf '%s' "$1" | bash "$GATE" hook; }

# set_status <FILE> <status> — what an owning agent does when it finishes
set_status() {
  sed -i.bak "s|^status: .*|status: $2|" "$CTX/$1.md"
  rm -f "$CTX/$1.md.bak"
}
to_crlf() { awk '{ printf "%s\r\n", $0 }' "$1" >"$1.tmp" && mv "$1.tmp" "$1"; }
strip_front_matter() {
  awk 'NR == 1 && $0 == "---" { fm = 1; next } fm && $0 == "---" { fm = 0; next } !fm' "$1" >"$1.tmp" && mv "$1.tmp" "$1"
}

echo "── wiring"
expect_output '"matcher": "Agent\|Task"' "PreToolUse hook matches the subagent tool" cat "$PROJECT/.claude/settings.json"
expect_output 'hooks/forge-gate\.sh hook"' "PreToolUse runs the gate" cat "$PROJECT/.claude/settings.json"
expect_output 'hooks/forge-gate\.sh status"' "SessionStart runs the board" cat "$PROJECT/.claude/settings.json"

echo "── fresh bootstrap: every gate closed"
for file in PRODUCT DESIGN ARCHITECTURE CONVENTIONS INTERFACES ANALYTICS SECURITY; do
  expect_output "✗ $file\.md +template" "$file.md ships as template" gate status
done
expect_output "Tasks \(PROGRESS\.md\): none yet" "empty task board" gate status
expect_output "Errors \(ERRORS_LOG\.md\): none logged" "empty errors log" gate status
expect_exit 0 "product may always start" gate check product
expect_exit 0 "qa is never gated" gate check qa
expect_exit 1 "architect waits for PRODUCT.md" gate check architect
expect_exit 1 "backend waits for the spec and architecture" gate check backend
expect_exit 2 "an unknown agent is a usage error" gate check not-an-agent

echo "── hook: blocks gated dispatch, nothing else"
expect_exit 2 "dispatching backend is blocked" dispatch backend
expect_output "PRODUCT\.md — template \(owner: product\)" "block reason names the file and its owner" dispatch backend
expect_output "forge-gate: skip" "block reason explains the user-only escape hatch" dispatch backend
expect_exit 2 "plugin-namespaced subagent type is gated too" dispatch forge:backend
expect_exit 0 "product passes" dispatch product
expect_exit 0 "non-Forge subagents pass" dispatch general-purpose
expect_exit 0 "an explicit skip passes" dispatch backend "forge-gate: skip — user wants a throwaway spike"
expect_exit 0 "FORGE_GATES=off disables the hook" dispatch_gates_off backend
expect_exit 2 "pretty-printed JSON is parsed" hook_raw $'{\n  "tool_input": {\n    "subagent_type" : "backend"\n  }\n}'
expect_exit 0 "a subagent_type quoted inside the prompt is not a dispatch" hook_raw '{"tool_input":{"prompt":"see \"subagent_type\": \"backend\""}}'
expect_exit 0 "a payload without subagent_type fails open" hook_raw '{"tool_name":"Agent","tool_input":{"prompt":"hi"}}'
expect_exit 0 "malformed input fails open" hook_raw 'not json at all'

echo "── gates open as owners mark files ready"
set_status PRODUCT ready
expect_exit 0 "architect starts once PRODUCT.md is ready" gate check architect
expect_exit 0 "designer starts once PRODUCT.md is ready" gate check designer
expect_exit 1 "analyst still waits for ARCHITECTURE.md" gate check analyst
for file in ARCHITECTURE CONVENTIONS INTERFACES; do set_status "$file" ready; done
expect_exit 0 "backend starts once the Architect's three files are ready" gate check backend
expect_exit 0 "the hook lets it through too" dispatch backend
expect_exit 1 "frontend-web still waits for DESIGN.md" gate check frontend-web
set_status DESIGN n/a
expect_exit 0 "n/a opens a gate" gate check frontend-web
set_status ARCHITECTURE draft
expect_exit 1 "draft keeps a gate closed" gate check backend
expect_output "✗ ARCHITECTURE\.md +draft +owner: architect +→ blocks analyst" "board shows who a draft blocks" gate status
set_status ARCHITECTURE '"Ready"'
expect_exit 0 "quoted, capitalized status values parse" gate check backend
expect_exit 1 "devops waits for SECURITY.md" gate check devops
set_status SECURITY 'draft  # threat model under review'
to_crlf "$CTX/SECURITY.md"
expect_exit 1 "CRLF files parse (still draft)" gate check devops
set_status SECURITY 'ready  # signed off'
expect_exit 0 "trailing comments are ignored" gate check devops

echo "── fails open on anything it can't read"
set_status CONVENTIONS template
strip_front_matter "$CTX/CONVENTIONS.md"
expect_exit 0 "a file without front matter doesn't block" gate check backend
expect_output "\? CONVENTIONS\.md +unset" "…but the board flags it" gate status
rm "$CTX/INTERFACES.md"
expect_exit 0 "a missing file doesn't block" gate check backend
expect_output "\? INTERFACES\.md +missing" "…but the board flags it" gate status

echo "── session board: open tasks and latest errors"
cat >>"$CTX/PROGRESS.md" <<'EOF'
| T-01 | Write the MVP spec | product | 🟢 | none | |
| T-02 | Health endpoint | backend | 🟡 | T-01 | |
| T-03 | Review T-02 | qa | 🔁 | T-02 | |
| T-04 | Login screen | frontend-web | ⚪ | T-02 | waiting on DESIGN.md |
EOF
cat >>"$CTX/ERRORS_LOG.md" <<'EOF'

### ERR-001: Endpoint returned 200 on validation errors
- **Agent:** backend
EOF
expect_output "4 total — 🟢 1 done · 🟡 1 in progress · 🔁 1 in review · 🔴 0 blocked · ❌ 0 failed · ⚪ 1 not started" "counts tasks by status" gate status
expect_output "\| T-04 \| Login screen" "lists open tasks" gate status
expect_no_output "^\| T-01 \|" "hides done tasks" gate status
expect_output "1 logged — latest:" "counts logged errors" gate status
expect_output "ERR-001: Endpoint returned 200" "shows the latest errors" gate status

echo "── outside a bootstrapped project"
source_hook() { printf '%s' '{"tool_input":{"subagent_type":"backend"}}' | bash "$FORGE_ROOT/.claude/hooks/forge-gate.sh" hook; }
expect_exit 0 "the Forge source repo is never gated" source_hook
expect_output "Forge source repo" "…and its board says why" bash "$FORGE_ROOT/.claude/hooks/forge-gate.sh" status
mkdir -p "$WORK/bare/.claude/hooks"
cp "$GATE" "$WORK/bare/.claude/hooks/"
bare_hook() { printf '%s' '{"tool_input":{"subagent_type":"backend"}}' | bash "$WORK/bare/.claude/hooks/forge-gate.sh" hook; }
expect_exit 0 "no project_context/ — nothing to gate" bare_hook

echo
echo "$passed passed, $failed failed"
[[ "$failed" -eq 0 ]]
