BeforeAll {
    $script:Here = Split-Path -Parent $PSCommandPath
    $script:PackageRoot = Split-Path -Parent $script:Here

    function New-TestPackageCopy {
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-plugin-test-{0}" -f ([Guid]::NewGuid().ToString('N')))
        Copy-Item -LiteralPath $script:PackageRoot -Destination $tempRoot -Recurse -Force
        & pwsh -NoProfile -File (Join-Path $tempRoot 'scripts\Build-SkillDistributions.ps1') | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Failed to build skill distributions in test package copy.' }
        return $tempRoot
    }

    function Invoke-PluginBuild {
        param(
            [Parameter(Mandatory)] [string]$PackageCopy,
            [switch]$Check,
            [switch]$Clean
        )

        $scriptPath = Join-Path $PackageCopy 'scripts\Build-AgenticWorkflowPlugin.ps1'
        $args = @('-NoProfile', '-File', $scriptPath)
        if ($Check) { $args += '-Check' }
        if ($Clean) { $args += '-Clean' }
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

Describe 'Build-AgenticWorkflowPlugin.ps1' {
    It 'generates a Codex plugin manifest and local marketplace bundle' {
        $copy = New-TestPackageCopy
        try {
            (Invoke-PluginBuild -PackageCopy $copy) | Should -Be 0
            $marketplace = Join-Path $copy 'dist\plugin-marketplace\marketplace.json'
            $codexMarketplace = Join-Path $copy 'dist\plugin-marketplace\.agents\plugins\marketplace.json'
            $manifest = Join-Path $copy 'dist\plugin-marketplace\plugins\agentic-workflow-skills\.codex-plugin\plugin.json'
            $rootManifest = Join-Path $copy 'dist\plugin-marketplace\.codex-plugin\plugin.json'
            (Test-Path $marketplace) | Should -BeTrue
            (Test-Path $codexMarketplace) | Should -BeTrue
            (Test-Path $manifest) | Should -BeTrue
            (Test-Path $rootManifest) | Should -BeTrue

            $plugin = Get-Content -Raw -LiteralPath $manifest | ConvertFrom-Json
            $plugin.name | Should -Be 'agentic-workflow-skills'
            $plugin.skills | Should -Be './skills/'
            $plugin.interface.displayName | Should -Be 'Agentic Workflow Skills'

            $rootPlugin = Get-Content -Raw -LiteralPath $rootManifest | ConvertFrom-Json
            $rootPlugin.name | Should -Be 'agentic-workflow-skills'
            $rootPlugin.skills | Should -Be './skills/'

            $codex = Get-Content -Raw -LiteralPath $codexMarketplace | ConvertFrom-Json
            $codex.plugins[0].source.source | Should -Be 'url'
            $codex.plugins[0].source.url | Should -Be './'

            $remote = Get-Content -Raw -LiteralPath $marketplace | ConvertFrom-Json
            $remote.owner.name | Should -Be 'Agentic Workflow Skills Contributors'
            $remote.plugins[0].source | Should -Be './hosts/copilot-marketplace/plugins/agentic-workflow-skills'
        } finally {
            Remove-TestPath -Path $copy
        }
    }

    It 'bundles all eleven workflow skills including self-qa-review for each host' {
        $copy = New-TestPackageCopy
        try {
            (Invoke-PluginBuild -PackageCopy $copy) | Should -Be 0
            $pluginRoot = Join-Path $copy 'dist\plugin-marketplace\plugins\agentic-workflow-skills'

            @(Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'skills') -Directory).Name | Should -Contain 'self-qa-review'
            @(Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'skills') -Directory).Count | Should -Be 11
            @(Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'hosts\copilot\.github\skills') -Directory).Count | Should -Be 11
            @(Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'hosts\claude\.claude\skills') -Directory).Count | Should -Be 11
        } finally {
            Remove-TestPath -Path $copy
        }
    }

    It 'generates Claude and Copilot marketplace-compatible plugin roots' {
        $copy = New-TestPackageCopy
        try {
            (Invoke-PluginBuild -PackageCopy $copy) | Should -Be 0
            $bundleRoot = Join-Path $copy 'dist\plugin-marketplace'
            $claudeMarketplace = Join-Path $bundleRoot 'hosts\claude-marketplace\.claude-plugin\marketplace.json'
            $claudeManifest = Join-Path $bundleRoot 'hosts\claude-marketplace\plugins\agentic-workflow-skills\.claude-plugin\plugin.json'
            $copilotMarketplace = Join-Path $bundleRoot 'hosts\copilot-marketplace\marketplace.json'
            $copilotManifest = Join-Path $bundleRoot 'hosts\copilot-marketplace\plugins\agentic-workflow-skills\plugin.json'

            (Test-Path $claudeMarketplace) | Should -BeTrue
            (Test-Path $claudeManifest) | Should -BeTrue
            (Test-Path $copilotMarketplace) | Should -BeTrue
            (Test-Path $copilotManifest) | Should -BeTrue
            (Test-Path (Join-Path $bundleRoot '.claude-plugin\marketplace.json')) | Should -BeTrue
            (Test-Path (Join-Path $bundleRoot 'plugins\agentic-workflow-skills\.claude-plugin\plugin.json')) | Should -BeTrue
            (Test-Path (Join-Path $bundleRoot 'plugins\agentic-workflow-skills\plugin.json')) | Should -BeTrue
            (Test-Path (Join-Path $bundleRoot '.codex-plugin\plugin.json')) | Should -BeTrue
            (Test-Path (Join-Path $bundleRoot 'skills')) | Should -BeTrue

            @(Get-ChildItem -LiteralPath (Join-Path $bundleRoot 'hosts\claude-marketplace\plugins\agentic-workflow-skills\skills') -Directory).Count | Should -Be 11
            @(Get-ChildItem -LiteralPath (Join-Path $bundleRoot 'hosts\copilot-marketplace\plugins\agentic-workflow-skills\skills') -Directory).Count | Should -Be 11
            @(Get-ChildItem -LiteralPath (Join-Path $bundleRoot 'skills') -Directory).Count | Should -Be 11
        } finally {
            Remove-TestPath -Path $copy
        }
    }

    It 'detects plugin bundle drift' {
        $copy = New-TestPackageCopy
        try {
            (Invoke-PluginBuild -PackageCopy $copy) | Should -Be 0
            Add-Content -LiteralPath (Join-Path $copy 'dist\plugin-marketplace\plugins\agentic-workflow-skills\skills\story-to-plan\SKILL.md') -Value "`nDrift" -Encoding utf8
            (Invoke-PluginBuild -PackageCopy $copy -Check) | Should -Not -Be 0
        } finally {
            Remove-TestPath -Path $copy
        }
    }
}
