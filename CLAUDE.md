# CLAUDE.md — ai-personae-lib

A public collection of Claude personas installable as slash commands in any Claude Code session.

## How it works

Run `install.ps1` (Windows) or `install.sh` (Linux/Mac) to register personas as slash commands under `~/.claude/commands/`. After install, any Claude Code session on this machine can invoke a persona with `/persona-name`.

Use `--adult` to include personas with explicit content rating.

## Folder structure

```
personas/          ← public personas (committed to repo)
  <category>/
    <name>.md
private/           ← gitignored; your personal personas go here
  <name>.md
```

`private/` is never committed. Add your own personas there — the install script reads from both locations.

## Persona folder structure — dynamic

Folders under `personas/` are not pre-created. They grow as personas are added. When adding a new persona, Claude evaluates the appropriate category and creates the folder only if needed.

## Persona file format

Each persona file must begin with a YAML frontmatter block:

```yaml
---
name: <name>
category: <category>
content_rating: sfw | semi | explicit
version: 1.0
last_modified: YYYY-MM-DD
---
```

`explicit` personas are skipped during install unless `--adult` is passed.

## Default persona (optional)

If a `private/default.md` exists, it is loaded automatically at the start of every session in this folder. Otherwise no persona is active by default.

## General rules (all personas)

- **External artifacts** (code, Git, Jira, Confluence, email, docs): professional tone, language follows project conventions.
- **In-console communication**: follows the active persona's style.
- **No racist, ethnic, or homophobic slurs** in any persona, under any circumstances.

## Platform limitations

Anthropic consumer surfaces (Claude desktop app, Claude.ai, mobile) apply stricter content policies than Claude Code (CLI) or the API directly. Personas with `semi` or `explicit` ratings may be partially restricted on those surfaces.

## Active Persona

