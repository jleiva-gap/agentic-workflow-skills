param(
    [string]$MarketplaceRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) '..\agentic-workflow-skills-marketplace'),
    [switch]$Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageRoot = Split-Path -Parent $scriptRoot
$distRoot = Join-Path $packageRoot 'dist'
$generatedMarketplaceRoot = Join-Path $distRoot 'plugin-marketplace'
$protectedRelativePaths = @(
    '.git',
    '.gitignore',
    'hosts',
    'LICENSE',
    'README.md'
)

function Get-RelativeFiles {
    param([Parameter(Mandatory)] [string]$Root)

    Get-ChildItem -LiteralPath $Root -Recurse -File | ForEach-Object {
        [pscustomobject]@{
            RelativePath = $_.FullName.Substring($Root.Length).TrimStart('\','/')
            FullName = $_.FullName
        }
    }
}

function Test-IsProtectedPath {
    param([Parameter(Mandatory)] [string]$RelativePath)

    foreach ($protected in $protectedRelativePaths) {
        if ($RelativePath -ieq $protected) {
            return $true
        }

        if ($protected -eq 'hosts' -and $RelativePath.StartsWith('hosts\', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }

        if ($protected -eq 'hosts' -and $RelativePath.StartsWith('hosts/', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }

        if ($protected -eq '.git' -and $RelativePath.StartsWith('.git\', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }

        if ($protected -eq '.git' -and $RelativePath.StartsWith('.git/', [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory)] [string]$Path,
        [Parameter(Mandatory)] [string]$Content
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path $directory)) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }

    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    $normalized = $Content -replace "`r`n", "`n"
    $normalized = $normalized -replace "`r", "`n"
    [System.IO.File]::WriteAllText($Path, $normalized, $utf8NoBom)
}

function Assert-RepositoryRoot {
    param([Parameter(Mandatory)] [string]$Root)

    if (-not (Test-Path (Join-Path $Root '.git'))) {
        throw "Marketplace root does not look like a git repository: $Root"
    }
}

function Assert-GeneratedBundlePresent {
    if (-not (Test-Path $generatedMarketplaceRoot)) {
        throw "Generated marketplace bundle not found: $generatedMarketplaceRoot"
    }
}

function Assert-GeneratedMarketplaceMatches {
    param(
        [Parameter(Mandatory)] [string]$SourceRoot,
        [Parameter(Mandatory)] [string]$TargetRoot
    )

    $sourceFiles = @(Get-RelativeFiles -Root $SourceRoot)
    $targetFiles = @(Get-RelativeFiles -Root $TargetRoot | Where-Object { -not (Test-IsProtectedPath -RelativePath $_.RelativePath) })
    $sourcePaths = @($sourceFiles.RelativePath)
    $targetPaths = @($targetFiles.RelativePath)
    $missing = @($sourcePaths | Where-Object { $_ -notin $targetPaths })

    if ($missing.Count -gt 0) {
        throw "Marketplace drift detected. Missing: $($missing -join ', ')."
    }

    foreach ($sourceFile in $sourceFiles) {
        $targetFile = Join-Path $TargetRoot $sourceFile.RelativePath
        $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourceFile.FullName).Hash
        $targetHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $targetFile).Hash
        if ($sourceHash -ne $targetHash) {
            throw "Marketplace drift detected in $($sourceFile.RelativePath)."
        }
    }
}

function Write-RepositoryReadme {
    param([Parameter(Mandatory)] [string]$Root)

    $readmePath = Join-Path $Root 'README.md'
    if (Test-Path $readmePath) {
        return
    }

    Write-Utf8NoBom -Path $readmePath -Content @'
# Agentic Workflow Skills Marketplace

This repository is the published marketplace bundle for [agentic-workflow-skills](https://github.com/jleiva-gap/agentic-workflow-skills).

The bundle is generated from the source repository and synced here so Codex, GitHub Copilot CLI, and Claude Code can install it from a real Git repository URL.
'@
}

function Sync-Repository {
    param(
        [Parameter(Mandatory)] [string]$SourceRoot,
        [Parameter(Mandatory)] [string]$TargetRoot
    )

    if (-not (Test-Path $TargetRoot)) {
        New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
    }

    foreach ($targetFile in Get-RelativeFiles -Root $TargetRoot) {
        if (Test-IsProtectedPath -RelativePath $targetFile.RelativePath) {
            continue
        }

        $sourceFile = Join-Path $SourceRoot $targetFile.RelativePath
        if (-not (Test-Path $sourceFile)) {
            Remove-Item -LiteralPath $targetFile.FullName -Force
        }
    }

    foreach ($sourceFile in Get-RelativeFiles -Root $SourceRoot) {
        $targetFile = Join-Path $TargetRoot $sourceFile.RelativePath
        $targetParent = Split-Path -Parent $targetFile
        New-Item -ItemType Directory -Force -Path $targetParent | Out-Null
        Copy-Item -LiteralPath $sourceFile.FullName -Destination $targetFile -Force
    }

    Write-RepositoryReadme -Root $TargetRoot
}

try {
    Assert-RepositoryRoot -Root $MarketplaceRoot
    Assert-GeneratedBundlePresent

    if ($Check) {
        Assert-GeneratedMarketplaceMatches -SourceRoot $generatedMarketplaceRoot -TargetRoot $MarketplaceRoot
        Write-Host "Check passed. Published marketplace matches $MarketplaceRoot."
        exit 0
    }

    Sync-Repository -SourceRoot $generatedMarketplaceRoot -TargetRoot $MarketplaceRoot
    Write-Host "Published marketplace bundle to $MarketplaceRoot."
    Write-Host (Join-Path $MarketplaceRoot 'marketplace.json')
    exit 0
} catch {
    Write-Error $_
    exit 1
}
