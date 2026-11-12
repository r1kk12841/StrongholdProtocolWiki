# Translate all 70 Equipment items from CN JSON into EN JSON, excluding lore/flavor text as requested.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$cnDir = Join-Path $root 'data\cn'
$enDir = Join-Path $root 'data\en'
$rawDir = Join-Path $root 'data\raw'

function LoadJson($p) { Get-Content -Raw -Encoding UTF8 $p | ConvertFrom-Json }
function SaveJson($obj, $p) {
    [IO.File]::WriteAllText($p, (ConvertTo-Json -InputObject @($obj) -Depth 8), (New-Object Text.UTF8Encoding $false))
}

$g = LoadJson (Join-Path $root 'data\glossary.json')
$s3zhrows = LoadJson (Join-Path $rawDir 'closure_s3_zh.rows.json')

$equipIconMap = @{}
foreach ($r in ($s3zhrows | Where-Object { $_.h2 -eq '装备' })) {
    $cname = ($r.cells[1] -replace '价格[\s\S]*$', '').Trim()
    if ($r.icon) { $equipIconMap[$cname] = "https://static.closure.wiki/v3/autochess/shopitemicon/$($r.icon).webp" }
}

$eqData = @{
    # ==================== TIER I ====================
    '维式重锤' = @{
        status = 'unchanged'
        effect = 'ATK +15%'
        upgraded = 'ATK +25%'
    }
    '坚守盾牌' = @{
        status = 'unchanged'
        effect = 'DEF +20%'
        upgraded = 'DEF +35%'
    }
    '盟约之币' = @{
        status = 'unchanged'
        effect = 'Destroyed when equipped and grants 1 Funds'
        upgraded = 'Destroyed when equipped and grants 2 Funds'
    }
    '随身身份牌' = @{
        status = 'unchanged'
        effect = 'Destroyed when equipped; grants +3 stacks to the equipped Operator''s Alliance(s) (Alliances do not need to be active)'
        upgraded = 'Destroyed when equipped; grants +6 stacks to the equipped Operator''s Alliance(s) (Alliances do not need to be active)'
    }
    '源石溶剂' = @{
        status = 'unchanged'
        effect = 'Equipped Operator loses 60 HP per second, but gains +40% ATK'
        upgraded = 'Equipped Operator loses 60 HP per second, but gains +60% ATK'
    }
    '虹彩活血饮料' = @{
        status = 'new'
        effect = 'Equipped Operator cannot be healed by other sources, and recovers 75 HP per second'
        upgraded = 'Equipped Operator cannot be healed by other sources, and recovers 150 HP per second'
    }
    '雪祀之衣' = @{
        status = 'new'
        effect = 'Max HP +15%; equipped Operator is less likely to be targeted by enemies and has Block -1'
        upgraded = 'Max HP +25%; equipped Operator is less likely to be targeted by enemies and has Block -1'
    }
    # ==================== TIER II ====================
    '不屈弹射器' = @{
        status = 'unchanged'
        effect = 'Redeployment Time -30%, Max HP -30%'
        upgraded = 'Redeployment Time -50%, Max HP -30%'
    }
    '紧急调度券' = @{
        status = 'unchanged'
        effect = 'Destroyed when equipped; randomly obtain 1 Operator currently in the Dispatch Center (corresponding Operator in Dispatch Center disappears)'
        upgraded = 'Destroyed when equipped; randomly obtain 2 Operators currently in the Dispatch Center (corresponding Operators in Dispatch Center disappear)'
    }
    '战栗维式重锤' = @{
        status = 'unchanged'
        effect = 'ATK +20%; if equipped by a Ground Operator, attacks have a 10% chance to inflict Frighten for 2 seconds when dealing damage'
        upgraded = 'ATK +35%; if equipped by a Ground Operator, attacks have a 10% chance to inflict Frighten for 2 seconds when dealing damage'
    }
    '萨尔贡浓茶' = @{
        status = 'unchanged'
        effect = 'SP recovery rate +0.15/s'
        upgraded = 'SP recovery rate +0.25/s'
    }
    '精打细算玩偶' = @{
        status = 'unchanged'
        effect = 'Destroyed when equipped; gain an extra 1 Funds at the start of each subsequent round'
        upgraded = 'Destroyed when equipped; gain an extra 2 Funds at the start of each subsequent round'
    }
    '简易通讯机' = @{
        status = 'unchanged'
        effect = 'Destroyed when equipped; randomly obtain 1 Operator sharing the equipped Operator''s primary Alliance'
        upgraded = 'Destroyed when equipped; randomly obtain 2 Operators sharing the equipped Operator''s primary Alliance'
    }
    '见钱眼开玩偶' = @{
        status = 'unchanged'
        effect = 'Destroyed when equipped; gain an extra 2 Funds next round'
        upgraded = 'Destroyed when equipped; gain an extra 4 Funds next round'
    }
    '卫戍推荐信' = @{
        status = 'new'
        effect = 'When the Rest Phase ends, grants +1 stack to the equipped Operator''s active Alliance(s)'
        upgraded = 'When the Rest Phase ends, grants +2 stacks to the equipped Operator''s active Alliance(s)'
    }
    '聚合急救箱' = @{
        status = 'new'
        effect = 'The first time each allied Operator within Attack Range falls below 50% HP, immediately heals them for 35% of Max HP'
        upgraded = 'The first time each allied Operator within Attack Range falls below 50% HP, immediately heals them for 50% of Max HP'
    }
    '灵巧涡轮手套' = @{
        status = 'new'
        effect = 'After deployment, gains +2 ASPD per second (stacks up to 20 times); loses this effect when taking damage'
        upgraded = 'After deployment, gains +3 ASPD per second (stacks up to 20 times); loses this effect when taking damage'
    }
    # ==================== TIER III ====================
    '叙拉古正装' = @{
        status = 'unchanged'
        effect = 'ASPD +15; allied Operators 1 tile to the left and right of the equipped Operator''s deployment direction gain +10 ASPD'
        upgraded = 'ASPD +25; allied Operators 1 tile to the left and right of the equipped Operator''s deployment direction gain +15 ASPD'
    }
    '精准狙击镜' = @{
        status = 'unchanged'
        effect = 'When attacking targets 3 or more tiles away, damage dealt +30%'
        upgraded = 'When attacking targets 3 or more tiles away, damage dealt +50%'
    }
    '炎国短刀' = @{
        status = 'unchanged'
        effect = 'Each skill activation grants +5% ATK (stacks up to 10 times)'
        upgraded = 'Each skill activation grants +8% ATK (stacks up to 10 times)'
    }
    '迅捷作战粮' = @{
        status = 'unchanged'
        effect = 'On deployment, gain 3 SP; for every other Operator sharing an Alliance with the equipped Operator, gain an additional 3 SP'
        upgraded = 'On deployment, gain 6 SP; for every other Operator sharing an Alliance with the equipped Operator, gain an additional 6 SP'
    }
    '歌利亚头盔' = @{
        status = 'unchanged'
        effect = 'Max HP +25%; on deployment, if there is no other Operator 1 tile in front, Max HP +15% additionally'
        upgraded = 'Max HP +45%; on deployment, if there is no other Operator 1 tile in front, Max HP +25% additionally'
    }
    '阿戈尔重刃' = @{
        status = 'unchanged'
        effect = 'ATK +40%, ASPD -10'
        upgraded = 'ATK +60%, ASPD -10'
    }
    '奥术法阵' = @{
        status = 'unchanged'
        effect = 'RES +20; attacks Silence the target''s special abilities for 5 seconds'
        upgraded = 'RES +30; attacks Silence the target''s special abilities for 5 seconds'
    }
    '坚固维式重锤' = @{
        status = 'unchanged'
        effect = 'ATK +25%; the first time lethal damage is taken, HP cannot fall below 1 for 8 seconds'
        upgraded = 'ATK +45%; the first time lethal damage is taken, HP cannot fall below 1 for 8 seconds'
    }
    '加速维式重锤' = @{
        status = 'unchanged'
        effect = 'ATK +25%; ASPD +30'
        upgraded = 'ATK +45%; ASPD +30'
    }
    '突袭手雷' = @{
        status = 'unchanged'
        effect = 'Within 10 seconds after each deployment, attacks Stun the target for 2 seconds'
        upgraded = 'Within 15 seconds after each deployment, attacks Stun the target for 2 seconds'
    }
    '驮兽储蓄罐' = @{
        status = 'modified'
        s2Note = 'Renamed from Knightly Savings (驮兽储蓄罐).'
        effect = 'Destroyed when equipped and randomly grants 1–6 Funds'
        upgraded = 'Destroyed when equipped and randomly grants 2–12 Funds'
    }
    '乌萨斯呼吸器' = @{
        status = 'new'
        effect = 'Block +1, ATK +20%; each redeployment stacks these bonuses (stacks up to 2 times)'
        upgraded = 'Block +1, ATK +30%; each redeployment stacks these bonuses (stacks up to 3 times)'
    }
    '多功能补剂' = @{
        status = 'new'
        effect = 'Whenever the equipped Operator deals damage, grants +1 temporary stack to their active Alliance(s) (up to 12 stacks per battle)'
        upgraded = 'Whenever the equipped Operator deals damage, grants +2 temporary stacks to their active Alliance(s) (up to 24 stacks per battle)'
    }
    '伊比利亚骨刺刀' = @{
        status = 'new'
        effect = 'Whenever the equipped Operator deals damage, deals 1 additional instance of Arts damage equal to 25% of ATK'
        upgraded = 'Whenever the equipped Operator deals damage, deals 2 additional instances of Arts damage equal to 25% of ATK'
    }
    '定期存折' = @{
        status = 'new'
        effect = 'Destroyed when equipped and grants X Funds (starts at 0; increases by +1 each round while held)'
        upgraded = 'N/A'
    }
    '不退者之盾' = @{
        status = 'new'
        combinesWith = 'Unyielding Forcefield'
        combinesInto = 'Unyielding Aegis System'
        effect = 'Immune to Stun, Frozen, and other abnormal statuses; if held together with "Unyielding Forcefield", combines into "Unyielding Aegis System"'
        upgraded = 'N/A'
    }
    # ==================== TIER IV ====================
    '寻呼模块' = @{
        status = 'unchanged'
        effect = 'Destroyed when equipped; offers up to 3 Operators sharing the equipped Operator''s primary Alliance in the Dispatch Center, and pick 1 for free (Tier cannot exceed current Dispatch Center Level)'
        upgraded = 'N/A'
    }
    '蜂鸣器' = @{
        status = 'unchanged'
        effect = 'More likely to be targeted by enemies; Max HP +40%'
        upgraded = 'More likely to be targeted by enemies; Max HP +60%'
    }
    '伪装服' = @{
        status = 'unchanged'
        effect = 'After taking damage for the first time, gains Invisibility for 15 seconds'
        upgraded = 'After taking damage for the first time, gains Invisibility for 25 seconds'
    }
    '卡西米尔竞技旗' = @{
        status = 'unchanged'
        effect = 'For 15 seconds after deployment, damage dealt increases to 135%, then gradually decays'
        upgraded = 'For 15 seconds after deployment, damage dealt increases to 160%, then gradually decays'
    }
    '灼燃维式重锤' = @{
        status = 'unchanged'
        effect = 'ATK +30%; when dealing Arts damage, inflicts Burn Damage equal to 10% of the damage dealt'
        upgraded = 'ATK +50%; when dealing Arts damage, inflicts Burn Damage equal to 10% of the damage dealt'
    }
    '护盾无人机' = @{
        status = 'unchanged'
        effect = 'When healing, has a 10% chance to grant 1 Shield to the target (up to 1 stack)'
        upgraded = 'When healing, has a 15% chance to grant 1 Shield to the target (up to 1 stack)'
    }
    'M3茧甲' = @{
        status = 'unchanged'
        effect = 'When defeated during the Combat Phase, immediately revives (up to 1 time per battle)'
        upgraded = 'When defeated during the Combat Phase, immediately revives (up to 2 times per battle)'
    }
    '莱塔尼亚小鼓' = @{
        status = 'new'
        effect = 'Whenever a unit within the equipped Operator''s Attack Range is defeated, recovers 2 SP'
        upgraded = 'Whenever a unit within the equipped Operator''s Attack Range is defeated, recovers 4 SP'
    }
    '谢拉格不融冰' = @{
        status = 'unchanged'
        effect = 'When dealing damage, has a 12% chance to inflict Cold on the target for 1.5 seconds'
        upgraded = 'When dealing damage, has a 20% chance to inflict Cold on the target for 1.5 seconds'
    }
    '可靠怀表' = @{
        status = 'new'
        effect = 'Equipped Operator''s skill SP cost -20%, but ASPD -25% while skill is active'
        upgraded = 'Equipped Operator''s skill SP cost -40%, but ASPD -25% while skill is active'
    }
    '一次性促销券' = @{
        status = 'new'
        effect = 'Destroyed when equipped; offers 3 pieces of Equipment in the Dispatch Center, and pick 1 for free (Tier cannot exceed current Dispatch Center Level)'
        upgraded = 'Destroyed when equipped; offers 6 pieces of Equipment in the Dispatch Center, and pick 2 for free (Tier cannot exceed current Dispatch Center Level)'
    }
    '驱逐者警棍' = @{
        status = 'new'
        combinesWith = "Expeller's Gas"
        combinesInto = "Expeller's Riot Gear"
        effect = 'Equipped Operator deals +30% damage to enemies affected by Stun, Frozen, Fear, or other abnormal statuses; if held together with "Expeller''s Gas", combines into "Expeller''s Riot Gear"'
        upgraded = 'N/A'
    }
    '动能单手弩' = @{
        status = 'new'
        combinesWith = 'Kinetic Accelerator'
        combinesInto = 'Kinetic Bombardment Crossbow'
        effect = 'When dealing damage, has a 30% chance to increase ATK to 130% for that attack; if held together with "Kinetic Accelerator", combines into "Kinetic Bombardment Crossbow"'
        upgraded = 'N/A'
    }
    '汲取者之喙' = @{
        status = 'new'
        combinesWith = "Siphoner's Heart"
        combinesInto = "Siphoner's Scythe"
        effect = 'Whenever dealing damage, recovers HP equal to 5% of the damage dealt; if held together with "Siphoner''s Heart", combines into "Siphoner''s Scythe"'
        upgraded = 'N/A'
    }
    # ==================== TIER V ====================
    '双模机械臂' = @{
        status = 'unchanged'
        effect = 'ATK +30%; Physical and Arts damage dealt by the equipped Operator is converted into Weakness damage'
        upgraded = 'ATK +50%; Physical and Arts damage dealt by the equipped Operator is converted into Weakness damage'
    }
    '信标' = @{
        status = 'unchanged'
        effect = 'Destroyed along with the target Operator when equipped; offers 2 Operators of the same Tier in the Dispatch Center, and pick 1 for free. In Co-op Simulations with other teammates, sends 1 copy of the original Operator to the teammate with the most Operators of that Alliance in the next Rest Phase (random if tied; cannot be equipped on custom squad Operators)'
        upgraded = 'N/A'
    }
    '拟态物质' = @{
        status = 'unchanged'
        effect = 'Destroyed when equipped; if you already own at least 2 copies of this non-Elite Operator, obtain 1 more copy of them; otherwise, randomly obtain 1 Operator of the same Tier'
        upgraded = 'N/A'
    }
    '博士投影' = @{
        status = 'unchanged'
        effect = 'Destroyed at the start of the next round after equipping, promoting the equipped Operator to an Elite Operator'
        upgraded = 'Destroyed when equipped, immediately promoting the equipped Operator to an Elite Operator'
    }
    '天马之盔' = @{
        status = 'reworked'
        s2Note = 'Changed from +45% HP & +5% HP/s regen in S2 to +60% Max HP and combining with Pegasian Lance into Pegasian Glory.'
        combinesWith = 'Pegasian Lance'
        combinesInto = 'Pegasian Glory'
        effect = 'Max HP +60%; if held together with "Pegasian Lance", combines into "Pegasian Glory"'
        upgraded = 'N/A'
    }
    '电流维式重锤' = @{
        status = 'new'
        effect = 'ATK +30%; dealing damage has a 5% chance to inflict 1 stack of Paralysis on the target, and attacks against Paralyzed enemies ignore 30% DEF and RES'
        upgraded = 'ATK +50%; dealing damage has a 5% chance to inflict 1 stack of Paralysis on the target, and attacks against Paralyzed enemies ignore 30% DEF and RES'
    }
    '佣兵名牌' = @{
        status = 'new'
        effect = 'For every active Alliance, grants +6% ATK and +6% Max HP to the equipped Operator (stacks up to 8 times)'
        upgraded = 'For every active Alliance, grants +12% ATK and +12% Max HP to the equipped Operator (stacks up to 8 times)'
    }
    '人事部记录' = @{
        status = 'new'
        effect = 'Destroyed when equipped; immediately performs 1 special refresh of the Dispatch Center, prioritizing offering Operators sharing the equipped Operator''s primary Alliance (Tier cannot exceed current Dispatch Center Level)'
        upgraded = 'N/A'
    }
    '瓶装烈性反应' = @{
        status = 'new'
        effect = 'Equipped Operator deals +30% additional damage to enemies suffering from an Elemental Damage burst'
        upgraded = 'Equipped Operator deals +50% additional damage to enemies suffering from an Elemental Damage burst'
    }
    '不退者力场' = @{
        status = 'new'
        combinesWith = 'Unyielding Shield'
        combinesInto = 'Unyielding Aegis System'
        effect = 'Block +2; for each unit blocked, Max HP and DEF increase by +20%; if held together with "Unyielding Shield", combines into "Unyielding Aegis System"'
        upgraded = 'N/A'
    }
    '驱逐者瓦斯' = @{
        status = 'new'
        combinesWith = "Expeller's Baton"
        combinesInto = "Expeller's Riot Gear"
        effect = 'Duration of Stun, Frozen, Fear, and other abnormal statuses inflicted on enemies within the equipped Operator''s Attack Range increases by +100%; if held together with "Expeller''s Baton", combines into "Expeller''s Riot Gear"'
        upgraded = 'N/A'
    }
    '投机骰子' = @{
        status = 'new'
        effect = 'Destroyed when equipped; choose 1 of 3 Commands to replace your current Command'
        upgraded = 'N/A'
    }
    # ==================== TIER VI ====================
    '天马之枪' = @{
        status = 'reworked'
        s2Note = 'Changed from +35% ATK & +20% ATK as True damage in S2 to +50% ATK and combining with Pegasian Helm into Pegasian Glory.'
        combinesWith = 'Pegasian Helm'
        combinesInto = 'Pegasian Glory'
        effect = 'ATK +50%; if held together with "Pegasian Helm", combines into "Pegasian Glory"'
        upgraded = 'N/A'
    }
    '人事部文档' = @{
        status = 'unchanged'
        effect = 'Destroyed when equipped; sets maximum Deployment Limit to 9'
        upgraded = 'N/A'
    }
    '变形同构体' = @{
        status = 'unchanged'
        effect = 'Equipped Operator gains an additional Alliance determined by the other piece of Equipment they carry'
        upgraded = 'N/A'
    }
    '动能加速器' = @{
        status = 'new'
        combinesWith = 'Kinetic Hand Crossbow'
        combinesInto = 'Kinetic Bombardment Crossbow'
        effect = 'Each attack or heal grants +2 ASPD (up to 60 stacks); if held together with "Kinetic Hand Crossbow", combines into "Kinetic Bombardment Crossbow"'
        upgraded = 'N/A'
    }
    '汲取者之心' = @{
        status = 'new'
        combinesWith = "Siphoner's Beak"
        combinesInto = "Siphoner's Scythe"
        effect = 'ATK +30%, ASPD +30, loses 1% Max HP per second (cannot fall to 0); if held together with "Siphoner''s Beak", combines into "Siphoner''s Scythe"'
        upgraded = 'N/A'
    }
    '终极维式重锤' = @{
        status = 'new'
        s2Note = 'Replaces S2''s Steam Heart as the Tier VI Victoria hammer capstone.'
        effect = 'Equipped Operator gains the special effects of all Victorian Hammers currently on the field, and gains an additional +20% ATK for each type of special-effect Victorian Hammer present'
        upgraded = 'N/A'
    }
    '不退者卫护系统' = @{
        status = 'new'
        recipe = @('Unyielding Shield', 'Unyielding Forcefield')
        effect = 'Immune to Stun, Frozen, and other abnormal statuses; Block +2; for each unit blocked, Max HP and DEF increase by +20%; when the equipped Operator activates a skill, Lures enemies in surrounding range for 3 seconds'
        upgraded = 'N/A'
    }
    '动能轰击弩' = @{
        status = 'new'
        recipe = @('Kinetic Hand Crossbow', 'Kinetic Accelerator')
        effect = 'Dealing damage has a 30% chance to increase ATK to 130%; each attack grants +2 ASPD (up to 60 stacks), and once ASPD stacks reach the cap, each attack has a 30% chance to deal 100% of ATK as AoE Physical damage to a random enemy within Attack Range'
        upgraded = 'N/A'
    }
    '汲取者之镰' = @{
        status = 'new'
        recipe = @("Siphoner's Beak", "Siphoner's Heart")
        effect = 'ATK +30%, ASPD +30, loses 1% Max HP per second (cannot fall to 0), and recovers HP equal to 5% of damage dealt whenever dealing damage; while the equipped Operator''s skill is active, all of the above effects are doubled and the Operator cannot be healed'
        upgraded = 'N/A'
    }
    '驱逐者防暴装备' = @{
        status = 'new'
        recipe = @("Expeller's Baton", "Expeller's Gas")
        effect = 'Duration of Stun, Frozen, Fear, and other abnormal statuses on enemies within the equipped Operator''s Attack Range increases by +100%, and damage dealt to enemies affected by such statuses increases by +30%; while the equipped Operator''s skill is active, each time they inflict such an abnormal status, there is a 50% chance to spread it to another nearby enemy'
        upgraded = 'N/A'
    }
    '天马之耀' = @{
        status = 'new'
        recipe = @('Pegasian Helm', 'Pegasian Lance')
        effect = 'Max HP +60%, recovers 8% Max HP per second; ATK +50%, and dealing damage deals an additional 30% of ATK as True damage'
        upgraded = 'N/A'
    }
}

