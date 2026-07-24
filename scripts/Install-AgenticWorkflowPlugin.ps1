[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('codex', 'copilot', 'claude', 'all')]
    [string]$Platform,

    [ValidateSet('project', 'user')]
    [string]$Scope = 'project',

    [string]$ProjectRoot = (Get-Location).Path,

    [switch]$Force,

    [ValidateSet('generated', 'marketplace')]
    [string]$Source = 'generated',

    [string]$MarketplaceSource
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageRoot = Split-Path -Parent $scriptRoot
$pluginMarketplaceRoot = Join-Path $packageRoot 'dist\plugin-marketplace'
$platforms = @('codex', 'copilot', 'claude')
$pluginName = 'agentic-workflow-skills'
$marketplaceName = 'agentic-workflow-skills-local'

function Get-HomeRoot {
    if (-not [string]::IsNullOrWhiteSpace($env:AGENTIC_WORKFLOW_HOME)) {
        return $env:AGENTIC_WORKFLOW_HOME
    }
    if (-not [string]::IsNullOrWhiteSpace($env:HOME)) {
        return $env:HOME
    }
    return $HOME
}

function Test-PluginBundleCurrent {
    $buildScript = Join-Path $scriptRoot 'Build-AgenticWorkflowPlugin.ps1'
    & pwsh -NoProfile -File $buildScript -Check | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw 'Generated plugin bundle is not current. Run Build-AgenticWorkflowPlugin.ps1 before installing.'
    }
}

function Compare-File {
    param(
        [Parameter(Mandatory)] [string]$SourceFile,
        [Parameter(Mandatory)] [string]$TargetFile
    )

    if (-not (Test-Path $TargetFile)) { return $false }
    $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $SourceFile).Hash
    $targetHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $TargetFile).Hash
    return $sourceHash -eq $targetHash
}

function Get-RelativeFiles {
    param([Parameter(Mandatory)] [string]$Root)

    Get-ChildItem -LiteralPath $Root -Recurse -File | ForEach-Object {
        [pscustomobject]@{
            RelativePath = $_.FullName.Substring($Root.Length).TrimStart('\','/')
            FullName = $_.FullName
        }
    }
}

function Assert-InstallSafe {
    param(
        [Parameter(Mandatory)] [string]$SourceRoot,
        [Parameter(Mandatory)] [string]$TargetRoot
    )

    if ($Force -or -not (Test-Path $TargetRoot)) { return }

    foreach ($sourceFile in Get-RelativeFiles -Root $SourceRoot) {
        $targetFile = Join-Path $TargetRoot $sourceFile.RelativePath
        if ((Test-Path $targetFile) -and -not (Compare-File -SourceFile $sourceFile.FullName -TargetFile $targetFile)) {
            throw "Refusing to overwrite modified plugin file without -Force: $targetFile"
        }
    }
}

function Copy-Directory {
    param(
        [Parameter(Mandatory)] [string]$SourceRoot,
        [Parameter(Mandatory)] [string]$TargetRoot
    )

    if (-not (Test-Path $SourceRoot)) {
        throw "Required plugin source not found: $SourceRoot"
    }

    foreach ($sourceFile in Get-RelativeFiles -Root $SourceRoot) {
        $targetFile = Join-Path $TargetRoot $sourceFile.RelativePath
        $targetParent = Split-Path -Parent $targetFile
        New-Item -ItemType Directory -Force -Path $targetParent | Out-Null
        Copy-Item -LiteralPath $sourceFile.FullName -Destination $targetFile -Force
    }
}

function Get-InstallTarget {
    param([Parameter(Mandatory)] [string]$PlatformName)

    $homeRoot = Get-HomeRoot
    switch ($Scope) {
        'project' {
            switch ($PlatformName) {
                'codex' { return Join-Path $ProjectRoot '.agents\plugins\agentic-workflow-skills' }
                'copilot' { return Join-Path $ProjectRoot '.github\skills' }
                'claude' { return Join-Path $ProjectRoot '.claude\skills' }
            }
        }
        'user' {
            switch ($PlatformName) {
                'codex' { return Join-Path $homeRoot '.agents\plugins\agentic-workflow-skills' }
                'copilot' { return Join-Path $homeRoot '.copilot\skills' }
                'claude' { return Join-Path $homeRoot '.claude\skills' }
            }
        }
    }

    throw "Unsupported platform or scope: $PlatformName / $Scope"
}

function Get-PluginSource {
    param([Parameter(Mandatory)] [string]$PlatformName)

    switch ($PlatformName) {
        'codex' { return $pluginMarketplaceRoot }
        'copilot' { return Join-Path $pluginMarketplaceRoot 'plugins\agentic-workflow-skills\hosts\copilot\.github\skills' }
        'claude' { return Join-Path $pluginMarketplaceRoot 'plugins\agentic-workflow-skills\hosts\claude\.claude\skills' }
    }

    throw "Unsupported platform: $PlatformName"
}

function ConvertTo-GitHubRepositoryUrl {
    param([Parameter(Mandatory)] [string]$Url)

    $normalized = $Url.Trim()
    if ($normalized -match '^git@github\.com:(?<owner>[^/]+)/(?<repo>[^/]+?)(\.git)?$') {
        return "https://github.com/$($Matches.owner)/$($Matches.repo)"
    }

    if ($normalized -match '^ssh://git@github\.com/(?<owner>[^/]+)/(?<repo>[^/]+?)(\.git)?$') {
        return "https://github.com/$($Matches.owner)/$($Matches.repo)"
    }

    if ($normalized -match '^https://github\.com/(?<owner>[^/]+)/(?<repo>[^/]+?)(\.git)?$') {
        return "https://github.com/$($Matches.owner)/$($Matches.repo)"
    }

    return $normalized
}

function Get-ResolvedMarketplaceSource {
    if (-not [string]::IsNullOrWhiteSpace($MarketplaceSource)) {
        return (ConvertTo-GitHubRepositoryUrl -Url $MarketplaceSource)
    }

    if ($Source -ne 'marketplace') {
        return $null
    }

    try {
        $gitUrl = & git -C $packageRoot remote get-url origin 2>$null
        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($gitUrl)) {
            return (ConvertTo-GitHubRepositoryUrl -Url $gitUrl)
        }
    } catch {
        # Fall through to the explicit error below.
    }

    throw 'MarketplaceSource is required when -Source marketplace is used and the origin remote cannot be resolved.'
}

