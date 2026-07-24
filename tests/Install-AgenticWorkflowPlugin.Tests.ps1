BeforeAll {
    $script:Here = Split-Path -Parent $PSCommandPath
    $script:PackageRoot = Split-Path -Parent $script:Here

    function New-TestPackageCopy {
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-plugin-install-{0}" -f ([Guid]::NewGuid().ToString('N')))
        Copy-Item -LiteralPath $script:PackageRoot -Destination $tempRoot -Recurse -Force
        & pwsh -NoProfile -File (Join-Path $tempRoot 'scripts\Build-SkillDistributions.ps1') | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Failed to build skill distributions in test package copy.' }
        & pwsh -NoProfile -File (Join-Path $tempRoot 'scripts\Build-AgenticWorkflowPlugin.ps1') | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Failed to build plugin bundle in test package copy.' }
        return $tempRoot
    }

    function Invoke-PluginInstaller {
        param(
            [Parameter(Mandatory)] [string]$PackageCopy,
            [Parameter(Mandatory)] [string]$Platform,
            [string]$Scope = 'project',
            [string]$ProjectRoot = $script:PackageRoot,
            [string]$Source = 'generated',
            [string]$MarketplaceSource,
            [switch]$Force,
            [switch]$WhatIf,
            [switch]$CaptureOutput
        )

        $scriptPath = Join-Path $PackageCopy 'scripts\Install-AgenticWorkflowPlugin.ps1'
        $args = @('-NoProfile', '-File', $scriptPath, '-Platform', $Platform, '-Scope', $Scope, '-ProjectRoot', $ProjectRoot, '-Source', $Source)
        if ($MarketplaceSource) { $args += @('-MarketplaceSource', $MarketplaceSource) }
        if ($Force) { $args += '-Force' }
        if ($WhatIf) { $args += '-WhatIf' }
        if ($CaptureOutput) {
            $output = & pwsh @args 2>&1
            return [pscustomobject]@{
                ExitCode = $LASTEXITCODE
                Output = ($output | Out-String)
            }
        }

        & pwsh @args | Out-Null
        return $LASTEXITCODE
    }

    function Remove-TestPath {
        param([Parameter(Mandatory)] [string]$Path)
        if (Test-Path $Path) {
            Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Describe 'Install-AgenticWorkflowPlugin.ps1' {
    It 'installs the Codex plugin marketplace bundle to a project' {
        $copy = New-TestPackageCopy
        $projectRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-plugin-project-{0}" -f ([Guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path $projectRoot | Out-Null
        try {
            (Invoke-PluginInstaller -PackageCopy $copy -Platform codex -ProjectRoot $projectRoot) | Should -Be 0
            $marketplaceRoot = Join-Path $projectRoot '.agents\plugins\agentic-workflow-skills'
            (Test-Path (Join-Path $marketplaceRoot 'marketplace.json')) | Should -BeTrue
            (Test-Path (Join-Path $marketplaceRoot 'plugins\agentic-workflow-skills\.codex-plugin\plugin.json')) | Should -BeTrue
            @(Get-ChildItem -LiteralPath (Join-Path $marketplaceRoot 'plugins\agentic-workflow-skills\skills') -Directory).Count | Should -Be 11
        } finally {
            Remove-TestPath -Path $projectRoot
            Remove-TestPath -Path $copy
        }
    }

    It 'installs Claude and Copilot plugin skill bundles to project skill roots' {
        $copy = New-TestPackageCopy
        $projectRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-plugin-hosts-{0}" -f ([Guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path $projectRoot | Out-Null
        try {
            (Invoke-PluginInstaller -PackageCopy $copy -Platform copilot -ProjectRoot $projectRoot) | Should -Be 0
            (Invoke-PluginInstaller -PackageCopy $copy -Platform claude -ProjectRoot $projectRoot) | Should -Be 0
            @(Get-ChildItem -LiteralPath (Join-Path $projectRoot '.github\skills') -Recurse -Filter SKILL.md -File).Count | Should -Be 11
            @(Get-ChildItem -LiteralPath (Join-Path $projectRoot '.claude\skills') -Recurse -Filter SKILL.md -File).Count | Should -Be 11
            (Test-Path (Join-Path $projectRoot '.github\skills\self-qa-review\SKILL.md')) | Should -BeTrue
            (Test-Path (Join-Path $projectRoot '.claude\skills\self-qa-review\SKILL.md')) | Should -BeTrue
        } finally {
            Remove-TestPath -Path $projectRoot
            Remove-TestPath -Path $copy
        }
    }

    It 'prints marketplace install commands for a GitHub source' {
        $copy = New-TestPackageCopy
        $projectRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-plugin-marketplace-{0}" -f ([Guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path $projectRoot | Out-Null
        try {
            $result = Invoke-PluginInstaller -PackageCopy $copy -Platform all -ProjectRoot $projectRoot -Source marketplace -MarketplaceSource 'https://github.com/example/agentic-workflow-skills' -CaptureOutput
            $result.ExitCode | Should -Be 0
            $result.Output | Should -Match 'Marketplace source: https://github.com/example/agentic-workflow-skills'
            $result.Output | Should -Match 'codex plugin marketplace add "https://github.com/example/agentic-workflow-skills"'
            $result.Output | Should -Match 'claude plugin marketplace add "https://github.com/example/agentic-workflow-skills" --scope project'
            $result.Output | Should -Match 'copilot plugin marketplace add "https://github.com/example/agentic-workflow-skills" --scope project'
            (Test-Path (Join-Path $projectRoot '.agents\plugins\agentic-workflow-skills')) | Should -BeFalse
            (Test-Path (Join-Path $projectRoot '.github\skills')) | Should -BeFalse
            (Test-Path (Join-Path $projectRoot '.claude\skills')) | Should -BeFalse
        } finally {
            Remove-TestPath -Path $projectRoot
            Remove-TestPath -Path $copy
        }
    }
}
