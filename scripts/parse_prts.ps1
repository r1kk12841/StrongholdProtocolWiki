# Parse PRTS wikitext of Stronghold Protocol: Regulation into CN JSON data files.
# Usage: powershell -File scripts\parse_prts.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $root 'data\raw\prts_regulation.wikitext'
$outDir = Join-Path $root 'data\cn'
New-Item -ItemType Directory -Force $outDir | Out-Null
$text = [IO.File]::ReadAllText($src, [Text.Encoding]::UTF8)

# Remove HTML comments
$text = [regex]::Replace($text, '<!--[\s\S]*?-->', '')

# Find all template invocations whose name starts with $prefix, honoring nested braces.
function Get-Templates([string]$s, [string]$prefix) {
    $res = New-Object System.Collections.ArrayList
    $idx = 0
    while ($true) {
        $p = $s.IndexOf('{{' + $prefix, $idx)
        if ($p -lt 0) { break }
        $depth = 0; $i = $p
        while ($i -lt $s.Length - 1) {
            if ($s[$i] -eq '{' -and $s[$i + 1] -eq '{') { $depth++; $i += 2; continue }
            if ($s[$i] -eq '}' -and $s[$i + 1] -eq '}') { $depth--; $i += 2; if ($depth -eq 0) { break }; continue }
            $i++
        }
        [void]$res.Add([pscustomobject]@{ Pos = $p; Body = $s.Substring($p + 2, $i - $p - 4) })
        $idx = $i
    }
    return $res
}

# Split template body into named params at top-level '|'
function Get-Params([string]$body) {
    $parts = New-Object System.Collections.ArrayList
    $depth = 0; $sq = 0; $start = 0
    for ($i = 0; $i -lt $body.Length; $i++) {
        $c = $body[$i]
        if ($c -eq '{' -and $i + 1 -lt $body.Length -and $body[$i + 1] -eq '{') { $depth++; $i++; continue }
        if ($c -eq '}' -and $i + 1 -lt $body.Length -and $body[$i + 1] -eq '}') { $depth--; $i++; continue }
        if ($c -eq '[' -and $i + 1 -lt $body.Length -and $body[$i + 1] -eq '[') { $sq++; $i++; continue }
        if ($c -eq ']' -and $i + 1 -lt $body.Length -and $body[$i + 1] -eq ']') { $sq--; $i++; continue }
        if ($c -eq '|' -and $depth -eq 0 -and $sq -eq 0) { [void]$parts.Add($body.Substring($start, $i - $start)); $start = $i + 1 }
    }
    [void]$parts.Add($body.Substring($start))
    $h = [ordered]@{}
    foreach ($pt in ($parts | Select-Object -Skip 1)) {
        $eq = $pt.IndexOf('=')
        if ($eq -gt 0) { $h[$pt.Substring(0, $eq).Trim()] = $pt.Substring($eq + 1).Trim() }
    }
    return $h
}

# Strip wiki markup to plain text (numbers are highlighted later by the renderer)
function Clean([string]$s) {
    if ($null -eq $s) { return '' }
    $prev = $null
    while ($prev -ne $s) {
        $prev = $s
        $s = [regex]::Replace($s, '\{\{color\|[^|{}]*\|([^{}]*)\}\}', '$1')
        $s = [regex]::Replace($s, '\{\{术语\|[^|{}]*\|([^{}]*)\}\}', '$1')
        $s = [regex]::Replace($s, '\{\{干员头像\|([^|{}]*)(\|[^{}]*)?\}\}', '$1')
    }
    $s = [regex]::Replace($s, '<br\s*/?>', "`n")
    $s = [regex]::Replace($s, "'''", '')
    $s = $s -replace '&lt;', '<' -replace '&gt;', '>' -replace '&nbsp;', ' '
    return $s.Trim()
}

$tierMap = @{ 'Ⅰ' = 1; 'Ⅱ' = 2; 'Ⅲ' = 3; 'Ⅳ' = 4; 'Ⅴ' = 5; 'Ⅵ' = 6 }
$secStrat = $text.IndexOf('==S.W.E.E.P.策略报告==')
$secOps = $text.IndexOf('==干员数据库==')
$secPhase = $text.IndexOf('==机变阶段==')
$secEquip = $text.IndexOf('== 装备数据库 ==')
$secEnd = $text.IndexOf('== 战地广播 ==')
$secAddon = $text.IndexOf('=== 附加盟约 ===')

