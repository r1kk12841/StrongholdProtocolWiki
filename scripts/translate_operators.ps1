# Translate all 143 Operators from CN JSON into EN JSON, keeping only Alliances and Stronghold Ability (Base + Upgraded).
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
$s2rows = LoadJson (Join-Path $rawDir 'closure_s2.rows.json')
$s3zhrows = LoadJson (Join-Path $rawDir 'closure_s3_zh.rows.json')

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

$s2Ops = @{}
foreach ($r in ($s2rows | Where-Object { $_.h2 -eq 'Operators' })) {
    $ename = ($r.cells[1] -replace '★+$', '' -split "`n")[0].Trim()
    $s2Ops[$ename] = $true
}

# Helper to translate bracketed alliance lists like 【乌萨斯】【不屈】 -> [Ursus] and [Resilient]
function FormatAlliances([string]$raw) {
    $ms = @([regex]::Matches($raw, '【([^】]+)】') | ForEach-Object { "[" + $g.alliances.($_.Groups[1].Value) + "]" })
    if ($ms.Count -eq 1) { return "$($ms[0]) Alliance" }
    if ($ms.Count -eq 2) { return "$($ms[0]) and $($ms[1]) Alliances" }
    if ($ms.Count -eq 3) { return "$($ms[0]), $($ms[1]), and $($ms[2]) Alliances" }
    return ($ms -join ', ')
}

function FormatAlliancesOr([string]$raw) {
    $ms = @([regex]::Matches($raw, '【([^】]+)】') | ForEach-Object { "[" + $g.alliances.($_.Groups[1].Value) + "]" })
    if ($ms.Count -eq 1) { return "$($ms[0]) Alliance" }
    if ($ms.Count -eq 2) { return "$($ms[0]) or $($ms[1]) Alliances" }
    if ($ms.Count -eq 3) { return "$($ms[0]), $($ms[1]), or $($ms[2]) Alliances" }
    return ($ms -join ', ')
}

