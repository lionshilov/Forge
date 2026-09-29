#!/usr/bin/env bash
#
# forge-gate.sh — Forge's phase gates: the Routing Rules from root CLAUDE.md,
# enforced by the harness instead of left to the model's memory.
#
# Every gated project_context/*.md file opens with front matter:
#
#   ---
#   status: template
#   owner: architect
#   ---
#
# `template` and `draft` keep a gate closed; `ready` (downstream agents can
# build on it) or `n/a` (deliberately not needed, reason in the file) open it.
# The owning agent sets the status as the last step of its Before-Submitting
# checklist; the Orchestrator may flip draft → ready only to record the
# user's explicit sign-off.
#
# Usage:
#   forge-gate.sh status          Session board: gates, open tasks, latest errors.
#                                 Wired to SessionStart; used by /forge-status.
#   forge-gate.sh check <agent>   Exit 0 if <agent> may start, 1 if gated,
#                                 2 if <agent> isn't a Forge agent.
#   forge-gate.sh hook            PreToolUse hook on subagent dispatch: reads
#                                 the hook JSON on stdin, exits 2 to block.
#
# Skipping a gate is the user's call: a dispatch prompt containing
# `forge-gate: skip — <reason>` passes, and stays auditable in the transcript.
# FORGE_GATES=off in the environment disables the hook for a whole session.
#
# Fails open: missing files, unparsable input, unknown agents, and files
# without a status never block. Portable to bash 3.2 (macOS) and POSIX awk.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CTX="$ROOT/project_context"

# Gated context files in pipeline order, as <FILE>:<owning agent>.
GATED="PRODUCT:product
DESIGN:designer
ARCHITECTURE:architect
CONVENTIONS:architect
INTERFACES:architect
ANALYTICS:analyst
SECURITY:security"

# Routing Rules 1–6 and 9 as data — <agent>:<files that must be open first>.
# CI fails if an agent under agents/ is missing here.
RULES="
product:
designer:PRODUCT
architect:PRODUCT
analyst:PRODUCT ARCHITECTURE
security:PRODUCT ARCHITECTURE
ios-swift:PRODUCT DESIGN ARCHITECTURE CONVENTIONS INTERFACES
frontend-web:PRODUCT DESIGN ARCHITECTURE CONVENTIONS INTERFACES
backend:PRODUCT ARCHITECTURE CONVENTIONS INTERFACES
ml-cv:PRODUCT ARCHITECTURE CONVENTIONS INTERFACES
devops:PRODUCT ARCHITECTURE CONVENTIONS INTERFACES SECURITY
qa:
docs:PRODUCT
"

