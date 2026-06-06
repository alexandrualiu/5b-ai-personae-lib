#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="$HOME/.claude/personas.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: No install config found. Run install.sh first." >&2
    exit 1
fi

repo_path=$(awk -F'"' '/"repo_path"/ {print $4}' "$CONFIG_FILE")
adult=$(awk -F': ' '/"adult"/ {print $2}' "$CONFIG_FILE" | tr -d ',' | tr -d ' ')

if [[ ! -d "$repo_path" ]]; then
    echo "Error: Repo path not found: $repo_path" >&2
    exit 1
fi

echo "Pulling latest changes from repo..."
git -C "$repo_path" pull

echo "Reinstalling personas..."
if [[ "$adult" == "true" ]]; then
    bash "$repo_path/install.sh" --adult
else
    bash "$repo_path/install.sh"
fi