function TranslateAbility([string]$s) {
    if (-not $s) { return 'Same as base ability' }
    $s = ($s -replace "`r?`n", ' ').Trim()

    # Exact special/unique operator abilities first
    $exact = @{
        '<战斗中>造成的伤害变为弱点伤害（根据敌人的防御力与法术抗性变换伤害类型）' = '<In battle> Deals Weakness damage (changes damage type depending on the enemy''s DEF and RES)'
        '只需两名本干员即可合成精锐' = 'Only 2 copies of this Operator are needed for Elite promotion'
        '购买价格为1' = 'Purchase price is 1 Funds'
        '售出价格为3' = 'Sell price is 3 Funds'
        '售出价格为6' = 'Sell price is 6 Funds'
        '<获得时>获得一次免费刷新' = '<When obtained> Gain 1 free Refresh'
        '<获得时>获得两次免费刷新' = '<When obtained> Gain 2 free Refreshes'
        '<获得时>获得1次免费刷新（触发2次后升级，至多获得3次免费刷新）' = '<When obtained> Gain 1 free Refresh (upgrades after triggering 2 times, up to 3 free Refreshes)'
        '<获得时> 获得1次免费刷新（触发2次后升级，至多获得3次免费刷新）' = '<When obtained> Gain 1 free Refresh (upgrades after triggering 2 times, up to 3 free Refreshes)'
        '<售出时>下回合额外获得1资金' = '<When sold> Gain 1 extra Funds next round'
        '<售出时>下回合额外获得2资金' = '<When sold> Gain 2 extra Funds next round'
        '<获得时>获得等同于当前调度中心等级的【炎】层数' = '<When obtained> Gain [Yan] stacks equal to the current Dispatch Center Level'
        '<获得时>获得等同于当前调度中心等级两倍的【炎】层数' = '<When obtained> Gain [Yan] stacks equal to 2x the current Dispatch Center Level'
        '<获得时> 【谢拉格】层数+1（每次触发后升级，至多叠加12层）' = '<When obtained> +1 stack to [Kjerag] Alliance (upgrades after each trigger, up to +12 stacks)'
        '<战斗中>造成的伤害变为弱点伤害（根据敌人的防御力与法术抗性变换伤害类型）； 每击倒一名敌人使已激活的【叙拉古】【精准】层数+2（每回合至多叠加8层）' = '<In battle> Deals Weakness damage (changes damage type depending on the enemy''s DEF and RES); each enemy defeated grants +2 stacks to active [Siracusa] and [Precision] Alliances (up to 8 stacks per round)'
        '<战斗中>造成的伤害变为弱点伤害（根据敌人的防御力与法术抗性变换伤害类型）； 每击倒一名敌人使已激活的【叙拉古】【精准】层数+4（每回合至多叠加16层）' = '<In battle> Deals Weakness damage (changes damage type depending on the enemy''s DEF and RES); each enemy defeated grants +4 stacks to active [Siracusa] and [Precision] Alliances (up to 16 stacks per round)'
        '<售出时>进行一次I阶干员的免费特殊招募 本干员合成为精锐状态后，上述特殊招募变为V阶干员' = '<When sold> Perform 1 free special recruitment of a Tier I Operator (upgrades to a Tier V Operator after promoting to Elite)'
        '<售出时>进行一次V阶干员的免费特殊招募' = '<When sold> Perform 1 free special recruitment of a Tier V Operator'
        '<售出时>随机获得一名当前人数最多盟约的干员（不高于当前调度中心等级；无法获得自身）' = '<When sold> Randomly obtain 1 Operator from your Alliance with the highest Operator count (Tier cannot exceed current Dispatch Center Level; cannot obtain self)'
        '<战斗中>被击倒时召唤整备区的一名【卡西米尔】干员（优先选择最右侧）上场，并使整备区干员的当前再部署时间-30%' = '<In battle> When defeated, summons 1 [Kazimierz] Operator from the Bench (prioritizing the rightmost) onto the field, and reduces current Redeployment Time of Bench Operators by -30%'
        '<战斗中>被击倒时召唤整备区的一名【卡西米尔】干员（优先选择最右侧）上场，并使整备区干员的当前再部署时间-60%' = '<In battle> When defeated, summons 1 [Kazimierz] Operator from the Bench (prioritizing the rightmost) onto the field, and reduces current Redeployment Time of Bench Operators by -60%'
        '<获得时>获得一件维式重锤，小概率获得特殊维式重锤' = '<When obtained> Obtain 1 Victorian Hammer, with a small chance to obtain a special Victorian Hammer'
        '<获得时>获得一件特殊维式重锤，小概率获得终极维式重锤' = '<When obtained> Obtain 1 special Victorian Hammer, with a small chance to obtain an Ultimate Victorian Hammer'
        '<获得时>获得一次特殊刷新，下次刷新至少出现一名谢拉格干员' = '<When obtained> Gain 1 special refresh; the next refresh guarantees at least 1 [Kjerag] Operator'
        '<获得时>获得一次特殊刷新，下次刷新至少出现两名谢拉格干员' = '<When obtained> Gain 1 special refresh; the next refresh guarantees at least 2 [Kjerag] Operators'
        '<战斗中>自身被击倒或与替身发生替换时使周围八格的【阿戈尔】干员回复5点技力' = '<In battle> When defeated or swapped with her Substitute, [Ægir] Operators in the surrounding 8 tiles recover 5 SP'
        '<战斗中>自身被击倒或与替身发生替换时使周围八格的【阿戈尔】干员回复10点技力' = '<In battle> When defeated or swapped with her Substitute, [Ægir] Operators in the surrounding 8 tiles recover 10 SP'
        '<战斗中>攻击范围内每有一名敌人被击倒使攻击范围内及整备区中的干员再部署时间-3秒' = '<In battle> Each enemy defeated within Attack Range reduces Redeployment Time of Operators within Attack Range and on the Bench by -3s'
        '<战斗中>攻击范围内每有一名敌人被击倒使攻击范围内及整备区中的干员再部署时间-6秒' = '<In battle> Each enemy defeated within Attack Range reduces Redeployment Time of Operators within Attack Range and on the Bench by -6s'
        '<进入休整期时>使自身携带的装备变为精锐版本' = '<When entering Rest Phase> Upgrades all Equipment carried by this Operator'
        '<进入休整期时>获得1件“盟约之币”或“萨尔贡浓茶”，有小概率发现“拟态物质”' = '<When entering Rest Phase> Obtain 1 "Alliance Coin" or "Sargonian Teaspresso", with a small chance to discover "Mimic Matter"'
        '<进入休整期时>获得2件“盟约之币”或“萨尔贡浓茶”，有小概率发现“拟态物质”' = '<When entering Rest Phase> Obtain 2 "Alliance Coins" or "Sargonian Teaspressos", with a small chance to discover "Mimic Matter"'
        '<休整期结束时>本回合每进行过1次刷新，使已激活的【叙拉古】层数+2（每回合至多叠加8层），【奇迹】层数+1（每回合至多叠加4层）' = '<When Rest Phase ends> For each refresh performed this round, grants +2 stacks to active [Siracusa] Alliance (up to 8 stacks per round) and +1 stack to active [Marvel] Alliance (up to 4 stacks per round)'
        '<休整期结束时>本回合每进行过1次刷新，使已激活的【叙拉古】层数+4（每回合至多叠加16层），【奇迹】层数+2（每回合至多叠加8层）' = '<When Rest Phase ends> For each refresh performed this round, grants +4 stacks to active [Siracusa] Alliance (up to 16 stacks per round) and +2 stacks to active [Marvel] Alliance (up to 8 stacks per round)'
        '<战斗开始时>使身前一格干员获得特质“<开启技能时>使自身已激活的盟约层数+1（每回合至多叠加7层）”' = '<When battle starts> Grants the Operator 1 tile in front the ability: "<On skill activation> +1 stack to own active Alliance(s) (up to 7 stacks per round)"'
        '<战斗开始时>使身前一格干员获得特质“<开启技能时>使自身已激活的盟约层数+2（每回合至多叠加14层）”' = '<When battle starts> Grants the Operator 1 tile in front the ability: "<On skill activation> +2 stacks to own active Alliance(s) (up to 14 stacks per round)"'
        '<休整期结束时><休整期开始时>使已激活的【远见】层数+3' = '<When Rest Phase starts & ends> +3 stacks to active [Foresight] Alliance'
        '<休整期结束时><休整期开始时>使已激活的【远见】层数+6' = '<When Rest Phase starts & ends> +6 stacks to active [Foresight] Alliance'
        '<休整期结束时>使已激活的【伊比利亚】叠加等同于场上所有干员售出价格的层数（每回合至多叠加12层）' = '<When Rest Phase ends> Grants stacks to active [Iberia] Alliance equal to the total sell price of all Operators on the field (up to 12 stacks per round)'
        '<休整期结束时>使已激活的【伊比利亚】叠加等同于场上所有干员售出价格2倍的层数（每回合至多叠加24层）' = '<When Rest Phase ends> Grants stacks to active [Iberia] Alliance equal to 2x the total sell price of all Operators on the field (up to 24 stacks per round)'
        '<获得时>【炎】层数+8，【远见】层数+4' = '<When obtained> +8 stacks to [Yan] Alliance and +4 stacks to [Foresight] Alliance'
        '<获得时>【炎】层数+16，【远见】层数+8' = '<When obtained> +16 stacks to [Yan] Alliance and +8 stacks to [Foresight] Alliance'
        '<战斗中>周围八格每有一名敌人或干员进入沉睡或眩晕时使自身及身后一格干员已激活的盟约层数+1（每回合至多叠加9层）' = '<In battle> Whenever an enemy or Operator in the surrounding 8 tiles becomes Asleep or Stunned, grants +1 stack to active Alliance(s) of self and the Operator 1 tile behind (up to 9 stacks per round)'
        '<战斗中>周围八格每有一名敌人或干员进入沉睡或眩晕时使自身及身后一格干员已激活的盟约层数+2（每回合至多叠加18层）' = '<In battle> Whenever an enemy or Operator in the surrounding 8 tiles becomes Asleep or Stunned, grants +2 stacks to active Alliance(s) of self and the Operator 1 tile behind (up to 18 stacks per round)'
        '<战斗中>攻击范围内每有一名敌人陷入冻结自身回复1点技力，并使已激活的【谢拉格】层数+1（每回合至多叠加24层）' = '<In battle> Whenever an enemy within Attack Range becomes Frozen, recovers 1 SP and grants +1 stack to active [Kjerag] Alliance (up to 24 stacks per round)'
        '<战斗中>攻击范围内每有一名敌人冻结自身回复2点技力，并使已激活的【谢拉格】层数+2（每回合至多叠加48层）' = '<In battle> Whenever an enemy within Attack Range becomes Frozen, recovers 2 SP and grants +2 stacks to active [Kjerag] Alliance (up to 48 stacks per round)'
        '<战斗中>身前一格【谢拉格】【灵巧】干员每场战斗的叠层上限+75%' = '<In battle> Increases the per-battle stacking cap of the [Kjerag] or [Agile] Operator 1 tile in front by +75%'
        '<战斗中>身前一格【谢拉格】【灵巧】干员每场战斗的叠层上限+150%' = '<In battle> Increases the per-battle stacking cap of the [Kjerag] or [Agile] Operator 1 tile in front by +150%'
        '<进入休整期时>若同一行有3名干员，获得1个幽灵鲨、安哲拉、深巡或斯卡蒂' = '<When entering Rest Phase> If there are 3 Operators in the same row, obtain 1 Specter, Andreana, Underflow, or Skadi'
        '<进入休整期时>获得1个幽灵鲨、安哲拉、深巡或斯卡蒂' = '<When entering Rest Phase> Obtain 1 Specter, Andreana, Underflow, or Skadi'
        '<战斗中>场上其他与自身拥有相同盟约的干员在本回合战斗期的叠层上限+7' = '<In battle> Other Operators on the field sharing an Alliance with this Operator gain +7 stacking cap during this round''s Combat Phase'
        '<战斗中>场上其他与自身拥有相同盟约的干员在本回合战斗期的叠层上限+14' = '<In battle> Other Operators on the field sharing an Alliance with this Operator gain +14 stacking cap during this round''s Combat Phase'
        '<进入休整期时>触发身前一格的其他干员的“获得时”类效果' = '<When entering Rest Phase> Triggers the "When obtained" ability of the other Operator 1 tile in front'
        '<进入休整期时>触发身前两格的其他干员的“获得时”类效果' = '<When entering Rest Phase> Triggers the "When obtained" abilities of other Operators up to 2 tiles in front'
        '身前一格干员若为“休整期结束时”特质，本干员的特质与其相同' = 'If the Operator 1 tile in front has a "When Rest Phase ends" ability, this Operator copies that ability'
        '<休整期结束时> 本回合每消耗3资金，使已激活的【奥术】层数+2（每回合至多叠加18层）' = '<When Rest Phase ends> For every 3 Funds spent this round, grants +2 stacks to active [Arcane] Alliance (up to 18 stacks per round)'
        '<休整期结束时> 本回合每消耗3资金，使已激活的【奥术】层数+4（每回合至多叠加36层）' = '<When Rest Phase ends> For every 3 Funds spent this round, grants +4 stacks to active [Arcane] Alliance (up to 36 stacks per round)'
        '<战斗中>周围八格干员每场战斗的叠层上限+30%' = '<In battle> Increases the per-battle stacking cap of Operators in the surrounding 8 tiles by +30%'
        '<战斗中>周围八格干员每场战斗的叠层上限+60%' = '<In battle> Increases the per-battle stacking cap of Operators in the surrounding 8 tiles by +60%'
        '<战斗中>身前一格干员提升盟约层数时，每次提升的层数额外+1（不受叠层上限影响）' = '<In battle> Whenever the Operator 1 tile in front gains Alliance stacks, increases the stacks gained each time by +1 (unaffected by stacking caps)'
        '<战斗中>身前一格干员提升盟约层数时，每次提升的层数额外+2（不受叠层上限影响）' = '<In battle> Whenever the Operator 1 tile in front gains Alliance stacks, increases the stacks gained each time by +2 (unaffected by stacking caps)'
        '<战斗开始时>【阿戈尔】盟约每叠加20层，使场上所有敌人侵蚀损伤冷却恢复速度+1%' = '<When battle starts> For every 20 [Ægir] stacks, all enemies on the field have +1% Corrosion Damage cooldown recovery speed'
        '<战斗开始时>【阿戈尔】盟约每叠加10层，使场上所有敌人侵蚀损伤冷却恢复速度+1%' = '<When battle starts> For every 10 [Ægir] stacks, all enemies on the field have +1% Corrosion Damage cooldown recovery speed'
        '<战斗中>被击倒时召唤整备区最右侧的【卡西米尔】【突袭】干员上场，并使自身及被召唤干员已激活的盟约层数+6（每名干员每回合至多叠加12层）' = '<In battle> When defeated, summons the rightmost [Kazimierz] or [Raid] Operator from the Bench onto the field, and grants +6 stacks to active Alliance(s) of self and the summoned Operator (up to 12 stacks per Operator per round)'
        '<战斗中>被击倒时召唤整备区最右侧的【卡西米尔】【突袭】干员上场，并使自身及被召唤干员已激活的盟约层数+12（每名干员每回合至多叠加24层）' = '<In battle> When defeated, summons the rightmost [Kazimierz] or [Raid] Operator from the Bench onto the field, and grants +12 stacks to active Alliance(s) of self and the summoned Operator (up to 24 stacks per Operator per round)'
        '<战斗中>每击倒一名敌人使已激活的【叙拉古】层数+2（每场战斗至多叠加20层） （晋升为精锐状态时，使所有【叙拉古】干员获得此效果）' = '<In battle> Each enemy defeated grants +2 stacks to active [Siracusa] Alliance (up to 20 stacks per battle; when promoted to Elite, grants this effect to all [Siracusa] Operators)'
        '<战斗中>所有【叙拉古】干员每击倒一名敌人使已激活的【叙拉古】层数+4（每场战斗至多叠加40层）' = '<In battle> Whenever any [Siracusa] Operator defeats an enemy, grants +4 stacks to active [Siracusa] Alliance (up to 40 stacks per battle)'
        '<进入休整期时>获得一件随机装备（不高于当前调度中心等级）' = '<When entering Rest Phase> Obtain 1 random piece of Equipment (Tier cannot exceed current Dispatch Center Level)'
        '<进入休整期时>获得两件随机装备（不高于当前调度中心等级）' = '<When entering Rest Phase> Obtain 2 random pieces of Equipment (Tier cannot exceed current Dispatch Center Level)'
        '<获得时>【奥术】层数+10，【远见】层数+5 <战斗中>【奥术】【远见】每叠加3层，本干员攻击速度+1' = '<When obtained> +10 stacks to [Arcane] Alliance and +5 stacks to [Foresight] Alliance; <In battle> For every 3 stacks of [Arcane] or [Foresight], this Operator gains +1 ASPD'
        '<获得时>【奥术】层数+20，【远见】层数+10 <战斗中>【奥术】【远见】每叠加3层，本干员攻击速度+2' = '<When obtained> +20 stacks to [Arcane] Alliance and +10 stacks to [Foresight] Alliance; <In battle> For every 3 stacks of [Arcane] or [Foresight], this Operator gains +2 ASPD'
        '<进入休整期时>若同一行至少有三名干员，获得一名当前人数最多盟约的干员' = '<When entering Rest Phase> If there are at least 3 Operators in the same row, obtain 1 Operator from your Alliance with the highest Operator count'
        '<进入休整期时>获得一名当前人数最多盟约的干员' = '<When entering Rest Phase> Obtain 1 Operator from your Alliance with the highest Operator count'
        '<战斗中>【乌萨斯】盟约获得强化：击倒单位时叠加的临时层数提升至4层；在场6名不同【乌萨斯】干员时，提升至6层' = '<In battle> Enhances the [Ursus] Alliance: temporary stacks gained on defeating a unit increase to 4, or to 6 with 6 different [Ursus] Operators on the field'
        '<战斗中>【乌萨斯】盟约获得强化：击倒单位时叠加的临时层数提升至6层；在场6名不同【乌萨斯】干员时，提升至8层' = '<In battle> Enhances the [Ursus] Alliance: temporary stacks gained on defeating a unit increase to 6, or to 8 with 6 different [Ursus] Operators on the field'
    }
    if ($exact[$s]) { return $exact[$s] }

    # Pattern rules
    if ($s -match '^<获得时>((?:【[^】]+】)+)层数\+(\d+)$') {
        return "<When obtained> +$($Matches[2]) stacks to $(FormatAlliances $Matches[1])"
    }
    if ($s -match '^<获得时>获得(一|两)(?:件|枚|个)“?([^”]+)”?$') {
        $n = $(if ($Matches[1] -eq '一') { 1 } else { 2 })
        $eq = $g.equipment.($Matches[2])
        return "<When obtained> Obtain $n ""$eq"""
    }
    if ($s -match '^<进入休整期时>转化(\d+)层【乌萨斯】临时层数为固定层数$') {
        return "<When entering Rest Phase> Convert $($Matches[1]) temporary [Ursus] stacks into permanent stacks"
    }
    if ($s -match '^<进入休整期时>场上每有一名【乌萨斯】干员，转化(\d+)层【乌萨斯】临时层数为固定层数$') {
        return "<When entering Rest Phase> For every [Ursus] Operator on the field, convert $($Matches[1]) temporary [Ursus] stack(s) into permanent stacks"
    }
    if ($s -match '^<战斗开始时>使已激活的【乌萨斯】临时层数\+(\d+)$') {
        return "<When battle starts> +$($Matches[1]) temporary stacks to active [Ursus] Alliance"
    }
    if ($s -match '^<休整期结束时>使已激活的((?:【[^】]+】)+)层数\+(\d+)$') {
        return "<When Rest Phase ends> +$($Matches[2]) stacks to active $(FormatAlliances $Matches[1])"
    }
    if ($s -match '^<休整期结束时>使已激活的核心盟约层数\+(\d+)$') {
        return "<When Rest Phase ends> +$($Matches[1]) stacks to all active Core Alliances"
    }
    if ($s -match '^<休整期结束时>使当前已激活且层数最多的盟约层数\+(\d+)（此干员在整备区也生效）$') {
        return "<When Rest Phase ends> +$($Matches[1]) stack(s) to the most stacked active Alliance (also takes effect while on the Bench)"
    }
    if ($s -match '^<休整期结束时>使自身(?:及|以及)身前一格干员已激活的盟约层数\+(\d+)$') {
        return "<When Rest Phase ends> +$($Matches[1]) stacks to active Alliance(s) of self and the Operator 1 tile in front"
    }
    if ($s -match '^<进入休整期时>使自身及身(前|后)一格干员已激活的盟约层数\+(\d+)$') {
        $dir = $(if ($Matches[1] -eq '前') { 'in front' } else { 'behind' })
        return "<When entering Rest Phase> +$($Matches[2]) stacks to active Alliance(s) of self and the Operator 1 tile $dir"
    }
    if ($s -match '^<休整期结束时>使自身及身前一格干员已激活的盟约叠加等同于其售出价格(2倍)?的层数$') {
        $mult = $(if ($Matches[1]) { '2x ' } else { '' })
        return "<When Rest Phase ends> Grants stacks to active Alliance(s) of self and the Operator 1 tile in front equal to ${mult}their sell price"
    }
    if ($s -match '^<休整期结束时>自身售出价格\+(\d+)（自身售出价格至多为(\d+)）$') {
        return "<When Rest Phase ends> Own sell price +$($Matches[1]) (up to $($Matches[2]))"
    }
    if ($s -match '^<休整期结束时>\s*本回合每获得过一名干员，使已激活的((?:【[^】]+】)+)层数\+(\d+)（每回合至多叠加(\d+)层）$') {
        return "<When Rest Phase ends> For every Operator obtained this round, grants +$($Matches[2]) stacks to active $(FormatAlliances $Matches[1]) (up to $($Matches[3]) stacks per round)"
    }
    if ($s -match '^<休整期结束时>同一行每有1名干员，使已激活的((?:【[^】]+】)+)层数\+(\d+)$') {
        return "<When Rest Phase ends> For every Operator in the same row, grants +$($Matches[2]) stacks to active $(FormatAlliances $Matches[1])"
    }
    if ($s -match '^<休整期结束时>场上每有一名携带装备的干员，使已激活的((?:【[^】]+】)+)层数\+(\d+)$') {
        return "<When Rest Phase ends> For every Operator on the field carrying Equipment, grants +$($Matches[2]) stacks to active $(FormatAlliances $Matches[1])"
    }
    if ($s -match '^<休整期结束时>场上每有一名不同阶的【维多利亚】干员，使已激活的((?:【[^】]+】)+)层数\+(\d+)$') {
        return "<When Rest Phase ends> For every [Victoria] Operator of a different Tier on the field, grants +$($Matches[2]) stacks to active $(FormatAlliances $Matches[1])"
    }
    if ($s -match '^<休整期结束时>使整备区每名干员已激活的盟约层数\+(\d+)$') {
        return "<When Rest Phase ends> +$($Matches[1]) stack(s) to the active Alliance(s) of each Operator on the Bench"
    }
    if ($s -match '^<休整期结束时>整备区每有一名干员，使已激活的((?:【[^】]+】)+)层数\+(\d+)$') {
        return "<When Rest Phase ends> For every Operator on the Bench, grants +$($Matches[2]) stack(s) to active $(FormatAlliances $Matches[1])"
    }
    if ($s -match '^<刷新时>若为本回合首次主动刷新，使已激活的((?:【[^】]+】)+)层数\+(\d+)（此干员在整备区也生效）$') {
        return "<On refresh> On the first manual refresh each round, grants +$($Matches[2]) stacks to active $(FormatAlliances $Matches[1]) (also takes effect while on the Bench)"
    }
    if ($s -match '^<战斗结束时>每有一名存活的我方干员，使已激活的((?:【[^】]+】)+)层数\+(\d+)$') {
        return "<When battle ends> For every surviving allied Operator, grants +$($Matches[2]) stack(s) to active $(FormatAlliances $Matches[1])"
    }
    if ($s -match '^<战斗结束时>每有一名存活的我方干员，使自身已激活的盟约层数\+(\d+)$') {
        return "<When battle ends> For every surviving allied Operator, grants +$($Matches[1]) stack(s) to own active Alliance(s)"
    }
    if ($s -match '^<战斗中>对每名敌人首次造成伤害时使目标陷入(\d+)秒寒冷$') {
        return "<In battle> Dealing damage to each enemy for the first time inflicts Cold for $($Matches[1])s"
    }
    if ($s -match '^<战斗中>每次开启技能时使已激活的((?:【[^】]+】)+)层数\+(\d+)（每(回合|场战斗)至多叠加(\d+)层）$') {
        $per = $(if ($Matches[3] -eq '回合') { 'round' } else { 'battle' })
        return "<In battle> On each skill activation, grants +$($Matches[2]) stack(s) to active $(FormatAlliances $Matches[1]) (up to $($Matches[4]) stacks per $per)"
    }
    if ($s -match '^<战斗中>每次开启技能时使自身已激活的盟约层数\+(\d+)（每(回合|场战斗)至多叠加(\d+)层）$') {
        $per = $(if ($Matches[2] -eq '回合') { 'round' } else { 'battle' })
        return "<In battle> On each skill activation, grants +$($Matches[1]) stacks to own active Alliance(s) (up to $($Matches[3]) stacks per $per)"
    }
    if ($s -match '^<战斗中>每次开启技能时使身前一格干员回复(\d+)点技力$') {
        return "<In battle> On each skill activation, the Operator 1 tile in front recovers $($Matches[1]) SP"
    }
    if ($s -match '^<战斗中>部署时使已激活的((?:【[^】]+】)+)(?:盟约)?层数\+(\d+)（每(回合|场战斗)至多叠加(\d+)层）$') {
        $per = $(if ($Matches[3] -eq '回合') { 'round' } else { 'battle' })
        return "<In battle> On deployment, grants +$($Matches[2]) stack(s) to active $(FormatAlliances $Matches[1]) (up to $($Matches[4]) stacks per $per)"
    }
    if ($s -match '^<战斗中>部署时使自身已激活的盟约层数\+(\d+)（每场战斗至多叠加(\d+)层）$') {
        return "<In battle> On deployment, grants +$($Matches[1]) stacks to own active Alliance(s) (up to $($Matches[2]) stacks per battle)"
    }
    if ($s -match '^<战斗中>攻击范围内每有一名敌人被击倒使已激活的((?:【[^】]+】)+)层数\+(\d+)（每(回合|场战斗)至多叠加(\d+)层）$') {
        $per = $(if ($Matches[3] -eq '回合') { 'round' } else { 'battle' })
        return "<In battle> Whenever an enemy within Attack Range is defeated, grants +$($Matches[2]) stack(s) to active $(FormatAlliances $Matches[1]) (up to $($Matches[4]) stacks per $per)"
    }
    if ($s -match '^<战斗中>攻击范围内每有一名敌人进入冻结使已激活的【谢拉格】层数\+(\d+)（每回合至多叠加(\d+)层）$') {
        return "<In battle> Whenever an enemy within Attack Range becomes Frozen, grants +$($Matches[1]) stack(s) to active [Kjerag] Alliance (up to $($Matches[2]) stacks per round)"
    }
    if ($s -match '^<战斗中>攻击范围内每有一名敌人陷入恐惧使已激活的【迅捷】层数\+(\d+)（每回合至多叠加(\d+)层）$') {
        return "<In battle> Whenever an enemy within Attack Range becomes Feared, grants +$($Matches[1]) stacks to active [Swift] Alliance (up to $($Matches[2]) stacks per round)"
    }
    if ($s -match '^<战斗中>攻击范围内每有一名敌人触发元素损伤爆发使已激活的((?:【[^】]+】)+)层数\+(\d+)（每回合至多叠加(\d+)层）$') {
        return "<In battle> Whenever an enemy within Attack Range suffers an Elemental Damage burst, grants +$($Matches[2]) stack(s) to active $(FormatAlliances $Matches[1]) (up to $($Matches[3]) stacks per round)"
    }
    if ($s -match '^<战斗中>周围八格每有一名敌人触发元素损伤爆发使自身已激活的盟约层数\+(\d+)（每回合至多叠加(\d+)层）$') {
        return "<In battle> Whenever an enemy in the surrounding 8 tiles suffers an Elemental Damage burst, grants +$($Matches[1]) stack(s) to own active Alliance(s) (up to $($Matches[2]) stacks per round)"
    }
    if ($s -match '^<战斗中>攻击范围内每有一名我方干员部署使已激活的【阿戈尔】层数\+(\d+)（每场战斗至多叠加(\d+)层）$') {
        return "<In battle> Whenever an allied Operator is deployed within Attack Range, grants +$($Matches[1]) stacks to active [Ægir] Alliance (up to $($Matches[2]) stacks per battle)"
    }
    if ($s -match '^<战斗中>每击倒一名敌人或我方干员使已激活的((?:【[^】]+】)+)层数\+(\d+)（每回合至多叠加(\d+)层）$') {
        return "<In battle> Each enemy or allied Operator defeated grants +$($Matches[2]) stacks to active $(FormatAlliances $Matches[1]) (up to $($Matches[3]) stacks per round)"
    }
    if ($s -match '^<战斗中>每击倒一名敌人使已激活的((?:【[^】]+】)+)层数\+(\d+)（每回合至多叠加(\d+)层）$') {
        return "<In battle> Each enemy defeated grants +$($Matches[2]) stacks to active $(FormatAlliances $Matches[1]) (up to $($Matches[3]) stacks per round)"
    }
    if ($s -match '^<战斗中>自身被击倒或与傀儡发生替换时使已激活的【不屈】层数\+(\d+)（每回合至多叠加(\d+)层）$') {
        return "<In battle> When defeated or swapped with her Doll, grants +$($Matches[1]) stacks to active [Resilient] Alliance (up to $($Matches[2]) stacks per round)"
    }
    if ($s -match '^<战斗中>((?:【[^】]+】)+)每叠加(\d+)层，本干员攻击力\+(\d+)%$') {
        return "<In battle> For every $($Matches[2]) stack(s) of $(FormatAlliancesOr $Matches[1]), this Operator gains +$($Matches[3])% ATK"
    }
    if ($s -match '^<战斗中>((?:【[^】]+】)+)每叠加(\d+)层，本干员攻击速度\+(\d+)$') {
        return "<In battle> For every $($Matches[2]) stack(s) of $(FormatAlliancesOr $Matches[1]), this Operator gains +$($Matches[3]) ASPD"
    }
    if ($s -match '^<战斗中>((?:【[^】]+】)+)每叠加(\d+)层，本干员技力自然回复速度\+(\d+(?:\.\d+)?)/秒，攻击力\+(\d+)%$') {
        return "<In battle> For every $($Matches[2]) stack(s) of $(FormatAlliancesOr $Matches[1]), this Operator gains +$($Matches[3])/s SP recovery rate and +$($Matches[4])% ATK"
    }
    if ($s -match '^<战斗中>((?:【[^】]+】)+)每叠加(\d+)层，本干员技力自然回复速度\+(\d+(?:\.\d+)?)/秒，生命上限\+(\d+)%$') {
        return "<In battle> For every $($Matches[2]) stacks of $(FormatAlliancesOr $Matches[1]), this Operator gains +$($Matches[3])/s SP recovery rate and +$($Matches[4])% Max HP"
    }
    if ($s -match '^<战斗中>((?:【[^】]+】)+)每叠加(\d+)层，本干员技力自然回复速度\+(\d+(?:\.\d+)?)/秒$') {
        return "<In battle> For every $($Matches[2]) stacks of $(FormatAlliancesOr $Matches[1]), this Operator gains +$($Matches[3])/s SP recovery rate"
    }
    if ($s -match '^<战斗中>部署时【阿戈尔】盟约每叠加(\d+)层，使自身及周围四格的干员攻击速度\+(\d+)，持续(\d+)秒$') {
        return "<In battle> On deployment, for every $($Matches[1]) [Ægir] stacks, self and Operators in the adjacent 4 tiles gain +$($Matches[2]) ASPD for $($Matches[3])s"
    }
    if ($s -match '^<战斗中>部署时【阿戈尔】盟约每叠加(\d+)层，使自身及周围四格的干员攻击力\+(\d+)%，持续(\d+)秒$') {
        return "<In battle> On deployment, for every $($Matches[1]) [Ægir] stacks, self and Operators in the adjacent 4 tiles gain +$($Matches[2])% ATK for $($Matches[3])s"
    }
    if ($s -match '^<战斗中>【阿戈尔】盟约每叠加(\d+)层，自身及周围四格干员每次造成伤害时使目标移动速度-(\d+)%，持续(\d+)秒$') {
        return "<In battle> For every $($Matches[1]) [Ægir] stacks, whenever self or Operators in the adjacent 4 tiles deal damage, reduces target Movement Speed by -$($Matches[2])% for $($Matches[3])s"
    }
    if ($s -match '^<战斗中>【卡西米尔】每叠加(\d+)层，本干员部署后(\d+)秒内基础攻击力\+(\d+)、基础生命上限\+(\d+)$') {
        return "<In battle> For every $($Matches[1]) [Kazimierz] stacks, this Operator gains +$($Matches[3]) base ATK and +$($Matches[4]) base Max HP for $($Matches[2])s after deployment"
    }
    if ($s -match '^<战斗中>周围(\d+)格每有一名敌人被击倒自身回复(\d+)点技力$') {
        return "<In battle> Whenever an enemy in the surrounding $($Matches[1]) tiles is defeated, recovers $($Matches[2]) SP"
    }
    if ($s -match '^<战斗中>攻击力和生命上限\+(\d+)%$') {
        return "<In battle> ATK and Max HP +$($Matches[1])%"
    }

    throw "Untranslated operator ability: $s"
}

$cnOps = LoadJson (Join-Path $cnDir 'operators.json')
$enOps = @()
foreach ($o in $cnOps) {
    $enName = $g.operators.($o.name)
    if (-not $enName) { throw "Missing operator EN name for $($o.name)" }
    $alEn = @($o.alliances | ForEach-Object { $g.alliances.$_ })
    $enOps += [ordered]@{
        tier          = $o.tier
        cnName        = $o.name
        enName        = $enName
        icon          = $opIconMap[$o.name]
        cnAlliances   = $o.alliances
        enAlliances   = $alEn
        abilityTypeCn = $o.abilityType
        abilityTypeEn = $g.abilityTypes.($o.abilityType)
        status        = $(if ($s2Ops[$enName]) { 'returning' } else { 'new' })
        cnAbility     = $o.ability
        enAbility     = (TranslateAbility $o.ability)
        cnUpgraded    = $o.upgraded
        enUpgraded    = (TranslateAbility $o.upgraded)
    }
}
SaveJson $enOps (Join-Path $enDir 'operators.json')
"Translated $($enOps.Count) operators."
