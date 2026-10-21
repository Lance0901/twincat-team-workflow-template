param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

try {
    $root = (Resolve-Path -LiteralPath $RepoRoot).Path
    $requiredFiles = @(
        'AGENTS.md',
        'PROJECT_STATE.md',
        'STYLE_GUIDE.md',
        'docs\architecture\team-workflow.md',
        '.harness\config.json'
    )

    $missing = @(
        foreach ($relativePath in $requiredFiles) {
            if (-not (Test-Path -LiteralPath (Join-Path $root $relativePath))) {
                $relativePath
            }
        }
    )

    if ($missing.Count -gt 0) {
        throw "Missing required files: $($missing -join ', ')"
    }

    $configPath = Join-Path $root '.harness\config.json'
    $config = Get-Content -Raw -LiteralPath $configPath | ConvertFrom-Json

    if ($config.defaults.runtimeApproval -eq $true) {
        throw 'defaults.runtimeApproval must not be true.'
    }

    foreach ($name in @('activate', 'loginDownload', 'plcStateChange', 'adsWrite', 'ioChange', 'taskChange', 'libraryChange', 'routeChange')) {
        if ([string]$config.approvals.$name -ne 'explicit') {
            throw "approvals.$name must be explicit."
        }
    }

    [ordered]@{
        success = $true
        stage = 'ProjectPolicy'
        data = [ordered]@{
            repoRoot = $root
            requiredFileCount = $requiredFiles.Count
            configPath = $configPath
        }
        warnings = @()
        errors = @()
    } | ConvertTo-Json -Depth 6
}
catch {
    [ordered]@{
        success = $false
        stage = 'ProjectPolicy'
        data = [ordered]@{}
        warnings = @()
        errors = @(
            [ordered]@{
                code = 'PROJECT_POLICY_INVALID'
                message = $_.Exception.Message
            }
        )
    } | ConvertTo-Json -Depth 6
    exit 1
}

