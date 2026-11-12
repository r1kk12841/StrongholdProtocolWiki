# Validate translated EN JSON files against CN JSON files:
# 1. Exact entry counts
# 2. Zero leftover Chinese characters in EN fields
# 3. Numeric parity between CN and EN effect strings
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$enDir = Join-Path $root 'data\en'

function LoadJson($p) { Get-Content -Raw -Encoding UTF8 $p | ConvertFrom-Json }
function HasChinese([string]$s) { return [regex]::IsMatch($s, '[\u4e00-\u9fff]') }

$A = LoadJson (Join-Path $enDir 'alliances.json')
$S = LoadJson (Join-Path $enDir 'strategies.json')
$O = LoadJson (Join-Path $enDir 'operators.json')
$E = LoadJson (Join-Path $enDir 'equipment.json')

"Counts: Alliances=$($A.Count)/26, Strategies=$($S.Count)/61, Operators=$($O.Count)/143, Equipment=$($E.Count)/70"

$cnLeftovers = @()
foreach ($x in $A) {
    if (HasChinese $x.enName) { $cnLeftovers += "Alliance enName: $($x.enName)" }
    if (HasChinese $x.enEffect) { $cnLeftovers += "Alliance enEffect ($($x.enName)): $($x.enEffect)" }
    foreach ($op in $x.operators) {
        if (-not $op.en -or (HasChinese $op.en)) { $cnLeftovers += "Alliance op ($($x.enName)): $($op.cn)->$($op.en)" }
    }
}
foreach ($x in $S) {
    foreach ($f in 'enLeader', 'enName', 'enEffect', 'enUnlock') {
        if (-not $x.$f -or (HasChinese $x.$f)) { $cnLeftovers += "Strategy $f ($($x.cnLeader)): $($x.$f)" }
    }
}
foreach ($x in $O) {
    foreach ($f in 'enName', 'abilityTypeEn', 'enAbility', 'enUpgraded') {
        if (-not $x.$f -or (HasChinese $x.$f)) { $cnLeftovers += "Operator $f ($($x.cnName)): $($x.$f)" }
    }
    foreach ($al in $x.enAlliances) {
        if (-not $al -or (HasChinese $al)) { $cnLeftovers += "Operator alliance ($($x.cnName)): $al" }
    }
}
foreach ($x in $E) {
    foreach ($f in 'enName', 'enEffect', 'enUpgraded') {
        if (-not $x.$f -or (HasChinese $x.$f)) { $cnLeftovers += "Equipment $f ($($x.cnName)): $($x.$f)" }
    }
}
"Chinese leftovers in EN fields: $($cnLeftovers.Count)"
if ($cnLeftovers.Count -gt 0) { $cnLeftovers | ForEach-Object { "  $_" } }

# Check numeric parity in Alliances
function GetNums([string]$s) {
    # Normalize Chinese number words before extracting digits
    $s = $s -replace '两倍', '2' -replace '一', '1' -replace '两', '2' -replace '二', '2' -replace '三', '3' -replace '四', '4' -replace '八', '8'
    return @([regex]::Matches($s, '\d+(?:\.\d+)?') | ForEach-Object { $_.Value } | Sort-Object)
}
$numDiffs = @()
foreach ($x in $A) {
    $nCn = (GetNums $x.cnEffect) -join ','
    $nEn = (GetNums $x.enEffect) -join ','
    if ($nCn -ne $nEn) {
        $numDiffs += "Alliance $($x.enName): CN=[$nCn] vs EN=[$nEn]"
    }
}
"Alliance numeric diffs: $($numDiffs.Count)"
if ($numDiffs.Count -gt 0) { $numDiffs | ForEach-Object { "  $_" } }
