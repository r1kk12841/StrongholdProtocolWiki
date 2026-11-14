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
# DIY / Custom Roster Operators supported in Stronghold Protocol Regulation
$opByCn['赤刃明霄陈'] = [pscustomobject]@{
    cnName      = '赤刃明霄陈'
    enName      = "Ch'en the Dawnstreak (DIY)"
    tier        = 5
    icon        = 'https://web.hycdn.cn/arknights/game/assets/char/avatar/char_1050_chen3.png'
    enAlliances = @('Yan')
}
$opByCn['结城理'] = [pscustomobject]@{
    cnName      = '结城理'
    enName      = 'Makoto Yuki (DIY)'
    tier        = 5
    icon        = 'https://web.hycdn.cn/arknights/game/assets/char/avatar/char_4217_makoto.png'
    enAlliances = @('Reserve Operator')
}

$eqByCn = @{}
foreach ($e in $enEquips) { $eqByCn[$e.cnName] = $e }

$stratByKey = @{}
foreach ($s in $enStrats) { $stratByKey["$($s.cnLeader)|$($s.cnName)"] = $s }

function Translate-TabType([string]$cnType) {
    if ($cnType -eq '最终阵容') { return 'Final Lineup' }
    if ($cnType -match '^阶段阵容\s*\((\d+)-(\d+)回合\)$') {
        $r1 = [int]$Matches[1]
        $r2 = [int]$Matches[2]
        if ($r1 -eq $r2) { return "Round $r1 Lineup" }
        return "Phase Lineup (Rounds $r1–$r2)"
    }
    return 'Phase Lineup'
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
    '2120533571300941655' = @{
        enTitle = '300+ Stack Agile & Investor Yan Carry (Qiubai + Warfarin Engine)'
        archetype = 'Yan · Agile / Investor / Durable / Convergence'
        enScope = 'Playable whenever [Yan] and Warfarin are unbanned; slot Ch''en the Dawnstreak in the Tier V DIY slot.'
        enTabs = @(
            'Buy 2–3 Operators on Round 1 and upgrade to Lv. 3 on Round 3. Take 1-Fund bounties early while holding pairs (do not merge until Lv. 4!). Push Lv. 4 on Round 5–6 and triple into Windflit, Yu, Qiubai, and Warfarin. Point Warfarin at Qiubai (Skill 1) to rapidly stack both [Agile] and [Yan], while Saria stacks [Convergence]. Activate 3 [Investor] (Lee, SilverAsh the Reignfrost, Closure) for massive economy, and finish with Dusk, Blaze the Igniting Spark, or Ch''en the Dawnstreak (DIY).'
        )
    }
    '2120810432295978586' = @{
        enTitle = 'Durable Dynasty: New-Meta 6-Victoria & Swift/Agile Scaling'
        archetype = 'Victoria · Durable / Swift / Agile / Convergence'
        enScope = 'Zero competition for Precision/Arcane units in co-op; combines 3–6 [Victoria] with 80+ stacks/round of [Durable].'
        enTabs = @(
            'Jessica the Liberated is the true stacking engine of [Victoria], gaining stacks based on the number of equipped Operators on the field. Hold Tier I pairs on Rounds 1–3 (skipping Tier II), buy Equipment on Round 2, and triple into Lv. 4 Jessica the Liberated and Stainless on Round 4. Between Rounds 4–7, add Roberta + Qingzhi for 3 [Durable], Stainless for [Aid] + free Equipment upgrades, and Ripresa + Warfarin + Nightingale for [Agile] and [Convergence]. On Rounds 9–10, roll at Lv. 5 for Saria to double Jessica''s stacking speed (70+ [Victoria] and 80+ [Durable] stacks per round!), then cap out at Lv. 6 with Blaze the Igniting Spark.',
            'Round 1 Equipment generators: Pick Operators like Greyy the Lightningbearer, Kjera, Czerny, Olga, Carnelian, Catherine, Passenger, or Muelsyse so every ally holds at least 1 piece of Equipment early.',
            'Rounds 3–5 triples: Prioritize tripling into Tier IV Jessica the Liberated first, followed by Stainless, Warfarin, and Nightingale.',
            'Rounds 8–10 (Lv. 5 core): Saria is the #1 priority at Tier V to double Jessica the Liberated''s stacking trigger.',
            'Round 13 Endgame: Pick up Muelsyse (for Damazti Isomorph) and Blaze the Igniting Spark as your primary 6-[Victoria] + [Swift] carry.'
        )
    }
    '2120569391147659132' = @{
        enTitle = 'Penance Tailor-Made: Classic 3-Precision Siracusa Tempo'
        archetype = 'Siracusa · Precision / Marvel / Elite'
        enScope = 'Playable whenever [Siracusa] and Archetto are available.'
        enTabs = @(
            'Use Penance''s [Tailor-Made] refresh on Round 1 to grab Lappland or pairs. Hold pairs at Lv. 2 and triple into Tier III Vigil and Vulpisfoglia, plus Archetto (give Archetto a Siracusan Formal Suit Isomorph). At Lv. 4, pick up Ho''olheyak for 3 [Precision] and Angelina for free refreshes + Freeze. Position Archetto behind Vigil so Vigil''s kills stack [Siracusa] and [Precision] simultaneously, then transition into Lappland the Decadenza and Bellone at Lv. 5–6.',
            'Mid-game priority pool: Lappland, Aosta, Encore, Vulpisfoglia, Vigil, Angelina, Suzuran, Bellone, Lappland the Decadenza, GreyThroat, Contrail, Greyy the Lightningbearer, Archetto, Ho''olheyak, and Muelsyse.'
        )
    }
    '2120452489534216593' = @{
        enTitle = 'Hyper-Agile Olga Carry: Ursus + Swift + Precision Boss Slayer'
        archetype = 'Ursus · Agile / Swift / Precision / Arcane'
        enScope = 'Requires [Ursus] and [Agile] unbanned, plus Warfarin/Pallas and Тоска.'
        enTabs = @(
            'Why Olga carries: She natively holds [Ursus] (high ATK & HP scaling) and [Agile] (high ASPD), her Skill 1 is a low-SP Power Strike that chains non-stop with [Swift], and her Stronghold trait grants 130% ATK when unblocked plus bonus Boss damage. Point Warfarin or Pallas at Olga around Round 10 to push 40+ [Agile] stacks, pair with Тоска for [Swift], and give Olga a [Precision] Isomorph for explosive Boss DPS.',
            'Rounds 1–3: Open 3 [Ursus] early with Istina, Leto, Varkáris, and Uchu, alongside Greyy the Lightningbearer + Contrail + GreyThroat for [Precision]/[Agile] tempo.',
            'Rounds 4–7: Push Dispatch Center levels to find Olga, Zima the Raging Tide, and Тоска while bridging with Hoederer + Hellagur ([Raid]).',
            'Rounds 8–13: Buff Olga with Warfarin + Pallas to cap [Agile], stack [Swift] with Тоска, and add Talulah, Nymph, and Logos for the final Boss fight.'
        )
    }
    '2120392178422509756' = @{
        enTitle = 'Lv.2 Reroll Iberia: Homebound + Highmore + Blue Poison Carry'
        archetype = 'Iberia · Precision / Arcane / Convergence'
        enScope = 'Strong mid-game stabilizer and Boss killer using Encore''s Duet.'
        enTabs = @(
            'Position Homebound facing Highmore and Ho''olheyak to stack [Iberia] and [Precision], with Archetto behind Homebound/Ho''olheyak. Lumen + Rose Salt naturally activate [Convergence] for teamwide sustain while Elite Blue Poison and Thorns shred Bosses.',
            'Rounds 1–7: Collect pairs on Rounds 1–2, upgrade to Lv. 2 on Round 3, and triple into Homebound, Highmore, and Archetto to activate 3 [Iberia], 2 [Convergence], and 3 [Precision]. Give Stronghold Recommendation Letters to Homebound.',
            'Rounds 8–13: Push Lv. 3–4 on Rounds 7–11 to triple into Ho''olheyak, Lumen, Weedy, and Thorns (completing 6 [Iberia]), then push Lv. 5 on Round 13 for Muelsyse''s Isomorphs.'
        )
    }
    '2120791525858532959' = @{
        enTitle = 'Ultimate Co-op Babysitter: 6-Sargon Arcane + Agile Quicksand Wall'
        archetype = 'Sargon · Arcane / Convergence / Agile'
        enScope = 'Designed for 4-player co-op to solo-defend leaks across all mid-game waves.'
        enTabs = @(
            'Built around Pepe, Pozëmka, Papyrus, Passenger, Warfarin, Pallas, Logos, and Mantra. Creates screen-wide 6-[Sargon] Quicksand tiles with [Arcane], [Agile], and [Convergence] to effortlessly clear leaked waves for 3 teammates while scaling into late-game.'
        )
    }
    '2120584153495170043' = @{
        enTitle = 'Formulaic Lv.4 Yan (Wang Strategy): Guaranteed 400–800+ Yan Stacks'
        archetype = 'Yan · Durable / Elite'
        enScope = 'Solo N20 & Co-op viable; comes online by Round 8–10 using Wang''s [Black and White] Strategy.'
        enTabs = @(
            'Round 1: Buy 2 ground units (prioritize Bison). Round 2: Upgrade to Lv. 2. Rounds 3–4: Use Wang''s Strategy to transform spare Operators into Tier I Bison and Tier II Ju, tripling them to discover Tier III Windflit! Rounds 5–6: Stay at Lv. 3 (where only Tier I–III units appear) to guarantee Elite Windflit and triple cheap 2-Fund units into Tier IV Yu and Qiubai. Rounds 7–8+: Upgrade to Lv. 4, roll for Yu and Qiubai, and triple into Tier V Saria and Shu/Ch''en the Dawnstreak. Point Saria at Elite Windflit to duplicate Windflit''s stacking (up to 80–112 [Yan] stacks per round!) while 6-[Yan] summons Yan''s Protection.'
        )
    }
    '2120347885739573867' = @{
        enTitle = 'Makoto Yuki (DIY) Kjerag & Precision Stealth Boss Counter'
        archetype = 'Kjerag · Precision / Harmony / Elite'
        enScope = 'Slots Makoto Yuki in the DIY slot to solve Kjerag''s frontline survival and Stealth Boss matchups.'
        enTabs = @(
            'Combines 6 [Kjerag] (Pramanix the Prerita, Pramanix, Snow Hunter) and 3 [Precision] (Archetto, Snow Hunter) with Civilight Eterna ([Harmony]), Degenbrecher, and DIY Makoto Yuki to tank and burst down Stealth Bosses while keeping enemies permanently Frozen.'
        )
    }
    '2120532720267511521' = @{
        enTitle = 'Encore Duet Leithanien: Flexible Arcane + Precision + Convergence'
        archetype = 'Leithanien · Arcane / Precision / Convergence'
        enScope = 'Highly adaptable economy tempo using Encore''s extra Elite promotion rewards.'
        enTabs = @(
            'Hold Tier I pairs on Rounds 1–3 without leveling, then level on Round 4 to trigger Encore''s [Duet] double discovery rewards. Prioritize 6 [Leithanien] + 3 [Arcane] + 3 [Precision] + 3 [Convergence] around Eyjafjalla (main Boss carry with RES shred from 3 Arcane & 3 Precision), Ebenholz, Ho''olheyak, Eyjafjalla the Hvít Aska, Viviana, Rosmontis, Warfarin, Nightingale, and Haruka. Stay at Lv. 5 and discover Tier VI Muelsyse via triples rather than paying for Lv. 6.',
            'Rounds 4–5 (Early–Mid Game): Discover Ho''olheyak, Ebenholz, Eyjafjalla, Warfarin, Nightingale, and Czerny (for Leithanian Snare Drum).',
            'Rounds 7–9 (Mid–Late Game): Add Eyjafjalla the Hvít Aska, Viviana, Astgenne the Lightchaser, Mon3tr, and Rosmontis (or pivot to Sargon if Pozëmka + Pepe appear early).',
            'Rounds 10–11 (Endgame): Discover Muelsyse, Logos, and Haruka via Lv. 5 triples.'
        )
    }
    '2120631706519804614' = @{
        enTitle = '999-Stack Ursus + Swift Ho''olheyak & Talulah (80% Damage Share)'
        archetype = 'Ursus · Arcane / Precision / Swift / Convergence'
        enScope = 'All-environment build combining [Convergence] sustain, [Foresight]/[Marvel] economy, and 999 [Ursus].'
        enTabs = @(
            'Combines [Ursus] (Talulah, Тоска, Zima the Raging Tide, Uchu) with [Precision], [Swift], and [Arcane] (Ho''olheyak, Archetto, Nymph) plus [Convergence] (Haruka). High-[Swift] Ho''olheyak permanently levitates heavy elites while Talulah and Тоска convert massive [Ursus] stacks into Boss-melting damage.'
        )
    }
    '2121069219205484656' = @{
        enTitle = 'Beginner-Friendly Damazti Isomorph Leithanien (Arcane + Precision)'
        archetype = 'Leithanien · Arcane / Precision / Convergence / Foresight'
        enScope = 'Playable whenever [Leithanien], Ho''olheyak, and Archetto are unbanned.'
        enTabs = @(
            'Damazti Cluster guarantees two Damazti Isomorphs by Round 14. Rush Dispatch Center Lv. 3–4 to find Ho''olheyak and Archetto, and combine your first Damazti Isomorph with Czerny''s Leithanian Snare Drum on Ho''olheyak so she simultaneously stacks [Leithanien], [Precision], and [Arcane]! Stay at Lv. 4 to complete your core, then push Lv. 5 to discover Haruka and Logos.',
            'Rounds 1–4: Level to Lv. 2 on Round 2 and Lv. 3 on Rounds 3–5. Pick up Greyy the Lightningbearer (for Precision Scope), Archetto + Mitm (facing each other to stack [Foresight] + [Precision]), Encore, and Czerny (for Leithanian Snare Drum).',
            'Rounds 5–7: Triple into Ho''olheyak, Eyjafjalla, and Ebenholz, then push Lv. 4. Place Ebenholz forward and point Archetto + Mitm at Ho''olheyak.',
            'Rounds 8–11: Camp at Lv. 4 to assemble 6 [Leithanien] + 3 [Arcane] + 3 [Precision] and triple into Eyjafjalla the Hvít Aska and Viviana.',
            'Rounds 12–13: Push Lv. 5 to discover Logos, Haruka, and Muelsyse; activate 3 [Convergence] if Boss damage is high.'
        )
    }
    '2120364902949604089' = @{
        enTitle = 'Bandit King Bison: Express Delivery 700+ Stack Yan'
        archetype = 'Yan · Arcane / Convergence / Durable / Foresight'
        enScope = 'Requires [Yan] unbanned; pairs best with [Foresight] economy.'
        enTabs = @(
            'Rush Dispatch Center Lv. 3 so Bison''s [Express Delivery] Strategy (Cost 3: steal 2 random Operators from the shop!) becomes net-positive every round. Find Windflit at Lv. 3, then push Lv. 4 where [Express Delivery] steals 3 Operators per activation! Stabilize mid-game with Qiubai (Skill 3) and Yu (Skill 2), triple into Saria and Shu (pointing Saria at Windflit to double [Yan] stacks), and finish at Lv. 5–6 with Dusk, Logos, and Haruka for 700+ [Yan] stacks and 400+ [Convergence] stacks.'
        )
    }
    '2120814003258317698' = @{
        enTitle = 'Immortal Damazti Iberia: Precision Weedy + Homebound + Durable'
        archetype = 'Iberia · Precision / Convergence / Durable / Aid'
        enScope = 'Great when Homebound/Highmore and Precision Scope appear early.'
        enTabs = @(
            'Equip Weedy (or Highmore) with Damazti Isomorph + Precision Scope to make her a [Precision] Operator, then point Homebound (with Trusty Pocketwatch) at Weedy so every activation simultaneously stacks [Iberia], [Precision], and [Durable]! Add Archetto/Rosmontis for 3 [Precision], Lumen + Rose Salt for [Convergence], and Roberta for [Durable] + [Aid] to become unkillable while burning down enemies with boosted Iberia DoT.'
        )
    }
    '2120780115845514213' = @{
        enTitle = 'Ursus + Resilient + Agile "Rowdy Tin" Juggernaut'
        archetype = 'Ursus · Resilient / Agile / Marvel'
        enScope = 'Requires Gravel and Kazemaru unbanned; pair with anti-air teammates in co-op.'
        enTabs = @(
            'Upgrade to Lv. 2 on Round 2 to hunt for Simple Communicators (to Elite "Rowdy Tin"), Gravel + Varkáris (for [Resilient]), and Contrail (for [Agile] + [Marvel]). Triple into Olga (who grants an Ursus Respirator for "Rowdy Tin") and Kazemaru. Once "Rowdy Tin" hits Elite, fast-level to Lv. 5 for Talulah and Zima the Raging Tide, equipping "Rowdy Tin" with Siphoner''s Scythe and Kinetic Accelerator.'
        )
    }
    '2121060326347819607' = @{
        enTitle = 'N20 Ultimate Difficulty: 3-Durable 2-Aid 2-Agile Ægir'
        archetype = 'Ægir · Durable / Aid / Agile / Convergence'
        enScope = 'Requires Contrail ([Agile]) and Roberta ([Durable]/[Aid]) unbanned; built around Clementia''s Strategy.'
        enTabs = @(
            'Instead of forcing 6 [Ægir], this N20 build runs 3 [Ægir] (Underflow, Mizuki, Skadi the Corrupting Heart, Clementia) alongside 3 [Durable] (Underflow, Roberta, Cuora/Saria), 2 [Aid] (Mizuki, Roberta), and 2 [Agile] (Contrail, Pallas/Warfarin). Upgrade to Lv. 2 on Round 3 to triple into Roberta and Andreana; place Roberta on a crowded row to passively stack [Durable] and [Aid] every round, then push Lv. 4–6 for Skadi the Corrupting Heart, Clementia, and Pallas.'
        )
    }
    '2120712711453354036' = @{
        enTitle = 'Emperor Urgent Dispatch: 3-Resilient 6-Kazimierz Młynar'
        archetype = 'Kazimierz · Resilient / Raid / Elite'
        enScope = 'Requires [Resilient] and [Kazimierz] unbanned; uses Emperor''s Strategy to guarantee Resilient stackers.'
        enTabs = @(
            '3 [Resilient] grants 100% instant revival for ground Operators plus SP recovery on death, allowing Elite Młynar, Nearl the Radiant Knight, and Viviana to cycle skills non-stop without dying.',
            'Rounds 1–6: Prioritize Varkáris, Gravel, and Kazemaru to start stacking [Resilient] immediately, picking up Blemishine and Ethan along the way.',
            'Rounds 7–9: Pick up Blemishine, Fang the Fire-sharpened, and Młynar to keep 3 [Kazimierz] and [Resilient] scaling.',
            'Rounds 10–12: Add Viviana and Flametail (or Fartooth) to push toward 6 [Kazimierz].',
            'Round 13: Add Nearl the Radiant Knight and give Młynar a [Raid] Isomorph for Boss burst.'
        )
    }
    '2120375415002250452' = @{
        enTitle = 'Instant 999-Stack Ursus: Resilient "Rowdy Tin" + Talulah'
        archetype = 'Ursus · Resilient / Marvel / Agile'
        enScope = 'Uses Eunectes''s "Rowdy Tin" with [Ursus], [Precision], [Agile], and [Swift] Isomorphs.'
        enTabs = @(
            'Does not require 6 [Ursus]; built around 3 [Ursus] (Olga, Talulah, Zima the Raging Tide, Тоска) + [Resilient] (Gravel) + [Marvel]/[Agile] (Contrail) + Archetto. Equip "Rowdy Tin" with [Ursus], [Precision], [Agile], and [Swift] items so its skill friendly-fire repeatedly triggers Gravel''s [Resilient] revives and Talulah''s temporary [Ursus] stacks—instantly hitting 999 [Ursus] stacks!'
        )
    }
    '2120732577468416600' = @{
        enTitle = 'Sussurro Lv.3 Reroll Iberia: Dual Elite Blue Poison Carry'
        archetype = 'Iberia · Convergence / Durable / Elite'
        enScope = 'Stays at Dispatch Center Lv. 3 to Elite-promote the entire Iberia core.'
        enTabs = @(
            'Final lineup runs 6 [Iberia] + 2 [Convergence] + 2 [Durable], using the 8th deployment slot for a second Elite fully-equipped Blue Poison!',
            'Rounds 1–4: Pick Indigo, Blue Poison, Rose Salt, Podenco, and Cuora to stabilize early waves.',
            'Rounds 5–10: Upgrade to Lv. 3 on Round 5 and roll for Elite Homebound, Highmore, Blue Poison, Rose Salt, Lumen, and Czerny. Give Czerny''s Leithanian Snare Drum and Sussurro''s [Mandatory Rest] Strategy to Homebound for rapid [Iberia] stacking.',
            'Rounds 11–13: Once all Tier I–III Iberia units are Elite, upgrade to Lv. 4 to add Weedy for 6 [Iberia] and roll for Equipment upgrades.'
        )
    }
    '2120705819388210673' = @{
        enTitle = 'Victorian Isomorph Archetto: 6-Victoria + 3-Precision Nuker'
        archetype = 'Victoria · Precision / Agile / Convergence / Durable'
        enScope = 'Requires [Victoria] and Archetto/Ho''olheyak unbanned.'
        enTabs = @(
            'Use your Round 5 Damazti Isomorph to turn Elite Archetto into a [Victoria] Operator, and your Round 10 Damazti Isomorph to give Ho''olheyak [Agile] (or [Victoria]). Surround Ho''olheyak with Warfarin, Saria, and Mon3tr while Jessica the Liberated stacks [Victoria] and [Durable]. With 6 [Victoria] (+80% ATK per upgraded Equipment) and 3 [Precision], Elite Archetto''s multi-hit skill obliterates waves and Bosses.'
        )
    }
    '2120686752861772000' = @{
        enTitle = 'Mid-Game Carry: Cold-Wind 6-Kjerag + Тоска + Precision'
        archetype = 'Kjerag · Precision / Arcane / Swift'
        enScope = 'Uses Kjera''s [Unmelting Faith] Strategy when [Kjerag] and [Precision] are unbanned.'
        enTabs = @(
            'Overlap the attack ranges of 5-star Pramanix, 6-star Pramanix the Prerita, and Тоска to gain 40–60 [Kjerag] stacks per round while chaining Freeze and SP recovery. Give Precision Scopes to Snow Hunter for massive Boss crits, and add Ho''olheyak + Archetto for 3 [Precision] and [Arcane]. Keep [Kjerag] stacks around 350–400 so enemies don''t get perma-frozen outside your main kill zone.',
            'Rounds 8–11 transition: Matterhorn, Pramanix, Snow Hunter, Harold, Aurora, Gnosis, Pramanix the Prerita, Archetto, Santalla, Тоска, and Greyy the Lightningbearer.'
        )
    }
    '2120375016550949346' = @{
        enTitle = 'Pure 6-Ægir Fast-Level Tempo (Pith Honors Student)'
        archetype = 'Ægir · Harmony / Elite'
        enScope = 'Playable whenever [Ægir] is unbanned; uses Pith''s [Harmony] bond to bridge 6 [Ægir].'
        enTabs = @(
            'Hold levels on Rounds 1–3 to win the Round 3 bounty, then fast-level to Dispatch Center Lv. 4 to find Specter the Unchained, Mizuki, and Skadi. Once stabilized, push Lv. 5–6 for Ulpianus, Clementia, and Skadi the Corrupting Heart, using Pith ([Alliance Supporter]) for [Harmony] and picking up Olga/Catherine/Stainless to gear up your 6-[Ægir] carries.'
        )
    }
    '2121159884887595892' = @{
        enTitle = '2-Unit Core! Lv.2 Reroll 5-Scope "Rowdy Tin" + Contrail'
        archetype = 'Flex · Agile / Precision / Convergence / Durable'
        enScope = 'Playable whenever Contrail and Greyy the Lightningbearer are unbanned.'
        enTabs = @(
            'Upgrade to Dispatch Center Lv. 2 on Round 2 and stay at Lv. 2! Repeatedly buy and sell Greyy the Lightningbearer to farm 5+ Precision Scopes for "Rowdy Tin" (each Precision Scope stacks multiplicatively at max range!), stack [Agile] and [Marvel] with multiple Contrails, and use Simple Communicators to promote "Rowdy Tin" to Elite. Once fully geared, push Lv. 4 to add Nightingale + Warfarin + Roberta for 3 [Convergence] and [Durable] sustain.',
            'Rounds 1–10 Core Trio: Greyy the Lightningbearer, Contrail, and "Rowdy Tin".'
        )
    }
    '2120729415810155998' = @{
        enTitle = 'Marvel + Siracusa Infinite Shop Refresh (Chiave Strategy)'
        archetype = 'Siracusa · Marvel / Precision / Elite'
        enScope = 'Combines Chiave''s [Gang Action] free Siracusa units every 4 refreshes with [Marvel] free refreshes.'
        enTabs = @(
            'Pair Encore + Contrail ([Marvel]) with 3 [Siracusa] early so every [Marvel] free refresh advances Chiave''s [Gang Action] counter! Add Vigil, Archetto, and Ho''olheyak in the mid-game to activate and stack 3 [Precision], then roll infinitely at high Dispatch Center levels with Suzuran + Vulpisfoglia + Angelina to Elite-promote Lappland the Decadenza, Pozëmka, Bellone, and Lemuen.'
        )
    }
    '2120682538161729315' = @{
        enTitle = 'Dual-Core Hybrid: 6-Leithanien + Siracusa Lappland Carry'
        archetype = 'Leithanien · Siracusa / Convergence / Precision / Marvel'
        enScope = 'Requires [Leithanien] and [Siracusa] unbanned; uses Civilight Eterna''s [Harmony].'
        enTabs = @(
            'Stack [Siracusa] and [Leithanien] early with Vigil and Ebenholz, then use Encore''s [Duet] at Lv. 5 to discover Lappland the Decadenza, Civilight Eterna ([Harmony]), Haruka, and Muelsyse. Give Lappland the Decadenza a [Leithanien] Isomorph (Damazti Isomorph + Leithanian Snare Drum) so her global wolves trigger both [Siracusa] and 6-[Leithanien] bonuses while Haruka + Eyjafjalla the Hvít Aska sustain the squad.'
        )
    }
    '2121151107620702444' = @{
        enTitle = 'Double-Drum Santalla: Instant Max-Stack Kjerag (Jessica Strategy)'
        archetype = 'Kjerag · Foresight / Precision / Agile / Convergence'
        enScope = 'Requires [Foresight] and Santalla unbanned; uses Jessica''s Dispatch Modules.'
        enTabs = @(
            'Core trick: Equip Santalla with two Leithanian Snare Drums (+8 SP per enemy death in range). Because Santalla''s Freeze duration is short and her skill cycles non-stop with double Snare Drums, she Refreezes enemies repeatedly to skyrocket [Kjerag] stacks in a single wave! Pair with Haruka + Eyjafjalla the Hvít Aska ([Convergence] + 30% Sanctuary), Gnosis (40% Fragile), Pramanix the Prerita, SilverAsh the Reignfrost, and a [Kjerag]-Isomorph Logos.',
            'Rounds 1–5: Win 2+ Fund bounties and curve smoothly to Dispatch Center Lv. 4 by Round 5.',
            'Rounds 6–9 (Lv. 4 Spike): Find Santalla, Czerny (for two Leithanian Snare Drums), Archetto ([Foresight] + [Precision]), and Warfarin + Qiubai ([Agile]). Use Jessica''s Dispatch Modules on [Investor] or [Kjerag] units to hit SilverAsh the Reignfrost and Pramanix the Prerita at Lv. 5.'
        )
    }
    '2121053890782422050' = @{
        enTitle = 'Formulaic 999-Ursus + 6-Kazimierz + Resilient "Rowdy Tin"'
        archetype = 'Kazimierz · Ursus / Resilient / Agile'
        enScope = 'Works whenever [Kazimierz] + [Resilient] are unbanned; adds 999 [Ursus] if Ursus is open.'
        enTabs = @(
            '999-Ursus mechanic: Equip Elite "Rowdy Tin" with Olga''s Ursus Respirator + Damazti Isomorph so it becomes an [Ursus] Operator; when "Rowdy Tin" activates its skill, its friendly-fire repeatedly kills and revives your high-[Resilient] Gravel and Varkáris in front of it, generating hundreds of temporary [Ursus] stacks via Talulah! Stay at Lv. 2 on Rounds 2–7 to find 2 Simple Communicators (for Elite "Rowdy Tin"), Gravel, Resilient Catapults, Blemishine, and Olga + Contrail ([Agile]), then fast-level to Lv. 6 for Muelsyse, Talulah, Pallas, Młynar, and Viviana.'
        )
    }
    '2121125268301474731' = @{
        enTitle = 'One-Chart Ursus Guide: Тоска & Talulah Swift/Arcane Core'
        archetype = 'Ursus · Arcane / Swift / Harmony'
        enScope = 'Excels against high-HP/high-DEF elites using Zima the Raging Tide''s Strategy.'
        enTabs = @(
            'Core loop: Kills generate temporary [Ursus] stacks -> Varkáris & Uchu make them permanent -> Тоска doubles [Ursus] & [Swift] stacking -> Talulah + Nymph + Civilight Eterna clean up the battlefield.',
            'Rounds 5–10 transition: Varkáris, Podenco, Uchu, Ethan, Вий, Тоска, and Talulah.'
        )
    }
    '2120736544545060089' = @{
        enTitle = 'Unbeatable Late-Game: 6-Kazimierz 3-Resilient 2-Raid Młynar & Surtr'
        archetype = 'Kazimierz · Resilient / Raid'
        enScope = 'Playable whenever [Kazimierz] and [Resilient] are unbanned.'
        enTabs = @(
            'Uses Młynar''s [Business Metrics] and Damazti Cluster''s Isomorphs. Stack [Resilient] and [Kazimierz] early with Gravel, Blemishine, Fang the Fire-sharpened, and Kazemaru, then transition into Młynar, Nearl the Radiant Knight, Viviana, Entelechia, a [Kazimierz]-Isomorph Surtr, and a [Raid]-Isomorph Degenbrecher.',
            'Rounds 1–9 transition: Młynar, Blemishine, Fang the Fire-sharpened, Gravel, Wild Mane, Kazemaru, Eunectes, and Fartooth.'
        )
    }
    '2120829225865664699' = @{
        enTitle = '100% Swift + Precision + Arcane Sargon (Mantra & Nymph Carry)'
        archetype = 'Sargon · Swift / Precision / Arcane / Foresight'
        enScope = 'Best Sargon variant when [Agile] is banned; uses Pepe''s [Erudite] Strategy.'
        enTabs = @(
            'Upgrade to Lv. 2 on Round 2 and rush Lv. 4 on Round 5 to triple into Pozëmka, Тоска, Pepe, and Ho''olheyak. Pair Тоска + Nymph + Passenger + Papyrus + Archetto to reach 100% [Swift] cooldown reduction alongside 3 [Precision] and 3 [Arcane], with Mantra as the late-game hyper-carry.'
        )
    }
    '2121443262684425952' = @{
        enTitle = 'Ban-Proof Lv.3–4 Iberia: 6-Iberia + 3-Convergence + Durable'
        archetype = 'Iberia · Convergence / Precision / Durable'
        enScope = 'Works regardless of Add-on Alliance bans as long as [Iberia] is open; tested on N20.'
        enTabs = @(
            'Camp at Dispatch Center Lv. 3–4 using Encore''s [Duet] or Yara''s [Talent Lock] to quickly assemble 6 [Iberia] (Homebound, Highmore, Blue Poison, Rose Salt, Lumen, Weedy) + 3 [Convergence] (adding Nightingale). Give Homebound a Leithanian Snare Drum or Sargonian Teaspresso for near-permanent Alchemy units and 6-[Iberia] Slow/DoT. Use the remaining 2 deployment slots flexibly based on unbanned Add-on Alliances: Archetto/Ho''olheyak for [Precision] (pointing Archetto at Homebound), or Roberta/Saria for [Durable] to double your squad''s HP.',
            'Rounds 1–13 Flexible Setup: Indigo, Rose Salt, Highmore, Homebound, Weedy, Lumen, Archetto, and Roberta.'
        )
    }
    '2121009407271484320' = @{
        enTitle = 'Comprehensive 6-Kazimierz 3-Resilient 2-Raid Boss Buster'
        archetype = 'Kazimierz · Resilient / Raid / Elite'
        enScope = 'Ideal when [Precision]/[Arcane] are banned and [Kazimierz] + [Resilient]/[Raid] are open.'
        enTabs = @(
            'Detailed Kazimierz guide supporting Młynar, Emperor, Gavial the Invincible, or Flametail Strategies. Use Gravel (with Originium Solvent + Resilient Catapult) + Varkáris to cap per-round [Resilient] stacks, Blemishine + Hoederer for [Raid], and Młynar + Viviana + Nearl the Radiant Knight + Surtr + Entelechia + Degenbrecher for late-game Boss fights. 3 [Resilient] guarantees 100% ground revival and continuous SP generation so 10,000+ ATK Młynar never stops swinging.'
        )
    }
    '2121272587960895411' = @{
        enTitle = 'All-In Lv.2 Reroll: 3-Resilient + Agile + Multi-Scope "Rowdy Tin"'
        archetype = 'Flex · Resilient / Agile / Precision / Marvel'
        enScope = 'Stays at Dispatch Center Lv. 2 all game using Eunectes''s "Rowdy Tin" Strategy.'
        enTabs = @(
            'Upgrade to Lv. 2 on Round 2 and stay at Lv. 2. Collect Varkáris + Ferryman + Gravel for 3 [Resilient], Contrail + Greyy the Lightningbearer + Encore for [Agile] and [Marvel], and Archetto for [Precision]. Use Simple Communicators to promote "Rowdy Tin" to Elite (unlocking 6 Equipment slots!) and equip it with 4–5 Precision Scopes farmed from Greyy the Lightningbearer—letting "Rowdy Tin" kill Gravel to stack [Resilient] and one-shot the Round 14 Boss.'
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
            enType       = (Translate-TabType $tb.type)
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
