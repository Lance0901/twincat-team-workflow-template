param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

try {
    $root = (Resolve-Path -LiteralPath $RepoRoot).Path
    $templateRoot = (Resolve-Path -LiteralPath (Join-Path $root 'template')).Path
    $errors = [System.Collections.Generic.List[object]]::new()

    $requiredFiles = @(
        'AGENTS.md',
        'README.md',
        'CHANGELOG.md',
        'VERSION',
        'template\AGENTS.md',
        'template\PROJECT_STATE.md',
        'template\STYLE_GUIDE.md',
        'template\orca.yaml',
        'template\docs\architecture\team-workflow.md',
        'template\.harness\config.json',
        'template\tools\Setup-Project.ps1',
        'template\tools\Test-ProjectPolicy.ps1',
        'scripts\Install-TwinCATTeamWorkflow.ps1',
        'scripts\Test-Template.ps1'
    )

    foreach ($relativePath in $requiredFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $root $relativePath))) {
            $errors.Add([ordered]@{
                code = 'REQUIRED_FILE_MISSING'
                path = $relativePath
                message = 'Required file is missing.'
            })
        }
    }

    $configPath = Join-Path $templateRoot '.harness\config.json'
    if (Test-Path -LiteralPath $configPath) {
        $config = Get-Content -Raw -LiteralPath $configPath | ConvertFrom-Json
        if ($config.defaults.runtimeApproval -eq $true) {
            $errors.Add([ordered]@{
                code = 'RUNTIME_APPROVAL_DEFAULT_TRUE'
                path = 'template\.harness\config.json'
                message = 'Runtime approval must not default to true.'
            })
        }

        foreach ($name in @('activate', 'loginDownload', 'plcStateChange', 'adsWrite', 'ioChange', 'taskChange', 'libraryChange', 'routeChange')) {
            if ([string]$config.approvals.$name -ne 'explicit') {
                $errors.Add([ordered]@{
                    code = 'DANGEROUS_APPROVAL_NOT_EXPLICIT'
                    path = "template\.harness\config.json:approvals.$name"
                    message = "approvals.$name must be explicit."
                })
            }
        }
    }

    $orcaPath = Join-Path $templateRoot 'orca.yaml'
    if (Test-Path -LiteralPath $orcaPath) {
        $orcaContent = Get-Content -Raw -LiteralPath $orcaPath
        if ($orcaContent -notmatch 'tools/Setup-Project\.ps1') {
            $errors.Add([ordered]@{
                code = 'ORCA_SETUP_MISSING'
                path = 'template\orca.yaml'
                message = 'Orca setup must call tools/Setup-Project.ps1 with a relative path.'
            })
        }
    }

    foreach ($file in Get-ChildItem -LiteralPath $templateRoot -File -Recurse -Force) {
        if ($file.Extension -notin @('.md', '.json', '.yaml', '.yml', '.ps1', '.gitignore') -and $file.Name -ne '.gitkeep') {
            continue
        }

        $content = Get-Content -Raw -LiteralPath $file.FullName -ErrorAction SilentlyContinue
        if ($content -match '(?i)[A-Z]:\\Users\\') {
            $errors.Add([ordered]@{
                code = 'ABSOLUTE_USER_PATH_FOUND'
                path = $file.FullName.Substring($templateRoot.Length + 1)
                message = 'Template contains a Windows user absolute path.'
            })
        }
    }

    $policyScript = Join-Path $templateRoot 'tools\Test-ProjectPolicy.ps1'
    if (Test-Path -LiteralPath $policyScript) {
        $policyOutput = & powershell -NoProfile -ExecutionPolicy Bypass -File $policyScript -RepoRoot $templateRoot
        if ($LASTEXITCODE -ne 0) {
            $errors.Add([ordered]@{
                code = 'PROJECT_POLICY_FAILED'
                path = 'template\tools\Test-ProjectPolicy.ps1'
                message = ($policyOutput -join [Environment]::NewLine)
            })
        }
    }

    [ordered]@{
        success = ($errors.Count -eq 0)
        stage = 'TemplateValidation'
        data = [ordered]@{
            repoRoot = $root
            templateRoot = $templateRoot
            requiredFileCount = $requiredFiles.Count
            errorCount = $errors.Count
        }
        warnings = @()
        errors = @($errors)
    } | ConvertTo-Json -Depth 8

    if ($errors.Count -gt 0) {
        exit 1
    }
}
catch {
    [ordered]@{
        success = $false
        stage = 'TemplateValidation'
        data = [ordered]@{}
        warnings = @()
        errors = @(
            [ordered]@{
                code = 'TEMPLATE_VALIDATION_FAILED'
                message = $_.Exception.Message
            }
        )
    } | ConvertTo-Json -Depth 6
    exit 1
}