# ---------- Alliances ----------
$alliances = @()
foreach ($t in (Get-Templates $text '卫戍协议/盟约')) {
    $p = Get-Params $t.Body
    $ops = @()
    foreach ($m in [regex]::Matches($p['干员'], '\{\{干员头像\|([^|]+)\|[^{}]*?extext=(?:\{\{color\|[^|]*\|)?([ⅠⅡⅢⅣⅤⅥ])')) {
        $ops += [ordered]@{ name = $m.Groups[1].Value; tier = $tierMap[$m.Groups[2].Value] }
    }
    $alliances += [ordered]@{
        type      = $(if ($t.Pos -gt $secAddon) { 'addon' } else { 'core' })
        name      = $p['盟约']
        required  = [int]$p['人数']
        effect    = Clean $p['效果']
        operators = $ops
    }
}

# ---------- Strategies ----------
$strategies = @()
foreach ($t in (Get-Templates $text ':卫戍协议/策略')) {
    $p = Get-Params $t.Body
    $strategies += [ordered]@{
        leader = Clean $p['发起人']
        name   = Clean $p['策略']
        hp     = [int]$p['血量']
        effect = Clean $p['效果']
        unlock = Clean $p['解锁条件']
    }
}

# ---------- Operators ----------
$operators = @()
$opsText = $text.Substring($secOps, $secPhase - $secOps)
# Tier headers: "{{color|#xxx|Ⅰ}}阶干员"
$tierHeaders = [regex]::Matches($opsText, '([ⅠⅡⅢⅣⅤⅥ])\}\}阶干员')
foreach ($t in (Get-Templates $opsText '卫戍协议/参战干员')) {
    $tier = 0
    foreach ($h in $tierHeaders) { if ($h.Index -lt $t.Pos) { $tier = $tierMap[$h.Groups[1].Value] } }
    $p = Get-Params $t.Body
    $al = @()
    foreach ($k in '盟约1', '盟约2', '盟约3') { if ($p[$k]) { $al += $p[$k] } }
    $operators += [ordered]@{
        name        = $p['干员']
        tier        = $tier
        alliances   = $al
        abilityType = Clean $p['特质类型']
        ability     = Clean $p['特质1']
        upgraded    = Clean $p['特质2']
        extra       = @($p.Keys | Where-Object { $_ -notin '干员', '盟约1', '盟约2', '盟约3', '特质类型', '特质1', '特质2' } | ForEach-Object { "$_=$($p[$_])" })
    }
}

# ---------- Equipment ----------
$equipment = @()
$eqText = $text.Substring($secEquip, $secEnd - $secEquip)
foreach ($t in (Get-Templates $eqText ':卫戍协议/道具')) {
    $p = Get-Params $t.Body
    $eff = Clean $p['效果']
    $base = $eff; $up = ''
    $m = [regex]::Match($eff, '^【基础】([\s\S]*?)\n?【进阶】([\s\S]*)$')
    if ($m.Success) { $base = $m.Groups[1].Value.Trim(); $up = $m.Groups[2].Value.Trim() }
    $equipment += [ordered]@{
        tier     = [int]$p['等阶']
        name     = Clean $p['名称']
        price    = $p['售价']
        effect   = $base
        upgraded = $up
        extra    = @($p.Keys | Where-Object { $_ -notin '类型', '等阶', '名称', '售价', '效果', '描述' } | ForEach-Object { "$_=$($p[$_])" })
    }
}

function Save($obj, $name) {
    $json = ConvertTo-Json -InputObject @($obj) -Depth 6
    [IO.File]::WriteAllText((Join-Path $outDir $name), $json, (New-Object Text.UTF8Encoding $false))
}
Save $alliances 'alliances.json'
Save $strategies 'strategies.json'
Save $operators 'operators.json'
Save $equipment 'equipment.json'
"alliances=$($alliances.Count) strategies=$($strategies.Count) operators=$($operators.Count) equipment=$($equipment.Count)"
