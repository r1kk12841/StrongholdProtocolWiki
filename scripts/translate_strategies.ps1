# Translate all 61 Strategies from CN JSON into EN JSON, comparing against Season 2.
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

$stratIconMap = @{}
foreach ($r in ($s3zhrows | Where-Object { $_.h2 -eq '策略' })) {
    $l = ($r.cells[1] -replace '初始生命值[\s\S]*$', '').Trim()
    if ($r.icon) { $stratIconMap[$l] = "https://static.closure.wiki/v3/autochess/bandicon/$($r.icon).webp" }
}

function TranslateUnlock([string]$u) {
    if (-not $u) { return 'N/A' }
    $map = @{
        '通关任意模拟1次解锁' = 'Unlocks after clearing any 1 simulation'
        '通关任意模拟2次解锁' = 'Unlocks after clearing any 2 simulations'
        '通关任意模拟3次解锁' = 'Unlocks after clearing any 3 simulations'
        '通关任意模拟5次解锁' = 'Unlocks after clearing any 5 simulations'
        '通关任意模拟8次解锁' = 'Unlocks after clearing any 8 simulations'
        '通关任意模拟10次解锁' = 'Unlocks after clearing any 10 simulations'
        '通关【标准模拟】解锁' = 'Unlocks after clearing a Standard Simulation'
        '通关【险境模拟】解锁' = 'Unlocks after clearing a Dire Simulation'
        '通关【绝境模拟】解锁' = 'Unlocks after clearing an Ultimate Simulation'
        '通关任意联合模拟5次解锁' = 'Unlocks after clearing any 5 Co-op Simulations'
        '通关任意联合模拟10次解锁' = 'Unlocks after clearing any 10 Co-op Simulations'
        '消耗资金累计达到100时解锁' = 'Unlocks after spending a cumulative total of 100 Funds'
        '消耗资金累计达到200时解锁' = 'Unlocks after spending a cumulative total of 200 Funds'
        '消耗资金累计达到1000时解锁' = 'Unlocks after spending a cumulative total of 1000 Funds'
        '累计出售任意干员达到50个解锁' = 'Unlocks after selling a cumulative total of 50 Operators'
        '累计出售任意干员达到100个解锁' = 'Unlocks after selling a cumulative total of 100 Operators'
        '累计刷新调度中心100次解锁' = 'Unlocks after refreshing the Dispatch Center a cumulative total of 100 times'
        '累计刷新调度中心200次解锁' = 'Unlocks after refreshing the Dispatch Center a cumulative total of 200 times'
        '累计获得任意装备50个解锁' = 'Unlocks after obtaining a cumulative total of 50 pieces of Equipment'
        '累计获得任意装备100个解锁' = 'Unlocks after obtaining a cumulative total of 100 pieces of Equipment'
        '累计升级调度中心30次解锁' = 'Unlocks after upgrading the Dispatch Center a cumulative total of 30 times'
        '通关时的结算阵容中，包含任意【调和】干员解锁' = 'Unlocks after clearing a simulation with any [Harmony] Operator in squad'
        '通关时的结算阵容中，包含任意3名【助力】干员解锁' = 'Unlocks after clearing a simulation with any 3 [Aid] Operators in squad'
        '通关时的结算阵容中，包含任意2名【奇迹】干员解锁' = 'Unlocks after clearing a simulation with any 2 [Marvel] Operators in squad'
        '累计获得50名【炎】干员解锁' = 'Unlocks after obtaining a cumulative total of 50 [Yan] Operators'
        '通关时的结算阵容中，包含6名【炎】干员解锁' = 'Unlocks after clearing a simulation with 6 [Yan] Operators in squad'
        '累计获得50名【萨尔贡】干员解锁' = 'Unlocks after obtaining a cumulative total of 50 [Sargon] Operators'
        '通关时的结算阵容中，包含6名【萨尔贡】干员解锁' = 'Unlocks after clearing a simulation with 6 [Sargon] Operators in squad'
        '多场模拟中【维多利亚】盟约累计200层解锁' = 'Unlocks after achieving a cumulative total of 200 [Victoria] Alliance stacks across multiple simulations'
        '通关时的结算阵容中，包含6名【维多利亚】干员解锁' = 'Unlocks after clearing a simulation with 6 [Victoria] Operators in squad'
        '多场模拟中【阿戈尔】盟约累计200层解锁' = 'Unlocks after achieving a cumulative total of 200 [Ægir] Alliance stacks across multiple simulations'
        '通关时的结算阵容中，包含5名【阿戈尔】干员解锁' = 'Unlocks after clearing a simulation with 5 [Ægir] Operators in squad'
        '累计获得50名【卡西米尔】干员解锁' = 'Unlocks after obtaining a cumulative total of 50 [Kazimierz] Operators'
        '通关时的结算阵容中，包含6名【卡西米尔】干员解锁' = 'Unlocks after clearing a simulation with 6 [Kazimierz] Operators in squad'
        '累计获得50名【谢拉格】干员解锁' = 'Unlocks after obtaining a cumulative total of 50 [Kjerag] Operators'
        '通关时的结算阵容中，包含6名【谢拉格】干员解锁' = 'Unlocks after clearing a simulation with 6 [Kjerag] Operators in squad'
        '累计获得50名【叙拉古】干员解锁' = 'Unlocks after obtaining a cumulative total of 50 [Siracusa] Operators'
        '通关时的结算阵容中，包含6名【叙拉古】干员解锁' = 'Unlocks after clearing a simulation with 6 [Siracusa] Operators in squad'
        '通关时的结算阵容中，包含6名【莱塔尼亚】干员解锁' = 'Unlocks after clearing a simulation with 6 [Leithanien] Operators in squad'
        '通关时的结算阵容中，包含6名【乌萨斯】干员解锁' = 'Unlocks after clearing a simulation with 6 [Ursus] Operators in squad'
        '通关时的结算阵容中，包含6名【伊比利亚】干员解锁' = 'Unlocks after clearing a simulation with 6 [Iberia] Operators in squad'
    }
    if ($map[$u]) { return $map[$u] }
    throw "Untranslated unlock condition: $u"
}