usage() { sed -n '3,/^$/s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"; }

# The Forge source repo ships blank templates by design — gates don't apply there.
is_source_repo() { [[ -f "$ROOT/scripts/forge-init.sh" && -d "$ROOT/templates" ]]; }

is_closed() { [[ "$1" == "template" || "$1" == "draft" ]]; }

# Front-matter status of project_context/<FILE>.md: template|draft|ready|n/a,
# "missing" if the file doesn't exist, "unset" if it has no valid status.
status_of() {
  local file="$CTX/$1.md" status
  if [[ ! -f "$file" ]]; then
    echo "missing"
    return 0
  fi
  status="$(awk -v q="'" '
    { sub(/\r$/, "") }
    NR == 1 { if ($0 != "---") exit; next }
    $0 == "---" { exit }
    /^status:/ {
      sub(/^status:[ \t]*/, ""); sub(/[ \t#].*$/, ""); gsub(/"/, ""); gsub(q, "")
      print tolower($0); exit
    }' "$file")"
  case "$status" in
    template | draft | ready | n/a) echo "$status" ;;
    *) echo "unset" ;;
  esac
}

owner_of() {
  local file owner
  while IFS=: read -r file owner; do
    if [[ "$file" == "$1" ]]; then
      echo "$owner"
      return 0
    fi
  done <<<"$GATED"
  echo "?"
}

# Files <agent> needs open, one per line; exits 1 if <agent> isn't a Forge agent.
requires() {
  awk -F: -v agent="$1" '
    $1 == agent { n = split($2, need, " "); for (i = 1; i <= n; i++) print need[i]; found = 1; exit }
    END { exit !found }' <<<"$RULES"
}

known_agents() {
  awk -F: 'NF { printf "%s%s", sep, $1; sep = " " } END { print "" }' <<<"$RULES"
}

# Agents that can't start while project_context/<FILE>.md is closed.
blocked_by() {
  awk -F: -v file="$1" '
    NF {
      n = split($2, need, " ")
      for (i = 1; i <= n; i++) if (need[i] == file) { out = out sep $1; sep = ", "; break }
    }
    END { print out }' <<<"$RULES"
}

# One "  ✗ …" line per closed prerequisite of <agent>; exits 1 if <agent> isn't a Forge agent.
closed_prereqs() {
  local needs file status
  needs="$(requires "$1")" || return 1
  while read -r file; do
    [[ -n "$file" ]] || continue
    status="$(status_of "$file")"
    if is_closed "$status"; then
      echo "  ✗ $file.md — $status (owner: $(owner_of "$file"))"
    fi
  done <<<"$needs"
  return 0
}

tasks_board() {
  local file="$CTX/PROGRESS.md" rc=0
  [[ -f "$file" ]] || return 0
  awk -v max=25 '
    { sub(/\r$/, "") }
    /^[ \t]*<!--.*-->[ \t]*$/ { next }      # a comment line does not end a table
    !/^[ \t]*\|/ { col = 0; next }           # any other line does
    /^[ \t|:-]+$/ { next }                   # separator row
    {
      n = split($0, cell, "|"); hdr = 0
      for (i = 2; i < n; i++) { c = cell[i]; gsub(/^[ \t]+|[ \t]+$/, "", c); if (c == "Status") hdr = i }
      if (hdr) { col = hdr; seen = 1; next } # header row of a task table
      if (!col) next                         # a table without a Status column
      s = cell[col]; total++
      if (index(s, "🟢")) { n_done++; next }
      if (index(s, "🟡")) n_prog++
      else if (index(s, "🔁")) n_review++
      else if (index(s, "🔴")) n_blocked++
      else if (index(s, "❌")) n_failed++
      else n_todo++
      if (++n_open <= max) rows[n_open] = $0
    }
    END {
      if (!seen) exit 3
      if (!total) { print "Tasks (PROGRESS.md): none yet"; exit }
      printf "Tasks (PROGRESS.md): %d total — 🟢 %d done · 🟡 %d in progress · 🔁 %d in review · 🔴 %d blocked · ❌ %d failed · ⚪ %d not started\n", total, n_done, n_prog, n_review, n_blocked, n_failed, n_todo
      for (i = 1; i <= n_open && i <= max; i++) print rows[i]
      if (n_open > max) printf "… %d more open tasks in project_context/PROGRESS.md\n", n_open - max
    }' "$file" || rc=$?
  if [[ "$rc" -eq 3 ]]; then
    echo "Tasks: no table with a Status column in PROGRESS.md — top of the file:"
    head -n 40 "$file"
  fi
}

errors_board() {
  local file="$CTX/ERRORS_LOG.md" count
  [[ -f "$file" ]] || return 0
  count="$(grep -c '^### ERR-[0-9]' "$file" || true)"
  if [[ "$count" -eq 0 ]]; then
    echo "Errors (ERRORS_LOG.md): none logged"
    return 0
  fi
  echo "Errors (ERRORS_LOG.md): $count logged — latest:"
  grep '^### ERR-[0-9]' "$file" | tail -n 3 | sed 's/^### /  /'
}

cmd_status() {
  if is_source_repo; then
    echo "── Forge source repo: project_context/ holds the blank templates forge-init.sh ships — phase gates apply to bootstrapped projects, not here. ──"
    return 0
  fi
  [[ -d "$CTX" ]] || return 0
  local file owner status blocks
  echo "── Forge session board (auto-loaded by .claude/hooks/forge-gate.sh) ──"
  echo "Phase gates — status: in project_context/ front matter (template → draft → ready | n/a):"
  while IFS=: read -r file owner; do
    status="$(status_of "$file")"
    if is_closed "$status"; then
      blocks="$(blocked_by "$file")"
      if [[ -n "$blocks" ]]; then
        printf '  ✗ %-16s %-9s owner: %-10s → blocks %s\n' "$file.md" "$status" "$owner" "$blocks"
      else
        printf '  ✗ %-16s %-9s owner: %s\n' "$file.md" "$status" "$owner"
      fi
    elif [[ "$status" == "missing" || "$status" == "unset" ]]; then
      printf '  ? %-16s %-9s gate open by default — owner %s should add status: front matter\n' "$file.md" "$status" "$owner"
    else
      printf '  ✓ %-16s %s\n' "$file.md" "$status"
    fi
  done <<<"$GATED"
  tasks_board
  errors_board
}

cmd_check() {
  local agent="${1:-}" closed
  if [[ -z "$agent" ]]; then
    usage >&2
    exit 2
  fi
  if ! closed="$(closed_prereqs "$agent")"; then
    echo "forge-gate: '$agent' is not a Forge agent (known: $(known_agents))" >&2
    exit 2
  fi
  if [[ -z "$closed" ]]; then
    echo "✓ $agent: gate open"
    exit 0
  fi
  echo "✗ $agent: gated — route to the owner first:"
  printf '%s\n' "$closed"
  exit 1
}

cmd_hook() {
  local payload agent closed
  if [[ "${FORGE_GATES:-on}" == "off" ]] || is_source_repo; then exit 0; fi
  if [[ -t 0 ]]; then
    echo "forge-gate: hook mode reads the PreToolUse JSON on stdin" >&2
    exit 0
  fi
  payload="$(cat)"
  agent="$(tr '\n' ' ' <<<"$payload" \
    | grep -o '"subagent_type"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -n 1 | sed 's/.*"\([^"]*\)"$/\1/')" || true
  agent="${agent##*:}" # plugin-namespaced types look like <plugin>:<agent>
  [[ -n "$agent" ]] || exit 0
  if grep -qi 'forge-gate: skip' <<<"$payload"; then exit 0; fi
  closed="$(closed_prereqs "$agent")" || exit 0 # not a Forge agent — never gated
  [[ -n "$closed" ]] || exit 0
  {
    echo "Forge gate closed: the $agent agent can't start yet — its prerequisites in project_context/ aren't ready (Routing Rules, root CLAUDE.md):"
    printf '%s\n' "$closed"
    echo "Route to the owner first; it sets status: ready in the file's front matter once downstream agents can build on it (n/a if deliberately not needed)."
    echo "Only if the user explicitly decided to skip this gate: re-dispatch with a line 'forge-gate: skip — <their reason>' in the prompt, and record the skip in PROGRESS.md."
  } >&2
  exit 2
}

case "${1:-}" in
  status) cmd_status ;;
  check) cmd_check "${2:-}" ;;
  hook) cmd_hook ;;
  -h | --help | help) usage ;;
  *)
    usage >&2
    exit 2
    ;;
esac
