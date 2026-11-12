# Translate Alliances, Strategies, and Equipment from CN JSON into EN JSON, with S2 comparison status and exact scaling numbers.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$cnDir = Join-Path $root 'data\cn'
$enDir = Join-Path $root 'data\en'
$rawDir = Join-Path $root 'data\raw'
New-Item -ItemType Directory -Force $enDir | Out-Null

function LoadJson($p) { Get-Content -Raw -Encoding UTF8 $p | ConvertFrom-Json }
function SaveJson($obj, $p) {
    [IO.File]::WriteAllText($p, (ConvertTo-Json -InputObject @($obj) -Depth 8), (New-Object Text.UTF8Encoding $false))
}

$g = LoadJson (Join-Path $root 'data\glossary.json')
$s2rows = LoadJson (Join-Path $rawDir 'closure_s2.rows.json')
$s3zhrows = LoadJson (Join-Path $rawDir 'closure_s3_zh.rows.json')

# Icon maps from Closure S3
$allianceIconMap = @{}
foreach ($r in ($s3zhrows | Where-Object { $_.h2 -eq '盟约' })) {
    $cname = ($r.cells[1] -replace '激活所需人数[\s\S]*$', '').Trim()
    if ($r.icon) { $allianceIconMap[$cname] = "https://static.closure.wiki/v3/autochess/bondicon/$($r.icon).webp" }
}
$stratIconMap = @{}
foreach ($r in ($s3zhrows | Where-Object { $_.h2 -eq '策略' })) {
    $l = ($r.cells[1] -replace '初始生命值[\s\S]*$', '').Trim()
    if ($r.icon) { $stratIconMap[$l] = "https://static.closure.wiki/v3/autochess/bandicon/$($r.icon).webp" }
}
$equipIconMap = @{}
foreach ($r in ($s3zhrows | Where-Object { $_.h2 -eq '装备' })) {
    $cname = ($r.cells[1] -replace '价格[\s\S]*$', '').Trim()
    if ($r.icon) { $equipIconMap[$cname] = "https://static.closure.wiki/v3/autochess/shopitemicon/$($r.icon).webp" }
}
$opIconMap = @{}
foreach ($r in $s3zhrows) {
    foreach ($l in $r.links) {
        if ($l.name -and $l.char) { $opIconMap[$l.name] = "https://static.closure.wiki/v3/charavatars/$($l.char).webp" }
    }
    if ($r.h2 -eq '干员' -and $r.icon) {
        $cname = ($r.cells[1] -replace '★+$', '').Trim()
        $opIconMap[$cname] = "https://static.closure.wiki/v3/charavatars/$($r.icon).webp"
    }
}