$cnEquip = LoadJson (Join-Path $cnDir 'equipment.json')
$enEquip = @()
foreach ($e in $cnEquip) {
    $info = $eqData[$e.name]
    if (-not $info) { throw "Missing equipment translation for $($e.name)" }
    $isoCn = $g.isomorph.($e.name)
    $isoEn = $(if ($isoCn) { $g.alliances.$isoCn } else { '' })
    $enEquip += [ordered]@{
        tier         = $e.tier
        cnName       = $e.name
        enName       = $g.equipment.($e.name)
        icon         = $equipIconMap[$e.name]
        price        = [int]$e.price
        isomorphCn   = $(if ($isoCn) { $isoCn } else { '' })
        isomorphEn   = $isoEn
        status       = $info.status
        s2Note       = $(if ($info.s2Note) { $info.s2Note } else { '' })
        recipe       = $(if ($info.recipe) { $info.recipe } else { $null })
        combinesWith = $(if ($info.combinesWith) { $info.combinesWith } else { '' })
        combinesInto = $(if ($info.combinesInto) { $info.combinesInto } else { '' })
        cnEffect     = $e.effect
        enEffect     = $info.effect
        cnUpgraded   = $e.upgraded
        enUpgraded   = $info.upgraded
    }
}
SaveJson $enEquip (Join-Path $enDir 'equipment.json')
"Translated $($enEquip.Count) equipment items."