function Write-MarketplaceInstallInstructions {
    param(
        [Parameter(Mandatory)] [string]$PlatformName,
        [Parameter(Mandatory)] [string]$SourceReference
    )

    Write-Host "Marketplace source: $SourceReference"

    switch ($PlatformName) {
        'codex' {
            Write-Host 'Next Codex CLI steps:'
            Write-Host ("  codex plugin marketplace add `"{0}`"" -f $SourceReference)
            Write-Host ("  codex plugin add {0}@{1}" -f $pluginName, $marketplaceName)
            Write-Host 'Start a new Codex thread after installing so the plugin skills are loaded.'
        }
        'claude' {
            Write-Host 'Next Claude Code steps:'
            Write-Host ("  claude plugin marketplace add `"{0}`" --scope {1}" -f $SourceReference, $Scope)
            Write-Host ("  claude plugin install {0}@{1} --scope {2}" -f $pluginName, $marketplaceName, $Scope)
            Write-Host 'Reload or restart Claude Code after installing so the plugin skills are loaded.'
        }
        'copilot' {
            Write-Host 'Next GitHub Copilot CLI steps:'
            Write-Host ("  copilot plugin marketplace add `"{0}`" --scope {1}" -f $SourceReference, $Scope)
            Write-Host ("  copilot plugin install {0}@{1} --scope {2}" -f $pluginName, $marketplaceName, $Scope)
            Write-Host 'Restart or refresh Copilot after installing so the plugin skills are loaded.'
        }
    }
}

function Install-PluginPlatform {
    param([Parameter(Mandatory)] [string]$PlatformName)

    $targetRoot = Get-InstallTarget -PlatformName $PlatformName
    $result = [ordered]@{
        Platform = $PlatformName
        Destination = $targetRoot
        Succeeded = $false
        Message = ''
    }

    try {
        if ($Source -eq 'marketplace') {
            $sourceReference = Get-ResolvedMarketplaceSource
            if ($PSCmdlet.ShouldProcess($PlatformName, "Print $PlatformName marketplace install steps from $sourceReference")) {
                Write-MarketplaceInstallInstructions -PlatformName $PlatformName -SourceReference $sourceReference
            }
        } else {
            $sourceRoot = Get-PluginSource -PlatformName $PlatformName
            if ($PSCmdlet.ShouldProcess($targetRoot, "Install $PlatformName plugin bundle")) {
                Assert-InstallSafe -SourceRoot $sourceRoot -TargetRoot $targetRoot
                Copy-Directory -SourceRoot $sourceRoot -TargetRoot $targetRoot
            }
        }

        $result.Succeeded = $true
        if ($Source -eq 'marketplace') {
            $result.Message = "Prepared $PlatformName marketplace install commands from $((Get-ResolvedMarketplaceSource))"
        } else {
            $result.Message = "Installed $PlatformName plugin bundle to $targetRoot"
        }
        Write-Host $result.Message

        if ($PlatformName -eq 'codex' -and $Source -eq 'generated') {
            Write-Host 'Next Codex CLI steps:'
            Write-Host ("  codex plugin marketplace add `"{0}`"" -f $targetRoot)
            Write-Host ("  codex plugin add {0}@{1}" -f $pluginName, $marketplaceName)
            Write-Host 'Start a new Codex thread after installing so the plugin skills are loaded.'
        }
    } catch {
        $result.Message = $_.Exception.Message
        Write-Warning "Plugin installation failed for ${PlatformName}: $($result.Message)"
    }

    return [pscustomobject]$result
}

try {
    Test-PluginBundleCurrent
    $targets = if ($Platform -eq 'all') { $platforms } else { @($Platform) }
    $results = foreach ($target in $targets) { Install-PluginPlatform -PlatformName $target }
    $failed = @($results | Where-Object { -not $_.Succeeded })

    if ($failed.Count -gt 0) {
        Write-Host 'One or more plugin installations failed:'
        foreach ($failure in $failed) {
            Write-Host ("- {0}: {1}" -f $failure.Platform, $failure.Message)
        }
        exit 1
    }

    exit 0
} catch {
    Write-Error $_
    exit 1
}
