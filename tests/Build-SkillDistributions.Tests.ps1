BeforeAll {
    $script:Here = Split-Path -Parent $PSCommandPath
    $script:PackageRoot = Split-Path -Parent $script:Here

    function New-TestPackageCopy {
        $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic-workflow-skills-test-{0}" -f ([Guid]::NewGuid().ToString('N')))
        Copy-Item -LiteralPath $script:PackageRoot -Destination $tempRoot -Recurse -Force
        return $tempRoot
    }

    function Invoke-BuildScript {
        param(
            [Parameter(Mandatory)] [string]$PackageCopy,
            [switch]$Check,
            [switch]$Clean
        )

        $scriptPath = Join-Path $PackageCopy 'scripts\Build-SkillDistributions.ps1'
        $args = @('-NoProfile', '-File', $scriptPath)
        if ($Check) { $args += '-Check' }
        if ($Clean) { $args += '-Clean' }
        & pwsh @args | Out-Null
        return $LASTEXITCODE
    }

    function Get-GeneratedSkillFiles {
        param([Parameter(Mandatory)] [string]$PackageCopy)
        foreach ($hostName in 'codex','copilot','claude') {
            $hostRoot = Join-Path $PackageCopy (Join-Path 'dist' $hostName)
            if (Test-Path $hostRoot) {
                Get-ChildItem -LiteralPath $hostRoot -Recurse -Filter SKILL.md -File
            }
        }
    }

    function Get-GeneratedSkillDirectories {
        param([Parameter(Mandatory)] [string]$PackageCopy)
        Get-GeneratedSkillFiles -PackageCopy $PackageCopy | ForEach-Object { Split-Path -Parent $_.FullName }
    }

    function Remove-TestPackageCopy {
        param([Parameter(Mandatory)] [string]$Path)

        if (Test-Path $Path) {
            Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Describe 'Build-SkillDistributions.ps1' {
    It 'generates all generated skill files for eleven skills across three hosts' {
        $copy = New-TestPackageCopy
        try {
            $exitCode = Invoke-BuildScript -PackageCopy $copy
            $exitCode | Should -Be 0
            (Get-GeneratedSkillFiles -PackageCopy $copy).Count | Should -Be 33
        } finally {
            Remove-TestPackageCopy -Path $copy
        }
    }

    It 'packages shared references and templates with every generated skill' {
        $copy = New-TestPackageCopy
        try {
            (Invoke-BuildScript -PackageCopy $copy) | Should -Be 0
            foreach ($skillDir in Get-GeneratedSkillDirectories -PackageCopy $copy) {
                (Test-Path (Join-Path $skillDir 'references\input-contract.md')) | Should -BeTrue
                (Test-Path (Join-Path $skillDir 'references\artifact-contract.md')) | Should -BeTrue
                (Test-Path (Join-Path $skillDir 'templates\cross-tool-handoff-template.md')) | Should -BeTrue
            }
        } finally {
            Remove-TestPackageCopy -Path $copy
        }
    }

    It 'produces deterministic output on repeated runs' {
        $copy = New-TestPackageCopy
        try {
            (Invoke-BuildScript -PackageCopy $copy) | Should -Be 0
            $distRoot = Join-Path $copy 'dist'
            $first = Get-ChildItem -LiteralPath $distRoot -Recurse -File | Sort-Object FullName | ForEach-Object {
                [pscustomobject]@{
                    Path = $_.FullName.Substring($distRoot.Length).TrimStart('\','/')
                    Hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash
                }
            }
            (Invoke-BuildScript -PackageCopy $copy) | Should -Be 0
            $second = Get-ChildItem -LiteralPath $distRoot -Recurse -File | Sort-Object FullName | ForEach-Object {
                [pscustomobject]@{
                    Path = $_.FullName.Substring($distRoot.Length).TrimStart('\','/')
                    Hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash
                }
            }
            $first.Count | Should -Be $second.Count
            for ($i = 0; $i -lt $first.Count; $i++) {
                $first[$i].Path | Should -Be $second[$i].Path
                $first[$i].Hash | Should -Be $second[$i].Hash
            }
        } finally {
            Remove-TestPackageCopy -Path $copy
        }
    }

    It 'supports clean rebuild' {
        $copy = New-TestPackageCopy
        try {
            (Invoke-BuildScript -PackageCopy $copy) | Should -Be 0
            $distRoot = Join-Path $copy 'dist'
            Set-Content -LiteralPath (Join-Path $distRoot 'unrelated.txt') -Value 'keep me' -Encoding utf8
            (Invoke-BuildScript -PackageCopy $copy -Clean) | Should -Be 0
            (Test-Path (Join-Path $distRoot 'codex')) | Should -BeFalse
            (Invoke-BuildScript -PackageCopy $copy) | Should -Be 0
            (Get-GeneratedSkillFiles -PackageCopy $copy).Count | Should -Be 33
        } finally {
            Remove-TestPackageCopy -Path $copy
        }
    }

    It 'detects drift' {
        $copy = New-TestPackageCopy
        try {
            (Invoke-BuildScript -PackageCopy $copy) | Should -Be 0
            $file = Join-Path $copy 'dist\codex\.agents\skills\story-to-plan\SKILL.md'
            Add-Content -LiteralPath $file -Value "`nDrift" -Encoding utf8
            (Invoke-BuildScript -PackageCopy $copy -Check) | Should -Not -Be 0
        } finally {
            Remove-TestPackageCopy -Path $copy
        }
    }

    It 'fails on malformed metadata' {
        $copy = New-TestPackageCopy
        try {
            $metadata = Join-Path $copy 'src\skills\story-to-plan\metadata.json'
            Set-Content -LiteralPath $metadata -Value '{ invalid json' -Encoding utf8
            (Invoke-BuildScript -PackageCopy $copy) | Should -Not -Be 0
        } finally {
            Remove-TestPackageCopy -Path $copy
        }
    }

    It 'fails on missing body' {
        $copy = New-TestPackageCopy
        try {
            Remove-Item -LiteralPath (Join-Path $copy 'src\skills\story-to-plan\body.md') -Force
            (Invoke-BuildScript -PackageCopy $copy) | Should -Not -Be 0
        } finally {
            Remove-TestPackageCopy -Path $copy
        }
    }

    It 'escapes YAML quotes and special characters' {
        $copy = New-TestPackageCopy
        try {
            $metadata = Join-Path $copy 'src\skills\story-to-plan\metadata.json'
            $json = Get-Content -Raw -LiteralPath $metadata | ConvertFrom-Json
            $json.description = 'Use when the story contains "quotes", ampersands &, and colon: characters.'
            $json | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $metadata -Encoding utf8
            (Invoke-BuildScript -PackageCopy $copy) | Should -Be 0
            $skillFile = Join-Path $copy 'dist\codex\.agents\skills\story-to-plan\SKILL.md'
            $content = Get-Content -Raw -LiteralPath $skillFile
            ($content -split "`n" | Where-Object { $_ -like 'description:*' } | Select-Object -First 1) | Should -BeExactly 'description: "Use when the story contains \\"quotes\\", ampersands &, and colon: characters."'
        } finally {
            Remove-TestPackageCopy -Path $copy
        }
    }

    It 'works from a path with spaces' {
        $copy = New-TestPackageCopy
        $spacedParent = Join-Path ([System.IO.Path]::GetTempPath()) ("agentic workflow skills {0}" -f ([Guid]::NewGuid().ToString('N')))
        $spacedCopy = Join-Path $spacedParent (Split-Path $script:PackageRoot -Leaf)
        try {
            New-Item -ItemType Directory -Force -Path $spacedParent | Out-Null
            Copy-Item -LiteralPath $copy -Destination $spacedCopy -Recurse -Force
            Remove-TestPackageCopy -Path $copy
            (Invoke-BuildScript -PackageCopy $spacedCopy) | Should -Be 0
            (Get-GeneratedSkillFiles -PackageCopy $spacedCopy).Count | Should -Be 33
        } finally {
            Remove-TestPackageCopy -Path $spacedCopy
            Remove-TestPackageCopy -Path $spacedParent
        }
    }

    It 'does not delete unrelated files' {
        $copy = New-TestPackageCopy
        try {
            $marker = Join-Path $copy 'keep.txt'
            Set-Content -LiteralPath $marker -Value 'keep' -Encoding utf8
            (Invoke-BuildScript -PackageCopy $copy -Clean) | Should -Be 0
            (Test-Path $marker) | Should -BeTrue
        } finally {
            Remove-TestPackageCopy -Path $copy
        }
    }
}
