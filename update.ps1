#Requires -Version 5.1

$ConfigFile = Join-Path $env:USERPROFILE ".claude\personas.json"

if (-not (Test-Path $ConfigFile)) {
    Write-Error "No install config found. Run install.ps1 first."
    exit 1
}

$config   = Get-Content $ConfigFile | ConvertFrom-Json
$repoPath = $config.repo_path
$adult    = $config.adult

if (-not (Test-Path $repoPath)) {
    Write-Error "Repo path not found: $repoPath"
    exit 1
}

Write-Host "Pulling latest changes from repo..."
git -C $repoPath pull

Write-Host "Reinstalling personas..."
$installScript = Join-Path $repoPath "install.ps1"
if ($adult) {
    & $installScript -Adult
} else {
    & $installScript
}
