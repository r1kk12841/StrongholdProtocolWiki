# Build CN->EN glossary by joining Closure Wiki rows (season 2 EN, season 3 EN/ZH) on icon ids,
# then report which PRTS entries are matched and which need manual translation.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$raw = Join-Path $root 'data\raw'
$cn = Join-Path $root 'data\cn'
function LoadJson($p) { Get-Content -Raw -Encoding UTF8 $p | ConvertFrom-Json }

$s2 = LoadJson (Join-Path $raw 'closure_s2.rows.json')
$s3en = LoadJson (Join-Path $raw 'closure_s3.rows.json')
$s3zh = LoadJson (Join-Path $raw 'closure_s3_zh.rows.json')

function FirstLine($s) { return ($s -split "`n")[0].Trim() }

# ---------- icon -> EN (season 2) ----------
$enAlliance = @{}; $enStrat = @{}; $enEquip = @{}; $enIso = @{}
foreach ($r in $s2) {
    switch ($r.h2) {
        'Alliances' { $enAlliance[$r.icon] = FirstLine $r.cells[1] }
        'Strategies' {
            $m = [regex]::Match($r.cells[2], '^\[([^\]]+)\]')
            $enStrat[$r.icon] = [ordered]@{ leader = (FirstLine $r.cells[1]); name = $m.Groups[1].Value }
        }
        'Equipment' {
            $enEquip[$r.icon] = FirstLine $r.cells[1]
            $m = [regex]::Match($r.cells[1], '\(([^)]+)\)\s*$')
            if ($m.Success) { $enIso[$r.icon] = $m.Groups[1].Value }
        }
    }
}

# ---------- operator char id -> EN / ZH ----------
$opEn = @{}; $opZh = @{}
foreach ($r in @($s2) + @($s3en)) { foreach ($l in $r.links) { $opEn[$l.char] = $l.name } }
foreach ($r in $s3zh) { foreach ($l in $r.links) { $opZh[$l.char] = $l.name } }

# ---------- Season 3 ZH rows -> CN names ----------
$gAlliance = [ordered]@{}; $gLeader = [ordered]@{}; $gStrat = [ordered]@{}; $gEquip = [ordered]@{}; $gIso = [ordered]@{}; $gOp = [ordered]@{}
foreach ($r in $s3zh) {
    switch ($r.h2) {
        '盟约' {
            $name = ($r.cells[1] -replace '激活所需人数[\s\S]*$', '').Trim()
            $gAlliance[$name] = $enAlliance[$r.icon]
        }
        '策略' {
            $leader = ($r.cells[1] -replace '初始生命值[\s\S]*$', '').Trim()
            $sname = [regex]::Match($r.cells[2], '【([^】]+)】').Groups[1].Value
            $e = $enStrat[$r.icon]
            $gLeader[$leader] = $(if ($e) { $e.leader } else { $null })
            $gStrat["$leader|$sname"] = $(if ($e) { $e.name } else { $null })
        }
        '装备' {
            $name = ($r.cells[1] -replace '价格[\s\S]*$', '').Trim()
            $gEquip[$name] = $enEquip[$r.icon]
            $iso = [regex]::Match($r.cells[1], '变形同构体：(.+)$')
            $gIso[$name] = $(if ($iso.Success) { $iso.Groups[1].Value.Trim() } else { $null })
        }
    }
}
foreach ($k in $opZh.Keys) { $gOp[$opZh[$k]] = $opEn[$k] }

$glossary = [ordered]@{
    alliances  = $gAlliance
    leaders    = $gLeader
    strategies = $gStrat
    operators  = $gOp
    equipment  = $gEquip
    isomorph   = $gIso
}
[IO.File]::WriteAllText((Join-Path $root 'data\glossary.auto.json'), (ConvertTo-Json $glossary -Depth 5), (New-Object Text.UTF8Encoding $false))

# ---------- Coverage report against PRTS ----------
$A = LoadJson (Join-Path $cn 'alliances.json'); $S = LoadJson (Join-Path $cn 'strategies.json')
$O = LoadJson (Join-Path $cn 'operators.json'); $E = LoadJson (Join-Path $cn 'equipment.json')
$missA = @($A | Where-Object { -not $gAlliance[$_.name] } | ForEach-Object { $_.name })
$missL = @($S | Where-Object { -not $gLeader[$_.leader] } | ForEach-Object { $_.leader })
$missS = @($S | Where-Object { -not $gStrat["$($_.leader)|$($_.name)"] } | ForEach-Object { "$($_.leader)|$($_.name)" })
$allOps = @($O | ForEach-Object { $_.name }) + @($A | ForEach-Object { $_.operators | ForEach-Object { $_.name } }) | Sort-Object -Unique
$missO = @($allOps | Where-Object { -not $gOp[$_] })
$missE = @($E | Where-Object { -not $gEquip[$_.name] } | ForEach-Object { $_.name })
"Alliances missing ($($missA.Count)/$($A.Count)): $($missA -join ', ')"
"Leaders missing ($($missL.Count)/$($S.Count)): $($missL -join ', ')"
"Strategy names missing ($($missS.Count)/$($S.Count)): $($missS -join ', ')"
"Operators missing ($($missO.Count)/$($allOps.Count)): $($missO -join ', ')"
"Equipment missing ($($missE.Count)/$($E.Count)): $($missE -join ', ')"
