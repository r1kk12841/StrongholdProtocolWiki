# Build the complete CN->EN glossary and translated JSON data files for Stronghold Protocol: Regulation.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$cnDir = Join-Path $root 'data\cn'
$enDir = Join-Path $root 'data\en'
$rawDir = Join-Path $root 'data\raw'
New-Item -ItemType Directory -Force $enDir | Out-Null

function LoadJson($p) { Get-Content -Raw -Encoding UTF8 $p | ConvertFrom-Json }
function SaveJson($obj, $p) {
    [IO.File]::WriteAllText($p, (ConvertTo-Json -InputObject $obj -Depth 8), (New-Object Text.UTF8Encoding $false))
}

$auto = LoadJson (Join-Path $root 'data\glossary.auto.json')
$s2rows = LoadJson (Join-Path $rawDir 'closure_s2.rows.json')
$s3zhrows = LoadJson (Join-Path $rawDir 'closure_s3_zh.rows.json')

# ---------- 1. Complete Alliances Glossary ----------
$allianceMap = [ordered]@{}
foreach ($p in $auto.alliances.PSObject.Properties) {
    if ($p.Value) { $allianceMap[$p.Name] = $p.Value }
}
$allianceMap['乌萨斯'] = 'Ursus'
$allianceMap['伊比利亚'] = 'Iberia'
$allianceMap['莱塔尼亚'] = 'Leithanien'
$allianceMap['聚合'] = 'Convergence'

# Alliance Icon URLs from Closure S3
$allianceIconMap = @{}
foreach ($r in ($s3zhrows | Where-Object { $_.h2 -eq '盟约' })) {
    $cname = ($r.cells[1] -replace '激活所需人数[\s\S]*$', '').Trim()
    if ($r.icon) {
        $allianceIconMap[$cname] = "https://static.closure.wiki/v3/autochess/bondicon/$($r.icon).webp"
    }
}

# Check which alliances existed in S2 vs New/Modified
$s2AllianceSet = @{}
foreach ($r in ($s2rows | Where-Object { $_.h2 -eq 'Alliances' })) {
    $ename = ($r.cells[1] -split "`n")[0].Trim()
    $s2AllianceSet[$ename] = ($r.cells[2] -replace "`n", " / ")
}

# ---------- 2. Complete Operators Glossary ----------
$opMap = [ordered]@{}
foreach ($p in $auto.operators.PSObject.Properties) {
    if ($p.Value) { $opMap[$p.Name] = $p.Value }
}
$opMap['“暴躁铁皮”'] = '"Rowdy Tin"'
$opMap['盟约·辅助干员'] = 'Alliance - Supporter Operator'

# Operator Avatar URLs from Closure S3
$opIconMap = @{}
foreach ($r in $s3zhrows) {
    foreach ($l in $r.links) {
        if ($l.name -and $l.char) {
            $opIconMap[$l.name] = "https://static.closure.wiki/v3/charavatars/$($l.char).webp"
        }
    }
    if ($r.h2 -eq '干员' -and $r.icon) {
        $cname = ($r.cells[1] -replace '★+$', '').Trim()
        $opIconMap[$cname] = "https://static.closure.wiki/v3/charavatars/$($r.icon).webp"
    }
}

$s2OpSet = @{}
foreach ($r in ($s2rows | Where-Object { $_.h2 -eq 'Operators' })) {
    $ename = ($r.cells[1] -replace '★+$', '' -split "`n")[0].Trim()
    $s2OpSet[$ename] = $true
}

# ---------- 3. Complete Leaders & Strategies Glossary ----------
$leaderMap = [ordered]@{}
foreach ($p in $auto.leaders.PSObject.Properties) {
    if ($p.Value) { $leaderMap[$p.Name] = $p.Value }
}
$manualLeaders = @{
    '百炼嘉维尔' = 'Gavial the Invincible'
    '天空盒' = 'Skybox'
    '风丸' = 'Kazemaru'
    '妮芙' = 'Nymph'
    '但书' = 'Proviso'
    '大嘴莫布' = "'Mouthpiece' Mob"
    '奥达' = 'Odda'
    '森蚺' = 'Eunectes'
    '寻宝人' = 'Treasure Hunter'
    'Misery' = 'Misery'
    '苏苏洛' = 'Sussurro'
    '信仰搅拌机' = 'Sankta Miksaparato'
    '“追随者们”' = '"The Followers"'
    '琳琅诗怀雅' = 'Swire the Elegant Wit'
    '三船光平' = 'Kouhei Mifune'
    '雅拉' = 'Yaara'
    '渡桥' = 'Mitm'
    'Mechanist' = 'Mechanist'
    '布丁' = 'Pudding'
    '拜松' = 'Bison'
    '坚雷' = 'Dur-nar'
    '复奏' = 'Ripresa'
    '望' = 'Wang'
    '洛洛' = 'Rockrock'
    '歌蕾蒂娅' = 'Gladiia'
    '焰尾' = 'Flametail'
    '耶拉' = 'Kjera'
    '裁度' = 'Figurino'
    '车尔尼' = 'Czerny'
    '怒潮凛冬' = 'Zima the Raging Tide'
    '引星棘刺' = 'Thorns the Lodestar'
}
foreach ($k in $manualLeaders.Keys) { $leaderMap[$k] = $manualLeaders[$k] }

