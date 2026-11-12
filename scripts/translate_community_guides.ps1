# Translate the 20 extracted Skland community strategy guides into data/en/community_strategies.json.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$rawDir = Join-Path $root 'data\raw'
$enDir = Join-Path $root 'data\en'

function LoadJson($p) { Get-Content -Raw -Encoding UTF8 $p | ConvertFrom-Json }
function SaveJson($obj, $p) {
    [IO.File]::WriteAllText($p, (ConvertTo-Json -InputObject @($obj) -Depth 10), (New-Object Text.UTF8Encoding $false))
}

$g = LoadJson (Join-Path $root 'data\glossary.json')
$rawGuides = LoadJson (Join-Path $rawDir 'skland_guides.json')
$enOps = LoadJson (Join-Path $enDir 'operators.json')
$enEquips = LoadJson (Join-Path $enDir 'equipment.json')
$enStrats = LoadJson (Join-Path $enDir 'strategies.json')

# Build quick lookups by CN name
$opByCn = @{}
foreach ($o in $enOps) { $opByCn[$o.cnName] = $o }
# Alias 予愿安洁莉娜 -> 安洁莉娜
$opByCn['予愿安洁莉娜'] = $opByCn['安洁莉娜']

$eqByCn = @{}
foreach ($e in $enEquips) { $eqByCn[$e.cnName] = $e }

$stratByKey = @{}
foreach ($s in $enStrats) { $stratByKey["$($s.cnLeader)|$($s.cnName)"] = $s }

$tabTypeMap = @{
    '最终阵容' = 'Final Lineup'
    '阶段阵容 (1-3回合)' = 'Early Game (Rounds 1–3)'
    '阶段阵容 (1-7回合)' = 'Early–Mid Game (Rounds 1–7)'
    '阶段阵容 (4-7回合)' = 'Mid Game (Rounds 4–7)'
    '阶段阵容 (8-10回合)' = 'Mid–Late Game (Rounds 8–10)'
    '阶段阵容 (8-13回合)' = 'Late Game (Rounds 8–13)'
    '阶段阵容 (11-13回合)' = 'Endgame Transition (Rounds 11–13)'
}