$stratData = @{
    '阿米娅|众志合一' = @{
        status = 'unchanged'
        effect = "Passive: When there are 3, 4, or 5+ active Alliances on the field, all Operators gain +20%/+30%/+40% ATK and Max HP respectively"
    }
    '歌利亚|坚不可摧' = @{
        status = 'modified'
        s2Note = 'Initial Life Points reduced from 45 in S2 to 40.'
        effect = "Passive: Start with 40 Life Points"
    }
    '大帝|加急调派' = @{
        status = 'unchanged'
        effect = "Passive: Each time an allied Operator is deployed, their Redeployment Time is reduced by -50% for the rest of this battle"
    }
    '卡莱莎|食腐之蝶' = @{
        status = 'unchanged'
        effect = "Passive: When an allied Operator is defeated, remaining allied units on the field gain +20% ATK (up to +200%, lasts until defeated or battle ends)"
    }
    '伊奥莱塔·罗素|统御号令' = @{
        status = 'unchanged'
        effect = "Passive: When battle begins, for every 1 Elite Operator on the field, Elite Operators gain +10% ATK and Max HP"
    }
    '百炼嘉维尔|意志鼓舞' = @{
        status = 'new'
        effect = "Drag to use (Cost 0): Select an allied Operator; when the next battle begins, they are immediately defeated and revived, and gain 2 extra revives"
    }
    '天空盒|内部货源' = @{
        status = 'new'
        effect = "Tap to use (Cost 0): The next piece of Equipment purchased costs -1 Funds (minimum 0)"
    }
    '风丸|纸片替身' = @{
        status = 'new'
        effect = "Drag to use (Cost 0): Select an Operator in the Dispatch Center and transform them into a random Operator of the same Tier (up to 2 times per round)"
    }
    '妮芙|溃心领域' = @{
        status = 'new'
        effect = "Drag to use (Cost 0): Select a deployable tile; after battle begins, the first enemy passing through that tile is inflicted with Fear for 3 seconds (up to 1 time per round)`nUpgrades on Rounds 4, 8, and 12 to increase uses per round"
    }
    '夕|幻画为真' = @{
        status = 'reworked'
        s2Note = 'Changed from Dusk''s Scroll Special Arts item in S2 to an active drag command.'
        effect = "Drag to use (Cost 0): Select an allied Operator and obtain a copy of them, including Elite status and carried Equipment (up to 1 time per simulation)"
    }
    '但书|条文修正' = @{
        status = 'new'
        effect = "Unlocks on Round 4`nDrag to use (Cost 0): Select an allied Operator and grant +9 stacks to all of their active Alliances (Cooldown: 3 rounds)"
    }
    '大嘴莫布|全场聚焦' = @{
        status = 'new'
        effect = "Drag to use (Cost 1): Select an allied Operator; when the next battle begins, they temporarily become an Elite Operator until the battle ends"
    }
    '杰西卡|集结指示' = @{
        status = 'unchanged'
        effect = "Passive: Upon entering the Rest Phase on Rounds 4, 7, 10, and 13, obtain 1 <Dispatch Module>`n<Dispatch Module>: Destroyed when equipped; offers up to 3 other Operators sharing the equipped Operator's primary Alliance in the Dispatch Center, and pick 1 for free (Tier cannot exceed current Dispatch Center Level)"
    }
    '华法琳|重点监护' = @{
        status = 'modified'
        s2Note = 'HP changed 28->24; starts at +1 stack per Tier (was +2 in S2) and upgrades by +1 when Dispatch Center reaches Lv. 3 and Lv. 5.'
        effect = "Passive: When battle begins, grants +1 stack to the active Alliance(s) of 1 random allied Operator of each different Tier on the field`nUpgrades when Dispatch Center reaches Lv. 3 and Lv. 5, granting an additional +1 Alliance stack"
    }
    '桑葚|药枚实验' = @{
        status = 'reworked'
        s2Note = 'Changed from passive rightmost-column buff (25%) in S2 to targeted drag command (20%, upgrades on Round 7).'
        effect = "Drag to use (Cost 0): Select an allied Operator; when the next battle begins, they gain: each attack has a 20% chance to grant 1 Shield (up to 1 stack)`nEffect upgrades on Round 7"
    }
    '奥达|全力熔铸' = @{
        status = 'new'
        effect = "Passive: Upon entering the Rest Phase on Rounds 3, 6, 9, 12, and 14, obtain 1 random piece of Equipment of the current Dispatch Center Level"
    }
    '陈|以己之长' = @{
        status = 'modified'
        s2Note = 'Added +16% ATK and +16 ASPD bonus for Elite Operators.'
        effect = "Passive: Physical and Arts damage dealt by all Operators becomes Weakness damage (changes damage type depending on the enemy's DEF and RES); Elite Operators additionally gain +16% ATK and +16 ASPD"
    }
    '老鲤|得闲饮茶' = @{
        status = 'unchanged'
        effect = "Passive: Funds from Rounds 1 and 2 are held and released on Round 3; upon entering the Rest Phase on Round 3, randomly obtain 1 Tier II Operator and 1 Tier IV Operator"
    }
    '芬|协力共进' = @{
        status = 'unchanged'
        effect = "Passive: Upon entering the Rest Phase on Rounds 8, 10, 12, and 14, obtain 1 <Transmitter>`n<Transmitter>: Destroys the equipped Operator when equipped and offers 2 Operators of the same Tier in the Dispatch Center, picking 1 for free; the destroyed Operator is sent in the next round to the teammate with the most Operators of that Alliance"
    }
    'Touch|外勤医疗' = @{
        status = 'unchanged'
        effect = "Passive: 1 <Reserve Operator - Medic> appears on every player's battlefield; when battle begins, if there are at least 2 Elite Operators on the field, transforms into <Touch>"
    }
    '森蚺|暴躁铁皮' = @{
        status = 'new'
        effect = "Passive: On Round 1, obtain 1 special Operator <""Rowdy Tin""> capable of equipping 4 pieces of Equipment"
    }
    '寻宝人|宝藏探机' = @{
        status = 'new'
        effect = "Drag to use (Cost 1): Select a deployable tile and deploy 1 <""Simulated Treasure""> (Cooldown: 3 rounds)`n<""Simulated Treasure"">: Permanently disappears if touched by an enemy; if it still exists when battle ends, gain 1 extra Funds"
    }
    '缪尔赛思|至纯凝结' = @{
        status = 'reworked'
        s2Note = 'Changed from granting an upgraded Doctor Hologram on Round 1 in S2 to a 0-cost drag command.'
        effect = "Drag to use (Cost 0): Select an allied Operator and immediately promote them to an Elite Operator (up to 1 time per simulation)"
    }
    'Misery|消解空间' = @{
        status = 'new'
        effect = "Drag to use (Cost 0): Select an allied Operator; the first time they take damage after the next battle begins, they are defeated and summon the rightmost Operator from the Bench"
    }
    '“变形者集群”|变形同构' = @{
        status = 'unchanged'
        effect = "Passive: Obtain 1 special Equipment <Damazti Isomorph> every 5 rounds`n<Damazti Isomorph>: When equipped together with specific Equipment, the equipped Operator is treated as a member of the corresponding Alliance"
    }
    '小贾斯汀|私募基金' = @{
        status = 'reworked'
        s2Note = 'Changed from granting Knightly Savings on Rounds 1/4/7/10 in S2 to an active tap command with cooldown equal to Funds gained.'
        effect = "Tap to use (Cost 0): Randomly gain 1–6 Funds (Cooldown in rounds equals the amount of Funds gained)"
    }
    '铃兰|御守之力' = @{
        status = 'reworked'
        s2Note = 'Changed from passive start-of-round trigger on bottom-right Operator in S2 to an active drag command.'
        effect = "Drag to use (Cost 0): Select an allied Operator and trigger their <When obtained> ability"
    }
    '苏苏洛|强制休整' = @{
        status = 'new'
        effect = "Drag to use (Cost 0): Select an allied Operator; their <When Rest Phase ends> ability triggers 1 additional time this round"
    }
    '昆图斯|不稳定要素' = @{
        status = 'reworked'
        s2Note = 'Changed from obtaining Mutated Cells on Round 3 in S2 to an active drag command unlocking on Round 4.'
        effect = "Unlocks on Round 4`nDrag to use (Cost 0): Select an allied Operator and immediately transform them into a random Operator 1 Tier higher (up to Tier VI)"
    }
    '信仰搅拌机|献身护卫' = @{
        status = 'new'
        effect = "Unlocks on Round 4`nTap to use (Cost 0): Reduce your Life Points to match the player with the lowest Life Points on the field and gain Funds equal to the Life Points lost (up to 10 Funds); <When Rest Phase ends>, restore an equal amount of Life Points to that player"
    }
    '“追随者们”|好多委托！' = @{
        status = 'new'
        effect = "Passive: Every time you enter the Rest Phase, choose 1 of 2 random Commands to replace your current Command"
    }
    '坎诺特|利滚利' = @{
        status = 'unchanged'
        effect = "Passive: Leftover Funds at the end of each round carry over; when you have at least 5 leftover Funds, gain 1 extra Funds each round"
    }
    '鸭爵|“神秘顾客”' = @{
        status = 'unchanged'
        effect = "Passive: Starting from Round 5, some enemies encountered by you and your teammates may be replaced with <Duck Lord>, <Gopnik>, <Crying Thief>, or <Fatty>; defeating them grants a 1 Funds reward (including during Joint Defense Phases)"
    }
    '琳琅诗怀雅|最佳品味' = @{
        status = 'new'
        effect = "Unlocks after spending 60 Funds`nTap to use (Cost 0): Randomly obtain 1 Operator currently in the Dispatch Center`nUpgrades to obtain 2 Operators after spending 120 Funds"
    }
    '巫恋|替身娃娃' = @{
        status = 'unchanged'
        effect = "Passive: The first non-Elite Operator sold each round is instead swapped with 1 random Operator from the Dispatch Center"
    }
    '三船光平|东之极道' = @{
        status = 'new'
        effect = "Drag to use (Cost 0): Select an allied Operator, sell them, and add stacks equal to that Operator's Tier to all active Alliances"
    }
    '雅拉|人才锁定' = @{
        status = 'new'
        effect = "Tap to use (Cost 1): Refresh the Dispatch Center, guaranteed to include 1 Operator 1 Tier higher than the current Dispatch Center Level (up to Tier VI; up to 3 times per round)"
    }
    '渡桥|专享情报' = @{
        status = 'new'
        effect = "Tap to use (Cost 3): Perform a special refresh that prioritizes offering Operators currently deployed on the field (up to 1 time per simulation)"
    }
    'Mechanist|精巧设计' = @{
        status = 'new'
        effect = "Passive: The first time Equipment is merged and upgraded each round, 3 pieces of Equipment appear in the Dispatch Center (may include Equipment 1 Tier higher); pick 1 for free`nTap to use (Cost 0): Replace 1 piece of Equipment in the Dispatch Center with a new one (up to 2 times per round)"
    }
    '布丁|电气化！' = @{
        status = 'new'
        effect = "Drag to use (Cost 1): Select 1 piece of Equipment in the Dispatch Center and immediately destroy it; when the next battle begins, all Operators on the field with an empty Equipment slot temporarily gain that Equipment until the battle ends (cannot be used on <Destroyed when equipped> Equipment)"
    }
    '拜松|打包速递' = @{
        status = 'new'
        effect = "Tap to use (Cost 9): Obtain all Operators currently in the Dispatch Center; at the end of each round's Rest Phase, this Command's Funds cost is reduced by -1; resets after use and can be used again"
    }
    'Pith|优等生' = @{
        status = 'unchanged'
        effect = "Passive: On Round 1, obtain 1 special Operator capable of inflicting Nervous Impairment, Burn, and Necrosis Damage, who belongs to the [Harmony] Alliance`n[Harmony]: When active, adds +1 to the Operator count of active Core Alliances on the field, and [Harmony] Operators benefit from the effects of all active Core Alliances"
    }
    '坚雷|正直教官' = @{
        status = 'new'
        effect = "Drag to use (Cost 0): Select an allied Operator; in the next battle, the stacking cap of their Stronghold Ability is increased by an amount equal to the current Round number"
    }
    '复奏|二重奏' = @{
        status = 'new'
        effect = "Passive: The first time an Operator is promoted to an Elite Operator each round, gain 1 additional Promotion Reward"
    }
    '望|黑白相易' = @{
        status = 'new'
        effect = "Drag to use (Cost 1): Select an allied Operator to remove them, and obtain 1 [Yan] Operator of a Tier not exceeding that Operator's Tier`nReplaces <With 6 different [Yan] Operators on field> with: When battle begins, gathers a portion of all [Yan] Operators' stats to summon 'Yan's Protection'`nAdds <With 9 different [Yan] Operators on field>: Summons 2 'Yan's Protection' instead"
    }
    '杜遥夜|广交豪杰' = @{
        status = 'modified'
        s2Note = 'HP changed 29->26; changed from passive first-2-refreshes to active tap command (Cost 1, up to 2 times/round).'
        effect = "Tap to use (Cost 1): Refresh the Dispatch Center, prioritizing offering 1 [Yan] Operator (up to 2 times per round)"
    }
    '娜仁图亚|沙洲梦魇' = @{
        status = 'reworked'
        s2Note = 'Renamed from Passing Down the Profit; now discounts Dispatch Center upgrade by -3 Funds per 3 [Sargon] Operators, and replaces 6-[Sargon] with S2''s team ATK buff.'
        effect = "Passive: After obtaining 3 [Sargon] Operators, the current Dispatch Center upgrade cost is reduced by -3 Funds (triggers at most once per Dispatch Center Level)`nReplaces <With 6 different [Sargon] Operators on field> with: When any [Sargon] Operator activates a skill, all [Sargon] Operators gain increased ATK"
    }
    '佩佩|博学多通' = @{
        status = 'unchanged'
        effect = "Passive: After upgrading the Dispatch Center to Lv. 2, 4, and 6, gain 1 special refresh that prioritizes offering [Sargon] Operators"
    }
    '洛洛|自发制造' = @{
        status = 'new'
        s2Note = 'New leader in Regulation; inherits S2 Narantuya''s 8-tile equipment sharing effect for 6 [Victoria] Operators.'
        effect = "Passive: For every 3 [Victoria] Operators purchased, obtain 1 random piece of Equipment (Tier cannot exceed current Dispatch Center Level)`nReplaces <With 6 different [Victoria] Operators on field> with: After a [Victoria] Operator activates a skill, Operators in the surrounding 8 tiles also gain the effects of the Equipment carried by that Operator for a period of time"
    }
    '哈洛德|人才盲盒' = @{
        status = 'unchanged'
        effect = "Passive: Starting from Round 4, obtain 1 [Victoria] Operator every 2 rounds (Tier cannot exceed current Dispatch Center Level)"
    }
    '歌蕾蒂娅|猎人战法' = @{
        status = 'new'
        effect = "Unlocks when Dispatch Center reaches Lv. 4`nTap to use (Cost 1): Obtain 1 [Ægir] Operator (Tier cannot exceed current Dispatch Center Level)`nReplaces <With 6 different [Ægir] Operators on field> with: The first 3 [Ægir] Operators defeated for the first time summon the rightmost [Ægir] Operator from the Bench that can be deployed on their tile"
    }
    '克莱门莎|崇高牺牲' = @{
        status = 'unchanged'
        effect = "Passive: When an [Ægir] Operator is defeated, adds stacks to the active [Ægir] Alliance equal to that Operator's Tier"
    }
    '焰尾|骑士团长' = @{
        status = 'new'
        s2Note = 'New leader in Regulation; replaces 6-[Kazimierz] with S2''s Kazimierz 6-op True damage & Stun effect.'
        effect = "Tap to use (Cost 6): Obtain 1 [Kazimierz] Operator (Tier cannot exceed current Dispatch Center Level); at the end of each round's Rest Phase, this Command's Funds cost is reduced by -2; resets after use and can be used again`nReplaces <With 6 different [Kazimierz] Operators on field> with: While blocking, [Kazimierz] Operators deal True damage and Stun nearby enemies every 2 seconds; while not blocking, attacks deal bonus True damage"
    }
    '玛恩纳|业务指标' = @{
        status = 'unchanged'
        effect = "Passive: For every 1 [Kazimierz] Operator purchased, gain +1 Funds at the start of the next round (up to 3 Funds per round)"
    }
    '耶拉|不融信念' = @{
        status = 'new'
        s2Note = 'New leader in Regulation; replaces 6-[Kjerag] with S2''s Kjerag 6-op chill gust every 25s.'
        effect = "Passive: Upon entering the Rest Phase on Rounds 4, 7, 10, and 13, obtain 1 <Kjeragi Nevermeltice>`n<Kjeragi Nevermeltice>: Dealing damage has a 12% chance to inflict Cold for 1.5 seconds`nReplaces <With 6 different [Kjerag] Operators on field> with: A chill gust blows across the battlefield every 25 seconds, inflicting Cold on enemies"
    }
    '休露丝|雪域礼赠' = @{
        status = 'unchanged'
        effect = "Passive: The first [Kjerag] Operator purchased each round costs 1 Funds"
    }
    '裁度|量体裁衣' = @{
        status = 'new'
        s2Note = 'New leader in Regulation; replaces 6-[Siracusa] with S2''s Siracusa 6-op Invisibility + True damage & Fear.'
        effect = "Passive: Gain 1 Funds after the first manual refresh each round`nReplaces <With 6 different [Siracusa] Operators on field> with: [Siracusa] Operators gain Invisibility on deployment; while Invisible and for 10 seconds after leaving Invisibility, attacks have a chance to deal True damage and inflict Fear"
    }
    '贾维|团伙行动' = @{
        status = 'modified'
        s2Note = 'Changed from every 6 refreshes (up to 2/round) in S2 to 4 refreshes (up to 1/round).'
        effect = "Passive: After manually refreshing the Dispatch Center 4 times within a round, obtain 1 [Siracusa] Operator (Tier cannot exceed current Dispatch Center Level; triggers at most once per round)"
    }
    '车尔尼|流动乐章' = @{
        status = 'new'
        effect = "Tap to use (Cost 1): Obtain 1 [Leithanien] Operator (Tier cannot exceed current Dispatch Center Level); each use permanently increases this Command's Funds cost by +1"
    }
    '怒潮凛冬|无惧风雪' = @{
        status = 'new'
        effect = "Tap to use (Cost 5): Obtain 1 [Ursus] Operator (Tier cannot exceed current Dispatch Center Level); each time an [Ursus] Operator is purchased, this Command's Funds cost is reduced by -1; resets after use and can be used again"
    }
    '引星棘刺|出航时刻' = @{
        status = 'new'
        effect = "Unlocks when active [Iberia] Operator count reaches 4`nDrag to use (Cost 1): Select an Operator in the Dispatch Center and replace them with an [Iberia] Operator of a Tier not exceeding that Operator's Tier (up to 2 times per round)"
    }
}

$cnStrats = LoadJson (Join-Path $cnDir 'strategies.json')
$enStrats = @()
foreach ($s in $cnStrats) {
    $key = "$($s.leader)|$($s.name)"
    $info = $stratData[$key]
    if (-not $info) { throw "Missing strategy translation for $key" }
    $enStrats += [ordered]@{
        cnLeader = $s.leader
        enLeader = $g.leaders.($s.leader)
        cnName   = $s.name
        enName   = $g.strategies.$key
        icon     = $stratIconMap[$s.leader]
        hp       = $s.hp
        status   = $info.status
        s2Note   = $(if ($info.s2Note) { $info.s2Note } else { '' })
        cnEffect = $s.effect
        enEffect = $info.effect
        cnUnlock = $s.unlock
        enUnlock = (TranslateUnlock $s.unlock)
    }
}
SaveJson $enStrats (Join-Path $enDir 'strategies.json')
"Translated $($enStrats.Count) strategies."