$stratNameMap = [ordered]@{}
foreach ($p in $auto.strategies.PSObject.Properties) {
    if ($p.Value) { $stratNameMap[$p.Name] = $p.Value }
}
$manualStratNames = @{
    '百炼嘉维尔|意志鼓舞' = 'Willpower Boost'
    '天空盒|内部货源' = 'Insider Supply'
    '风丸|纸片替身' = 'Paper Substitute'
    '妮芙|溃心领域' = 'Heartrending Field'
    '夕|幻画为真' = 'Painted into Reality'
    '但书|条文修正' = 'Clause Amendment'
    '大嘴莫布|全场聚焦' = 'Center of Attention'
    '奥达|全力熔铸' = 'All-Out Forging'
    '森蚺|暴躁铁皮' = 'Rowdy Tin'
    '寻宝人|宝藏探机' = 'Treasure Finder'
    'Misery|消解空间' = 'Dissolution Space'
    '苏苏洛|强制休整' = 'Mandatory Rest'
    '信仰搅拌机|献身护卫' = 'Devoted Escort'
    '“追随者们”|好多委托！' = 'So Many Commissions!'
    '琳琅诗怀雅|最佳品味' = 'Finest Taste'
    '三船光平|东之极道' = 'Way of Higashi'
    '雅拉|人才锁定' = 'Talent Lock-In'
    '渡桥|专享情报' = 'Exclusive Intel'
    'Mechanist|精巧设计' = 'Ingenious Design'
    '布丁|电气化！' = 'Electrification!'
    '拜松|打包速递' = 'Bundled Express'
    '坚雷|正直教官' = 'Upright Instructor'
    '复奏|二重奏' = 'Duet'
    '望|黑白相易' = 'Reversal of Black and White'
    '娜仁图亚|沙洲梦魇' = 'Nightmare of the Sands'
    '洛洛|自发制造' = 'Spontaneous Crafting'
    '歌蕾蒂娅|猎人战法' = 'Hunter Tactics'
    '焰尾|骑士团长' = 'Knight Club Leader'
    '耶拉|不融信念' = 'Unmelting Faith'
    '裁度|量体裁衣' = 'Tailor-Made'
    '车尔尼|流动乐章' = 'Flowing Movement'
    '怒潮凛冬|无惧风雪' = 'Fearless of the Storm'
    '引星棘刺|出航时刻' = 'Time to Set Sail'
}
foreach ($k in $manualStratNames.Keys) { $stratNameMap[$k] = $manualStratNames[$k] }

$stratIconMap = @{}
foreach ($r in ($s3zhrows | Where-Object { $_.h2 -eq '策略' })) {
    $l = ($r.cells[1] -replace '初始生命值[\s\S]*$', '').Trim()
    if ($r.icon) {
        $stratIconMap[$l] = "https://static.closure.wiki/v3/autochess/bandicon/$($r.icon).webp"
    }
}

$s2LeaderSet = @{}
foreach ($r in ($s2rows | Where-Object { $_.h2 -eq 'Strategies' })) {
    $el = ($r.cells[1] -split "`n")[0].Trim()
    $s2LeaderSet[$el] = ($r.cells[2] -replace "`n", " / ")
}

