# ai-personae-lib

A collection of Claude personas installable as slash commands in any Claude Code session on your machine.

After install, type `/use-persona <name>` in any project to activate a persona for that session and all future sessions in that project.

---

## Install

**Windows:**
```powershell
git clone https://github.com/alexandrualiu/5b-ai-personae-lib
cd 5b-ai-personae-lib
powershell -ExecutionPolicy Bypass -File install.ps1
```

Add `-Adult` to include personas with explicit content rating:
```powershell
.\install.ps1 -Adult
```

**Linux / Mac:**
```bash
git clone https://github.com/alexandrualiu/5b-ai-personae-lib
cd 5b-ai-personae-lib
chmod +x install.sh
./install.sh
# or: ./install.sh --adult
```

Install registers two global slash commands in `~/.claude/commands/`:
- `/use-persona` — activate a persona on the current project
- `/list-personas` — list all available personas

---

## Usage

### Activate a persona on a project

Open Claude Code in any project directory and run:

```
/use-persona <name>
```

This writes an `## Active Persona` section into the project's `CLAUDE.md`, so the persona loads automatically at the start of every future session in that project.

If the persona name is not found, Claude will list available options and ask you to pick one.

### List installed personas

```
/list-personas
```

Displays all personas grouped by category, with name and content rating.

### Remove a persona from a project

Delete the `## Active Persona` section from the project's `CLAUDE.md`.

---

## Update

When new personas are added to the repo, pull and reinstall:

**Windows:**
```powershell
.\update.ps1
```

**Linux / Mac:**
```bash
./update.sh
```

Update reads the original install flags from `~/.claude/personas.json` and re-runs install automatically.

---

## Adding your own personas

Create a `private/` folder in the repo root — it is gitignored and never committed:

```
private/
  my-persona.md
```

Each persona file must start with a YAML frontmatter block:

```yaml
---
name: my-persona
category: companion
content_rating: sfw
version: 1.0
last_modified: 2025-01-01
---

# My Persona

(persona definition here)
```

**Content ratings:**

| Rating | Installed by default | Requires |
|--------|----------------------|----------|
| `sfw` | Yes | — |
| `semi` | Yes | — |
| `explicit` | No | `--adult` / `-Adult` |

Re-run install after adding new personas to `private/`.

### Adding public personas

Place persona files under `personas/<category>/`:

```
personas/
  professional/
    my-assistant.md
  fictional/
    books/
      my-character.md
```

Folders are created as needed — no predefined structure required. Open a PR to contribute.

---

## How it works

Install does **not** copy persona files. It saves an index (`~/.claude/personas.json`) with the name, category, content rating, and **source path** of each persona. `/use-persona` writes that source path directly into the project's `CLAUDE.md`.

This means: editing a persona file takes effect immediately in the next Claude Code session — no reinstall needed.

---

## Platform note

Anthropic consumer surfaces (Claude desktop app, Claude.ai, mobile) apply stricter content policies than Claude Code (CLI). Personas with `semi` or `explicit` ratings may be partially restricted on those surfaces.
