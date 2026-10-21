param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

$policyScript = Join-Path $PSScriptRoot 'Test-ProjectPolicy.ps1'
if (-not (Test-Path -LiteralPath $policyScript)) {
    throw "Policy script not found: $policyScript"
}

& powershell -NoProfile -ExecutionPolicy Bypass -File $policyScript -RepoRoot $RepoRoot
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

