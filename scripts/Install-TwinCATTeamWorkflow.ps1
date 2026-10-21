param(
    [Parameter(Mandatory = $true)]
    [string]$TargetRepo,

    [switch]$Apply,
    [switch]$Overwrite
)

$ErrorActionPreference = 'Stop'

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$FullPath
    )

    $baseUri = [System.Uri]::new(($BasePath.TrimEnd('\') + '\'))
    $fileUri = [System.Uri]::new($FullPath)
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($fileUri).ToString()).Replace('/', '\')
}

try {
    $sourceRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\template')).Path
    $targetRoot = (Resolve-Path -LiteralPath $TargetRepo).Path

    if ($sourceRoot -eq $targetRoot) {
        throw 'TargetRepo must not be the template source directory.'
    }

    $plan = @(
        foreach ($sourceFile in Get-ChildItem -LiteralPath $sourceRoot -File -Recurse -Force) {
            $relativePath = Get-RelativePath -BasePath $sourceRoot -FullPath $sourceFile.FullName
            $destination = Join-Path $targetRoot $relativePath
            $action = 'create'

            if (Test-Path -LiteralPath $destination) {
                $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourceFile.FullName).Hash
                $destinationHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $destination).Hash
                if ($sourceHash -eq $destinationHash) {
                    $action = 'unchanged'
                }
                elseif ($Overwrite) {
                    $action = 'overwrite'
                }
                else {
                    $action = 'conflict'
                }
            }

            [ordered]@{
                path = $relativePath
                action = $action
                source = $sourceFile.FullName
                destination = $destination
            }
        }
    )

    $conflicts = @($plan | Where-Object { $_.action -eq 'conflict' })
    if ($Apply -and $conflicts.Count -gt 0) {
        $conflictPaths = $conflicts.path -join ', '
        throw "Installation stopped. Existing files differ: $conflictPaths. Review them before using -Overwrite."
    }

    if ($Apply) {
        foreach ($item in $plan | Where-Object { $_.action -in @('create', 'overwrite') }) {
            $destinationDirectory = Split-Path -Parent $item.destination
            if (-not (Test-Path -LiteralPath $destinationDirectory)) {
                New-Item -ItemType Directory -Force -Path $destinationDirectory | Out-Null
            }
            Copy-Item -LiteralPath $item.source -Destination $item.destination -Force:$Overwrite
        }
    }

    $warnings = @()
    if ($conflicts.Count -gt 0) {
        $warnings += 'Conflicting files were not modified.'
    }

    [ordered]@{
        success = $true
        stage = 'InstallTwinCATTeamWorkflow'
        data = [ordered]@{
            sourceRoot = $sourceRoot
            targetRoot = $targetRoot
            apply = [bool]$Apply
            overwrite = [bool]$Overwrite
            counts = [ordered]@{
                create = @($plan | Where-Object { $_.action -eq 'create' }).Count
                overwrite = @($plan | Where-Object { $_.action -eq 'overwrite' }).Count
                unchanged = @($plan | Where-Object { $_.action -eq 'unchanged' }).Count
                conflict = $conflicts.Count
            }
            files = $plan
        }
        warnings = @($warnings)
        errors = @()
    } | ConvertTo-Json -Depth 8
}
catch {
    [ordered]@{
        success = $false
        stage = 'InstallTwinCATTeamWorkflow'
        data = [ordered]@{}
        warnings = @()
        errors = @(
            [ordered]@{
                code = 'INSTALL_FAILED'
                message = $_.Exception.Message
            }
        )
    } | ConvertTo-Json -Depth 6
    exit 1
}

