param(
    [switch]$Check,
    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageRoot = Split-Path -Parent $scriptRoot
$srcRoot = Join-Path $packageRoot 'src'
$sharedRoot = Join-Path $srcRoot 'shared'
$platformRoot = Join-Path $packageRoot 'platform'
$distRoot = Join-Path $packageRoot 'dist'
$skillNames = @(
    'story-to-plan',
    'implement-approved-plan',
    'resume-approved-plan',
    'create-handoff',
    'verify-handoff',
    'self-qa-review',
    'critical-review',
    'adversarial-review',
    'critical-adversarial-review',
    'review-findings-validator',
    'critical-review-with-validation'
)
$hosts = @('codex', 'copilot', 'claude')

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

function Read-JsonFile {
    param([Parameter(Mandatory)] [string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Required file not found: $Path"
    }

    try {
        return Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json -Depth 10
    } catch {
        throw "Invalid JSON in ${Path}: $($_.Exception.Message)"
    }
}

function Normalize-Lines {
    param([Parameter(Mandatory)] [string]$Text)
    return ($Text -replace "`r`n", "`n" -replace "`r", "`n")
}

function Escape-YamlScalar {
    param([Parameter(Mandatory)] $Value)

    if ($null -eq $Value) { return 'null' }
    if ($Value -is [bool]) { return $Value.ToString().ToLowerInvariant() }
    if ($Value -is [int] -or $Value -is [long] -or $Value -is [double] -or $Value -is [decimal]) { return [string]$Value }

    $text = [string]$Value
    $text = $text -replace '\\', '\\\\'
    $text = $text -replace '"', '\\"'
    $text = $text -replace "`r`n", '\n'
    $text = $text -replace "`r", '\n'
    $text = $text -replace "`n", '\n'
    return '"' + $text + '"'
}

function Get-SkillDefinitions {
    foreach ($skillName in $skillNames) {
        $skillDir = Join-Path $srcRoot (Join-Path 'skills' $skillName)
        $metadataPath = Join-Path $skillDir 'metadata.json'
        $bodyPath = Join-Path $skillDir 'body.md'

        if (-not (Test-Path $metadataPath)) { throw "Missing canonical metadata: $metadataPath" }
        if (-not (Test-Path $bodyPath)) { throw "Missing canonical body: $bodyPath" }

        $metadata = Read-JsonFile $metadataPath
        if ($metadata.name -ne $skillName) { throw "Canonical metadata name mismatch in $metadataPath" }
        if ([string]::IsNullOrWhiteSpace($metadata.description)) { throw "Canonical metadata description missing in $metadataPath" }

        [pscustomobject]@{
            Name = $skillName
            Metadata = $metadata
            Body = Normalize-Lines (Get-Content -Raw -LiteralPath $bodyPath)
        }
    }
}

function Get-HostConfig {
    param([Parameter(Mandatory)] [string]$HostName)

    $configPath = Join-Path (Join-Path $platformRoot $HostName) 'metadata.json'
    $config = Read-JsonFile $configPath

    if ($config.host -ne $HostName) { throw "Platform metadata host mismatch in $configPath" }
    if ([string]::IsNullOrWhiteSpace($config.distributionRoot)) { throw "Missing distributionRoot in $configPath" }
    if ([string]::IsNullOrWhiteSpace($config.skillFileName)) { throw "Missing skillFileName in $configPath" }

    return $config
}

function New-FrontMatter {
    param(
        [Parameter(Mandatory)] [string]$HostName,
        [Parameter(Mandatory)] $Skill
    )

    $frontmatter = [ordered]@{
        name = $Skill.Metadata.name
        description = $Skill.Metadata.description
    }

    switch ($HostName) {
        'codex' {
            $frontmatter.argumentHint = $Skill.Metadata.argumentHint
            $frontmatter.allowImplicitInvocation = [bool]$Skill.Metadata.allowImplicitInvocation
        }
        'copilot' {
            $frontmatter.'argument-hint' = $Skill.Metadata.argumentHint
            $frontmatter.'user-invocable' = $true
            $frontmatter.'disable-model-invocation' = $true
        }
        'claude' {
            $frontmatter.'argument-hint' = $Skill.Metadata.argumentHint
            $frontmatter.'user-invocable' = $true
            $frontmatter.'disable-model-invocation' = $true
        }
        default {
            throw "Unsupported host: $HostName"
        }
    }

    $lines = @('---')
    $lines += foreach ($entry in $frontmatter.GetEnumerator()) {
        "$($entry.Key): $(Escape-YamlScalar $entry.Value)"
    }
    $lines += '---'
    $lines += ''
    return $lines -join "`n"
}

function New-SkillFileContent {
    param(
        [Parameter(Mandatory)] [string]$HostName,
        [Parameter(Mandatory)] $Skill
    )

    $header = New-FrontMatter -HostName $HostName -Skill $Skill
    return $header + $Skill.Body + "`n"
}

function Copy-SharedSupportFiles {
    param([Parameter(Mandatory)] [string]$SkillDirectory)

    $supportFolders = @('references', 'templates')
    foreach ($folderName in $supportFolders) {
        $sourceFolder = Join-Path $sharedRoot $folderName
        if (-not (Test-Path $sourceFolder)) {
            throw "Missing shared support folder: $sourceFolder"
        }

        $targetFolder = Join-Path $SkillDirectory $folderName
        Get-ChildItem -LiteralPath $sourceFolder -File | ForEach-Object {
            $targetPath = Join-Path $targetFolder $_.Name
            $content = Get-Content -Raw -LiteralPath $_.FullName
            Write-Utf8NoBom -Path $targetPath -Content $content
        }
    }
}

function Write-Distributions {
    param([Parameter(Mandatory)] [string]$OutputRoot)

    $skills = @(Get-SkillDefinitions | Sort-Object Name)
    foreach ($hostName in $hosts) {
        $hostConfig = Get-HostConfig -HostName $hostName
        $hostOutputRoot = Join-Path $OutputRoot (Join-Path $hostName $hostConfig.distributionRoot)
        if (Test-Path $hostOutputRoot) {
            Remove-Item -LiteralPath $hostOutputRoot -Recurse -Force
        }
        foreach ($skill in $skills) {
            $skillDirectory = Join-Path $hostOutputRoot $skill.Name
            $skillPath = Join-Path $skillDirectory $hostConfig.skillFileName
            $content = New-SkillFileContent -HostName $hostName -Skill $skill
            Write-Utf8NoBom -Path $skillPath -Content $content
            Copy-SharedSupportFiles -SkillDirectory $skillDirectory
        }
    }

    return $skills.Count
}

function Get-FileInventory {
    param([Parameter(Mandatory)] [string]$Root)

    if (-not (Test-Path $Root)) { return @() }

    Get-ChildItem -LiteralPath $Root -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Substring($Root.Length).TrimStart('\','/')
        if ($relativePath -notlike 'plugin-marketplace\*' -and $relativePath -notlike 'plugin-marketplace/*') {
            [pscustomobject]@{
                RelativePath = $relativePath
                Hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash
            }
        }
    } | Sort-Object RelativePath
}

function Assert-DirectoryTreesMatch {
    param(
        [Parameter(Mandatory)] [string]$ExpectedRoot,
        [Parameter(Mandatory)] [string]$ActualRoot
    )

    $expected = @(Get-FileInventory -Root $ExpectedRoot)
    $actual = @(Get-FileInventory -Root $ActualRoot)

    $expectedPaths = @($expected.RelativePath)
    $actualPaths = @($actual.RelativePath)

    $missing = @($expectedPaths | Where-Object { $_ -notin $actualPaths })
    $extra = @($actualPaths | Where-Object { $_ -notin $expectedPaths })

    if ($missing.Count -gt 0 -or $extra.Count -gt 0) {
        throw "Generated distribution drift detected. Missing: $($missing -join ', '). Extra: $($extra -join ', ')."
    }

    foreach ($expectedFile in $expected) {
        $actualFile = $actual | Where-Object { $_.RelativePath -eq $expectedFile.RelativePath }
        if ($expectedFile.Hash -ne $actualFile.Hash) {
            throw "Generated distribution drift detected in $($expectedFile.RelativePath)."
        }
    }
}

try {
    if ($Clean) {
        foreach ($hostName in $hosts) {
            $hostRoot = Join-Path $distRoot $hostName
            if (Test-Path $hostRoot) {
                Remove-Item -LiteralPath $hostRoot -Recurse -Force
            }
        }
        Write-Host 'Cleaned generated skill distributions.'
        exit 0
    }

    if ($Check) {
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-skills-check-{0}" -f ([Guid]::NewGuid().ToString('N')))
        $tempDistRoot = Join-Path $tempRoot 'dist'
        New-Item -ItemType Directory -Force -Path $tempDistRoot | Out-Null
        try {
            Write-Distributions -OutputRoot $tempDistRoot | Out-Null
            Assert-DirectoryTreesMatch -ExpectedRoot $tempDistRoot -ActualRoot $distRoot
            Write-Host "Check passed. Generated distributions match $distRoot."
        } finally {
            if (Test-Path $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
        }
        exit 0
    }

    $generatedCount = Write-Distributions -OutputRoot $distRoot
    Write-Host "Generated $generatedCount skills across 3 hosts under $distRoot."
    foreach ($hostName in $hosts) {
        $hostConfig = Get-HostConfig -HostName $hostName
        Write-Host (Join-Path $distRoot (Join-Path $hostName $hostConfig.distributionRoot))
    }
    exit 0
} catch {
    Write-Error $_
    exit 1
}




