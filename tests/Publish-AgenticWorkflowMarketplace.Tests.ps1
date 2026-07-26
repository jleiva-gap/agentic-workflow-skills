BeforeAll {
    $script:Here = Split-Path -Parent $PSCommandPath
    $script:PackageRoot = Split-Path -Parent $script:Here

    function New-TestPackageCopy {
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-publish-test-{0}" -f ([Guid]::NewGuid().ToString('N')))
        Copy-Item -LiteralPath $script:PackageRoot -Destination $tempRoot -Recurse -Force
        & pwsh -NoProfile -File (Join-Path $tempRoot 'scripts\Build-SkillDistributions.ps1') | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Failed to build skill distributions in test package copy.' }
        & pwsh -NoProfile -File (Join-Path $tempRoot 'scripts\Build-AgenticWorkflowPlugin.ps1') | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Failed to build plugin bundle in test package copy.' }
        return $tempRoot
    }

    function Invoke-PublishScript {
        param(
            [Parameter(Mandatory)] [string]$PackageCopy,
            [Parameter(Mandatory)] [string]$MarketplaceRoot,
            [switch]$Check
        )

        $scriptPath = Join-Path $PackageCopy 'scripts\Publish-AgenticWorkflowMarketplace.ps1'
        $args = @('-NoProfile', '-File', $scriptPath, '-MarketplaceRoot', $MarketplaceRoot)
        if ($Check) { $args += '-Check' }
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

Describe 'Publish-AgenticWorkflowMarketplace.ps1' {
    It 'publishes and verifies the marketplace bundle when the marketplace root is relative' {
        $copy = New-TestPackageCopy
        $marketplaceRoot = Join-Path $copy '..\agentic-workflow-marketplace-target'
        try {
            New-Item -ItemType Directory -Force -Path (Join-Path $marketplaceRoot '.git') | Out-Null

            (Invoke-PublishScript -PackageCopy $copy -MarketplaceRoot $marketplaceRoot) | Should -Be 0
            (Invoke-PublishScript -PackageCopy $copy -MarketplaceRoot $marketplaceRoot -Check) | Should -Be 0

            (Test-Path (Join-Path $marketplaceRoot 'hosts\copilot-marketplace\marketplace.json')) | Should -BeTrue
            (Test-Path (Join-Path $marketplaceRoot 'skills\critical-review\templates\review-findings-template.md')) | Should -BeTrue
        } finally {
            Remove-TestPath -Path $marketplaceRoot
            Remove-TestPath -Path $copy
        }
    }
}
