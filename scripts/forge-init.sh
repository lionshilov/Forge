#!/usr/bin/env bash
#
# forge-init.sh — bootstrap a new project with the Forge agent system.
#
# Usage:
#   ./scripts/forge-init.sh <target-directory> [project-name] [--template <name>]
#
# Examples:
#   ./scripts/forge-init.sh ~/code/my-app "My App"
#   ./scripts/forge-init.sh ~/code/calc "Calc" --template vanilla-static
#   ./scripts/forge-init.sh ~/code/web "Web" --template nextjs-supabase
#   ./scripts/forge-init.sh ~/code/ios-app "iOS App" --template swiftui-ios
#
# What it does:
#   1. Creates the target directory (if it doesn't exist)
#   2. Copies Forge's CLAUDE.md, agents/, and project_context/ templates
#   3. If --template is given, layers the chosen stack starter on top
#   4. Initializes git with an initial commit
#   5. Prints next steps

set -euo pipefail

TARGET=""
PROJECT_NAME=""
TEMPLATE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --template)
      TEMPLATE="$2"
      shift 2
      ;;
    --help|-h)
      grep -E '^#( |$)' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    --*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [[ -z "$TARGET" ]]; then TARGET="$1"
      elif [[ -z "$PROJECT_NAME" ]]; then PROJECT_NAME="$1"
      else echo "Unexpected argument: $1" >&2; exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <target-directory> [project-name] [--template <name>]" >&2
  echo "Templates available: vanilla-static, nextjs-supabase, swiftui-ios" >&2
  exit 1
fi

PROJECT_NAME="${PROJECT_NAME:-$(basename "$TARGET")}"
FORGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -n "$TEMPLATE" && ! -d "$FORGE_ROOT/templates/$TEMPLATE" ]]; then
  echo "Unknown template: $TEMPLATE" >&2
  echo "Available templates:" >&2
  find "$FORGE_ROOT/templates" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort | sed 's/^/  /' >&2
  exit 1
fi

if [[ -e "$TARGET" && -n "$(ls -A "$TARGET" 2>/dev/null || true)" ]]; then
  echo "Target '$TARGET' exists and is not empty. Aborting." >&2
  exit 1
fi

mkdir -p "$TARGET"

# Copy Forge brain
cp "$FORGE_ROOT/CLAUDE.md" "$TARGET/CLAUDE.md"
cp -R "$FORGE_ROOT/agents" "$TARGET/agents"
cp -R "$FORGE_ROOT/project_context" "$TARGET/project_context"
cp "$FORGE_ROOT/.gitignore" "$TARGET/.gitignore"

# Layer template on top (if any)
if [[ -n "$TEMPLATE" ]]; then
  # -R preserves structure; overwriting is fine since target is empty of template files
  rsync -a --exclude 'README.md' --exclude '.DS_Store' "$FORGE_ROOT/templates/$TEMPLATE/" "$TARGET/" 2>/dev/null || {
    # Fallback if rsync missing
    (cd "$FORGE_ROOT/templates/$TEMPLATE" && \
     find . -type f -not -name 'README.md' -print0 | while IFS= read -r -d '' f; do
       mkdir -p "$TARGET/$(dirname "$f")"
       cp "$FORGE_ROOT/templates/$TEMPLATE/$f" "$TARGET/$f"
     done)
  }
fi

# README — prefer Forge's bootstrap copy; template READMEs inform via their own copies inside subdirs
cat > "$TARGET/README.md" <<EOF
# $PROJECT_NAME

Bootstrapped with [Forge](https://github.com/)${TEMPLATE:+ using the \`$TEMPLATE\` template}.

## Getting started

1. Open this directory in Claude Code
2. Describe what you want to build
3. The Orchestrator (configured in \`CLAUDE.md\`) routes your work to specialist agents under \`agents/\`

Cross-agent context lives in \`project_context/\`:

- \`PRODUCT.md\` — what you're building and for whom
- \`ARCHITECTURE.md\` — system design decisions
- \`CONVENTIONS.md\` — code style and patterns
- \`INTERFACES.md\` — contracts between modules
- \`ERRORS_LOG.md\` — failures and their fixes
- \`PROGRESS.md\` — current task status
EOF

# Template-specific run instructions
if [[ "$TEMPLATE" == "nextjs-supabase" ]]; then
  cat >> "$TARGET/README.md" <<'EOF'

## Run (Next.js + Supabase)

```bash
pnpm install            # or npm install
cp .env.example .env.local   # then fill in Supabase values
pnpm dev
```
EOF
elif [[ "$TEMPLATE" == "vanilla-static" ]]; then
  cat >> "$TARGET/README.md" <<'EOF'

## Run (vanilla static)

```bash
open index.html         # macOS — or double-click
# or serve with any static server:
python3 -m http.server 8000
```
EOF
elif [[ "$TEMPLATE" == "swiftui-ios" ]]; then
  cat >> "$TARGET/README.md" <<'EOF'

## Run (SwiftUI iOS)

1. Create a new Xcode project (iOS → App → SwiftUI, iOS 17+ deployment target)
2. Copy `Sources/` into the Xcode project's main group
3. Build and run

See `Sources/` for the MVVM starter.
EOF
fi

# Git init. If the user hasn't configured git identity (e.g. CI, fresh machine),
# init the repo but skip the initial commit — the user can commit once they
# configure their identity. Forge doesn't need to force a commit to be useful.
if [[ ! -d "$TARGET/.git" ]]; then
  (
    cd "$TARGET"
    git init -q
    if git config user.email >/dev/null 2>&1 && git config user.name >/dev/null 2>&1; then
      git add -A
      git commit -q -m "Initial commit (bootstrapped with Forge${TEMPLATE:+, $TEMPLATE template})"
    else
      git add -A
      echo "  (git identity not configured — staged changes but didn't commit)" >&2
    fi
  )
fi

cat <<EOF

✓ Forge project created at: $TARGET${TEMPLATE:+
✓ Template applied: $TEMPLATE}

Next steps:
  cd "$TARGET"
EOF
case "$TEMPLATE" in
  nextjs-supabase)
    echo "  pnpm install && cp .env.example .env.local"
    echo "  claude            # then describe what you want to build"
    ;;
  vanilla-static)
    echo "  open index.html"
    echo "  claude            # then describe what you want to build"
    ;;
  swiftui-ios)
    echo "  # Create an Xcode project, copy Sources/ in"
    echo "  claude            # then describe what you want to build"
    ;;
  *)
    echo "  claude            # then describe what you want to build"
    ;;
esac
echo