# ---------- 4. Complete Equipment Glossary ----------
$equipMap = [ordered]@{}
foreach ($p in $auto.equipment.PSObject.Properties) {
    if ($p.Value) { $equipMap[$p.Name] = $p.Value }
}
$manualEquip = @{
    '虹彩活血饮料' = 'Iridescent Revitalizing Drink'
    '雪祀之衣' = 'Snow-Ritual Garb'
    '卫戍推荐信' = 'Stronghold Letter of Recommendation'
    '聚合急救箱' = 'Convergence First-Aid Kit'
    '灵巧涡轮手套' = 'Agile Turbo Gloves'
    '驮兽储蓄罐' = 'Burdenbeast Piggy Bank'
    '乌萨斯呼吸器' = 'Ursus Respirator'
    '多功能补剂' = 'Multi-Purpose Tonic'
    '伊比利亚骨刺刀' = 'Iberian Bone-Spur Blade'
    '定期存折' = 'Fixed-Term Passbook'
    '不退者之盾' = "Unyielding Shield"
    '莱塔尼亚小鼓' = 'Leithanian Snare Drum'
    '可靠怀表' = 'Reliable Pocket Watch'
    '一次性促销券' = 'One-Time Promo Coupon'
    '驱逐者警棍' = "Expeller's Baton"
    '动能单手弩' = 'Kinetic Hand Crossbow'
    '汲取者之喙' = "Siphoner's Beak"
    '电流维式重锤' = 'Shocking Victorian Hammer'
    '佣兵名牌' = 'Mercenary Dog Tag'
    '人事部记录' = 'HR Record'
    '瓶装烈性反应' = 'Bottled Volatile Reaction'
    '不退者力场' = "Unyielding Forcefield"
    '驱逐者瓦斯' = "Expeller's Gas"
    '投机骰子' = 'Speculative Dice'
    '动能加速器' = 'Kinetic Accelerator'
    '汲取者之心' = "Siphoner's Heart"
    '终极维式重锤' = 'Ultimate Victorian Hammer'
    '不退者卫护系统' = "Unyielding Aegis System"
    '动能轰击弩' = 'Kinetic Bombardment Crossbow'
    '汲取者之镰' = "Siphoner's Scythe"
    '驱逐者防暴装备' = "Expeller's Riot Gear"
    '天马之耀' = 'Pegasian Glory'
}
foreach ($k in $manualEquip.Keys) { $equipMap[$k] = $manualEquip[$k] }

$equipIconMap = @{}
foreach ($r in ($s3zhrows | Where-Object { $_.h2 -eq '装备' })) {
    $cname = ($r.cells[1] -replace '价格[\s\S]*$', '').Trim()
    if ($r.icon) {
        $equipIconMap[$cname] = "https://static.closure.wiki/v3/autochess/shopitemicon/$($r.icon).webp"
    }
}

$s2EquipSet = @{}
foreach ($r in ($s2rows | Where-Object { $_.h2 -eq 'Equipment' -and $_.h3 -ne 'Arts' })) {
    $ename = ($r.cells[1] -split "`n")[0].Trim()
    $s2EquipSet[$ename] = "$($r.cells[2]) || $($r.cells[3])"
}

$abilityTypeMap = @{
    '持续叠加' = 'Can stack'
    '作战能力' = 'Combat'
    '单次叠加' = 'One-time'
    '整备能力' = 'Prep'
    '特异化' = 'Special'
}

$protoMap = @{
    'Pith(卫戍协议)' = 'Pith'
    'Sharp(卫戍协议)' = 'Sharp'
    '预备干员-重装(卫戍协议)' = 'Reserve Operator - Defender'
    '郁金香(卫戍协议)' = 'Tulip'
    'Stormeye(卫戍协议)' = 'Stormeye'
    '预备干员-术师(卫戍协议)' = 'Reserve Operator - Caster'
    '预备干员-近卫(卫戍协议)' = 'Reserve Operator - Guard'
    'Misery(卫戍协议)' = 'Misery'
    'Mechanist(卫戍协议)' = 'Mechanist'
    'Raidian(卫戍协议)' = 'Raidian'
    '领主·Sharp' = 'Lord · Sharp'
    'Touch(卫戍协议)' = 'Touch'
    '预备干员-先锋(卫戍协议)' = 'Reserve Operator - Vanguard'
}

$fullGlossary = [ordered]@{
    alliances    = $allianceMap
    leaders      = $leaderMap
    strategies   = $stratNameMap
    operators    = $opMap
    equipment    = $equipMap
    isomorph     = $auto.isomorph
    abilityTypes = $abilityTypeMap
    prototypes   = $protoMap
}
SaveJson $fullGlossary (Join-Path $root 'data\glossary.json')
"Saved data\glossary.json successfully."
