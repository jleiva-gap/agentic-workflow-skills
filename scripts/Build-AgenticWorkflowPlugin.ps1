param(
    [switch]$Check,
    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageRoot = Split-Path -Parent $scriptRoot
$distRoot = Join-Path $packageRoot 'dist'
$pluginMarketplaceRoot = Join-Path $distRoot 'plugin-marketplace'
$pluginName = 'agentic-workflow-skills'
$marketplaceName = 'agentic-workflow-skills-local'
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

function Copy-DirectoryContents {
    param(
        [Parameter(Mandatory)] [string]$SourceRoot,
        [Parameter(Mandatory)] [string]$TargetRoot
    )

    if (-not (Test-Path $SourceRoot)) {
        throw "Required source directory not found: $SourceRoot"
    }

    Get-ChildItem -LiteralPath $SourceRoot -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Substring($SourceRoot.Length).TrimStart('\','/')
        $targetPath = Join-Path $TargetRoot $relativePath
        $targetParent = Split-Path -Parent $targetPath
        New-Item -ItemType Directory -Force -Path $targetParent | Out-Null
        Copy-Item -LiteralPath $_.FullName -Destination $targetPath -Force
    }
}

function Get-FileInventory {
    param([Parameter(Mandatory)] [string]$Root)

    if (-not (Test-Path $Root)) { return @() }

    Get-ChildItem -LiteralPath $Root -Recurse -File | ForEach-Object {
        [pscustomobject]@{
            RelativePath = $_.FullName.Substring($Root.Length).TrimStart('\','/')
            Hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash
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
        throw "Generated plugin drift detected. Missing: $($missing -join ', '). Extra: $($extra -join ', ')."
    }

    foreach ($expectedFile in $expected) {
        $actualFile = $actual | Where-Object { $_.RelativePath -eq $expectedFile.RelativePath }
        if ($expectedFile.Hash -ne $actualFile.Hash) {
            throw "Generated plugin drift detected in $($expectedFile.RelativePath)."
        }
    }
}

function Test-DistributionsCurrent {
    $buildScript = Join-Path $scriptRoot 'Build-SkillDistributions.ps1'
    & pwsh -NoProfile -File $buildScript -Check | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw 'Generated dist/ skills are not current. Run Build-SkillDistributions.ps1 before building the plugin bundle.'
    }
}

function New-PluginManifestJson {
    $manifest = [ordered]@{
        name = $pluginName
        version = '0.1.0'
        description = 'Agentic workflow skills for planning, implementation, resume, handoff, verification, and review.'
        author = [ordered]@{
            name = 'Agentic Workflow Skills Contributors'
        }
        license = 'Apache-2.0'
        keywords = @('agentic-workflow', 'skills', 'planning', 'handoff', 'review', 'self-qa')
        skills = './skills/'
        interface = [ordered]@{
            displayName = 'Agentic Workflow Skills'
            shortDescription = 'Reusable workflow skills for artifact-driven delivery.'
            longDescription = 'Planning, implementation, handoff, resume, verification, and review workflows packaged as a local Codex plugin.'
            developerName = 'Agentic Workflow Skills Contributors'
            category = 'Productivity'
            capabilities = @('Write')
            defaultPrompt = @(
                'Plan a story with story-to-plan.',
                'Resume work with a process id.',
                'Run self-QA review before handoff.',
                'Use critical-review-with-validation for strict review coverage.'
            )
            brandColor = '#2563EB'
        }
    }

    return ($manifest | ConvertTo-Json -Depth 20)
}

function New-ClaudePluginManifestJson {
    $manifest = [ordered]@{
        name = $pluginName
        version = '0.1.0'
        description = 'Agentic workflow skills for planning, implementation, resume, handoff, verification, and review.'
        author = [ordered]@{
            name = 'Agentic Workflow Skills Contributors'
        }
        license = 'Apache-2.0'
        keywords = @('agentic-workflow', 'skills', 'planning', 'handoff', 'review', 'self-qa')
        skills = './skills/'
    }

    return ($manifest | ConvertTo-Json -Depth 20)
}

function New-CopilotPluginManifestJson {
    $manifest = [ordered]@{
        name = $pluginName
        version = '0.1.0'
        description = 'Agentic workflow skills for planning, implementation, resume, handoff, verification, and review.'
        author = [ordered]@{
            name = 'Agentic Workflow Skills Contributors'
        }
        license = 'Apache-2.0'
        keywords = @('agentic-workflow', 'skills', 'planning', 'handoff', 'review', 'self-qa')
        skills = 'skills/'
    }

    return ($manifest | ConvertTo-Json -Depth 20)
}

function New-MarketplaceJson {
    $marketplace = [ordered]@{
        name = $marketplaceName
        interface = [ordered]@{
            displayName = 'Agentic Workflow Skills Local'
        }
        plugins = @(
            [ordered]@{
                name = $pluginName
                source = [ordered]@{
                    source = 'local'
                    path = './plugins/agentic-workflow-skills'
                }
                policy = [ordered]@{
                    installation = 'AVAILABLE'
                    authentication = 'ON_INSTALL'
                }
                category = 'Productivity'
            }
        )
    }

    return ($marketplace | ConvertTo-Json -Depth 20)
}

function New-ClaudeMarketplaceJson {
    $marketplace = [ordered]@{
        name = $marketplaceName
        owner = [ordered]@{
            name = 'Agentic Workflow Skills Contributors'
        }
        description = 'Local marketplace for Agentic Workflow Skills.'
        plugins = @(
            [ordered]@{
                name = $pluginName
                source = './plugins/agentic-workflow-skills'
                description = 'Agentic workflow skills for planning, implementation, resume, handoff, verification, and self-QA review.'
                version = '0.1.0'
                author = [ordered]@{
                    name = 'Agentic Workflow Skills Contributors'
                }
            }
        )
    }

    return ($marketplace | ConvertTo-Json -Depth 20)
}

function New-CopilotMarketplaceJson {
    $marketplace = [ordered]@{
        name = $marketplaceName
        interface = [ordered]@{
            displayName = 'Agentic Workflow Skills Local'
        }
        plugins = @(
            [ordered]@{
                name = $pluginName
                source = [ordered]@{
                    source = 'local'
                    path = './plugins/agentic-workflow-skills'
                }
                policy = [ordered]@{
                    installation = 'AVAILABLE'
                    authentication = 'ON_INSTALL'
                }
                category = 'Productivity'
            }
        )
    }

    return ($marketplace | ConvertTo-Json -Depth 20)
}

function Assert-ExpectedSkillsPresent {
    param([Parameter(Mandatory)] [string]$SkillRoot)

    foreach ($skillName in $skillNames) {
        $skillFile = Join-Path $SkillRoot (Join-Path $skillName 'SKILL.md')
        if (-not (Test-Path $skillFile)) {
            throw "Missing generated skill in plugin bundle: $skillFile"
        }
    }
}

function Write-PluginMarketplace {
    param([Parameter(Mandatory)] [string]$OutputRoot)

    Test-DistributionsCurrent

    $marketplaceRoot = Join-Path $OutputRoot 'plugin-marketplace'
    if (Test-Path $marketplaceRoot) {
        Remove-Item -LiteralPath $marketplaceRoot -Recurse -Force
    }

    $pluginRoot = Join-Path $marketplaceRoot 'plugins\agentic-workflow-skills'
    $codexSkillRoot = Join-Path $distRoot 'codex\.agents\skills'
    $copilotSkillRoot = Join-Path $distRoot 'copilot\.github\skills'
    $claudeSkillRoot = Join-Path $distRoot 'claude\.claude\skills'

    Copy-DirectoryContents -SourceRoot $codexSkillRoot -TargetRoot (Join-Path $pluginRoot 'skills')
    Copy-DirectoryContents -SourceRoot $codexSkillRoot -TargetRoot (Join-Path $pluginRoot 'hosts\codex\.agents\skills')
    Copy-DirectoryContents -SourceRoot $copilotSkillRoot -TargetRoot (Join-Path $pluginRoot 'hosts\copilot\.github\skills')
    Copy-DirectoryContents -SourceRoot $claudeSkillRoot -TargetRoot (Join-Path $pluginRoot 'hosts\claude\.claude\skills')

    $claudeMarketplacePluginRoot = Join-Path $marketplaceRoot 'hosts\claude-marketplace\plugins\agentic-workflow-skills'
    $copilotMarketplacePluginRoot = Join-Path $marketplaceRoot 'hosts\copilot-marketplace\plugins\agentic-workflow-skills'
    Copy-DirectoryContents -SourceRoot $claudeSkillRoot -TargetRoot (Join-Path $claudeMarketplacePluginRoot 'skills')
    Copy-DirectoryContents -SourceRoot $copilotSkillRoot -TargetRoot (Join-Path $copilotMarketplacePluginRoot 'skills')

    Assert-ExpectedSkillsPresent -SkillRoot (Join-Path $pluginRoot 'skills')
    Assert-ExpectedSkillsPresent -SkillRoot (Join-Path $pluginRoot 'hosts\codex\.agents\skills')
    Assert-ExpectedSkillsPresent -SkillRoot (Join-Path $pluginRoot 'hosts\copilot\.github\skills')
    Assert-ExpectedSkillsPresent -SkillRoot (Join-Path $pluginRoot 'hosts\claude\.claude\skills')
    Assert-ExpectedSkillsPresent -SkillRoot (Join-Path $claudeMarketplacePluginRoot 'skills')
    Assert-ExpectedSkillsPresent -SkillRoot (Join-Path $copilotMarketplacePluginRoot 'skills')

    Write-Utf8NoBom -Path (Join-Path $pluginRoot '.codex-plugin\plugin.json') -Content (New-PluginManifestJson)
    Write-Utf8NoBom -Path (Join-Path $marketplaceRoot 'marketplace.json') -Content (New-MarketplaceJson)
    Write-Utf8NoBom -Path (Join-Path $claudeMarketplacePluginRoot '.claude-plugin\plugin.json') -Content (New-ClaudePluginManifestJson)
    Write-Utf8NoBom -Path (Join-Path $marketplaceRoot 'hosts\claude-marketplace\.claude-plugin\marketplace.json') -Content (New-ClaudeMarketplaceJson)
    Write-Utf8NoBom -Path (Join-Path $copilotMarketplacePluginRoot 'plugin.json') -Content (New-CopilotPluginManifestJson)
    Write-Utf8NoBom -Path (Join-Path $marketplaceRoot 'hosts\copilot-marketplace\marketplace.json') -Content (New-CopilotMarketplaceJson)
}

try {
    if ($Clean) {
        if (Test-Path $pluginMarketplaceRoot) {
            Remove-Item -LiteralPath $pluginMarketplaceRoot -Recurse -Force
        }
        Write-Host 'Cleaned generated plugin marketplace bundle.'
        exit 0
    }

    if ($Check) {
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-plugin-check-{0}" -f ([Guid]::NewGuid().ToString('N')))
        $tempDistRoot = Join-Path $tempRoot 'dist'
        New-Item -ItemType Directory -Force -Path $tempDistRoot | Out-Null
        try {
            Write-PluginMarketplace -OutputRoot $tempDistRoot
            Assert-DirectoryTreesMatch -ExpectedRoot (Join-Path $tempDistRoot 'plugin-marketplace') -ActualRoot $pluginMarketplaceRoot
            Write-Host "Check passed. Generated plugin marketplace matches $pluginMarketplaceRoot."
        } finally {
            if (Test-Path $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
        }
        exit 0
    }

    Write-PluginMarketplace -OutputRoot $distRoot
    Write-Host "Generated plugin marketplace bundle under $pluginMarketplaceRoot."
    Write-Host (Join-Path $pluginMarketplaceRoot 'marketplace.json')
    Write-Host (Join-Path $pluginMarketplaceRoot 'plugins\agentic-workflow-skills')
    exit 0
} catch {
    Write-Error $_
    exit 1
}