# ==============================================================================
# 1. ALLIANCES TRANSLATION (26 entries, exact PRTS scaling formulas)
# ==============================================================================
$allianceEffects = @{
    '炎' = @{
        status = 'reworked'
        s2Note = 'Season 2 summoned Yan''s Protection; reworked in Regulation to random Elemental Damage & enemy Elemental recovery speed (Wang''s Strategy restores Yan''s Protection).'
        effect = "[Yan] Operators gain +(23+0.9×stacks)% ATK`n<With 6 different [Yan] Operators on field> When battle begins, [Yan] Operators deal 6% of ATK as random Elemental Damage on each attack; all enemies' Elemental Damage recovery speed increases by (40+0.3×stacks)%"
    }
    '萨尔贡' = @{
        status = 'reworked'
        s2Note = 'Season 2 6-op bonus granted teamwide ATK on skill activation; reworked in Regulation to create Quicksand tiles (Narantuya''s Strategy restores the ATK bonus).'
        effect = "When any [Sargon] Operator activates a skill, all [Sargon] Operators gain +12 ASPD (up to +300) for (5+0.22×stacks) seconds`n<With 6 different [Sargon] Operators on field> Whenever a [Sargon] Operator activates a skill, creates a Quicksand tile within Attack Range. Enemies on Quicksand tiles suffer (20+0.025×stacks)% Slow, and every 5 seconds take (5000+25×stacks) Arts damage and are Bound for 1 second; while a [Sargon] Operator's skill is active, Quicksand tiles within their Attack Range double the Slow effect on enemies and deal (800+4×stacks) Arts damage per second"
    }
    '维多利亚' = @{
        status = 'modified'
        s2Note = '6-op bonus adjusted from +50% ATK per normal equipment in S2 to +40% ATK (+80% for upgraded equipment).'
        effect = "[Victoria] Operators carrying equipment deal (125+0.8×stacks)% damage`n<For every 25 stacks> Obtain 1 Victorian Hammer with a random special effect`n<With 6 different [Victoria] Operators on field> [Victoria] Operators gain +40% ATK for each piece of equipment they carry, or +80% ATK if the equipment is upgraded"
    }
    '谢拉格' = @{
        status = 'reworked'
        s2Note = 'Added <Every 100 stacks> Kjeragi Nevermeltice; 6-op bonus reworked from periodic chill gust to summoning a Snowmountain Colossus (Kjera''s Strategy restores the chill gust).'
        effect = "[Kjerag] Operators deal 125% damage, and (135+1×stacks)% damage against Cold and Frozen enemies`n<For every 100 stacks> Obtain 1 Kjeragi Nevermeltice`n<With 6 different [Kjerag] Operators on field> At the start of battle, summons an autonomous Snowmountain Colossus whose ATK and HP scale with [Kjerag] stacks. The Snowmountain Colossus switches between Colossus and Snowmountain forms: Snowmountain Form can block enemies, deals splash damage, and deals high Arts damage to Frozen enemies while removing Frozen; Colossus Form is mobile and deals ranged splash damage to enemies"
    }
    '阿戈尔' = @{
        status = 'modified'
        s2Note = 'Revival threshold changed from <With 5 different [Ægir] Operators> in S2 to <With 6 different [Ægir] Operators>.'
        effect = "[Ægir] Operators gain +(35+1×stacks)% HP`nWhen battle begins, [Ægir] Operators sequentially devour the Operator 1 tile in front of them, dealing 5000 Physical damage to them and gaining their base ATK and Block, while adding [Ægir] stacks equal to the devoured Operator's Tier (among [Ægir] Operators, those positioned further left and up are prioritized to devour first)`n<With 6 different [Ægir] Operators on field> The first 3 [Ægir] Operators defeated for the first time will immediately revive"
    }
    '叙拉古' = @{
        status = 'reworked'
        s2Note = 'Season 2 6-op bonus granted Invisibility + 3% chance for True damage & Fear; reworked in Regulation to random abnormal status on attack and AoE True damage.'
        effect = "[Siracusa] Operators gain +(25+0.8×stacks) ASPD on deployment for (32+0.4×stacks) seconds`n<With 6 different [Siracusa] Operators on field> Each attack has a 30% chance to inflict a random abnormal status on the enemy for (1+0.0018×stacks) seconds; when an enemy has 2 or more abnormal statuses, deals (800+10×stacks) True damage per second to itself and nearby enemies"
    }
    '卡西米尔' = @{
        status = 'reworked'
        s2Note = 'Season 2 3-op boosted ATK on deployment without stack-scaling cap; 6-op reworked from True damage aura/unblocked bonus to Bench reinforcement + 65% ATK True damage for 30s.'
        effect = "Whenever an Operator is deployed, [Kazimierz] Operators gain +20% ATK (up to +(50+1×stacks)%) until the end of battle`n<With 6 different [Kazimierz] Operators on field> When a [Kazimierz] Ground Operator is defeated, they retreat and summon the rightmost [Kazimierz] Operator from the Bench into battle (does not change current active Alliance status); for 30 seconds after skill activation or deployment, [Kazimierz] Operators' attacks deal an additional 65% of ATK as True damage"
    }
    '乌萨斯' = @{
        status = 'new'
        s2Note = 'New Core Alliance in Regulation.'
        effect = "[Ursus] Operators gain +(35+0.75×stacks)% ATK and +(10+0.3×stacks)% HP; when an [Ursus] Operator defeats another unit, adds 2 temporary stacks to [Ursus]`n<With 6 different [Ursus] Operators on field> (15+0.05×stacks)% of damage taken by [Ursus] Operators is converted into HP loss over 10 seconds, which stops if the damage source is defeated; while blocking enemies, deals (50+0.25×stacks)% of ATK as Arts damage per second to blocked enemies; temporary stacks gained when an [Ursus] Operator defeats another unit increase to 4"
    }
    '伊比利亚' = @{
        status = 'new'
        s2Note = 'New Core Alliance in Regulation.'
        effect = "Whenever an [Iberia] Operator or Alchemy Unit deals damage, inflicts Arts damage over time equal to (11+0.06×stacks)% of ATK per second (stacks up to 10 times) for 10 seconds`n<With 6 different [Iberia] Operators on field> Arts damage over time inflicted by [Iberia] Operators or Alchemy Units is doubled and reduces target Movement Speed by -4% (up to -80%) for 10 seconds; whenever an [Iberia] Operator or Alchemy Unit deals damage, there is a 20% chance to bounce to a nearby enemy, dealing 300% of ATK as Arts damage"
    }
    '莱塔尼亚' = @{
        status = 'new'
        s2Note = 'New Core Alliance in Regulation.'
        effect = "[Leithanien] Operators and summons gain +(30+1×stacks)% ATK; when an enemy on the field is defeated, summons 'A Measure' nearby (up to 10 on the field)`n<With 6 different [Leithanien] Operators on field> When summoning 'A Measure', there is a (30+0.1×stacks)% chance to summon 'A Choir' instead, which grants +20 ASPD to [Leithanien] Operators while on the field; maximum number of [Leithanien] summons on the field increases to 20; when an allied Operator on the field is defeated, additionally summons 'A Measure'"
    }
    '精准' = @{
        status = 'modified'
        s2Note = '3-op threshold changed from <At 30 stacks> (+1 Attack Range) in S2 to <With 3 different [Precision] Operators on field> (applies to all Ranged Operators + ignore 30% DEF/RES).'
        effect = "[Precision] Operators gain +(10+1.2×stacks)% ATK`n<With 3 different [Precision] Operators on field> Effect expands to apply to [Precision] Operators and all Ranged Operators, and attacks ignore 30% DEF and RES"
    }
    '迅捷' = @{
        status = 'unchanged'
        s2Note = 'Same mechanics as Season 2.'
        effect = "When a [Swift] Operator's skill ends, there is a (20+0.35×stacks)% chance to immediately recover 12 SP`n<At 40 stacks> When any Operator's skill ends, there is an equal chance to recover an additional 15 SP"
    }
    '灵巧' = @{
        status = 'unchanged'
        s2Note = 'Same mechanics as Season 2.'
        effect = "[Agile] Operators and Operators in the adjacent 4 tiles gain +(10+1×stacks) ASPD`n<At 40 stacks> Effect range expands to the surrounding 8 tiles of [Agile] Operators"
    }
    '坚守' = @{
        status = 'reworked'
        s2Note = 'Season 2 <At 50 stacks> granted +1 Block to Ground Operators; reworked in Regulation to <With 3 different [Durable] Operators> damage sharing + Arts retaliation & Fragile.'
        effect = "All Operators gain +(25+1.2×stacks)% HP`n<With 3 different [Durable] Operators on field> When non-[Durable] Operators on the field take damage, 40% of the damage taken is shared equally among [Durable] Operators; when a [Durable] Operator takes damage, the damage source takes (850+10×stacks) Arts damage (triggers at most once every 0.2 seconds) and suffers 40% Fragile for 5 seconds"
    }
    '助力' = @{
        status = 'modified'
        s2Note = 'Added <With 3 different [Aid] Operators on field> upgrading end-of-Rest-Phase stacks from +2 to +4.'
        effect = "All Operators gain +(15+1.2×stacks)% DEF and -30% Redeployment Time`nWhen the Rest Phase ends, all currently active Alliances gain +2 stacks`n<With 3 different [Aid] Operators on field> Increases to +4 stacks instead"
    }
    '远见' = @{
        status = 'modified'
        s2Note = 'Added <Upon reaching 150 stacks for the first time> for an extra -1 Funds purchase cost reduction.'
        effect = "<For every 10 stacks> Gain 2 Funds once`n<Upon reaching 80 stacks for the first time> Purchase price of all [Foresight] Operators is permanently reduced by 1 Funds`n<Upon reaching 150 stacks for the first time> Purchase price of all [Foresight] Operators is permanently reduced by an additional 1 Funds`n[Foresight] Operators on the Bench also count toward activating this Alliance"
    }
    '奇迹' = @{
        status = 'unchanged'
        s2Note = 'Same mechanics as Season 2.'
        effect = "When refreshing the Dispatch Center, there is an (18+0.25×stacks)% chance that the next refresh costs 0 Funds`n<Upon reaching 100 stacks for the first time> Every Dispatch Center refresh is guaranteed to offer at least 1 Operator of a Tier equal to the current Dispatch Center Level`n[Marvel] Operators on the Bench also count toward activating this Alliance"
    }
    '投资人' = @{
        status = 'unchanged'
        s2Note = 'Same mechanics as Season 2.'
        effect = "Operators' 'When obtained' abilities trigger 2 times each time`n<At 100 stacks> 'When obtained' abilities trigger 3 times each time`n[Investor] Operators on the Bench also count toward activating this Alliance"
    }
    '突袭' = @{
        status = 'unchanged'
        s2Note = 'Same mechanics as Season 2.'
        effect = "When a [Raid] Operator has not attacked for 10 seconds or when their skill is ready, if there are no enemies within range, they retain SP and immediately redeploy near a ground enemy, gaining +(25+1×stacks)% ATK and HP during this period`n<At 50 stacks> All Operators gain +50 ASPD"
    }
    '不屈' = @{
        status = 'modified'
        s2Note = 'Secondary threshold changed from <At 30 stacks> in S2 to <With 3 different [Resilient] Operators on field>.'
        effect = "When a Ground Operator is defeated, there is an (18+0.4×stacks)% chance they can be immediately redeployed`n<With 3 different [Resilient] Operators on field> Whenever a Ground Operator is defeated, all Operators on the field gain +5 SP"
    }
    '调和' = @{
        status = 'unchanged'
        s2Note = 'Same mechanics as Season 2.'
        effect = "When active, adds +1 to the Operator count of active Core Alliances on the field, and [Harmony] Operators benefit from the effects of all active Core Alliances"
    }
    '协防干员' = @{
        status = 'modified'
        s2Note = 'Damage dealt bonus increased from 110%/120% in S2 to 120%/140%.'
        effect = "All Operators take -20% Physical and Arts damage; [Assist Operators] deal 120% damage, and Elite [Assist Operators] deal 140% damage"
    }
    '独行' = @{
        status = 'modified'
        s2Note = 'ATK and HP bonus increased from +50% in S2 to +60%.'
        effect = "<With exactly 1 [Solo] Operator on field> The [Solo] Operator gains +60% ATK and HP and +15 Starting SP (deactivates if 2 or more [Solo] Operators are on the field)"
    }
    '绝技' = @{
        status = 'unchanged'
        s2Note = 'Same mechanics as Season 2.'
        effect = "<With 2 Elite Operators on field> Elite Operators gain +30% ATK`n<With 5 Elite Operators on field> Elite Operators have -30% SP cost`n(Any Operator in Elite status counts toward activating this Alliance)"
    }
    '聚合' = @{
        status = 'new'
        s2Note = 'New Add-on Alliance in Regulation.'
        effect = "Allied units within the Attack Range of [Convergence] Operators recover HP equal to (16+0.12×stacks)% of ATK and Elemental Damage equal to (8+0.06×stacks)% of ATK per second`n<With 3 [Convergence] Operators on field> All Operators within the Attack Range of [Convergence] Operators gain (15+0.08×stacks)% Sanctuary"
    }
    '奥术' = @{
        status = 'reworked'
        s2Note = 'Season 2 <At 30 stacks> caused attacks to ignore 15 RES; reworked in Regulation to <With 3 different [Arcane] Operators> reducing enemy RES on hit and disabling Invisibility.'
        effect = "Whenever an [Arcane] Operator deals damage, deals an additional instance of Arts damage equal to (20+0.4×stacks)% of ATK`n<With 3 different [Arcane] Operators on field> Whenever any enemy on the field takes damage, their RES is reduced by -1 (up to (-30-0.05×stacks)); enemies within the Attack Range of [Arcane] Operators lose Invisibility"
    }
}

$cnAlliances = LoadJson (Join-Path $cnDir 'alliances.json')
$enAlliances = @()
foreach ($a in $cnAlliances) {
    $info = $allianceEffects[$a.name]
    if (-not $info) { throw "Missing alliance translation for $($a.name)" }
    $ops = @()
    foreach ($o in $a.operators) {
        $ops += [ordered]@{
            cn   = $o.name
            en   = $g.operators.($o.name)
            tier = $o.tier
            icon = $opIconMap[$o.name]
        }
    }
    $enAlliances += [ordered]@{
        type      = $a.type
        cnName    = $a.name
        enName    = $g.alliances.($a.name)
        icon      = $allianceIconMap[$a.name]
        required  = $a.required
        status    = $info.status
        s2Note    = $info.s2Note
        cnEffect  = $a.effect
        enEffect  = $info.effect
        operators = $ops
    }
}
SaveJson $enAlliances (Join-Path $enDir 'alliances.json')
"Translated $($enAlliances.Count) alliances."
