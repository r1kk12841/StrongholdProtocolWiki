# Fetch and decode community strategy guides from Skland API into data/raw/skland_guides.json
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$rawDir = Join-Path $root 'data\raw'
$existingPath = Join-Path $rawDir 'skland_guides.json'

# Load existing 20 guides so we preserve all of them
$existingGuides = @()
if (Test-Path $existingPath) {
    $parsedExisting = Get-Content -Raw -Encoding UTF8 $existingPath | ConvertFrom-Json
    foreach ($item in $parsedExisting) { $existingGuides += $item }
}

# 1. Fetch Skland resource dictionary
$resResp = curl.exe -s "https://zonai.skland.com/web/v1/game/garrison/guide/resource" | ConvertFrom-Json
$d = $resResp.data

$bondMap = @{}
foreach ($b in $d.bonds) { $bondMap[$b.bondId] = $b.name }

$stratMap = @{}
foreach ($s in $d.strategies) {
    $cleanEff = $(if ($s.effect) { ($s.effect -replace '<[^>]+>', '') -replace '\\n', ' ' } else { '' })
    $stratMap[$s.strategyId] = [ordered]@{
        id        = $s.strategyId
        name      = $s.name
        initiator = $s.initiatorName
        effect    = $cleanEff
    }
}

$itemMap = @{}
foreach ($it in $d.items) { $itemMap[$it.itemId] = $it.name }

$charMap = @{}
foreach ($c in $d.chars) {
    $skMap = @{}
    foreach ($sk in $c.skills) { $skMap[$sk.skillId] = $sk.name }
    $modMap = @{}
    foreach ($m in $c.modules) { $modMap[$m.moduleId] = $m.name }
    $charMap[$c.charId] = @{
        name      = $c.name
        shopLevel = $c.shopLevel
        skills    = $skMap
        modules   = $modMap
    }
}

function Convert-SklandItem($item) {
    $g = $item.guide
    $poster = $item.poster
    $rts = $item.rts

    $strats = @()
    foreach ($sid in $g.strategyIds) {
        if ($stratMap[$sid]) {
            $st = $stratMap[$sid]
            $strats += [ordered]@{
                initiator = $st.initiator
                name      = $st.name
                effect    = $st.effect
            }
        }
    }

    $tabs = @()
    foreach ($t in $g.tabs) {
        $regBonds = @()
        if ($t.activeBonds -and $t.activeBonds.regularBondIds) {
            foreach ($bid in $t.activeBonds.regularBondIds) {
                if ($bondMap[$bid]) { $regBonds += $bondMap[$bid] }
            }
        }
        $seaBonds = @()
        if ($t.activeBonds -and $t.activeBonds.seasonBondIds) {
            foreach ($bid in $t.activeBonds.seasonBondIds) {
                if ($bondMap[$bid]) { $seaBonds += $bondMap[$bid] }
            }
        }

        $chars = @()
        foreach ($rc in $t.recChars) {
            $cInfo = $charMap[$rc.charId]
            if (-not $cInfo) { continue }
            $skName = $(if ($rc.skillId -and $cInfo.skills[$rc.skillId]) { $cInfo.skills[$rc.skillId] } else { '无' })
            $modName = $(if ($rc.moduleId -and $cInfo.modules[$rc.moduleId]) { $cInfo.modules[$rc.moduleId] } else { '无' })
            $chars += [ordered]@{
                name      = $cInfo.name
                shopLevel = [int]$cInfo.shopLevel
                skill     = $skName
                module    = $modName
                isElite   = ([int]$rc.mergeLevel -ge 1)
            }
        }

        $items = @()
        foreach ($ri in $t.recItems) {
            if ($ri.itemId -and $itemMap[$ri.itemId]) {
                $items += $itemMap[$ri.itemId]
            }
        }

        $tabTypeStr = $(if ($t.tabType -eq 1) {
            '最终阵容'
        } else {
            "阶段阵容 ($($t.startRound)-$($t.endRound)回合)"
        })

        $tabs += [ordered]@{
            type         = $tabTypeStr
            seasonBonds  = $seaBonds
            regularBonds = $regBonds
            chars        = $chars
            items        = $items
            idea         = [string]$t.operationIdea
        }
    }

    return [ordered]@{
        id              = [string]$g.guideId
        title           = [string]$g.title
        author          = $(if ($poster -and $poster.nickname) { [string]$poster.nickname } else { 'Skland Player' })
        applicableScope = [string]$g.applicableScope
        stats           = [ordered]@{
            collects = [string]$(if ($rts.collected) { $rts.collected } else { 0 })
            likes    = [string]$(if ($rts.liked) { $rts.liked } else { 0 })
            views    = [string]$(if ($rts.viewed) { $rts.viewed } else { 0 })
        }
        strategies      = $strats
        tabs            = $tabs
    }
}

# 2. Fetch 4 pages (80 guides) from sortType=1
$fetchedById = @{}
$token = ""
for ($p = 1; $p -le 4; $p++) {
    $url = "https://zonai.skland.com/web/v1/game/garrison/guide/index?source=COMMUNITY&sortType=1&pageSize=20&seasonId=act3autochess"
    if ($token) { $url += "&pageToken=$([uri]::EscapeDataString($token))" }
    $resp = curl.exe -s $url | ConvertFrom-Json
    if (-not $resp.data.list) { break }
    foreach ($it in $resp.data.list) {
        $conv = Convert-SklandItem $it
        if ($conv.tabs.Count -gt 0 -and $conv.tabs[0].chars.Count -gt 0 -and $conv.strategies.Count -gt 0) {
            $fetchedById[$conv.id] = $conv
        }
    }
    $token = $resp.data.pageToken
    if (-not $resp.data.hasMore -or -not $token) { break }
}

# Merge existing 20 guides (updating stats if re-fetched) + top new guides
$merged = @()
$seen = @{}

foreach ($ex in $existingGuides) {
    if ($fetchedById[$ex.id]) {
        $ex.stats = $fetchedById[$ex.id].stats
    }
    $merged += $ex
    $seen[$ex.id] = $true
}

# Add new guides from fetchedById sorted by collects descending (take top 40 new guides with collects >= 25)
$newCandidates = $fetchedById.Values | Where-Object { -not $seen[$_.id] -and ([int]$_.stats.collects -ge 25) } | Sort-Object { [int]$_.stats.collects } -Descending | Select-Object -First 40
foreach ($nc in $newCandidates) {
    $merged += $nc
    $seen[$nc.id] = $true
}

[IO.File]::WriteAllText($existingPath, (ConvertTo-Json -InputObject @($merged) -Depth 10), (New-Object Text.UTF8Encoding $true))
"Saved $($merged.Count) guides to $existingPath ($($existingGuides.Count) existing + $($newCandidates.Count) new)."
