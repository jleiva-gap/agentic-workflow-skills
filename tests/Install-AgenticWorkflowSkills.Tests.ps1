BeforeAll {
    $script:Here = Split-Path -Parent $PSCommandPath
    $script:PackageRoot = Split-Path -Parent $script:Here

    function New-TestPackageCopy {
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-skills-install-{0}" -f ([Guid]::NewGuid().ToString('N')))
        Copy-Item -LiteralPath $script:PackageRoot -Destination $tempRoot -Recurse -Force
        & pwsh -NoProfile -File (Join-Path $tempRoot 'scripts\Build-SkillDistributions.ps1') | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Failed to build test package copy.' }
        return $tempRoot
    }

    function Invoke-Installer {
        param(
            [Parameter(Mandatory)] [string]$PackageCopy,
            [Parameter(Mandatory)] [string]$Platform,
            [string]$Scope = 'project',
            [string]$ProjectRoot = $script:PackageRoot,
            [switch]$Force,
            [switch]$WhatIf
        )

        $scriptPath = Join-Path $PackageCopy 'scripts\Install-AgenticWorkflowSkills.ps1'
        $args = @('-NoProfile', '-File', $scriptPath, '-Platform', $Platform, '-Scope', $Scope, '-ProjectRoot', $ProjectRoot)
        if ($Force) { $args += '-Force' }
        if ($WhatIf) { $args += '-WhatIf' }
        & pwsh @args | Out-Null
        return $LASTEXITCODE
    }

    function Get-ProjectTargets {
        param([Parameter(Mandatory)] [string]$ProjectRoot)
        [ordered]@{
            codex = Join-Path $ProjectRoot '.agents\skills'
            copilot = Join-Path $ProjectRoot '.github\skills'
            claude = Join-Path $ProjectRoot '.claude\skills'
        }
    }

    function Assert-InstalledSupportFiles {
        param(
            [Parameter(Mandatory)] [string]$TargetRoot,
            [Parameter(Mandatory)] [string]$SkillName
        )

        $skillRoot = Join-Path $TargetRoot $SkillName
        (Test-Path (Join-Path $skillRoot 'references\input-contract.md')) | Should -BeTrue
        (Test-Path (Join-Path $skillRoot 'references\artifact-contract.md')) | Should -BeTrue
        (Test-Path (Join-Path $skillRoot 'templates\cross-tool-handoff-template.md')) | Should -BeTrue
    }

    function Remove-TestPath {
        param([Parameter(Mandatory)] [string]$Path)
        if (Test-Path $Path) {
            Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Describe 'Install-AgenticWorkflowSkills.ps1' {
    It 'installs each project destination correctly' {
        $copy = New-TestPackageCopy
        $projectRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-project-{0}" -f ([Guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path $projectRoot | Out-Null
        try {
            foreach ($platform in 'codex','copilot','claude') {
                (Invoke-Installer -PackageCopy $copy -Platform $platform -ProjectRoot $projectRoot) | Should -Be 0
                $targetRoot = (Get-ProjectTargets -ProjectRoot $projectRoot)[$platform]
                @(Get-ChildItem -LiteralPath $targetRoot -Recurse -Filter SKILL.md -File).Count | Should -Be 11
                Assert-InstalledSupportFiles -TargetRoot $targetRoot -SkillName 'create-handoff'
            }
        } finally {
            Remove-TestPath -Path $projectRoot
            Remove-TestPath -Path $copy
        }
    }

    It 'installs each user destination with a mocked home directory' {
        $copy = New-TestPackageCopy
        $mockHome = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-home-{0}" -f ([Guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path $mockHome | Out-Null
        $oldHome = $env:AGENTIC_WORKFLOW_HOME
        try {
            $env:AGENTIC_WORKFLOW_HOME = $mockHome
            foreach ($platform in 'codex','copilot','claude') {
                (Invoke-Installer -PackageCopy $copy -Platform $platform -Scope user) | Should -Be 0
            }
            @(Get-ChildItem -LiteralPath (Join-Path $mockHome '.agents\skills') -Recurse -Filter SKILL.md -File).Count | Should -Be 11
            @(Get-ChildItem -LiteralPath (Join-Path $mockHome '.copilot\skills') -Recurse -Filter SKILL.md -File).Count | Should -Be 11
            @(Get-ChildItem -LiteralPath (Join-Path $mockHome '.claude\skills') -Recurse -Filter SKILL.md -File).Count | Should -Be 11
        } finally {
            $env:AGENTIC_WORKFLOW_HOME = $oldHome
            Remove-TestPath -Path $mockHome
            Remove-TestPath -Path $copy
        }
    }

    It 'installs all three platforms together' {
        $copy = New-TestPackageCopy
        $projectRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-all-{0}" -f ([Guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path $projectRoot | Out-Null
        try {
            (Invoke-Installer -PackageCopy $copy -Platform all -ProjectRoot $projectRoot) | Should -Be 0
            @(Get-ChildItem -LiteralPath (Join-Path $projectRoot '.agents\skills') -Recurse -Filter SKILL.md -File).Count | Should -Be 11
            @(Get-ChildItem -LiteralPath (Join-Path $projectRoot '.github\skills') -Recurse -Filter SKILL.md -File).Count | Should -Be 11
            @(Get-ChildItem -LiteralPath (Join-Path $projectRoot '.claude\skills') -Recurse -Filter SKILL.md -File).Count | Should -Be 11
        } finally {
            Remove-TestPath -Path $projectRoot
            Remove-TestPath -Path $copy
        }
    }

    It 'refuses to overwrite modified existing skills without Force' {
        $copy = New-TestPackageCopy
        $projectRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-refuse-{0}" -f ([Guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot '.agents\skills\story-to-plan') | Out-Null
        try {
            Set-Content -LiteralPath (Join-Path $projectRoot '.agents\skills\story-to-plan\SKILL.md') -Value 'changed' -Encoding utf8
            (Invoke-Installer -PackageCopy $copy -Platform codex -ProjectRoot $projectRoot) | Should -Not -Be 0
        } finally {
            Remove-TestPath -Path $projectRoot
            Remove-TestPath -Path $copy
        }
    }

    It 'refuses to overwrite modified installed support files without Force' {
        $copy = New-TestPackageCopy
        $projectRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-refuse-support-{0}" -f ([Guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path $projectRoot | Out-Null
        try {
            (Invoke-Installer -PackageCopy $copy -Platform codex -ProjectRoot $projectRoot) | Should -Be 0
            $supportFile = Join-Path $projectRoot '.agents\skills\create-handoff\references\input-contract.md'
            Set-Content -LiteralPath $supportFile -Value 'changed' -Encoding utf8
            (Invoke-Installer -PackageCopy $copy -Platform codex -ProjectRoot $projectRoot) | Should -Not -Be 0
        } finally {
            Remove-TestPath -Path $projectRoot
            Remove-TestPath -Path $copy
        }
    }

    It 'overwrites modified existing skills with Force' {
        $copy = New-TestPackageCopy
        $projectRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-force-{0}" -f ([Guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot '.agents\skills\story-to-plan') | Out-Null
        try {
            $target = Join-Path $projectRoot '.agents\skills\story-to-plan\SKILL.md'
            Set-Content -LiteralPath $target -Value 'changed' -Encoding utf8
            (Invoke-Installer -PackageCopy $copy -Platform codex -ProjectRoot $projectRoot -Force) | Should -Be 0
            (Get-Content -Raw -LiteralPath $target) | Should -Match 'story-to-plan'
        } finally {
            Remove-TestPath -Path $projectRoot
            Remove-TestPath -Path $copy
        }
    }

    It 'supports WhatIf' {
        $copy = New-TestPackageCopy
        $projectRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-whatif-{0}" -f ([Guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path $projectRoot | Out-Null
        try {
            (Invoke-Installer -PackageCopy $copy -Platform codex -ProjectRoot $projectRoot -WhatIf) | Should -Be 0
            (Test-Path (Join-Path $projectRoot '.agents\skills\story-to-plan\SKILL.md')) | Should -BeFalse
        } finally {
            Remove-TestPath -Path $projectRoot
            Remove-TestPath -Path $copy
        }
    }

    It 'preserves unrelated skills' {
        $copy = New-TestPackageCopy
        $projectRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-preserve-{0}" -f ([Guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot '.agents\skills\unrelated') | Out-Null
        $marker = Join-Path $projectRoot '.agents\skills\unrelated\keep.txt'
        Set-Content -LiteralPath $marker -Value 'keep' -Encoding utf8
        try {
            (Invoke-Installer -PackageCopy $copy -Platform codex -ProjectRoot $projectRoot) | Should -Be 0
            (Test-Path $marker) | Should -BeTrue
        } finally {
            Remove-TestPath -Path $projectRoot
            Remove-TestPath -Path $copy
        }
    }

    It 'reports partial failures for Platform=all' {
        $copy = New-TestPackageCopy
        $projectRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-partial-{0}" -f ([Guid]::NewGuid().ToString('N')))
        New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot '.agents\skills') | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot '.claude\skills') | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $projectRoot '.github') | Out-Null
        Set-Content -LiteralPath (Join-Path $projectRoot '.github\skills') -Value 'block copilot' -Encoding utf8
        try {
            (Invoke-Installer -PackageCopy $copy -Platform all -ProjectRoot $projectRoot) | Should -Not -Be 0
            (Get-ChildItem -LiteralPath (Join-Path $projectRoot '.agents\skills') -Recurse -Filter SKILL.md -File).Count | Should -Be 11
            (Get-ChildItem -LiteralPath (Join-Path $projectRoot '.claude\skills') -Recurse -Filter SKILL.md -File).Count | Should -Be 11
        } finally {
            Remove-TestPath -Path $projectRoot
            Remove-TestPath -Path $copy
        }
    }
}