# Curated English titles, scope notes, and phase gameplay notes per guide ID
$guideTranslations = @{
    '2120430515119446229' = @{
        enTitle = 'Kjerag Lv.4 Shop Infinite Truesilver Slash & Perma-Freeze Pramanix'
        archetype = 'Kjerag · Swift / Precision / Arcane'
        enScope = 'Stays at Dispatch Center Lv. 4–5; requires [Swift] and [Precision] unbanned.'
        enTabs = @(
            'Core carries are [SilverAsh the Reignfrost] and [Pramanix the Prerita]. Once [Swift] is online, SilverAsh can chain infinite Truesilver Slashes; give him a [Precision] Isomorph (Damazti Isomorph + Precision Scope) for +30% DEF/RES ignore. Pramanix the Prerita benefits from [Swift] + [Agile] + Warfarin''s SP trait to keep her skill active permanently while proccing [Arcane] bonus Arts damage—combining AoE grouping, anti-air, Freeze, and anti-Invisibility.'
        )
    }
    '2120358988790611711' = @{
        enTitle = 'The Witch King Arrives! 8-Leithanien Burst Carry'
        archetype = 'Leithanien · Arcane / Precision / Convergence'
        enScope = 'Can stay at Dispatch Center Lv. 4 for a long time to triple core 4-cost Casters.'
        enTabs = @(
            "Early game: Stack [Marvel] with Contrail + Ripresa, and pick up Defenders/Medics to preserve Life Points since core Medics are at Tier IV–V.`nLeveling pace: Upgrade to Lv. 3 on Round 5, and Lv. 4 before Round 8. Hold pairs to triple into Eyjafjalla the Hvít Aska and Viviana at Lv. 4 (or push Lv. 5 before Round 11).`nEquipment & Isomorphs: Give Damazti Isomorph + Leithanian Snare Drum to Archetto and Ho'olheyak first to reach 6–8 [Leithanien]. Extra Isomorphs can give Eyjafjalla [Agile] to stack with Warfarin.`nPositioning: Mid-game Archetto -> Ebenholz, Warfarin -> Ho'olheyak. Late-game Archetto -> Eyjafjalla the Hvít Aska, Warfarin -> Eyjafjalla.`nFinal synergies: 8 [Leithanien], 3 [Precision], 3 [Arcane], 2 [Convergence], 2 [Agile], 2 [Foresight], 2 [Marvel]."
        )
    }
    '2120035477467843899' = @{
        enTitle = 'Immortal 4-Slot "Rowdy Tin" Solo Carry (Lv.2 Reroll)'
        archetype = 'Flex · Agile / Precision / Foresight'
        enScope = 'Playable whenever [Agile] or [Precision] is unbanned (ideally [Agile] unbanned; [Foresight] is a great economy bonus).'
        enTabs = @(
            'Upgrade to Dispatch Center Lv. 2 on Round 2, then stay at Lv. 2 for up to 9 rounds hunting for Simple Communicators to duplicate "Rowdy Tin" (since it has no Alliance, Simple Communicator copies it directly!) until it promotes to Elite—keep a 4th copy if you find Doctor Hologram later. While at Lv. 2, pick up Greyy the Lightningbearer + Contrail to stack [Agile]/[Precision], Mitm on Bench for [Foresight], and triple into Archetto or Poncirus. Once [Agile] stacks are rolling, level to Lv. 4 for Siphoner''s Beak (lifesteal) and Lv. 5 for Damazti Isomorph + Precision Scope / Durable Shield so "Rowdy Tin" inherits 3–4 Alliance buffs across its 4 Equipment slots.'
        )
    }
    '2120373362380711053' = @{
        enTitle = '6-Kazimierz Raid & Resilient "Rowdy Tin" Boss Buster'
        archetype = 'Kazimierz · Raid / Resilient / Precision'
        enScope = 'Hard-counters Stealth/high-burst bosses with 6 [Kazimierz] + [Raid] + [Resilient].'
        enTabs = @(
            'Final setup: Activate 6 [Kazimierz]. Equip "Rowdy Tin" with Damazti Isomorph + Kazimierz Knightclub Pennant, Raid Grenade, and Mercenary Dog Tag.',
            'Rounds 1–7 (Early Game): Stay at Dispatch Center Lv. 2 looking for Simple Communicators to copy "Rowdy Tin". Activate early synergies: Greyy the Lightningbearer + Contrail ([Agile]), Contrail + Ripresa ([Marvel]), Archetto + Greyy ([Precision]), Varkáris + Gravel ([Resilient]), and Blemishine + Ethan ([Raid]).',
            'Rounds 8–13 (Mid–Late Game): Equip Damazti Isomorph on "Rowdy Tin" to reach 6 [Kazimierz] alongside Blemishine, Młynar, Gravel, Fartooth, and Nearl the Radiant Knight. Run Archetto + Ho''olheyak + Fartooth for 3 [Precision], Surtr/Entelechia + Gravel for [Resilient], and Blemishine + Surtr + Nearl for [Raid].'
        )
    }
    '2119688022455878781' = @{
        enTitle = 'No Tier VI Needed! Blue Poison 3-Precision Iberia Carry'
        archetype = 'Iberia · Precision / Arcane / Convergence'
        enScope = 'Budget-friendlyLv. 3–4 core; Blue Poison accounts for 50%+ of Boss DPS even at N15.'
        enTabs = @(
            'Pick strong tempo units early. After reaching Dispatch Center Lv. 3, roll for Homebound, Archetto, and Highmore (Weedy can sub if Highmore is missing). Activating 3 [Precision] on Elite Blue Poison (Skill 2) completely solves [Iberia]''s single-target Boss damage bottleneck without needing any Tier VI Operators.'
        )
    }
    '2119678702295243883' = @{
        enTitle = 'Effortless 6-Ursus & Swift/Arcane Steamroll'
        archetype = 'Ursus · Arcane / Swift'
        enScope = 'Uses Jessica''s Dispatch Modules on Rounds 4/7/10/13 to guaranteed-pull Ursus units.'
        enTabs = @(
            'Leveling curve: Upgrade to Lv. 2 on Round 3, Lv. 3 on Round 4–5, push Lv. 4 after finding Ho''olheyak, and push Lv. 5 after finding Тоска. Combines 6 [Ursus] damage-to-HP-loss conversion and blocking Arts DoT with [Arcane] and [Swift].'
        )
    }
    '2119659275765524488' = @{
        enTitle = 'Leithanien Arcane & Precision Tempo'
        archetype = 'Leithanien · Arcane / Precision / Convergence'
        enScope = 'Uses Czerny''s Strategy to steadily generate Leithanien units on demand.'
        enTabs = @(
            'Assemble 3 [Leithanien] with Czerny early to stabilize mid-game rounds and farm Leithanian Snare Drums, then push Dispatch Center Lv. 5 to complete 6 [Leithanien] with Viviana, Eyjafjalla the Hvít Aska, Logos, and Degenbrecher.'
        )
    }
    '2119646537562390695' = @{
        enTitle = 'Fortress Ægir: Aid + Durable Unkillable Wall'
        archetype = 'Ægir · Aid / Durable / Agile'
        enScope = 'Ideal when [Convergence] / Skadi the Corrupting Heart is unavailable; stacks massive HP and DEF.'
        enTabs = @(
            'When [Convergence] isn''t available, pair 6 [Ægir] with [Durable] (massive Max HP scaling + damage sharing) and [Aid] (high DEF scaling + end-of-round stacks to all active Alliances) using Roberta, Underflow, and Andreana. Mid-game is virtually impenetrable; in the final Boss fight, Clementia equipped with Bottled Volatile Reaction shreds Elemental burst bars.'
        )
    }
    '2119643616472469549' = @{
        enTitle = 'Power Promised by the Mountains: Compound Interest Kjerag'
        archetype = 'Kjerag · Arcane / Agile'
        enScope = 'Economy-driven Kjerag build using Cannot''s Compound Interest to fast-level.'
        enTabs = @(
            'Hold pairs while banking 5+ Funds for Cannot''s interest to level up quickly. Roll at Dispatch Center Lv. 4 for Gnosis (whose When-obtained refresh guarantees more Kjerag units) and triple into Lv. 5 Pramanix the Prerita and SilverAsh the Reignfrost.'
        )
    }
    '2120412783959272260' = @{
        enTitle = 'Why Agile-Arcane-Precision Sargon Is the Ultimate All-Rounder'
        archetype = 'Sargon · Precision / Arcane / Agile / Convergence'
        enScope = 'Requires [Sargon] unbanned; works fine even if one of [Precision], [Arcane], or [Agile] is banned.'
        enTabs = @(
            'Final composition: 3–6 [Sargon] + 3 [Precision] + 3 [Arcane] + 2 [Agile] + 2 [Convergence]. With Damazti Isomorph + Sargonian Teaspresso, you can convert Ho''olheyak into [Sargon] and Mantra/Logos into [Precision] to hit 6 [Sargon] Quicksand tiles while Pozëmka and Ho''olheyak melt everything.',
            'Rounds 1–3 (Early Game): Pick low-cost transition units like Specter, Frostleaf, Varkáris, GreyThroat, Contrail, Greyy the Lightningbearer, Click, and Miss.Christine to open [Arcane], [Precision], and [Agile] early. Hold onto Papyrus.',
            'Rounds 4–7 (Mid Game): Before pushing Lv. 4, pick up Archetto, Vigil, and Homebound to activate 3 [Precision].',
            'Rounds 8–10 (Scaling Phase): Roll at Lv. 4 for Ho''olheyak, Warfarin, Passenger, and Nightingale. Position Warfarin behind Ho''olheyak and Archetto behind your main stacker to turbo-charge [Precision] and [Arcane] stacks.',
            'Rounds 11–13 (Endgame Transition): Push Lv. 5 for Pozëmka, Pepe, and Mon3tr (who boosts surrounding stacking caps by +30%/+60%). Swap out pure stackers for high-rarity carries like Logos before the Boss round.'
        )
    }
    '2119628371243420138' = @{
        enTitle = 'Damazti Isomorph Kazimierz & Raid Surtr/Młynar'
        archetype = 'Kazimierz · Raid / Resilient / Precision / Swift'
        enScope = 'Strong whenever [Raid] and Hoederer are unbanned; convert into 6 [Kazimierz] before the Boss.'
        enTabs = @(
            'Early game: Transition with [Precision] + [Foresight] (give Mitm a Precision Isomorph and pair with Archetto) and [Swift] (Podenco, Meteorite, Poncirus). Blemishine with [Swift] or [Resilient] Isomorph can tank indefinitely.`nCore transition: Use Varkáris + Gravel/Blemishine to stack [Resilient] and Hoederer + Blemishine to stack [Raid]. In the late game, give Surtr a [Kazimierz] Isomorph (Damazti Isomorph + Kazimierz Knightclub Pennant) and give Elite Młynar (Skill 3) a Precision Scope, backed by Nearl the Radiant Knight and Civilight Eterna.'
        )
    }
    '2119600551361739936' = @{
        enTitle = 'Reforging Yan''s Glory: Wang 9-Yan Dual Yan''s Protection'
        archetype = 'Yan · Foresight / Elite'
        enScope = 'Uses Wang''s Strategy to convert spare Operators into Yan units and restore the 6/9-Yan summons.'
        enTabs = @(
            'Do not force Bison at Lv. 1; prioritize preserving HP until Dispatch Center Lv. 3–4. Give Mitm and Archetto [Yan] Isomorphs (Damazti Isomorph + Yanese Dagger) and position Archetto behind Shu to rapidly stack [Yan] and [Foresight]. Use Wang''s drag command to transform unused Operators into [Yan] Operators; if you find an HR File (+1 Deployment Limit), reach 9 [Yan] on the Boss round to summon two 1.5x ATK / 90% DR Yan''s Protections.'
        )
    }
    '2119597268695777131' = @{
        enTitle = 'Small-Synergy Agile & Precision Kjerag Freeze'
        archetype = 'Kjerag · Agile / Precision / Marvel'
        enScope = 'Focuses on 3 [Kjerag] + high [Agile]/[Precision] attack speed rather than forcing 6 [Kjerag].'
        enTabs = @(
            'Build around Contrail + Greyy the Lightningbearer + Snow Hunter + GreyThroat to activate 2 [Agile] and 3 [Precision] early while Contrail stacks [Marvel] for free refreshes. Add 3 [Kjerag] with Kjera (who generates Kjeragi Nevermeltice) and Pramanix (who stacks [Kjerag] every time an enemy is Frozen). With high [Agile] ASPD and Nevermeltice on ranged carries, enemies stay permanently Frozen.'
        )
    }
    '2120389865357667046' = @{
        enTitle = 'Lv.2 Reroll "Rowdy Tin" into 6-Victoria & Agile Boss Assassin'
        archetype = 'Victoria · Agile / Aid / Marvel'
        enScope = 'Best when [Victoria] and [Agile] (Contrail) are unbanned.'
        enTabs = @(
            'Phase 1 (Rounds 1–9): Upgrade to Lv. 2 on Round 2 and stay at Lv. 2 until upgrading costs 0–2 Funds. Use Simple Communicators to promote "Rowdy Tin" to Elite, stack [Agile] and [Marvel] with Contrail, and grab economy dolls + Iridescent Revitalizing Drink.`nPhase 2 (Late Game): Fast-level to Lv. 5, roll for Vina Victoria, Jessica the Liberated, and Stainless, and find Damazti Isomorph + any Victorian Hammer to turn "Rowdy Tin" into a [Victoria] Operator. With 6 [Victoria] (+80% ATK per upgraded equipment across 4 slots!), Siphoner''s Scythe, and Pallas''s [Agile] buff, "Rowdy Tin" melts Bosses single-handedly.'
        )
    }
    '2119572187623476444' = @{
        enTitle = 'Hyper-Agile 6-Victoria Pallas & Tragodia Max Cap'
        archetype = 'Victoria · Agile / Aid / Durable / Marvel'
        enScope = 'Pairs Mechanist''s free Equipment upgrades with Tragodia''s per-round Equipment generation.'
        enTabs = @(
            'Tragodia hands out free Equipment every round while Stainless upgrades them and Jessica the Liberated stacks [Victoria] and [Durable] for every equipped Operator on the field. Run 3 [Aid] + 2 [Durable] for a frontline wall, and give Pallas a [Victoria] Isomorph + Ultimate Victorian Hammer so she unleashes ultra-high-ASPD whips under 6 [Victoria].'
        )
    }
    '2119556635704697091' = @{
        enTitle = 'Leithanien & Precision Pallas / Ebenholz Dual Carry'
        archetype = 'Leithanien · Precision / Agile / Convergence'
        enScope = 'Uses Cannot''s Compound Interest to fund a high-rarity Leithanien + Precision board.'
        enTabs = @(
            'Combine 6 [Leithanien] (Ebenholz, Czerny, Eyjafjalla the Hvít Aska, Degenbrecher) with 3 [Precision] (Archetto, Greyy the Lightningbearer, Precision Scope + Damazti Isomorph) and Pallas + Nightingale for sustained AoE burst and Sanctuary.'
        )
    }
    '2119552220731015487' = @{
        enTitle = '3-Precision Siracusa: 200+ Stacks/Round Lappland the Decadenza'
        archetype = 'Siracusa · Precision / Elite'
        enScope = 'Chiave''s Strategy grants free Siracusa units every 4 refreshes; peaks at 700+ Siracusa stacks.'
        enTabs = @(
            'Core requirement is promoting Lappland the Decadenza to Elite (which shares her +4 [Siracusa] stacks per kill across ALL [Siracusa] Operators) and pairing her with Suzuran and Vulpisfoglia. Activate 3 [Precision] using Vigil + Archetto + a Precision Scope Isomorph so Lappland''s global wolves ignore 30% RES and trigger 6-[Siracusa]''s multi-status AoE True damage.'
        )
    }
    '2119645040845374130' = @{
        enTitle = 'Easy 400+ Stacks: Yan-Arcane-Precision-Swift Victoria (Blaze Alter Carry)'
        archetype = 'Victoria · Arcane / Precision / Foresight'
        enScope = 'Recommended when [Precision], [Arcane], and [Victoria] are available.'
        enTabs = @(
            'Use Damazti Cluster''s free Isomorphs to bridge [Victoria], [Yan], [Arcane], [Precision], and [Swift]. Archetto + Ho''olheyak + Dusk rapidly stack Alliances while Blaze the Igniting Spark (who natively holds [Yan], [Victoria], and [Swift]) scales from both Elemental Damage bursts and 6-[Victoria] Equipment multipliers.'
        )
    }
    '2120165028755480406' = @{
        enTitle = 'Harmony Pith + Agile & Aid 6-Ægir Scaling'
        archetype = 'Ægir · Aid / Agile / Convergence / Harmony'
        enScope = 'Uses Pith''s [Harmony] Alliance (+1 to Core Alliance count) for smooth 6-Ægir activation.'
        enTabs = @(
            'Activate [Aid] early so every Rest Phase adds stacks to [Agile] and [Ægir]. Level smoothly (Lv. 2 on R2, Lv. 3 on R4–5, Lv. 4 on R6–7, Lv. 5 on R8–9, Lv. 6 on R10–11). Use Pith + 2 Defenders as devour fodder early, then transition into Mizuki + Warfarin + Pallas + Ulpianus + Skadi the Corrupting Heart + Clementia.'
        )
    }
    '2119975763311388699' = @{
        enTitle = '9000+ ATK Eyjafjalla: 3-Precision 3-Arcane Leithanien (Ch''en Weakness)'
        archetype = 'Leithanien · Arcane / Precision / Convergence'
        enScope = 'Requires Ho''olheyak unbanned; does not need 6 [Leithanien] or Tier VI Degenbrecher.'
        enTabs = @(
            'Built around 3 [Precision] + 3 [Arcane] + Ch''en''s Weakness damage Strategy rather than forcing 6 [Leithanien]. The only essential low-tier Leithanien unit is Czerny for his Leithanian Snare Drum (give Drums to Ho''olheyak and Archetto). Roll at Dispatch Center Lv. 3–4 to promote Archetto, Ebenholz, Ho''olheyak, and Eyjafjalla. Position Ebenholz in front of Archetto during mid-game rounds to stack [Precision], then move Eyjafjalla in front of Archetto to stack [Arcane] for Boss rounds—reaching 9,000+ ATK on Eyjafjalla.'
        )
    }
}

