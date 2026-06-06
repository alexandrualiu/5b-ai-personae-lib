#Requires -Version 5.1
param(
    [switch]$Adult,
    [switch]$All
)

$RepoRoot    = $PSScriptRoot
$ClaudeDir   = Join-Path $env:USERPROFILE ".claude"
$CommandsDir = Join-Path $ClaudeDir "commands"
$ConfigFile  = Join-Path $ClaudeDir "personas.json"

New-Item -ItemType Directory -Force -Path $CommandsDir | Out-Null

function Parse-Frontmatter {
    param([string]$FilePath)
    $lines = Get-Content $FilePath
    if ($lines[0] -ne '---') { return $null }
    $meta = @{}
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -eq '---') { break }
        if ($lines[$i] -match '^(\w+):\s*(.+)$') {
            $meta[$Matches[1]] = $Matches[2].Trim()
        }
    }
    return $meta
}

$personas  = @()
$installed = 0
$skipped   = 0

$searchPaths = @(
    Join-Path $RepoRoot "personas"
    Join-Path $RepoRoot "private"
)

foreach ($searchPath in $searchPaths) {
    if (-not (Test-Path $searchPath)) { continue }

    Get-ChildItem -Path $searchPath -Recurse -Filter "*.md" | ForEach-Object {
        $meta = Parse-Frontmatter $_.FullName
        if (-not $meta) {
            Write-Host "  SKIP (no frontmatter): $($_.Name)"
            $skipped++
            return
        }

        $rating = $meta['content_rating']
        if ($rating -eq 'explicit' -and -not $Adult -and -not $All) {
            Write-Host "  SKIP (explicit, use -Adult): $($meta['name'])"
            $skipped++
            return
        }

        $personas += @{
            name           = $meta['name']
            category       = $meta['category']
            content_rating = $rating
            source         = $_.FullName
        }

        Write-Host "  OK: $($meta['name']) ($($meta['category']), $rating)"
        $installed++
    }
}

# Save index — source paths point directly to repo files, no copying
$config = @{
    repo_path = $RepoRoot
    adult     = $Adult.IsPresent
    timestamp = (Get-Date -Format 'o')
    personas  = $personas
} | ConvertTo-Json -Depth 3
Set-Content $ConfigFile $config -Encoding UTF8

# Install generic global commands
Set-Content (Join-Path $CommandsDir "use-persona.md") @'
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
'@ -Encoding UTF8

Set-Content (Join-Path $CommandsDir "list-personas.md") @'
Read the file `~/.claude/personas.json`.

Display all personas grouped by category. For each show: name, content_rating, source path.
'@ -Encoding UTF8

Write-Host ""
Write-Host "Installed: $installed  Skipped: $skipped"
Write-Host "Global commands ready: /use-persona, /list-personas"
