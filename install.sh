#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADULT=false
ALL=false

for arg in "$@"; do
    case $arg in
        --adult) ADULT=true ;;
        --all)   ALL=true ;;
    esac
done

CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
CONFIG_FILE="$CLAUDE_DIR/personas.json"

mkdir -p "$COMMANDS_DIR"

parse_frontmatter() {
    local file="$1"
    local key="$2"
    if [[ "$(head -1 "$file")" != "---" ]]; then echo ""; return; fi
    awk -v key="$key" '
        /^---/ { if (NR>1) exit }
        NR>1 && $0 ~ "^"key": " { sub("^"key": ",""); print; exit }
    ' "$file"
}

personas_json="[]"
installed=0
skipped=0

for search_path in "$REPO_ROOT/personas" "$REPO_ROOT/private"; do
    [[ -d "$search_path" ]] || continue

    while IFS= read -r -d '' file; do
        name=$(parse_frontmatter "$file" "name")
        if [[ -z "$name" ]]; then
            echo "  SKIP (no frontmatter): $(basename "$file")"
            ((skipped++)) || true
            continue
        fi

        rating=$(parse_frontmatter "$file" "content_rating")
        category=$(parse_frontmatter "$file" "category")

        if [[ "$rating" == "explicit" && "$ADULT" == "false" && "$ALL" == "false" ]]; then
            echo "  SKIP (explicit, use --adult): $name"
            ((skipped++)) || true
            continue
        fi

        # Append to personas array (build JSON manually for portability)
        entry="{\"name\":\"$name\",\"category\":\"$category\",\"content_rating\":\"$rating\",\"source\":\"$file\"}"
        if [[ "$personas_json" == "[]" ]]; then
            personas_json="[$entry]"
        else
            personas_json="${personas_json%]},${entry}]"
        fi

        echo "  OK: $name ($category, $rating)"
        ((installed++)) || true
    done < <(find "$search_path" -name "*.md" -print0)
done

# Save index — source paths point directly to repo files, no copying
cat > "$CONFIG_FILE" <<EOF
{
  "repo_path": "$REPO_ROOT",
  "adult": $ADULT,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "personas": $personas_json
}
EOF

# Install generic global commands
cat > "$COMMANDS_DIR/use-persona.md" <<'CMD'
Read the file `~/.claude/personas.json` to get the list of available personas.

Find the persona whose name matches "$ARGUMENTS" (case-insensitive).

If not found: display all available personas grouped by category and ask the user to pick one.

If found:
1. Read the current directory's CLAUDE.md if it exists.
2. If an "## Active Persona" section already exists, replace it. Otherwise append it.
3. Write this section into CLAUDE.md, using the exact source path from personas.json:

## Active Persona

At the start of every session in this project, read the file `[source]` in full and adopt the [name] persona, following all rules defined in that file.

Confirm to the user which persona is now active for this project.
CMD

cat > "$COMMANDS_DIR/list-personas.md" <<'CMD'
Read the file `~/.claude/personas.json`.

Display all personas grouped by category. For each show: name, content_rating, source path.
CMD

echo ""
echo "Installed: $installed  Skipped: $skipped"
echo "Global commands ready: /use-persona, /list-personas"