$enGuides = @()
foreach ($raw in $rawGuides) {
    $tr = $guideTranslations[$raw.id]
    if (-not $tr) { throw "Missing translation for guide $($raw.id)" }

    $strats = @()
    foreach ($st in $raw.strategies) {
        $sObj = $stratByKey["$($st.initiator)|$($st.name)"]
        if (-not $sObj) { throw "Missing strategy $($st.initiator)|$($st.name)" }
        $strats += [ordered]@{
            cnLeader = $sObj.cnLeader
            enLeader = $sObj.enLeader
            cnName   = $sObj.cnName
            enName   = $sObj.enName
            icon     = $sObj.icon
            enEffect = $sObj.enEffect
        }
    }

    $tabs = @()
    for ($ti = 0; $ti -lt $raw.tabs.Count; $ti++) {
        $tb = $raw.tabs[$ti]
        $chars = @()
        foreach ($ch in $tb.chars) {
            $oObj = $opByCn[$ch.name]
            if (-not $oObj) { throw "Missing operator $($ch.name)" }
            $chars += [ordered]@{
                cnName      = $oObj.cnName
                enName      = $oObj.enName
                tier        = $oObj.tier
                icon        = $oObj.icon
                isElite     = [bool]$ch.isElite
                enAlliances = $oObj.enAlliances
                cnSkill     = $ch.skill
            }
        }
        $items = @()
        foreach ($it in $tb.items) {
            $eObj = $eqByCn[$it]
            if (-not $eObj) { throw "Missing equipment $it" }
            $items += [ordered]@{
                cnName     = $eObj.cnName
                enName     = $eObj.enName
                tier       = $eObj.tier
                icon       = $eObj.icon
                isomorphEn = $eObj.isomorphEn
                enEffect   = $eObj.enEffect
            }
        }
        $sBonds = @($tb.seasonBonds | Where-Object { $_ } | ForEach-Object { $g.alliances.$_ })
        $rBonds = @($tb.regularBonds | Where-Object { $_ } | ForEach-Object { $g.alliances.$_ })
        $enNote = $(if ($ti -lt $tr.enTabs.Count) { $tr.enTabs[$ti] } else { $tr.enTabs[0] })

        $tabs += [ordered]@{
            cnType       = $tb.type
            enType       = $(if ($tabTypeMap[$tb.type]) { $tabTypeMap[$tb.type] } else { $tb.type })
            seasonBonds  = $sBonds
            regularBonds = $rBonds
            allAlliances = @($sBonds) + @($rBonds)
            chars        = $chars
            items        = $items
            cnIdea       = $tb.idea
            enIdea       = $enNote
        }
    }

    $enGuides += [ordered]@{
        id         = $raw.id
        cnTitle    = $raw.title
        enTitle    = $tr.enTitle
        archetype  = $tr.archetype
        author     = $raw.author
        collects   = [int]$raw.stats.collects
        likes      = [int]$raw.stats.likes
        views      = [int]$raw.stats.views
        cnScope    = $raw.applicableScope
        enScope    = $tr.enScope
        strategies = $strats
        tabs       = $tabs
    }
}

SaveJson $enGuides (Join-Path $enDir 'community_strategies.json')
"Translated $($enGuides.Count) community strategy guides."
