[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory)]
    [ValidateSet('codex', 'copilot', 'claude', 'all')]
    [string]$Platform,

    [ValidateSet('project', 'user')]
    [string]$Scope = 'project',

    [string]$ProjectRoot = (Get-Location).Path,

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageRoot = Split-Path -Parent $scriptRoot
$distRoot = Join-Path $packageRoot 'dist'
$platformRoot = Join-Path $packageRoot 'platform'
$skillNames = @(
    'story-to-plan',
    'implement-approved-plan',
    'resume-approved-plan',
    'create-handoff',
    'verify-handoff',
    'self-qa-review',
    'critical-review-agent',
    'adversarial-review-agent',
    'critical-adversarial-review-agent',
    'review-findings-validator-agent',
    'critical-review-with-validation-agent'
)
$platforms = @('codex', 'copilot', 'claude')

function Read-JsonFile {
    param([Parameter(Mandatory)] [string]$Path)

    if (-not (Test-Path $Path)) { throw "Required file not found: $Path" }
    try {
        return Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json -Depth 10
    } catch {
        throw "Invalid JSON in ${Path}: $($_.Exception.Message)"
    }
}

function Get-HostConfig {
    param([Parameter(Mandatory)] [string]$PlatformName)

    $configPath = Join-Path (Join-Path $platformRoot $PlatformName) 'metadata.json'
    $config = Read-JsonFile $configPath
    if ($config.host -ne $PlatformName) { throw "Platform metadata host mismatch in $configPath" }
    if ([string]::IsNullOrWhiteSpace($config.distributionRoot)) { throw "Missing distributionRoot in $configPath" }
    if ([string]::IsNullOrWhiteSpace($config.skillFileName)) { throw "Missing skillFileName in $configPath" }
    return $config
}

function Get-DistSkillRoot {
    param([Parameter(Mandatory)] [string]$PlatformName)
    $config = Get-HostConfig -PlatformName $PlatformName
    return Join-Path $distRoot (Join-Path $PlatformName $config.distributionRoot)
}

function Get-InstallRoot {
    param(
        [Parameter(Mandatory)] [string]$PlatformName,
        [Parameter(Mandatory)] [string]$ScopeName
    )

    switch ($ScopeName) {
        'project' {
            switch ($PlatformName) {
                'codex' { return Join-Path $ProjectRoot '.agents\skills' }
                'copilot' { return Join-Path $ProjectRoot '.github\skills' }
                'claude' { return Join-Path $ProjectRoot '.claude\skills' }
            }
        }
        'user' {
            $userHome = if (-not [string]::IsNullOrWhiteSpace($env:AGENTIC_WORKFLOW_HOME)) {
                $env:AGENTIC_WORKFLOW_HOME
            } elseif (-not [string]::IsNullOrWhiteSpace($env:HOME)) {
                $env:HOME
            } else {
                $HOME
            }

            switch ($PlatformName) {
                'codex' { return Join-Path $userHome '.agents\skills' }
                'copilot' { return Join-Path $userHome '.copilot\skills' }
                'claude' { return Join-Path $userHome '.claude\skills' }
            }
        }
    }

    throw "Unsupported scope or platform: $ScopeName / $PlatformName"
}

function Test-DistCurrent {
    $buildScript = Join-Path $scriptRoot 'Build-SkillDistributions.ps1'
    & pwsh -NoProfile -File $buildScript -Check | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw 'Generated dist/ is not current. Run the build script before installing.'
    }
}

function Compare-SkillFile {
    param(
        [Parameter(Mandatory)] [string]$SourceFile,
        [Parameter(Mandatory)] [string]$TargetFile
    )

    if (-not (Test-Path $TargetFile)) { return $false }
    $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $SourceFile).Hash
    $targetHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $TargetFile).Hash
    return $sourceHash -eq $targetHash
}

function Get-RelativeSkillFiles {
    param([Parameter(Mandatory)] [string]$Root)

    Get-ChildItem -LiteralPath $Root -Recurse -File | ForEach-Object {
        [pscustomobject]@{
            RelativePath = $_.FullName.Substring($Root.Length).TrimStart('\','/')
            FullName = $_.FullName
        }
    }
}

function Assert-SkillInstallSafe {
    param(
        [Parameter(Mandatory)] [string]$SourceDir,
        [Parameter(Mandatory)] [string]$TargetDir
    )

    if ($Force -or -not (Test-Path $TargetDir)) { return }

    foreach ($sourceFile in Get-RelativeSkillFiles -Root $SourceDir) {
        $targetFile = Join-Path $TargetDir $sourceFile.RelativePath
        if ((Test-Path $targetFile) -and -not (Compare-SkillFile -SourceFile $sourceFile.FullName -TargetFile $targetFile)) {
            throw "Refusing to overwrite modified skill file without -Force: $targetFile"
        }
    }
}

function Copy-SkillDirectory {
    param(
        [Parameter(Mandatory)] [string]$SourceDir,
        [Parameter(Mandatory)] [string]$TargetDir
    )

    foreach ($sourceFile in Get-RelativeSkillFiles -Root $SourceDir) {
        $targetFile = Join-Path $TargetDir $sourceFile.RelativePath
        $targetParent = Split-Path -Parent $targetFile
        New-Item -ItemType Directory -Force -Path $targetParent | Out-Null
        Copy-Item -LiteralPath $sourceFile.FullName -Destination $targetFile -Force
    }
}

function Install-Platform {
    param([Parameter(Mandatory)] [string]$PlatformName)

    $config = Get-HostConfig -PlatformName $PlatformName
    $sourceRoot = Get-DistSkillRoot -PlatformName $PlatformName
    if (-not (Test-Path $sourceRoot)) {
        throw "Generated distribution not found: $sourceRoot"
    }

    $destinationRoot = Get-InstallRoot -PlatformName $PlatformName -ScopeName $Scope
    $result = [ordered]@{
        Platform = $PlatformName
        Destination = $destinationRoot
        Succeeded = $false
        Message = ''
    }

    try {
        if ($PSCmdlet.ShouldProcess($destinationRoot, "Install $PlatformName skills")) {
            New-Item -ItemType Directory -Force -Path $destinationRoot | Out-Null
            foreach ($skillName in $skillNames) {
                $sourceSkillDir = Join-Path $sourceRoot $skillName
                $targetSkillDir = Join-Path $destinationRoot $skillName
                Assert-SkillInstallSafe -SourceDir $sourceSkillDir -TargetDir $targetSkillDir
                Copy-SkillDirectory -SourceDir $sourceSkillDir -TargetDir $targetSkillDir
            }
        }
        $result.Succeeded = $true
        $result.Message = "Installed $PlatformName skills to $destinationRoot"
        Write-Host $result.Message
        Write-Host 'Superpowers dependencies must be installed separately if they are not already available.'
    } catch {
        $result.Message = $_.Exception.Message
        Write-Warning "Installation failed for ${PlatformName}: $($result.Message)"
    }

    return [pscustomobject]$result
}

try {
    Test-DistCurrent
    $targets = if ($Platform -eq 'all') { $platforms } else { @($Platform) }
    $results = foreach ($item in $targets) { Install-Platform -PlatformName $item }

    $failed = @($results | Where-Object { -not $_.Succeeded })
    if ($failed.Count -gt 0) {
        Write-Host 'One or more platform installations failed:'
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
