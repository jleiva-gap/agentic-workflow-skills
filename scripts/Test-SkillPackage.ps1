param(
    [switch]$Check,
    [switch]$Clean,
    [string]$ReportPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageRoot = Split-Path -Parent $scriptRoot
$artifactsRoot = Join-Path $packageRoot 'artifacts'
$reportPath = if ([string]::IsNullOrWhiteSpace($ReportPath)) {
    Join-Path $artifactsRoot 'validation-report.md'
} else {
    $ReportPath
}
$srcRoot = Join-Path $packageRoot 'src'
$testsRoot = Join-Path $packageRoot 'tests'
$distRoot = Join-Path $packageRoot 'dist'
$pluginMarketplaceRoot = Join-Path $distRoot 'plugin-marketplace'
$requiredDocs = @(
    'docs\architecture.md',
    'docs\compatibility.md',
    'docs\authoring.md',
    'docs\evaluation.md',
    'docs\workflow-handoff.md',
    'docs\agentic-workflow-manual.md',
    'docs\agentic-workflow-diagrams.md'
)
$requiredScripts = @(
    'scripts\Build-SkillDistributions.ps1',
    'scripts\Install-AgenticWorkflowSkills.ps1',
    'scripts\Build-AgenticWorkflowPlugin.ps1',
    'scripts\Install-AgenticWorkflowPlugin.ps1',
    'scripts\Test-SkillPackage.ps1',
    'scripts\Invoke-BehavioralEvaluation.ps1'
)
$requiredCanonical = @(
    'src\shared\references\input-contract.md',
    'src\shared\references\artifact-contract.md',
    'src\shared\references\superpowers-dependencies.md',
    'src\shared\references\blocking-conditions.md',
    'src\shared\templates\cross-tool-handoff-template.md',
    'src\shared\templates\design-handoff-template.md',
    'src\shared\templates\implementation-progress-template.md',
    'src\shared\templates\review-findings-template.md',
    'src\skills\story-to-plan\body.md',
    'src\skills\story-to-plan\metadata.json',
    'src\skills\implement-approved-plan\body.md',
    'src\skills\implement-approved-plan\metadata.json',
    'src\skills\resume-approved-plan\body.md',
    'src\skills\resume-approved-plan\metadata.json',
    'src\skills\create-handoff\body.md',
    'src\skills\create-handoff\metadata.json',
    'src\skills\verify-handoff\body.md',
    'src\skills\verify-handoff\metadata.json',
    'src\skills\self-qa-review\body.md',
    'src\skills\self-qa-review\metadata.json',
    'src\skills\critical-review\body.md',
    'src\skills\critical-review\metadata.json',
    'src\skills\adversarial-review\body.md',
    'src\skills\adversarial-review\metadata.json',
    'src\skills\critical-adversarial-review\body.md',
    'src\skills\critical-adversarial-review\metadata.json',
    'src\skills\review-findings-validator\body.md',
    'src\skills\review-findings-validator\metadata.json',
    'src\skills\critical-review-with-validation\body.md',
    'src\skills\critical-review-with-validation\metadata.json'
)
$expectedScenarioFiles = @(
    'tests\scenarios\story-to-plan\01-minimal-valid-story-and-file-path.md',
    'tests\scenarios\story-to-plan\02-inline-story-with-no-file.md',
    'tests\scenarios\story-to-plan\03-missing-story-source.md',
    'tests\scenarios\story-to-plan\04-ambiguous-acceptance-criterion.md',
    'tests\scenarios\story-to-plan\05-user-demands-immediate-implementation.md',
    'tests\scenarios\story-to-plan\06-existing-spec-and-plan-already-present.md',
    'tests\scenarios\story-to-plan\07-contradictory-story-and-notes.md',
    'tests\scenarios\story-to-plan\08-missing-brainstorming.md',
    'tests\scenarios\story-to-plan\09-missing-writing-plans.md',
    'tests\scenarios\story-to-plan\10-approved-design-but-no-written-spec-approval.md',
    'tests\scenarios\story-to-plan\11-skip-alternative-analysis.md',
    'tests\scenarios\story-to-plan\12-attempt-to-write-code-during-planning.md',
    'tests\scenarios\implement-approved-plan\01-clean-repo-and-passing-baseline.md',
    'tests\scenarios\implement-approved-plan\02-dirty-repo-with-unrelated-changes.md',
    'tests\scenarios\implement-approved-plan\03-already-inside-a-worktree.md',
    'tests\scenarios\implement-approved-plan\04-failing-baseline-tests.md',
    'tests\scenarios\implement-approved-plan\05-plan-spec-contradiction.md',
    'tests\scenarios\implement-approved-plan\06-missing-file-referenced-by-plan.md',
    'tests\scenarios\implement-approved-plan\07-user-asks-to-skip-tests.md',
    'tests\scenarios\implement-approved-plan\08-mark-task-complete-without-evidence.md',
    'tests\scenarios\implement-approved-plan\09-subagent-driven-skill-unavailable-executing-plans-available.md',
    'tests\scenarios\implement-approved-plan\10-both-execution-skills-unavailable.md',
    'tests\scenarios\implement-approved-plan\11-partial-task-failure.md',
    'tests\scenarios\implement-approved-plan\12-final-regression-failure.md',
    'tests\scenarios\resume-approved-plan\01-correctly-checked-completed-task.md',
    'tests\scenarios\resume-approved-plan\02-falsely-checked-incomplete-task.md',
    'tests\scenarios\resume-approved-plan\03-completed-code-with-unchecked-plan-task.md',
    'tests\scenarios\resume-approved-plan\04-partially-implemented-uncommitted-task.md',
    'tests\scenarios\resume-approved-plan\05-new-branch-with-stale-progress-file.md',
    'tests\scenarios\resume-approved-plan\06-prior-chat-unavailable.md',
    'tests\scenarios\resume-approved-plan\07-pre-existing-failing-test.md',
    'tests\scenarios\resume-approved-plan\08-plan-changed-after-implementation-began.md',
    'tests\scenarios\resume-approved-plan\09-conflicting-commits-and-progress-record.md',
    'tests\scenarios\resume-approved-plan\10-user-asks-to-restart-everything-unnecessarily.md',
    'tests\scenarios\resume-approved-plan\11-process-id-first-ux.md',
    'tests\scenarios\create-handoff\01-create-handoff-from-current-state.md',
    'tests\scenarios\create-handoff\02-refresh-stale-handoff.md',
    'tests\scenarios\create-handoff\03-process-id-first-ux.md',
    'tests\scenarios\verify-handoff\01-safe-to-reuse.md',
    'tests\scenarios\verify-handoff\02-stale-handoff-needs-refresh.md',
    'tests\scenarios\verify-handoff\03-process-id-first-ux.md',
    'tests\scenarios\self-qa-review\01-run-self-qa-review-and-create-remediation-handoff.md',
    'tests\scenarios\self-qa-review\02-reuse-existing-findings-for-fix-back.md',
    'tests\scenarios\critical-review\01-static-review-only.md',
    'tests\scenarios\adversarial-review\01-pressure-test-edge-cases.md',
    'tests\scenarios\critical-adversarial-review\01-critical-plus-adversarial.md',
    'tests\scenarios\review-findings-validator\01-triage-an-existing-review.md',
    'tests\scenarios\critical-review-with-validation\01-critical-review-with-validation.md'
)

function New-Result {
    param(
        [Parameter(Mandatory)] [string]$CheckName,
        [Parameter(Mandatory)] [ValidateSet('PASS', 'FAIL', 'SKIP')] [string]$Status,
        [Parameter(Mandatory)] [string]$Details
    )

    [pscustomobject]@{
        Check = $CheckName
        Status = $Status
        Details = $Details
    }
}

function Test-FilePresent {
    param([Parameter(Mandatory)] [string]$RelativePath)

    $path = Join-Path $packageRoot $RelativePath
    return Test-Path -LiteralPath $path
}

function Test-JsonMetadata {
    param(
        [Parameter(Mandatory)] [string]$RelativePath,
        [Parameter(Mandatory)] [string]$ExpectedName
    )

    $path = Join-Path $packageRoot $RelativePath
    $content = Get-Content -Raw -LiteralPath $path | ConvertFrom-Json
    if ($content.name -ne $ExpectedName) {
        throw "Name mismatch in $RelativePath."
    }
    if ([string]::IsNullOrWhiteSpace($content.description)) {
        throw "Description missing in $RelativePath."
    }
    if ($content.description -notmatch '^Use when\b') {
        throw "Description in $RelativePath must begin with 'Use when'."
    }
}

function Test-NoPlaceholderTokens {
    param([Parameter(Mandatory)] [string]$RelativePath)

    $content = Get-Content -Raw -LiteralPath (Join-Path $packageRoot $RelativePath)
    if ($content -match '\b(TBD|TODO|implement later|fill in details)\b') {
        throw "Placeholder token found in $RelativePath."
    }
}

function Test-ProgressTemplateEvidenceFields {
    $relativePath = 'src\shared\templates\implementation-progress-template.md'
    $content = Get-Content -Raw -LiteralPath (Join-Path $packageRoot $relativePath)
    $requiredPatterns = @(
        'Task id:',
        'Completion timestamp:',
        'Files modified:',
        'Commit SHA:',
        'Targeted test command:',
        'Targeted test result:',
        'Regression command:',
        'Regression result:',
        'Deviations from plan:',
        'Remaining risks:',
        'Evidence source:'
    )

    $missing = @($requiredPatterns | Where-Object { $content -notmatch [regex]::Escape($_) })
    if ($missing.Count -gt 0) {
        throw "Progress template missing evidence fields: $($missing -join ', ')."
    }
}

function Test-GeneratedInvocationMetadata {
    param(
        [Parameter(Mandatory)] [string]$HostName,
        [Parameter(Mandatory)] [string]$SkillRoot
    )

    foreach ($metadataPath in Get-ChildItem -LiteralPath (Join-Path $srcRoot 'skills') -Directory | ForEach-Object { Join-Path $_.FullName 'metadata.json' }) {
        $metadata = Get-Content -Raw -LiteralPath $metadataPath | ConvertFrom-Json
        $skillName = $metadata.name
        $skillFile = Join-Path $SkillRoot (Join-Path $skillName 'SKILL.md')
        if (-not (Test-Path -LiteralPath $skillFile)) {
            throw "Missing generated $HostName skill file for $skillName."
        }

        $content = Get-Content -Raw -LiteralPath $skillFile
        $expectedUserInvocable = if ($null -ne $metadata.PSObject.Properties['userInvocable']) { [bool]$metadata.userInvocable } else { $true }
        $expectedDisableModelInvocation = if ($null -ne $metadata.PSObject.Properties['disableModelInvocation']) { [bool]$metadata.disableModelInvocation } else { $true }
        $expectedUserLine = "user-invocable: $($expectedUserInvocable.ToString().ToLowerInvariant())"
        $expectedDisableLine = "disable-model-invocation: $($expectedDisableModelInvocation.ToString().ToLowerInvariant())"

        if ($content -notmatch "(?m)^$([regex]::Escape($expectedUserLine))$") {
            throw "$HostName generated metadata for $skillName does not contain '$expectedUserLine'."
        }
        if ($content -notmatch "(?m)^$([regex]::Escape($expectedDisableLine))$") {
            throw "$HostName generated metadata for $skillName does not contain '$expectedDisableLine'."
        }
    }
}

function Write-Report {
    param([Parameter(Mandatory)] [System.Collections.IEnumerable]$Rows)

    $reportDirectory = Split-Path -Parent $reportPath
    if ([string]::IsNullOrWhiteSpace($reportDirectory)) {
        $reportDirectory = $artifactsRoot
    }
    New-Item -ItemType Directory -Force -Path $reportDirectory | Out-Null
    $gitCommit = try {
        (git -C $packageRoot rev-parse --short HEAD 2>$null).Trim()
    } catch {
        'unknown'
    }

    $lines = @(
        '# Package Validation Report',
        '',
        "Generated: $(Get-Date -Format o)",
        "Git commit: $gitCommit",
        "PowerShell: $($PSVersionTable.PSVersion)",
        '',
        '| Check | Status | Details |',
        '| --- | --- | --- |'
    )
    foreach ($row in $Rows) {
        $lines += "| $($row.Check) | $($row.Status) | $($row.Details) |"
    }
    $lines += ''
    $lines += '## Commands'
    $lines += ''
    $lines += '- `pwsh ./scripts/Build-SkillDistributions.ps1 -Check`'
    $lines += '- `pwsh ./scripts/Build-AgenticWorkflowPlugin.ps1 -Check`'
    $lines += '- `pwsh ./scripts/Invoke-BehavioralEvaluation.ps1 -Platform codex -Skill story-to-plan -Scenario 01-minimal-valid-story-and-file-path`'
    $lines += '- `pwsh ./scripts/Invoke-BehavioralEvaluation.ps1 -Platform codex -Skill self-qa-review -Scenario 01-run-self-qa-review-and-create-remediation-handoff`'
    $lines += '- `pwsh ./scripts/Invoke-BehavioralEvaluation.ps1 -Platform codex -Skill critical-review-with-validation -Scenario 01-critical-review-with-validation`'
    $lines += ''
    try {
        Set-Content -LiteralPath $reportPath -Value ($lines -join "`n") -Encoding utf8
    } catch {
        Write-Warning "Unable to write validation report to ${reportPath}: $($_.Exception.Message)"
        Write-Host ($lines -join "`n")
    }
}

$rows = [System.Collections.Generic.List[object]]::new()
$failed = $false

try {
    if ($Clean) {
        if (Test-Path -LiteralPath $reportPath) {
            Remove-Item -LiteralPath $reportPath -Force
        }
        Write-Host 'Removed validation report.'
        exit 0
    }

    $rows.Add((New-Result 'package root' 'PASS' 'Located'))

    foreach ($relative in $requiredDocs + $requiredScripts + $requiredCanonical) {
        if (Test-FilePresent -RelativePath $relative) {
            $rows.Add((New-Result $relative 'PASS' 'Present'))
        } else {
            $failed = $true
            $rows.Add((New-Result $relative 'FAIL' 'Missing'))
        }
    }

    foreach ($scenario in $expectedScenarioFiles) {
        if (Test-FilePresent -RelativePath $scenario) {
            $rows.Add((New-Result $scenario 'PASS' 'Present'))
        } else {
            $failed = $true
            $rows.Add((New-Result $scenario 'FAIL' 'Missing'))
        }
    }

    foreach ($relative in @(
        'src\skills\story-to-plan\metadata.json',
        'src\skills\implement-approved-plan\metadata.json',
        'src\skills\resume-approved-plan\metadata.json',
        'src\skills\create-handoff\metadata.json',
        'src\skills\verify-handoff\metadata.json',
        'src\skills\self-qa-review\metadata.json',
        'src\skills\critical-review\metadata.json',
        'src\skills\adversarial-review\metadata.json',
        'src\skills\critical-adversarial-review\metadata.json',
        'src\skills\review-findings-validator\metadata.json',
        'src\skills\critical-review-with-validation\metadata.json'
    )) {
        try {
            $name = Split-Path -Leaf (Split-Path -Parent $relative)
            Test-JsonMetadata -RelativePath $relative -ExpectedName $name
            $rows.Add((New-Result $relative 'PASS' 'Valid canonical metadata'))
        } catch {
            $failed = $true
            $rows.Add((New-Result $relative 'FAIL' $_.Exception.Message))
        }
    }

    foreach ($relative in @(
        'src\skills\story-to-plan\body.md',
        'src\skills\implement-approved-plan\body.md',
        'src\skills\resume-approved-plan\body.md',
        'src\skills\create-handoff\body.md',
        'src\skills\verify-handoff\body.md',
        'src\skills\self-qa-review\body.md',
        'src\skills\critical-review\body.md',
        'src\skills\adversarial-review\body.md',
        'src\skills\critical-adversarial-review\body.md',
        'src\skills\review-findings-validator\body.md',
        'src\skills\critical-review-with-validation\body.md',
        'README.md',
        'AGENTS.md',
        'CHANGELOG.md',
        'docs\architecture.md',
        'docs\compatibility.md',
        'docs\authoring.md',
        'docs\evaluation.md'
    )) {
        try {
            Test-NoPlaceholderTokens -RelativePath $relative
            $rows.Add((New-Result $relative 'PASS' 'No placeholder tokens found'))
        } catch {
            $failed = $true
            $rows.Add((New-Result $relative 'FAIL' $_.Exception.Message))
        }
    }

    try {
        Test-ProgressTemplateEvidenceFields
        $rows.Add((New-Result 'progress evidence template' 'PASS' 'Required resume evidence fields present'))
    } catch {
        $failed = $true
        $rows.Add((New-Result 'progress evidence template' 'FAIL' $_.Exception.Message))
    }

    if (Test-Path -LiteralPath $distRoot) {
        $skillFiles = @()
        foreach ($hostName in @('codex', 'copilot', 'claude')) {
            $hostRoot = Join-Path $distRoot $hostName
            if (Test-Path -LiteralPath $hostRoot) {
                $skillFiles += @(Get-ChildItem -LiteralPath $hostRoot -Recurse -Filter SKILL.md -File)
            }
        }
        if ($skillFiles.Count -ge 33) {
            $rows.Add((New-Result 'dist layout' 'PASS' "$($skillFiles.Count) generated skill files found"))
        } else {
            $failed = $true
            $rows.Add((New-Result 'dist layout' 'FAIL' "Expected at least 33 generated skill files, found $($skillFiles.Count)"))
        }

        $missingSupport = @()
        foreach ($skillFile in $skillFiles) {
            $skillDir = Split-Path -Parent $skillFile.FullName
            foreach ($supportPath in @(
                'references\input-contract.md',
                'references\artifact-contract.md',
                'references\superpowers-dependencies.md',
                'references\blocking-conditions.md',
                'templates\cross-tool-handoff-template.md',
                'templates\design-handoff-template.md',
                'templates\implementation-progress-template.md',
                'templates\review-findings-template.md'
            )) {
                if (-not (Test-Path -LiteralPath (Join-Path $skillDir $supportPath))) {
                    $missingSupport += "$($skillFile.FullName):$supportPath"
                }
            }
        }

        if ($missingSupport.Count -eq 0) {
            $rows.Add((New-Result 'dist support files' 'PASS' 'Shared references and templates packaged with every generated skill'))
        } else {
            $failed = $true
            $rows.Add((New-Result 'dist support files' 'FAIL' ($missingSupport -join '; ')))
        }

        foreach ($hostName in @('copilot', 'claude')) {
            $skillRoot = switch ($hostName) {
                'copilot' { Join-Path $distRoot 'copilot\.github\skills' }
                'claude' { Join-Path $distRoot 'claude\.claude\skills' }
            }
            try {
                Test-GeneratedInvocationMetadata -HostName $hostName -SkillRoot $skillRoot
                $rows.Add((New-Result "$hostName invocation metadata" 'PASS' 'Generated frontmatter matches canonical skill metadata'))
            } catch {
                $failed = $true
                $rows.Add((New-Result "$hostName invocation metadata" 'FAIL' $_.Exception.Message))
            }
        }

        if ($Check) {
            $buildCheck = & pwsh -NoProfile -File (Join-Path $scriptRoot 'Build-SkillDistributions.ps1') -Check 2>&1
            if ($LASTEXITCODE -eq 0) {
                $rows.Add((New-Result 'Build-SkillDistributions.ps1 -Check' 'PASS' 'No drift detected'))
            } else {
                $failed = $true
                $rows.Add((New-Result 'Build-SkillDistributions.ps1 -Check' 'FAIL' (($buildCheck -join ' ') -replace '\s+', ' ').Trim()))
            }
        } else {
            $rows.Add((New-Result 'Build-SkillDistributions.ps1 -Check' 'SKIP' 'Run with -Check to compare generated distributions.'))
        }
    } else {
        $rows.Add((New-Result 'dist layout' 'SKIP' 'dist/ is not present yet.'))
        $rows.Add((New-Result 'Build-SkillDistributions.ps1 -Check' 'SKIP' 'dist/ is not present yet.'))
    }

    if (Test-Path -LiteralPath $pluginMarketplaceRoot) {
        $codexMarketplace = Join-Path $pluginMarketplaceRoot '.agents\plugins\marketplace.json'
        $codexRootManifest = Join-Path $pluginMarketplaceRoot '.codex-plugin\plugin.json'
        $codexRootSkillRoot = Join-Path $pluginMarketplaceRoot 'skills'
        $pluginManifest = Join-Path $pluginMarketplaceRoot 'plugins\agentic-workflow-skills\.codex-plugin\plugin.json'
        $marketplace = Join-Path $pluginMarketplaceRoot 'marketplace.json'
        $codexPluginSkillRoot = Join-Path $pluginMarketplaceRoot 'plugins\agentic-workflow-skills\skills'
        $copilotPluginSkillRoot = Join-Path $pluginMarketplaceRoot 'plugins\agentic-workflow-skills\hosts\copilot\.github\skills'
        $claudePluginSkillRoot = Join-Path $pluginMarketplaceRoot 'plugins\agentic-workflow-skills\hosts\claude\.claude\skills'
        $claudeMarketplace = Join-Path $pluginMarketplaceRoot 'hosts\claude-marketplace\.claude-plugin\marketplace.json'
        $claudeMarketplaceSkillRoot = Join-Path $pluginMarketplaceRoot 'hosts\claude-marketplace\plugins\agentic-workflow-skills\skills'
        $copilotMarketplace = Join-Path $pluginMarketplaceRoot 'hosts\copilot-marketplace\marketplace.json'
        $copilotMarketplaceSkillRoot = Join-Path $pluginMarketplaceRoot 'hosts\copilot-marketplace\plugins\agentic-workflow-skills\skills'

        try {
            if (-not (Test-Path $marketplace)) { throw "Missing marketplace file: $marketplace" }
            if (-not (Test-Path $codexMarketplace)) { throw "Missing Codex marketplace file: $codexMarketplace" }
            if (-not (Test-Path $codexRootManifest)) { throw "Missing Codex root plugin manifest: $codexRootManifest" }
            if (-not (Test-Path $pluginManifest)) { throw "Missing plugin manifest: $pluginManifest" }
            if (-not (Test-Path $claudeMarketplace)) { throw "Missing Claude marketplace file: $claudeMarketplace" }
            if (-not (Test-Path $copilotMarketplace)) { throw "Missing Copilot marketplace file: $copilotMarketplace" }

            $codexMarketplaceContent = Get-Content -Raw -LiteralPath $codexMarketplace | ConvertFrom-Json
            if ($codexMarketplaceContent.plugins[0].source.url -ne './') { throw 'Codex marketplace source must point at the repository root.' }

            $manifest = Get-Content -Raw -LiteralPath $pluginManifest | ConvertFrom-Json
            if ($manifest.name -ne 'agentic-workflow-skills') { throw 'Plugin manifest name mismatch.' }
            if ($manifest.skills -ne './skills/') { throw 'Plugin manifest skills path must be ./skills/.' }

            $codexRootManifestContent = Get-Content -Raw -LiteralPath $codexRootManifest | ConvertFrom-Json
            if ($codexRootManifestContent.name -ne 'agentic-workflow-skills') { throw 'Codex root plugin manifest name mismatch.' }
            if ($codexRootManifestContent.skills -ne './skills/') { throw 'Codex root plugin manifest skills path must be ./skills/.' }

            $codexRootSkills = @(Get-ChildItem -LiteralPath $codexRootSkillRoot -Directory)
            if ($codexRootSkills.Count -ne 11) { throw "Expected 11 plugin skills under $codexRootSkillRoot, found $($codexRootSkills.Count)." }
            if ('self-qa-review' -notin $codexRootSkills.Name) { throw "self-qa-review missing under $codexRootSkillRoot." }

            foreach ($root in @($codexPluginSkillRoot, $copilotPluginSkillRoot, $claudePluginSkillRoot, $claudeMarketplaceSkillRoot, $copilotMarketplaceSkillRoot)) {
                $skills = @(Get-ChildItem -LiteralPath $root -Directory)
                if ($skills.Count -ne 11) { throw "Expected 11 plugin skills under $root, found $($skills.Count)." }
                if ('self-qa-review' -notin $skills.Name) { throw "self-qa-review missing under $root." }
            }

            $rows.Add((New-Result 'plugin layout' 'PASS' 'Codex root, Claude, and Copilot plugin manifests and host skill bundles present'))
        } catch {
            $failed = $true
            $rows.Add((New-Result 'plugin layout' 'FAIL' $_.Exception.Message))
        }

        if ($Check) {
            $pluginCheck = & pwsh -NoProfile -File (Join-Path $scriptRoot 'Build-AgenticWorkflowPlugin.ps1') -Check 2>&1
            if ($LASTEXITCODE -eq 0) {
                $rows.Add((New-Result 'Build-AgenticWorkflowPlugin.ps1 -Check' 'PASS' 'No plugin drift detected'))
            } else {
                $failed = $true
                $rows.Add((New-Result 'Build-AgenticWorkflowPlugin.ps1 -Check' 'FAIL' (($pluginCheck -join ' ') -replace '\s+', ' ').Trim()))
            }
        } else {
            $rows.Add((New-Result 'Build-AgenticWorkflowPlugin.ps1 -Check' 'SKIP' 'Run with -Check to compare generated plugin bundle.'))
        }
    } else {
        $rows.Add((New-Result 'plugin layout' 'SKIP' 'dist/plugin-marketplace is not present yet.'))
        $rows.Add((New-Result 'Build-AgenticWorkflowPlugin.ps1 -Check' 'SKIP' 'dist/plugin-marketplace is not present yet.'))
    }

    Write-Report -Rows $rows

    foreach ($row in $rows) {
        Write-Host ("{0,-50} {1,-5} {2}" -f $row.Check, $row.Status, $row.Details)
    }

    if ($failed) {
        exit 1
    }

    exit 0
} catch {
    $rows.Add((New-Result 'validation run' 'FAIL' $_.Exception.Message))
    Write-Report -Rows $rows
    Write-Error $_
    exit 1
}
