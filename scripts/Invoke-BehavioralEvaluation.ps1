param(
    [Parameter(Mandatory)]
    [ValidateSet('codex', 'copilot', 'claude')]
    [string]$Platform,

    [Parameter(Mandatory)]
    [ValidateSet(
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
    )]
    [string]$Skill,

    [string]$Scenario,

    [switch]$AllowModelInvocation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageRoot = Split-Path -Parent $scriptRoot
$scenarioRoot = Join-Path $packageRoot (Join-Path 'tests\scenarios' $Skill)
$artifactsRoot = Join-Path $packageRoot 'artifacts\evaluations'

function Get-ScenarioFiles {
    param([string]$Root)

    if (-not (Test-Path -LiteralPath $Root)) {
        return @()
    }

    Get-ChildItem -LiteralPath $Root -Filter *.md -File | Sort-Object Name
}

function Resolve-ScenarioFile {
    param(
        [string]$Root,
        [string]$Value
    )

    $files = @(Get-ScenarioFiles -Root $Root)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    $name = Split-Path -Leaf $Value
    if (-not $name.EndsWith('.md', [System.StringComparison]::OrdinalIgnoreCase)) {
        $name = "$name.md"
    }

    $resolved = $files | Where-Object {
        $_.Name -eq $name -or $_.BaseName -eq ([System.IO.Path]::GetFileNameWithoutExtension($name))
    } | Select-Object -First 1
    return $resolved
}

if (-not (Test-Path -LiteralPath $scenarioRoot)) {
    throw "Scenario directory not found: $scenarioRoot"
}

$availableScenarios = @(Get-ScenarioFiles -Root $scenarioRoot)
if ($availableScenarios.Count -eq 0) {
    throw "No scenarios found for $Skill under $scenarioRoot"
}

if ([string]::IsNullOrWhiteSpace($Scenario)) {
    Write-Host "Available scenarios for $Skill on ${Platform}:"
    foreach ($file in $availableScenarios) {
        Write-Host ("- {0}" -f $file.BaseName)
    }
    Write-Host 'Provide -Scenario to record an evaluation artifact.'
    exit 0
}

$scenarioFile = Resolve-ScenarioFile -Root $scenarioRoot -Value $Scenario
if ($null -eq $scenarioFile) {
    throw "Scenario not found: $Scenario"
}

New-Item -ItemType Directory -Force -Path $artifactsRoot | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$artifactPath = Join-Path $artifactsRoot "$stamp-$Platform-$Skill-$($scenarioFile.BaseName)-evaluation.md"

$lines = @(
    '# Behavioral Evaluation Record',
    '',
    "Generated: $(Get-Date -Format o)",
    "Platform: $Platform",
    "Skill: $Skill",
    "Scenario: $($scenarioFile.BaseName)",
    "Scenario file: $($scenarioFile.FullName.Substring($packageRoot.Length).TrimStart('\'))",
    "Model invocation requested: $([bool]$AllowModelInvocation)",
    '',
    '## Result',
    '',
    'This runner records the evaluation request and scenario context.',
    'It does not invoke a model automatically.',
    'Use the scenario text to run the pressure test in your chosen host and record the observed behavior here.',
    '',
    '## Scenario',
    '',
    (Get-Content -Raw -LiteralPath $scenarioFile.FullName).TrimEnd()
)

Set-Content -LiteralPath $artifactPath -Value ($lines -join "`n") -Encoding utf8

Write-Host "Recorded evaluation scaffold at $artifactPath"
if (-not $AllowModelInvocation) {
    Write-Host 'Model invocation was not requested. No agent action was taken.'
}
