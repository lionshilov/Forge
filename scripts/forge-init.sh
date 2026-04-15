#!/usr/bin/env bash
#
# forge-init.sh — bootstrap a new project with the Forge agent system.
#
# Usage:
#   ./scripts/forge-init.sh <target-directory> [project-name]
#
# Example:
#   ./scripts/forge-init.sh ~/code/my-new-app "My New App"
#
# What it does:
#   1. Creates the target directory (if it doesn't exist)
#   2. Copies Forge's CLAUDE.md, agents/, and project_context/ templates into it
#   3. Initializes git
#   4. Prints next steps

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <target-directory> [project-name]" >&2
  exit 1
fi

TARGET="$1"
PROJECT_NAME="${2:-$(basename "$TARGET")}"
FORGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -e "$TARGET" && -n "$(ls -A "$TARGET" 2>/dev/null || true)" ]]; then
  echo "Target '$TARGET' exists and is not empty. Aborting." >&2
  exit 1
fi

mkdir -p "$TARGET"

# Copy the agent brain into the new project
cp "$FORGE_ROOT/CLAUDE.md" "$TARGET/CLAUDE.md"
cp -R "$FORGE_ROOT/agents" "$TARGET/agents"
cp -R "$FORGE_ROOT/project_context" "$TARGET/project_context"
cp "$FORGE_ROOT/.gitignore" "$TARGET/.gitignore"

# Minimal README so the project isn't naked
cat > "$TARGET/README.md" <<EOF
# $PROJECT_NAME

Bootstrapped with [Forge](https://github.com/) — a multi-agent system for going from idea to MVP with Claude Code.

## Getting started

1. Open this directory in Claude Code
2. Describe what you want to build
3. The Orchestrator (configured in \`CLAUDE.md\`) will decompose the work and route subtasks to specialist agents under \`agents/\`

All cross-agent context lives in \`project_context/\`:

- \`PRODUCT.md\` — what you're building and for whom (created by the Product agent)
- \`ARCHITECTURE.md\` — how the system is designed (created by the Architect)
- \`CONVENTIONS.md\` — code style and patterns (created by the Architect)
- \`INTERFACES.md\` — contracts between modules (created by the Architect)
- \`ERRORS_LOG.md\` — failures and their fixes (maintained by QA)
- \`PROGRESS.md\` — current task status (maintained by the Orchestrator)
EOF

# Initialize git
if [[ ! -d "$TARGET/.git" ]]; then
  (cd "$TARGET" && git init -q && git add -A && git commit -q -m "Initial commit (bootstrapped with Forge)")
fi

cat <<EOF

✓ Forge project created at: $TARGET

Next steps:
  cd "$TARGET"
  claude            # open in Claude Code
  → then just describe what you want to build

EOF
