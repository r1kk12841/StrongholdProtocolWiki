# Render output/index.html from data/en/*.json
# Standalone, dark/light-capable, searchable, filterable wiki for Stronghold Protocol: Regulation
# with interactive Run Planner / Pinned Operator Build Recommender & Skland Community Strategies.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$enDir = Join-Path $root 'data\en'
$outDir = Join-Path $root 'output'
New-Item -ItemType Directory -Force $outDir | Out-Null

$alliancesJson = [IO.File]::ReadAllText((Join-Path $enDir 'alliances.json'), [Text.Encoding]::UTF8)
$strategiesJson = [IO.File]::ReadAllText((Join-Path $enDir 'strategies.json'), [Text.Encoding]::UTF8)
$operatorsJson = [IO.File]::ReadAllText((Join-Path $enDir 'operators.json'), [Text.Encoding]::UTF8)
$equipmentJson = [IO.File]::ReadAllText((Join-Path $enDir 'equipment.json'), [Text.Encoding]::UTF8)
$communityJson = [IO.File]::ReadAllText((Join-Path $enDir 'community_strategies.json'), [Text.Encoding]::UTF8)

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Stronghold Protocol: Regulation — English Wiki, Run Planner &amp; Community Builds</title>
  <style>
    :root {
      --bg-0: #0b0f14;
      --bg-1: #111821;
      --bg-2: #17212d;
      --bg-3: #1f2d3d;
      --border: #28384c;
      --text: #e6edf5;
      --muted: #8fa3b8;
      --accent: #0098dc;
      --accent-soft: rgba(0, 152, 220, 0.16);
      --teal: #40b196;
      --teal-soft: rgba(64, 177, 150, 0.16);
      --gold: #f5b301;
      --gold-soft: rgba(245, 179, 1, 0.16);
      --orange: #ff7f2a;
      --orange-soft: rgba(255, 127, 42, 0.16);
      --purple: #b084f5;
      --purple-soft: rgba(176, 132, 245, 0.16);
      --tier-1: #9ea7b3;
      --tier-2: #e2e8f0;
      --tier-3: #2dd4bf;
      --tier-4: #38bdf8;
      --tier-5: #facc15;
      --tier-6: #fb923c;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Inter, "Noto Sans", sans-serif;
      background: var(--bg-0);
      color: var(--text);
      line-height: 1.5;
      font-size: 14px;
    }
    a { color: var(--accent); text-decoration: none; }
    /* Sticky Top Header */
    .topbar {
      position: sticky;
      top: 0;
      z-index: 50;
      background: rgba(11, 15, 20, 0.94);
      backdrop-filter: blur(10px);
      border-bottom: 1px solid var(--border);
      padding: 12px 20px;
    }
    .topbar-inner {
      max-width: 1400px;
      margin: 0 auto;
      display: flex;
      flex-wrap: wrap;
      gap: 12px 20px;
      align-items: center;
      justify-content: space-between;
    }
    .brand {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .brand-badge {
      background: linear-gradient(135deg, #0098dc, #40b196);
      color: #061018;
      font-weight: 800;
      font-size: 12px;
      letter-spacing: 0.06em;
      padding: 4px 8px;
      border-radius: 6px;
      text-transform: uppercase;
    }
    .brand h1 {
      margin: 0;
      font-size: 18px;
      font-weight: 700;
      letter-spacing: -0.01em;
    }
    .brand-sub {
      color: var(--muted);
      font-size: 12px;
    }
    .search-wrap {
      position: relative;
      flex: 1 1 320px;
      max-width: 520px;
    }
    .search-input {
      width: 100%;
      padding: 9px 76px 9px 36px;
      border-radius: 8px;
      border: 1px solid var(--border);
      background: var(--bg-1);
      color: var(--text);
      font-size: 14px;
      outline: none;
      transition: border-color 0.15s, box-shadow 0.15s;
    }
    .search-input:focus {
      border-color: var(--accent);
      box-shadow: 0 0 0 3px rgba(0, 152, 220, 0.2);
    }
    .search-icon {
      position: absolute;
      left: 11px;
      top: 50%;
      transform: translateY(-50%);
      color: var(--muted);
      pointer-events: none;
      font-size: 14px;
    }
    .search-kbd {
      position: absolute;
      right: 8px;
      top: 50%;
      transform: translateY(-50%);
      display: flex;
      align-items: center;
      gap: 4px;
    }
    .kbd {
      font-size: 11px;
      color: var(--muted);
      background: var(--bg-2);
      border: 1px solid var(--border);
      padding: 1px 6px;
      border-radius: 4px;
    }
    .clear-btn {
      display: none;
      background: var(--bg-3);
      color: var(--text);
      border: none;
      border-radius: 4px;
      padding: 2px 6px;
      font-size: 11px;
      cursor: pointer;
    }
    .controls-row {
      max-width: 1400px;
      margin: 10px auto 0;
      display: flex;
      flex-wrap: wrap;
      gap: 8px 16px;
      align-items: center;
      justify-content: space-between;
    }
    .tabs {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }
    .tab-btn {
      background: var(--bg-1);
      color: var(--muted);
      border: 1px solid var(--border);
      padding: 6px 12px;
      border-radius: 7px;
      font-size: 13px;
      font-weight: 600;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 6px;
      transition: all 0.15s;
    }
    .tab-btn:hover { color: var(--text); border-color: #3a506b; }
    .tab-btn.active {
      background: var(--accent-soft);
      color: #58c7ff;
      border-color: var(--accent);
    }
    .tab-count {
      background: var(--bg-2);
      color: var(--muted);
      padding: 1px 6px;
      border-radius: 99px;
      font-size: 11px;
      font-weight: 700;
    }
    .tab-btn.active .tab-count {
      background: rgba(0, 152, 220, 0.28);
      color: #8addff;
    }
    .toggles {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      align-items: center;
    }
    .toggle-btn {
      background: var(--bg-1);
      color: var(--muted);
      border: 1px solid var(--border);
      padding: 5px 10px;
      border-radius: 6px;
      font-size: 12px;
      cursor: pointer;
    }
    .toggle-btn.active {
      background: var(--teal-soft);
      color: #6ee7cb;
      border-color: var(--teal);
    }
    /* Sticky Pinned Squad Drawer */
    .pinned-bar {
      max-width: 1400px;
      margin: 10px auto 0;
      padding: 10px 14px;
      background: linear-gradient(90deg, rgba(0, 152, 220, 0.12), rgba(64, 177, 150, 0.12));
      border: 1px solid rgba(0, 152, 220, 0.45);
      border-radius: 9px;
      display: none;
      flex-direction: column;
      gap: 8px;
    }
    .pinned-bar.visible { display: flex; }
    .pinned-top {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
    }
    .pinned-list {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 6px;
    }
    .pinned-chip {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: var(--bg-1);
      border: 1px solid var(--accent);
      border-radius: 99px;
      padding: 2px 8px 2px 3px;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
    }
    .pinned-chip img {
      width: 22px;
      height: 22px;
      border-radius: 50%;
      object-fit: contain;
      background: var(--bg-2);
    }
    .pinned-chip-remove {
      color: var(--muted);
      font-weight: 800;
      margin-left: 2px;
    }
    .pinned-chip:hover .pinned-chip-remove { color: #f87171; }
    .pinned-synergies {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      align-items: center;
      font-size: 12px;
    }
    .synergy-meter {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      padding: 2px 8px;
      border-radius: 6px;
      background: var(--bg-1);
      border: 1px solid var(--border);
      font-weight: 600;
    }
    .synergy-meter.active {
      background: var(--teal-soft);
      border-color: var(--teal);
      color: #6ee7cb;
    }
    .synergy-meter.near {
      background: var(--gold-soft);
      border-color: var(--gold);
      color: #fde047;
    }
    /* Pin Button */
    .pin-btn {
      background: var(--bg-2);
      color: var(--muted);
      border: 1px solid var(--border);
      border-radius: 5px;
      padding: 2px 7px;
      font-size: 11px;
      font-weight: 700;
      cursor: pointer;
      transition: all 0.12s;
      display: inline-flex;
      align-items: center;
      gap: 3px;
    }
    .pin-btn:hover {
      border-color: var(--accent);
      color: var(--text);
    }
    .pin-btn.pinned {
      background: var(--gold-soft);
      color: #fde047;
      border-color: var(--gold);
    }
    /* Main Container */
    .container {
      max-width: 1400px;
      margin: 0 auto;
      padding: 20px;
    }
    .section-block {
      margin-bottom: 36px;
    }
    .section-head {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
      margin-bottom: 12px;
      padding-bottom: 8px;
      border-bottom: 1px solid var(--border);
    }
    .section-title {
      margin: 0;
      font-size: 18px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .sub-filters {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      align-items: center;
    }
    .chip {
      background: var(--bg-1);
      color: var(--muted);
      border: 1px solid var(--border);
      padding: 4px 10px;
      border-radius: 999px;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.12s;
    }
    .chip:hover { color: var(--text); }
    .chip.active {
      background: var(--accent-soft);
      color: #67cdff;
      border-color: var(--accent);
    }
    .select-filter {
      background: var(--bg-1);
      color: var(--text);
      border: 1px solid var(--border);
      padding: 4px 10px;
      border-radius: 6px;
      font-size: 12px;
    }
    /* Run Planner Panel inside Community Section */
    .planner-box {
      background: var(--bg-1);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 16px;
      margin-bottom: 18px;
    }
    .planner-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 14px;
      margin-top: 12px;
    }
    .planner-card {
      background: var(--bg-2);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 12px;
    }
    .planner-card h4 {
      margin: 0 0 8px 0;
      font-size: 13px;
      text-transform: uppercase;
      letter-spacing: 0.04em;
      color: var(--muted);
    }
    .QuickPin-picker {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      max-height: 155px;
      overflow-y: auto;
      padding: 4px;
      background: var(--bg-1);
      border: 1px solid var(--border);
      border-radius: 6px;
    }
    /* Community Guide Cards */
    .guides-grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 16px;
    }
    .guide-card {
      background: var(--bg-1);
      border: 1px solid var(--border);
      border-radius: 10px;
      padding: 16px 18px;
      transition: border-color 0.15s;
    }
    .guide-card.matched-build {
      border-color: var(--teal);
      box-shadow: 0 0 0 1px rgba(64, 177, 150, 0.35);
    }
    .guide-header {
      display: flex;
      flex-wrap: wrap;
      align-items: flex-start;
      justify-content: space-between;
      gap: 10px;
      margin-bottom: 12px;
      padding-bottom: 10px;
      border-bottom: 1px solid var(--border);
    }
    .guide-title {
      font-size: 16px;
      font-weight: 700;
      color: var(--text);
      margin: 0;
    }
    .guide-meta {
      font-size: 12px;
      color: var(--muted);
      margin-top: 3px;
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      align-items: center;
    }
    .guide-stats {
      display: flex;
      gap: 10px;
      font-size: 12px;
      color: var(--muted);
      background: var(--bg-2);
      padding: 4px 10px;
      border-radius: 6px;
      border: 1px solid var(--border);
      white-space: nowrap;
    }
    .guide-row {
      display: grid;
      grid-template-columns: 120px 1fr;
      gap: 10px;
      align-items: start;
      margin-bottom: 10px;
    }
    @media (max-width: 680px) {
      .guide-row { grid-template-columns: 1fr; gap: 4px; }
    }
    .guide-label {
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.04em;
      color: var(--muted);
      padding-top: 4px;
    }
    .phase-tabs {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      margin-bottom: 10px;
    }
    .phase-btn {
      background: var(--bg-2);
      color: var(--muted);
      border: 1px solid var(--border);
      padding: 4px 10px;
      border-radius: 6px;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
    }
    .phase-btn.active {
      background: var(--accent-soft);
      color: #67cdff;
      border-color: var(--accent);
    }
    .guide-notes {
      background: var(--bg-2);
      border-left: 3px solid var(--accent);
      padding: 10px 12px;
      border-radius: 6px;
      font-size: 13px;
      color: #d6e3f0;
      margin-top: 8px;
    }
    .op-card-mini {
      position: relative;
      display: inline-flex;
      flex-direction: column;
      align-items: center;
      width: 58px;
      padding: 4px;
      border-radius: 8px;
      background: var(--bg-2);
      border: 1px solid var(--border);
      cursor: pointer;
      text-align: center;
      transition: all 0.12s;
    }
    .op-card-mini:hover { border-color: var(--accent); }
    .op-card-mini.is-pinned {
      border-color: var(--gold);
      background: rgba(245, 179, 1, 0.14);
      box-shadow: 0 0 0 1px var(--gold);
    }
    .op-card-mini img {
      width: 44px;
      height: 44px;
      border-radius: 6px;
      background: var(--bg-1);
      object-fit: contain;
    }
    .op-elite-star {
      position: absolute;
      top: 3px;
      right: 3px;
      background: rgba(11, 15, 20, 0.9);
      color: var(--gold);
      font-size: 10px;
      font-weight: 800;
      padding: 0 4px;
      border-radius: 4px;
      border: 1px solid rgba(245, 179, 1, 0.45);
    }
    /* Tables */
    .table-card {
      background: var(--bg-1);
      border: 1px solid var(--border);
      border-radius: 10px;
      overflow: hidden;
      margin-bottom: 18px;
    }
    .table-scroll {
      overflow-x: auto;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      text-align: left;
    }
    thead {
      background: var(--bg-2);
      border-bottom: 1px solid var(--border);
    }
    th {
      padding: 10px 14px;
      font-size: 12px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.04em;
      color: var(--muted);
      white-space: nowrap;
    }
    td {
      padding: 12px 14px;
      border-top: 1px solid var(--border);
      vertical-align: top;
    }
    tbody tr:first-child td { border-top: none; }
    tbody tr:hover { background: rgba(255, 255, 255, 0.02); }
    tbody tr.row-pinned { background: rgba(245, 179, 1, 0.07); }
    .icon-cell {
      width: 56px;
      min-width: 56px;
      text-align: center;
      vertical-align: middle;
    }
    .icon-bond {
      width: 42px;
      height: 42px;
      object-fit: contain;
    }
    .icon-avatar {
      width: 44px;
      height: 44px;
      border-radius: 8px;
      object-fit: contain;
      background: var(--bg-2);
      border: 1px solid var(--border);
    }
    .icon-equip {
      width: 44px;
      height: 44px;
      object-fit: contain;
    }
    .entity-name {
      font-weight: 700;
      font-size: 14px;
      color: var(--text);
    }
    .cn-sub {
      display: none;
      color: var(--muted);
      font-size: 12px;
      font-weight: 400;
      margin-top: 2px;
    }
    body.show-cn .cn-sub { display: block; }
    .s2-note {
      display: none;
      margin-top: 6px;
      padding: 5px 8px;
      border-radius: 6px;
      background: rgba(245, 179, 1, 0.1);
      border-left: 3px solid var(--gold);
      color: #f3d37a;
      font-size: 12px;
    }
    body.show-s2 .s2-note { display: block; }
    .meta-line {
      font-size: 12px;
      color: var(--muted);
      margin-top: 3px;
    }
    /* Badges */
    .badge {
      display: inline-block;
      padding: 1px 7px;
      border-radius: 4px;
      font-size: 11px;
      font-weight: 700;
      letter-spacing: 0.02em;
      vertical-align: middle;
    }
    .badge-new { background: var(--teal-soft); color: #5eead4; border: 1px solid rgba(64,177,150,0.4); }
    .badge-reworked { background: var(--orange-soft); color: #fdba74; border: 1px solid rgba(255,127,42,0.4); }
    .badge-modified { background: var(--gold-soft); color: #fde047; border: 1px solid rgba(245,179,1,0.4); }
    .badge-unchanged, .badge-returning { background: rgba(143,163,184,0.12); color: var(--muted); border: 1px solid rgba(143,163,184,0.25); }
    .badge-match { background: var(--teal-soft); color: #5eead4; border: 1px solid var(--teal); font-size: 12px; padding: 2px 8px; }
    .badge-alliance {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      background: var(--bg-2);
      color: #c8d9eb;
      border: 1px solid var(--border);
      padding: 2px 8px;
      border-radius: 99px;
      font-size: 12px;
      font-weight: 600;
      margin: 2px 4px 2px 0;
      cursor: pointer;
      transition: border-color 0.12s, color 0.12s;
    }
    .badge-alliance:hover {
      border-color: var(--accent);
      color: #67cdff;
    }
    .badge-alliance.core-bond {
      background: var(--accent-soft);
      border-color: rgba(0, 152, 220, 0.5);
      color: #7dd3fc;
    }
    .badge-type {
      display: inline-block;
      padding: 1px 6px;
      border-radius: 4px;
      font-size: 11px;
      font-weight: 700;
      margin-right: 6px;
      background: var(--purple-soft);
      color: #d8b4fe;
      border: 1px solid rgba(176,132,245,0.35);
    }
    .tier-pill {
      display: inline-block;
      padding: 1px 7px;
      border-radius: 4px;
      font-size: 11px;
      font-weight: 800;
      background: var(--bg-2);
      border: 1px solid var(--border);
    }
    .tier-1 { color: var(--tier-1); }
    .tier-2 { color: var(--tier-2); }
    .tier-3 { color: var(--tier-3); }
    .tier-4 { color: var(--tier-4); }
    .tier-5 { color: var(--tier-5); }
    .tier-6 { color: var(--tier-6); }
    /* Rich text formatting inside effects */
    .hl-num { color: #38bdf8; font-weight: 600; }
    .hl-cond { color: #4ade80; font-weight: 600; }
    .hl-tag { color: #fbbf24; font-weight: 600; }
    /* Operator avatar strip inside Alliances */
    .op-grid {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      max-width: 340px;
    }
    .op-mini {
      position: relative;
      display: inline-flex;
      flex-direction: column;
      align-items: center;
      width: 46px;
      cursor: pointer;
      text-align: center;
    }
    .op-mini img {
      width: 40px;
      height: 40px;
      border-radius: 6px;
      background: var(--bg-2);
      border: 1px solid var(--border);
      object-fit: contain;
    }
    .op-mini:hover img { border-color: var(--accent); }
    .op-mini.is-pinned img {
      border-color: var(--gold);
      box-shadow: 0 0 0 2px rgba(245, 179, 1, 0.55);
    }
    .op-mini-tier {
      position: absolute;
      top: 0;
      left: 2px;
      background: rgba(11, 15, 20, 0.88);
      font-size: 10px;
      font-weight: 800;
      padding: 0 4px;
      border-radius: 4px;
      line-height: 1.3;
    }
    .op-mini-name {
      font-size: 10px;
      color: var(--muted);
      max-width: 46px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      margin-top: 2px;
    }
    .empty-msg {
      padding: 28px;
      text-align: center;
      color: var(--muted);
      background: var(--bg-1);
      border: 1px dashed var(--border);
      border-radius: 10px;
    }
    /* Equipment Combine Recipe Bar */
    .recipe-bar {
      display: inline-flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 6px;
      margin-bottom: 8px;
      padding: 5px 10px;
      background: var(--bg-2);
      border: 1px solid var(--border);
      border-radius: 8px;
    }
    .recipe-bar-sub {
      margin-top: 8px;
      margin-bottom: 0;
    }
    .recipe-label {
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.04em;
      color: var(--muted);
      margin-right: 2px;
    }
    .recipe-pill {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 3px 8px 3px 4px;
      background: var(--bg-1);
      border: 1px solid var(--border);
      border-radius: 6px;
      cursor: pointer;
      transition: border-color 0.12s, background 0.12s;
    }
    .recipe-pill:hover {
      border-color: var(--accent);
      background: var(--bg-3);
    }
    .recipe-pill img {
      width: 26px;
      height: 26px;
      object-fit: contain;
    }
    .recipe-pill-name {
      font-size: 12px;
      font-weight: 600;
      color: var(--text);
    }
    .recipe-op {
      font-size: 13px;
      font-weight: 800;
      color: var(--gold);
      padding: 0 2px;
    }
    /* Floating Back-to-Top Button */
    .back-to-top {
      position: fixed;
      right: 16px;
      bottom: 18px;
      z-index: 60;
      background: var(--accent);
      color: #041019;
      border: none;
      border-radius: 999px;
      padding: 9px 14px;
      font-size: 12px;
      font-weight: 800;
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.45);
      cursor: pointer;
      display: none;
      align-items: center;
      gap: 4px;
    }
    .back-to-top.visible { display: inline-flex; }
    .pin-collapse-btn {
      display: none;
      background: var(--bg-2);
      color: var(--text);
      border: 1px solid var(--border);
      border-radius: 5px;
      padding: 2px 8px;
      font-size: 11px;
      font-weight: 700;
      cursor: pointer;
    }

    /* ==================== MOBILE OPTIMIZATION (<= 768px) ==================== */
    @media (max-width: 768px) {
      .topbar {
        padding: 8px 12px;
      }
      .topbar-inner {
        gap: 8px;
      }
      .brand {
        gap: 8px;
        width: 100%;
        justify-content: space-between;
      }
      .brand-badge {
        font-size: 10px;
        padding: 3px 6px;
        white-space: nowrap;
        order: 2;
      }
      .brand h1 {
        font-size: 15px;
        line-height: 1.25;
      }
      .brand-sub {
        display: none;
      }
      .search-wrap {
        flex: 1 1 100%;
        max-width: 100%;
      }
      .search-input, .select-filter {
        font-size: 16px; /* Prevents iOS auto-zoom on focus */
        padding: 8px 60px 8px 34px;
      }
      .select-filter {
        padding: 6px 10px;
        font-size: 13px;
      }
      .kbd {
        display: none;
      }
      .controls-row {
        margin-top: 8px;
        gap: 6px;
      }
      .tabs {
        width: 100%;
        flex-wrap: nowrap;
        overflow-x: auto;
        -webkit-overflow-scrolling: touch;
        scrollbar-width: none;
        padding-bottom: 2px;
      }
      .tabs::-webkit-scrollbar { display: none; }
      .tab-btn {
        flex: 0 0 auto;
        padding: 6px 10px;
        font-size: 12px;
        white-space: nowrap;
      }
      .toggles {
        width: 100%;
        justify-content: flex-start;
        gap: 6px;
      }
      .toggle-btn {
        flex: 1 1 auto;
        text-align: center;
        padding: 5px 8px;
        font-size: 11px;
      }
      /* Compact & Collapsible Pinned Squad Bar on Mobile */
      .pinned-bar {
        margin-top: 6px;
        padding: 8px 10px;
        gap: 6px;
      }
      .pin-collapse-btn {
        display: inline-flex;
        align-items: center;
      }
      .pinned-list {
        flex-wrap: nowrap;
        overflow-x: auto;
        max-width: 100%;
        -webkit-overflow-scrolling: touch;
        scrollbar-width: none;
        padding-bottom: 2px;
      }
      .pinned-list::-webkit-scrollbar { display: none; }
      .pinned-chip {
        flex: 0 0 auto;
      }
      .pinned-bar.mobile-collapsed .pinned-actions,
      .pinned-bar.mobile-collapsed .pinned-synergies {
        display: none !important;
      }
      .pinned-actions {
        width: 100%;
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
      }
      .pinned-actions .pin-btn {
        flex: 1 1 auto;
        justify-content: center;
        padding: 5px 6px;
      }
      .pinned-synergies {
        flex-wrap: nowrap;
        overflow-x: auto;
        -webkit-overflow-scrolling: touch;
        scrollbar-width: none;
        padding-bottom: 2px;
      }
      .pinned-synergies::-webkit-scrollbar { display: none; }
      .synergy-meter {
        flex: 0 0 auto;
      }
      /* Main Container & Filters */
      .container {
        padding: 12px 10px 64px;
      }
      .section-block {
        margin-bottom: 26px;
      }
      .section-head {
        gap: 8px;
      }
      .section-title {
        font-size: 16px;
      }
      .sub-filters, #opTierFilters {
        width: 100%;
        flex-wrap: nowrap !important;
        overflow-x: auto;
        -webkit-overflow-scrolling: touch;
        scrollbar-width: none;
        padding-bottom: 4px;
      }
      .sub-filters::-webkit-scrollbar, #opTierFilters::-webkit-scrollbar { display: none; }
      .chip {
        flex: 0 0 auto;
        white-space: nowrap;
        padding: 5px 11px;
      }
      .op-select-row {
        display: flex;
        width: 100%;
        gap: 6px;
      }
      .op-select-row .select-filter {
        flex: 1 1 50%;
        min-width: 0;
      }
      /* Planner & Community Cards on Mobile */
      .planner-box {
        padding: 12px;
      }
      .planner-grid {
        grid-template-columns: 1fr;
        gap: 10px;
      }
      .guide-card {
        padding: 12px;
      }
      .guide-header {
        flex-direction: column;
        align-items: stretch;
        gap: 8px;
      }
      .guide-actions-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        width: 100%;
      }
      .phase-tabs {
        flex-wrap: nowrap;
        overflow-x: auto;
        -webkit-overflow-scrolling: touch;
        scrollbar-width: none;
      }
      .phase-tabs::-webkit-scrollbar { display: none; }
      .phase-btn {
        flex: 0 0 auto;
        white-space: nowrap;
      }
      /* Convert Data Tables into Responsive Mobile Cards */
      .table-card {
        background: transparent;
        border: none;
        border-radius: 0;
        overflow: visible;
      }
      .table-scroll {
        overflow-x: visible;
      }
      table, tbody {
        display: block;
        width: 100%;
      }
      thead {
        display: none;
      }
      tbody tr {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        background: var(--bg-1);
        border: 1px solid var(--border);
        border-radius: 10px;
        padding: 12px;
        margin-bottom: 10px;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.22);
      }
      tbody tr.row-pinned {
        border-color: var(--gold);
        background: rgba(245, 179, 1, 0.08);
      }
      tbody td {
        border-top: none;
        padding: 0;
      }
      tbody td.icon-cell {
        width: 52px !important;
        min-width: 52px !important;
        margin-right: 10px;
        text-align: left;
      }
      tbody td.title-cell {
        flex: 1 1 calc(100% - 64px);
        min-width: 0 !important;
      }
      tbody td.body-cell {
        width: 100% !important;
        min-width: 100% !important;
        margin-top: 10px;
        padding-top: 8px;
        border-top: 1px dashed rgba(255, 255, 255, 0.09);
      }
      tbody td.body-cell[data-label]::before {
        content: attr(data-label);
        display: block;
        font-size: 10px;
        font-weight: 800;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: var(--muted);
        margin-bottom: 4px;
      }
      .op-grid {
        max-width: 100%;
      }
      .recipe-bar {
        display: flex;
        width: 100%;
      }
    }
  </style>
</head>
<body class="show-s2">
  <header class="topbar">
    <div class="topbar-inner">
      <div class="brand">
        <span class="brand-badge">Season 3 · Regulation</span>
        <div>
          <h1>Stronghold Protocol: Regulation (卫戍协议·规程)</h1>
          <div class="brand-sub">English Wiki · Exact PRTS Scaling · Skland Community Builds &amp; Interactive Run Planner</div>
        </div>
      </div>
      <div class="search-wrap">
        <span class="search-icon">&#128269;</span>
        <input id="globalSearch" class="search-input" type="search" placeholder="Search Alliances, Strategies, Operators, Equipment, Community Builds... (Press /)" autocomplete="off" />
        <div class="search-kbd">
          <button id="clearSearch" class="clear-btn" type="button">Clear</button>
          <span class="kbd">/</span>
        </div>
      </div>
    </div>
    <div class="controls-row">
      <div class="tabs" id="mainTabs">
        <button class="tab-btn active" data-tab="all" type="button">All Sections</button>
        <button class="tab-btn" data-tab="community" type="button">&#127942; Community Builds &amp; Planner <span class="tab-count" id="cntCommunity">20</span></button>
        <button class="tab-btn" data-tab="alliances" type="button">Alliances <span class="tab-count" id="cntAlliances">26</span></button>
        <button class="tab-btn" data-tab="strategies" type="button">Strategies <span class="tab-count" id="cntStrategies">61</span></button>
        <button class="tab-btn" data-tab="operators" type="button">Operators <span class="tab-count" id="cntOperators">143</span></button>
        <button class="tab-btn" data-tab="equipment" type="button">Equipment <span class="tab-count" id="cntEquipment">70</span></button>
      </div>
      <div class="toggles">
        <button id="toggleS2" class="toggle-btn active" type="button">Season 2 Diff Notes</button>
        <button id="toggleCN" class="toggle-btn" type="button">Show CN Text</button>
      </div>
    </div>
    <!-- Sticky Pinned Squad Bar (appears whenever >=1 Operator is pinned) -->
    <div id="pinnedBar" class="pinned-bar">
      <div class="pinned-top">
        <div style="display:flex;align-items:center;justify-content:space-between;width:100%;gap:8px;">
          <div class="pinned-list" id="pinnedList" style="flex:1;min-width:0;"></div>
          <button id="btnTogglePinDrawer" class="pin-collapse-btn" type="button">Hide &#9650;</button>
        </div>
        <div class="pinned-actions" style="display:flex;gap:8px;align-items:center;">
          <button id="btnViewRecommendations" class="pin-btn pinned" type="button">View Recommended Builds</button>
          <button id="btnFilterPinnedOps" class="pin-btn" type="button">Only Pinned in Operators</button>
          <button id="btnClearPins" class="pin-btn" type="button">Clear All Pins</button>
        </div>
      </div>
      <div class="pinned-synergies" id="pinnedSynergies"></div>
    </div>
  </header>

  <main class="container">
    <!-- ==================== COMMUNITY BUILDS & RUN PLANNER ==================== -->
    <section class="section-block" id="sec-community">
      <div class="section-head">
        <h2 class="section-title">&#127942; Skland Community Strategies &amp; Run Build Recommender</h2>
        <div class="sub-filters" id="communityAllianceFilters">
          <button class="chip active" data-alliance="all" type="button">All Builds (20)</button>
          <button class="chip" data-alliance="Yan" type="button">Yan</button>
          <button class="chip" data-alliance="Sargon" type="button">Sargon</button>
          <button class="chip" data-alliance="Victoria" type="button">Victoria</button>
          <button class="chip" data-alliance="Kjerag" type="button">Kjerag</button>
          <button class="chip" data-alliance="Ægir" type="button">Ægir</button>
          <button class="chip" data-alliance="Siracusa" type="button">Siracusa</button>
          <button class="chip" data-alliance="Kazimierz" type="button">Kazimierz</button>
          <button class="chip" data-alliance="Ursus" type="button">Ursus</button>
          <button class="chip" data-alliance="Iberia" type="button">Iberia</button>
          <button class="chip" data-alliance="Leithanien" type="button">Leithanien</button>
          <button class="chip" data-alliance="matched" type="button" id="chipMatchedOnly">Matching Pinned Ops</button>
        </div>
      </div>

      <!-- Interactive Run Planner / Operator Pinning Box -->
      <div class="planner-box">
        <div style="display:flex;flex-wrap:wrap;justify-content:space-between;align-items:center;gap:10px;">
          <div>
            <strong style="font-size:15px;color:#58c7ff;">&#128204; Run Build Recommender (Pin Operators to Filter &amp; Rank Builds)</strong>
            <div style="font-size:12px;color:var(--muted);margin-top:2px;">
              Click any Operator avatar in Community Builds, Alliances, or the Operators table (or use the quick-picker below) to <strong>Pin</strong> them. Community builds are automatically ranked by how many of your Pinned Operators &amp; Alliances they share, and missing Operators to complete your synergies are suggested!
            </div>
          </div>
          <div style="display:flex;gap:8px;align-items:center;">
            <input id="pinPickerSearch" class="select-filter" type="search" placeholder="Quick-find Operator to pin..." style="min-width:210px;" />
          </div>
        </div>
        <div class="planner-grid">
          <div class="planner-card">
            <h4>Quick-Pin Operator Pool (Click to Pin / Unpin)</h4>
            <div class="QuickPin-picker" id="quickPinPicker"></div>
          </div>
          <div class="planner-card" id="plannerRecommendations">
            <h4>Best-Fit Next Operators &amp; Alliance Progress</h4>
            <div style="color:var(--muted);font-size:12px;">Pin 1 or more Operators to see Alliance threshold progress (e.g. 2/3 Core, 1/2 Add-on) and top recommended Operators that complete multiple Alliances at once.</div>
          </div>
        </div>
      </div>

      <div id="communityContainer" class="guides-grid"></div>
    </section>

    <!-- ==================== ALLIANCES ==================== -->
    <section class="section-block" id="sec-alliances">
      <div class="section-head">
        <h2 class="section-title">Alliances</h2>
        <div class="sub-filters" id="allianceFilters">
          <button class="chip active" data-filter="all" type="button">All (26)</button>
          <button class="chip" data-filter="core" type="button">Core Alliances (10)</button>
          <button class="chip" data-filter="addon" type="button">Add-on Alliances (16)</button>
          <button class="chip" data-filter="new" type="button">New in S3</button>
          <button class="chip" data-filter="reworked" type="button">Reworked / Modified</button>
        </div>
      </div>
      <div id="alliancesContainer"></div>
    </section>

    <!-- ==================== STRATEGIES ==================== -->
    <section class="section-block" id="sec-strategies">
      <div class="section-head">
        <h2 class="section-title">Strategies</h2>
        <div class="sub-filters" id="strategyFilters">
          <button class="chip active" data-filter="all" type="button">All (61)</button>
          <button class="chip" data-filter="new" type="button">New in S3</button>
          <button class="chip" data-filter="reworked" type="button">Reworked / Modified</button>
          <button class="chip" data-filter="unchanged" type="button">Returning Unchanged</button>
        </div>
      </div>
      <div id="strategiesContainer"></div>
    </section>

    <!-- ==================== OPERATORS ==================== -->
    <section class="section-block" id="sec-operators">
      <div class="section-head">
        <h2 class="section-title">Operators (Alliances &amp; Stronghold Abilities)</h2>
        <div class="sub-filters" style="flex-wrap:wrap !important;overflow-x:visible;">
          <div id="opTierFilters" style="display:flex;flex-wrap:wrap;gap:6px;">
            <button class="chip active" data-tier="all" type="button">All Tiers</button>
            <button class="chip" data-tier="1" type="button">Tier I</button>
            <button class="chip" data-tier="2" type="button">Tier II</button>
            <button class="chip" data-tier="3" type="button">Tier III</button>
            <button class="chip" data-tier="4" type="button">Tier IV</button>
            <button class="chip" data-tier="5" type="button">Tier V</button>
            <button class="chip" data-tier="6" type="button">Tier VI</button>
            <button class="chip" data-tier="pinned" type="button">Pinned Only</button>
          </div>
          <div class="op-select-row" style="display:flex;gap:6px;">
            <select id="opAllianceSelect" class="select-filter">
              <option value="all">All Alliances</option>
            </select>
            <select id="opTypeSelect" class="select-filter">
              <option value="all">All Ability Types</option>
              <option value="Can stack">Can stack</option>
              <option value="Combat">Combat</option>
              <option value="One-time">One-time</option>
              <option value="Prep">Prep</option>
              <option value="Special">Special</option>
            </select>
          </div>
        </div>
      </div>
      <div id="operatorsContainer"></div>
    </section>

    <!-- ==================== EQUIPMENT ==================== -->
    <section class="section-block" id="sec-equipment">
      <div class="section-head">
        <h2 class="section-title">Equipment</h2>
        <div class="sub-filters" id="equipTierFilters">
          <button class="chip active" data-tier="all" type="button">All Tiers (70)</button>
          <button class="chip" data-tier="1" type="button">Tier I</button>
          <button class="chip" data-tier="2" type="button">Tier II</button>
          <button class="chip" data-tier="3" type="button">Tier III</button>
          <button class="chip" data-tier="4" type="button">Tier IV</button>
          <button class="chip" data-tier="5" type="button">Tier V</button>
          <button class="chip" data-tier="6" type="button">Tier VI</button>
          <button class="chip" data-tier="new" type="button">New in S3</button>
        </div>
      </div>
      <div id="equipmentContainer"></div>
    </section>
  </main>

  <button id="backToTopBtn" class="back-to-top" type="button" onclick="window.scrollTo({top:0,behavior:'smooth'})">&#8593; Top</button>

  <script>
    const DATA = {
      alliances: $alliancesJson,
      strategies: $strategiesJson,
      operators: $operatorsJson,
      equipment: $equipmentJson,
      community: $communityJson
    };

    const ROMAN = ['', 'I', 'II', 'III', 'IV', 'V', 'VI'];

    // Fast lookup maps
    const OP_BY_NAME = {};
    DATA.operators.forEach(o => { OP_BY_NAME[o.enName] = o; });
    const ALLIANCE_BY_NAME = {};
    DATA.alliances.forEach(a => { ALLIANCE_BY_NAME[a.enName] = a; });
    const EQUIP_BY_NAME = {};
    DATA.equipment.forEach(e => { EQUIP_BY_NAME[e.enName] = e; });

    function esc(s) {
      if (!s) return '';
      return String(s)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
    }

    function formatEffect(text) {
      if (!text) return '<span style="color:var(--muted)">N/A</span>';
      let h = esc(text);
      const conds = [];
      h = h.replace(/&lt;([^&]+)&gt;/g, (_, c) => {
        conds.push(c);
        return '@@COND_' + (conds.length - 1) + '@@';
      });
      const tags = [];
      h = h.replace(/\[([^\]]+)\]/g, (_, t) => {
        tags.push(t);
        return '@@TAG_' + (tags.length - 1) + '@@';
      });
      const forms = [];
      h = h.replace(/([+-]?\([+-]?\d+(?:\.\d+)?[+-]\d+(?:\.\d+)?×stacks\)%?)/g, (_, f) => {
        forms.push(f);
        return '@@FORM_' + (forms.length - 1) + '@@';
      });
      h = h.replace(/(^|[\s/:;,(])([+-]?\d+(?:[.\u2013-]\d+)?(?:\s*%|s\b|\/s\b|x\b)?)/g, '`$1<span class="hl-num">`$2</span>');
      h = h.replace(/@@FORM_(\d+)@@/g, (_, i) => '<span class="hl-num">' + forms[Number(i)] + '</span>');
      h = h.replace(/@@TAG_(\d+)@@/g, (_, i) => '<span class="hl-tag">[' + tags[Number(i)] + ']</span>');
      h = h.replace(/@@COND_(\d+)@@/g, (_, i) => '<span class="hl-cond">&lt;' + conds[Number(i)] + '&gt;</span>');
      return h.replace(/\n/g, '<br>');
    }

    function statusBadge(st) {
      const labels = {
        new: 'NEW',
        reworked: 'REWORKED',
        modified: 'MODIFIED',
        unchanged: 'S2',
        returning: 'S2'
      };
      return '<span class="badge badge-' + st + '">' + (labels[st] || st) + '</span>';
    }

    // Load persisted pinned operators from localStorage
    let savedPins = [];
    try {
      savedPins = JSON.parse(localStorage.getItem('sp3_pinned_ops') || '[]');
    } catch (_) {}

    let state = {
      q: '',
      tab: 'all',
      communityAlliance: 'all',
      guideTabIdx: {},
      allianceFilter: 'all',
      strategyFilter: 'all',
      opTier: 'all',
      opAlliance: 'all',
      opType: 'all',
      equipTier: 'all',
      pinSearch: '',
      pinnedOps: new Set(savedPins.filter(n => OP_BY_NAME[n]))
    };

    function savePins() {
      try {
        localStorage.setItem('sp3_pinned_ops', JSON.stringify(Array.from(state.pinnedOps)));
      } catch (_) {}
    }

    window.togglePinOperator = function(opName, ev) {
      if (ev) ev.stopPropagation();
      if (!OP_BY_NAME[opName]) return;
      if (state.pinnedOps.has(opName)) {
        state.pinnedOps.delete(opName);
      } else {
        state.pinnedOps.add(opName);
      }
      savePins();
      renderAll();
    };

    // Populate Operator Alliance dropdown
    const opAllianceSelect = document.getElementById('opAllianceSelect');
    DATA.alliances.forEach(a => {
      const opt = document.createElement('option');
      opt.value = a.enName;
      opt.textContent = a.enName + ' (' + (a.type === 'core' ? 'Core' : 'Add-on') + ')';
      opAllianceSelect.appendChild(opt);
    });

    function matchQuery(fields) {
      if (!state.q) return true;
      const hay = fields.filter(Boolean).join(' ').toLowerCase();
      return hay.includes(state.q);
    }

    function renderEquipPill(enName) {
      const item = EQUIP_BY_NAME[enName];
      if (!item) return '<span class="recipe-pill"><span class="recipe-pill-name">' + esc(enName) + '</span></span>';
      return '<span class="recipe-pill" onclick="jumpToEquipment(\'' + esc(item.enName).replace(/'/g, "\\'") + '\')" title="Tier ' + ROMAN[item.tier] + ' · ' + esc(item.enEffect) + '">' +
        (item.icon ? '<img src="' + esc(item.icon) + '" alt="' + esc(item.enName) + '" loading="lazy">' : '') +
        '<span class="recipe-pill-name">' + esc(item.enName) + '</span>' +
        '<span class="tier-pill tier-' + item.tier + '" style="font-size:10px;padding:0 5px">T' + ROMAN[item.tier] + '</span>' +
      '</span>';
    }

    // ==================== PINNED SQUAD & RUN RECOMMENDER ENGINE ====================
    function scoreGuideAgainstPins(g) {
      if (state.pinnedOps.size === 0) {
        return { matchedOps: [], matchedCount: 0, bestTabIdx: 0, rating: (g.collects || 0) + (g.likes || 0) };
      }
      const allGuideOps = new Set();
      let bestTabIdx = 0;
      let bestTabMatches = -1;
      g.tabs.forEach((tb, idx) => {
        let tabMatchCount = 0;
        tb.chars.forEach(c => {
          allGuideOps.add(c.enName);
          if (state.pinnedOps.has(c.enName)) tabMatchCount++;
        });
        if (tabMatchCount > bestTabMatches) {
          bestTabMatches = tabMatchCount;
          bestTabIdx = idx;
        }
      });
      const matchedOps = Array.from(state.pinnedOps).filter(n => allGuideOps.has(n));
      return {
        matchedOps,
        matchedCount: matchedOps.length,
        bestTabIdx,
        rating: (g.collects || 0) + (g.likes || 0)
      };
    }

    function getSortedMatchingGuides() {
      if (state.pinnedOps.size === 0) return [];
      return DATA.community
        .map(g => ({ g, matchInfo: scoreGuideAgainstPins(g) }))
        .filter(x => x.matchInfo.matchedCount > 0)
        .sort((a, b) => {
          if (b.matchInfo.matchedCount !== a.matchInfo.matchedCount) {
            return b.matchInfo.matchedCount - a.matchInfo.matchedCount;
          }
          if (b.g.collects !== a.g.collects) {
            return b.g.collects - a.g.collects;
          }
          if (b.g.likes !== a.g.likes) {
            return b.g.likes - a.g.likes;
          }
          return b.g.views - a.g.views;
        });
    }

    function computePinAnalysis() {
      const pinnedArr = Array.from(state.pinnedOps).map(n => OP_BY_NAME[n]).filter(Boolean);
      const allianceCounts = {};
      pinnedArr.forEach(o => {
        o.enAlliances.forEach(a => {
          allianceCounts[a] = (allianceCounts[a] || 0) + 1;
        });
      });

      const matchingGuides = getSortedMatchingGuides();

      // Score unpinned operators primarily by how many top-matching & high-rated builds use them
      const opBuildStats = {};
      matchingGuides.forEach(({ g, matchInfo }) => {
        const seenInGuide = new Set();
        g.tabs.forEach(tb => {
          tb.chars.forEach(c => {
            if (!state.pinnedOps.has(c.enName) && OP_BY_NAME[c.enName] && !seenInGuide.has(c.enName)) {
              seenInGuide.add(c.enName);
              if (!opBuildStats[c.enName]) {
                opBuildStats[c.enName] = { maxMatchedOps: 0, buildCount: 0, bestRating: 0 };
              }
              const st = opBuildStats[c.enName];
              st.buildCount += 1;
              if (matchInfo.matchedCount > st.maxMatchedOps) {
                st.maxMatchedOps = matchInfo.matchedCount;
              }
              if (g.collects > st.bestRating) {
                st.bestRating = g.collects;
              }
            }
          });
        });
      });

      const candidateScores = Object.keys(opBuildStats).map(opName => {
        const o = OP_BY_NAME[opName];
        const st = opBuildStats[opName];
        const matchedAlliances = o.enAlliances.filter(a => (allianceCounts[a] || 0) > 0);
        return {
          op: o,
          maxMatchedOps: st.maxMatchedOps,
          buildCount: st.buildCount,
          bestRating: st.bestRating,
          matchedAlliances
        };
      });

      candidateScores.sort((a, b) =>
        b.maxMatchedOps - a.maxMatchedOps ||
        b.buildCount - a.buildCount ||
        b.bestRating - a.bestRating ||
        a.op.tier - b.op.tier
      );

      return { pinnedArr, allianceCounts, matchingGuides, candidateScores: candidateScores.slice(0, 8) };
    }

    window.scrollToGuideCard = function(guideId) {
      const card = document.getElementById('guide-card-' + guideId);
      if (card) {
        card.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    };

    function renderPinnedBarAndPlanner() {
      const { pinnedArr, allianceCounts, matchingGuides, candidateScores } = computePinAnalysis();
      const bar = document.getElementById('pinnedBar');
      const listEl = document.getElementById('pinnedList');
      const synEl = document.getElementById('pinnedSynergies');

      if (pinnedArr.length === 0) {
        bar.classList.remove('visible');
      } else {
        bar.classList.add('visible');
        listEl.innerHTML = '<strong style="font-size:12px;color:#fde047;margin-right:4px;">&#128204; Pinned (' + pinnedArr.length + '):</strong>' +
          pinnedArr.map(o => (
            '<span class="pinned-chip" onclick="togglePinOperator(\'' + esc(o.enName).replace(/'/g, "\\'") + '\')" title="Click to unpin ' + esc(o.enName) + '">' +
              (o.icon ? '<img src="' + esc(o.icon) + '" alt="">' : '') +
              '<span>' + esc(o.enName) + '</span>' +
              '<span class="pinned-chip-remove">&times;</span>' +
            '</span>'
          )).join('');

        const sortedAlliances = Object.keys(allianceCounts).sort((a, b) => {
          const ca = allianceCounts[a], cb = allianceCounts[b];
          const ra = ALLIANCE_BY_NAME[a] ? ALLIANCE_BY_NAME[a].required : 2;
          const rb = ALLIANCE_BY_NAME[b] ? ALLIANCE_BY_NAME[b].required : 2;
          return (cb / rb) - (ca / ra) || cb - ca;
        });
        synEl.innerHTML = '<span style="color:var(--muted);font-weight:600;">Active / Near Alliances:</span>' +
          sortedAlliances.map(a => {
            const cnt = allianceCounts[a];
            const alObj = ALLIANCE_BY_NAME[a];
            const req = alObj ? alObj.required : 2;
            const maxTarget = (alObj && alObj.type === 'core' && cnt >= req) ? 6 : req;
            const cls = cnt >= req ? 'active' : (cnt === req - 1 ? 'near' : '');
            return '<span class="synergy-meter ' + cls + '" onclick="filterByAlliance(\'' + esc(a).replace(/'/g, "\\'") + '\')" style="cursor:pointer">' +
              esc(a) + ' <span>' + cnt + '/' + maxTarget + '</span>' +
            '</span>';
          }).join('');
      }

      // Render Quick-Pin Picker
      const pickerEl = document.getElementById('quickPinPicker');
      const qPin = state.pinSearch;
      const pool = DATA.operators.filter(o => {
        if (!qPin) return true;
        return (o.enName + ' ' + o.cnName + ' ' + o.enAlliances.join(' ')).toLowerCase().includes(qPin);
      });
      pickerEl.innerHTML = pool.map(o => {
        const isP = state.pinnedOps.has(o.enName);
        return '<button type="button" class="pin-btn ' + (isP ? 'pinned' : '') + '" onclick="togglePinOperator(\'' + esc(o.enName).replace(/'/g, "\\'") + '\')">' +
          '<span class="tier-' + o.tier + '">T' + ROMAN[o.tier] + '</span> ' +
          esc(o.enName) +
        '</button>';
      }).join('');

      // Render Recommended Builds & Companion Operators in Planner
      const recEl = document.getElementById('plannerRecommendations');
      if (pinnedArr.length === 0) {
        recEl.innerHTML = '<h4>Recommended Builds &amp; Next Operators</h4>' +
          '<div style="color:var(--muted);font-size:12px;">Pin 1 or more Operators (by clicking any Operator avatar or using the pool on the left) to automatically filter &amp; rank Community Builds by <strong>Matched Operators (most &rarr; least)</strong> and <strong>Rating (high &rarr; low)</strong>!</div>';
      } else {
        const topBuildsHtml = matchingGuides.slice(0, 5).map(({ g, matchInfo }) => (
          '<div onclick="scrollToGuideCard(\'' + g.id + '\')" style="display:flex;justify-content:space-between;align-items:center;gap:8px;padding:6px 8px;background:var(--bg-1);border:1px solid var(--border);border-radius:6px;cursor:pointer;margin-bottom:5px;">' +
            '<div style="min-width:0;flex:1;">' +
              '<div style="font-weight:700;font-size:12px;color:var(--text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + esc(g.enTitle) + '</div>' +
              '<div style="font-size:11px;color:var(--muted);">Matches: <strong style="color:#5eead4">' + esc(matchInfo.matchedOps.join(', ')) + '</strong></div>' +
            '</div>' +
            '<div style="display:flex;align-items:center;gap:6px;flex-shrink:0;">' +
              '<span class="badge badge-match">' + matchInfo.matchedCount + '/' + pinnedArr.length + ' Ops</span>' +
              '<span style="font-size:11px;color:var(--gold);font-weight:700;">&#9733; ' + g.collects + '</span>' +
            '</div>' +
          '</div>'
        )).join('');

        const recsHtml = candidateScores.map(c => (
          '<span class="recipe-pill" onclick="togglePinOperator(\'' + esc(c.op.enName).replace(/'/g, "\\'") + '\')" title="Click to Pin · Used in ' + c.buildCount + ' matching build(s)">' +
            (c.op.icon ? '<img src="' + esc(c.op.icon) + '" alt="">' : '') +
            '<span class="recipe-pill-name">' + esc(c.op.enName) + '</span>' +
            '<span class="tier-pill tier-' + c.op.tier + '" style="font-size:10px;padding:0 4px">T' + ROMAN[c.op.tier] + '</span>' +
            '<span style="font-size:11px;color:var(--teal);">(' + c.buildCount + ' build' + (c.buildCount > 1 ? 's' : '') + ')</span>' +
          '</span>'
        )).join('');

        recEl.innerHTML =
          '<h4>Top Matching Builds (' + matchingGuides.length + ' found · Sorted by Matched Ops &darr; then Rating &#9733; &darr;)</h4>' +
          (topBuildsHtml || '<div style="color:var(--muted);font-size:12px;margin-bottom:8px;">No builds contain any of your pinned Operators yet.</div>') +
          '<h4 style="margin-top:10px;">Core Teammates in Top Matching Builds (Click to Pin)</h4>' +
          '<div style="display:flex;flex-wrap:wrap;gap:6px;">' + (recsHtml || '<span style="color:var(--muted)">No teammate suggestions found.</span>') + '</div>';
      }
    }

    // ==================== COMMUNITY STRATEGIES RENDERER ====================
    window.setGuideTab = function(guideId, idx) {
      state.guideTabIdx[guideId] = idx;
      renderCommunity();
    };

    window.pinEntireBuild = function(guideId) {
      const g = DATA.community.find(x => x.id === guideId);
      if (!g) return;
      const matchInfo = scoreGuideAgainstPins(g);
      const tabIdx = (state.guideTabIdx[guideId] !== undefined) ? state.guideTabIdx[guideId] : matchInfo.bestTabIdx;
      const tb = g.tabs[tabIdx] || g.tabs[0];
      state.pinnedOps.clear();
      tb.chars.forEach(c => {
        if (OP_BY_NAME[c.enName]) state.pinnedOps.add(c.enName);
      });
      savePins();
      renderAll();
    };

    function renderCommunity() {
      const enriched = DATA.community.map(g => {
        const matchInfo = scoreGuideAgainstPins(g);
        return { g, matchInfo };
      }).filter(({ g, matchInfo }) => {
        // When operators are pinned, automatically filter to builds that match >=1 pinned operator
        if (state.pinnedOps.size > 0 && matchInfo.matchedCount === 0) {
          return false;
        }
        if (state.communityAlliance === 'matched') {
          if (matchInfo.matchedCount === 0) return false;
        } else if (state.communityAlliance !== 'all') {
          const hasAl = g.tabs.some(tb => (tb.allAlliances || []).includes(state.communityAlliance));
          if (!hasAl) return false;
        }
        const opNames = g.tabs.flatMap(tb => tb.chars.map(c => c.enName + ' ' + c.cnName)).join(' ');
        const eqNames = g.tabs.flatMap(tb => tb.items.map(i => i.enName + ' ' + i.cnName)).join(' ');
        const stNames = g.strategies.map(s => s.enLeader + ' ' + s.enName + ' ' + s.cnLeader + ' ' + s.cnName).join(' ');
        const alNames = g.tabs.flatMap(tb => tb.allAlliances || []).join(' ');
        const notes = g.tabs.map(tb => tb.enIdea + ' ' + tb.cnIdea).join(' ');
        return matchQuery([g.enTitle, g.cnTitle, g.archetype, g.author, g.enScope, opNames, eqNames, stNames, alNames, notes]);
      });

      // Strict sorting:
      // 1. Number of matched pinned operators (most -> least)
      // 2. Build rating: Favorites/Collects (high -> low), then Likes (high -> low), then Views (high -> low)
      enriched.sort((a, b) => {
        if (state.pinnedOps.size > 0 && b.matchInfo.matchedCount !== a.matchInfo.matchedCount) {
          return b.matchInfo.matchedCount - a.matchInfo.matchedCount;
        }
        if (b.g.collects !== a.g.collects) {
          return b.g.collects - a.g.collects;
        }
        if (b.g.likes !== a.g.likes) {
          return b.g.likes - a.g.likes;
        }
        return b.g.views - a.g.views;
      });

      document.getElementById('cntCommunity').textContent = enriched.length;
      const el = document.getElementById('communityContainer');
      if (!enriched.length) {
        el.innerHTML = '<div class="empty-msg">No Community Builds match your current filter or pinned Operators.</div>';
        return;
      }

      el.innerHTML = enriched.map(({ g, matchInfo }) => {
        const tabIdx = (state.guideTabIdx[g.id] !== undefined)
          ? state.guideTabIdx[g.id]
          : (state.pinnedOps.size > 0 ? matchInfo.bestTabIdx : 0);
        const tb = g.tabs[tabIdx] || g.tabs[0];
        const isMatched = matchInfo.matchedCount > 0;

        const phaseTabsHtml = g.tabs.length > 1 ? (
          '<div class="phase-tabs">' +
            g.tabs.map((t, idx) => (
              '<button type="button" class="phase-btn ' + (idx === tabIdx ? 'active' : '') + '" onclick="setGuideTab(\'' + g.id + '\', ' + idx + ')">' +
                esc(t.enType) +
              '</button>'
            )).join('') +
          '</div>'
        ) : '';

        const stratsHtml = g.strategies.map(s => (
          '<span class="recipe-pill" title="' + esc(s.enEffect) + '">' +
            (s.icon ? '<img src="' + esc(s.icon) + '" alt="" style="border-radius:4px">' : '') +
            '<span class="recipe-pill-name">' + esc(s.enLeader) + ' · [' + esc(s.enName) + ']</span>' +
          '</span>'
        )).join(' ');

        const bondsHtml = [
          ...(tb.seasonBonds || []).map(a => '<span class="badge-alliance core-bond" onclick="filterByAlliance(\'' + esc(a).replace(/'/g, "\\'") + '\')">&#9733; ' + esc(a) + '</span>'),
          ...(tb.regularBonds || []).map(a => '<span class="badge-alliance" onclick="filterByAlliance(\'' + esc(a).replace(/'/g, "\\'") + '\')">' + esc(a) + '</span>')
        ].join('');

        const charsHtml = tb.chars.map(c => {
          const isP = state.pinnedOps.has(c.enName);
          return '<div class="op-card-mini ' + (isP ? 'is-pinned' : '') + '" onclick="togglePinOperator(\'' + esc(c.enName).replace(/'/g, "\\'") + '\')" title="Click to ' + (isP ? 'Unpin' : 'Pin') + ' ' + esc(c.enName) + ' (Tier ' + ROMAN[c.tier] + (c.isElite ? ', Elite' : '') + ')">' +
            (c.icon ? '<img src="' + esc(c.icon) + '" alt="' + esc(c.enName) + '" loading="lazy">' : '<div style="width:44px;height:44px"></div>') +
            '<span class="op-mini-tier tier-' + c.tier + '">' + ROMAN[c.tier] + '</span>' +
            (c.isElite ? '<span class="op-elite-star">E</span>' : '') +
            '<span class="op-mini-name" style="max-width:52px;font-weight:600;color:var(--text)">' + esc(c.enName) + '</span>' +
          '</div>';
        }).join('');

        const itemsHtml = (tb.items && tb.items.length)
          ? tb.items.map(it => renderEquipPill(it.enName)).join(' ')
          : '<span style="color:var(--muted);font-size:12px">Flexible / Situational</span>';

        return '<article id="guide-card-' + g.id + '" class="guide-card ' + (isMatched ? 'matched-build' : '') + '">' +
          '<div class="guide-header">' +
            '<div>' +
              '<h3 class="guide-title">' +
                esc(g.enTitle) + ' ' +
                (isMatched ? '<span class="badge badge-match">&#128204; Matches ' + matchInfo.matchedCount + '/' + state.pinnedOps.size + ' Pinned Op(s): ' + esc(matchInfo.matchedOps.join(', ')) + '</span>' : '') +
              '</h3>' +
              '<div class="cn-sub">' + esc(g.cnTitle) + '</div>' +
              '<div class="guide-meta">' +
                '<span style="color:#67cdff;font-weight:600">' + esc(g.archetype) + '</span>' +
                '<span>by <strong>' + esc(g.author) + '</strong> (Skland)</span>' +
                (g.enScope ? '<span>· ' + esc(g.enScope) + '</span>' : '') +
              '</div>' +
            '</div>' +
            '<div class="guide-actions-bar" style="display:flex;align-items:center;gap:8px;">' +
              '<button type="button" class="pin-btn" onclick="pinEntireBuild(\'' + g.id + '\')" title="Load this lineup into your Pinned Squad">&#128204; Pin Lineup</button>' +
              '<div class="guide-stats">' +
                '<span title="Favorites">&#9733; ' + g.collects + '</span>' +
                '<span title="Likes">&#9829; ' + g.likes + '</span>' +
                '<span title="Views">&#128065; ' + g.views + '</span>' +
              '</div>' +
            '</div>' +
          '</div>' +
          phaseTabsHtml +
          '<div class="guide-row">' +
            '<div class="guide-label">Strategist(s)</div>' +
            '<div style="display:flex;flex-wrap:wrap;gap:6px;">' + stratsHtml + '</div>' +
          '</div>' +
          '<div class="guide-row">' +
            '<div class="guide-label">Active Alliances</div>' +
            '<div>' + bondsHtml + '</div>' +
          '</div>' +
          '<div class="guide-row">' +
            '<div class="guide-label">Lineup <span style="font-weight:400;text-transform:none">(E = Elite)</span></div>' +
            '<div style="display:flex;flex-wrap:wrap;gap:6px;">' + charsHtml + '</div>' +
          '</div>' +
          '<div class="guide-row">' +
            '<div class="guide-label">Key Equipment</div>' +
            '<div style="display:flex;flex-wrap:wrap;gap:6px;">' + itemsHtml + '</div>' +
          '</div>' +
          '<div class="guide-notes">' +
            '<strong>Gameplay &amp; Tempo Guide:</strong> ' + formatEffect(tb.enIdea) +
            '<div class="cn-sub" style="margin-top:6px;padding-top:6px;border-top:1px dashed var(--border);">' + esc(tb.cnIdea) + '</div>' +
          '</div>' +
        '</article>';
      }).join('');
    }

    function renderAlliances() {
      const list = DATA.alliances.filter(a => {
        if (state.allianceFilter === 'core' && a.type !== 'core') return false;
        if (state.allianceFilter === 'addon' && a.type !== 'addon') return false;
        if (state.allianceFilter === 'new' && a.status !== 'new') return false;
        if (state.allianceFilter === 'reworked' && a.status !== 'reworked' && a.status !== 'modified') return false;
        const opNames = a.operators.map(o => o.en + ' ' + o.cn).join(' ');
        return matchQuery([a.enName, a.cnName, a.enEffect, a.s2Note, opNames]);
      });
      document.getElementById('cntAlliances').textContent = list.length;
      const el = document.getElementById('alliancesContainer');
      if (!list.length) {
        el.innerHTML = '<div class="empty-msg">No Alliances match your current search/filter.</div>';
        return;
      }
      const rows = list.map(a => {
        const opsHtml = a.operators.map(o => {
          const isP = state.pinnedOps.has(o.en);
          return '<div class="op-mini ' + (isP ? 'is-pinned' : '') + '" onclick="togglePinOperator(\'' + esc(o.en).replace(/'/g, "\\'") + '\')" title="Click to ' + (isP ? 'Unpin' : 'Pin') + ' ' + esc(o.en) + ' (Tier ' + ROMAN[o.tier] + ')">' +
            (o.icon ? '<img src="' + esc(o.icon) + '" alt="' + esc(o.en) + '" loading="lazy">' : '<div style="width:40px;height:40px;background:var(--bg-2);border-radius:6px"></div>') +
            '<span class="op-mini-tier tier-' + o.tier + '">' + ROMAN[o.tier] + '</span>' +
            '<span class="op-mini-name">' + esc(o.en) + '</span>' +
          '</div>';
        }).join('');
        return '<tr>' +
          '<td class="icon-cell">' + (a.icon ? '<img class="icon-bond" src="' + esc(a.icon) + '" alt="" loading="lazy">' : '') + '</td>' +
          '<td class="title-cell" style="min-width:165px">' +
            '<div class="entity-name">' + esc(a.enName) + ' ' + statusBadge(a.status) + '</div>' +
            '<div class="cn-sub">' + esc(a.cnName) + '</div>' +
            '<div class="meta-line">' + (a.type === 'core' ? 'Core Alliance' : 'Add-on Alliance') + ' · Req. <span class="hl-cond">' + a.required + '</span></div>' +
          '</td>' +
          '<td class="body-cell" data-label="Effect (Exact Scaling)" style="min-width:340px">' +
            formatEffect(a.enEffect) +
            (a.s2Note ? '<div class="s2-note"><strong>vs. Season 2:</strong> ' + esc(a.s2Note) + '</div>' : '') +
          '</td>' +
          '<td class="body-cell" data-label="Operators (Tap to Pin)" style="width:350px"><div class="op-grid">' + opsHtml + '</div></td>' +
        '</tr>';
      }).join('');
      el.innerHTML = '<div class="table-card"><div class="table-scroll"><table>' +
        '<thead><tr><th></th><th>Alliance</th><th>Effect (Exact Scaling)</th><th>Operators (Click to Pin)</th></tr></thead>' +
        '<tbody>' + rows + '</tbody></table></div></div>';
    }

    function renderStrategies() {
      const list = DATA.strategies.filter(s => {
        if (state.strategyFilter === 'new' && s.status !== 'new') return false;
        if (state.strategyFilter === 'reworked' && s.status !== 'reworked' && s.status !== 'modified') return false;
        if (state.strategyFilter === 'unchanged' && s.status !== 'unchanged') return false;
        return matchQuery([s.enLeader, s.cnLeader, s.enName, s.cnName, s.enEffect, s.enUnlock, s.s2Note]);
      });
      document.getElementById('cntStrategies').textContent = list.length;
      const el = document.getElementById('strategiesContainer');
      if (!list.length) {
        el.innerHTML = '<div class="empty-msg">No Strategies match your current search/filter.</div>';
        return;
      }
      const rows = list.map(s => (
        '<tr>' +
          '<td class="icon-cell">' + (s.icon ? '<img class="icon-avatar" src="' + esc(s.icon) + '" alt="" loading="lazy">' : '') + '</td>' +
          '<td class="title-cell" style="min-width:170px">' +
            '<div class="entity-name">' + esc(s.enLeader) + ' ' + statusBadge(s.status) + '</div>' +
            '<div class="cn-sub">' + esc(s.cnLeader) + ' · ' + esc(s.cnName) + '</div>' +
            '<div class="meta-line">Life Points <span class="hl-cond">' + s.hp + '</span></div>' +
          '</td>' +
          '<td class="body-cell" data-label="Strategy &amp; Effect" style="min-width:360px">' +
            '<div style="font-weight:700;color:#fbbf24;margin-bottom:2px">[' + esc(s.enName) + ']</div>' +
            formatEffect(s.enEffect) +
            (s.s2Note ? '<div class="s2-note"><strong>vs. Season 2:</strong> ' + esc(s.s2Note) + '</div>' : '') +
          '</td>' +
          '<td class="body-cell" data-label="Unlock Condition" style="min-width:200px;color:var(--muted);font-size:13px">' + esc(s.enUnlock) + '</td>' +
        '</tr>'
      )).join('');
      el.innerHTML = '<div class="table-card"><div class="table-scroll"><table>' +
        '<thead><tr><th></th><th>Strategist</th><th>Strategy &amp; Effect</th><th>Unlock Condition</th></tr></thead>' +
        '<tbody>' + rows + '</tbody></table></div></div>';
    }

    function renderOperators() {
      const list = DATA.operators.filter(o => {
        if (state.opTier === 'pinned') {
          if (!state.pinnedOps.has(o.enName)) return false;
        } else if (state.opTier !== 'all' && String(o.tier) !== state.opTier) {
          return false;
        }
        if (state.opAlliance !== 'all' && !o.enAlliances.includes(state.opAlliance)) return false;
        if (state.opType !== 'all' && o.abilityTypeEn !== state.opType) return false;
        return matchQuery([o.enName, o.cnName, o.enAlliances.join(' '), o.abilityTypeEn, o.enAbility, o.enUpgraded]);
      });
      document.getElementById('cntOperators').textContent = list.length;
      const el = document.getElementById('operatorsContainer');
      if (!list.length) {
        el.innerHTML = '<div class="empty-msg">No Operators match your current search/filter.</div>';
        return;
      }
      const rows = list.map(o => {
        const isP = state.pinnedOps.has(o.enName);
        const alBadges = o.enAlliances.map(a => (
          '<span class="badge-alliance" onclick="filterByAlliance(\'' + esc(a).replace(/'/g, "\\'") + '\')">' + esc(a) + '</span>'
        )).join('');
        return '<tr class="' + (isP ? 'row-pinned' : '') + '">' +
          '<td class="icon-cell">' + (o.icon ? '<img class="icon-avatar" src="' + esc(o.icon) + '" alt="" loading="lazy" style="cursor:pointer" onclick="togglePinOperator(\'' + esc(o.enName).replace(/'/g, "\\'") + '\')">' : '') + '</td>' +
          '<td class="title-cell" style="min-width:185px">' +
            '<div class="entity-name">' + esc(o.enName) + ' ' + statusBadge(o.status) + '</div>' +
            '<div class="cn-sub">' + esc(o.cnName) + '</div>' +
            '<div class="meta-line" style="display:flex;gap:6px;align-items:center;">' +
              '<span class="tier-pill tier-' + o.tier + '">Tier ' + ROMAN[o.tier] + '</span>' +
              '<button type="button" class="pin-btn ' + (isP ? 'pinned' : '') + '" onclick="togglePinOperator(\'' + esc(o.enName).replace(/'/g, "\\'") + '\')">' +
                (isP ? '&#128204; Pinned' : '+ Pin') +
              '</button>' +
            '</div>' +
          '</td>' +
          '<td class="body-cell" data-label="Alliances" style="min-width:150px">' + alBadges + '</td>' +
          '<td class="body-cell" data-label="Stronghold Ability (Base)" style="min-width:290px"><span class="badge-type">' + esc(o.abilityTypeEn) + '</span>' + formatEffect(o.enAbility) + '</td>' +
          '<td class="body-cell" data-label="Upgraded Ability (Elite)" style="min-width:290px"><span class="badge-type">' + esc(o.abilityTypeEn) + '</span>' + formatEffect(o.enUpgraded) + '</td>' +
        '</tr>';
      }).join('');
      el.innerHTML = '<div class="table-card"><div class="table-scroll"><table>' +
        '<thead><tr><th></th><th>Operator</th><th>Alliances</th><th>Stronghold Ability</th><th>Upgraded Ability (Elite)</th></tr></thead>' +
        '<tbody>' + rows + '</tbody></table></div></div>';
    }

    function renderEquipment() {
      const list = DATA.equipment.filter(e => {
        if (state.equipTier === 'new') {
          if (e.status !== 'new') return false;
        } else if (state.equipTier !== 'all' && String(e.tier) !== state.equipTier) {
          return false;
        }
        const recText = (Array.isArray(e.recipe) ? e.recipe.join(' ') : '') + ' ' + (e.combinesWith || '') + ' ' + (e.combinesInto || '');
        return matchQuery([e.enName, e.cnName, e.isomorphEn, e.enEffect, e.enUpgraded, e.s2Note, recText]);
      });
      document.getElementById('cntEquipment').textContent = list.length;
      const el = document.getElementById('equipmentContainer');
      if (!list.length) {
        el.innerHTML = '<div class="empty-msg">No Equipment items match your current search/filter.</div>';
        return;
      }
      const rows = list.map(e => {
        let recipeHtml = '';
        if (Array.isArray(e.recipe) && e.recipe.length === 2) {
          recipeHtml = '<div class="recipe-bar">' +
            '<span class="recipe-label">Combined From:</span>' +
            renderEquipPill(e.recipe[0]) +
            '<span class="recipe-op">+</span>' +
            renderEquipPill(e.recipe[1]) +
          '</div><br>';
        }
        let combinesIntoHtml = '';
        if (e.combinesWith && e.combinesInto) {
          combinesIntoHtml = '<div class="recipe-bar recipe-bar-sub">' +
            '<span class="recipe-label">Combines With</span>' +
            renderEquipPill(e.combinesWith) +
            '<span class="recipe-op">&rarr;</span>' +
            renderEquipPill(e.combinesInto) +
          '</div>';
        }
        return '<tr>' +
          '<td class="icon-cell">' + (e.icon ? '<img class="icon-equip" src="' + esc(e.icon) + '" alt="" loading="lazy">' : '') + '</td>' +
          '<td class="title-cell" style="min-width:190px">' +
            '<div class="entity-name">' + esc(e.enName) + ' ' + statusBadge(e.status) + '</div>' +
            '<div class="cn-sub">' + esc(e.cnName) + '</div>' +
            '<div class="meta-line">' +
              '<span class="tier-pill tier-' + e.tier + '">Tier ' + ROMAN[e.tier] + '</span> · ' +
              'Price <span style="color:var(--gold);font-weight:700">' + e.price + '</span>' +
              (e.isomorphEn ? ' · <span style="color:var(--teal);font-weight:600">(' + esc(e.isomorphEn) + ')</span>' : '') +
            '</div>' +
          '</td>' +
          '<td class="body-cell" data-label="Base Effect &amp; Recipe" style="min-width:320px">' +
            recipeHtml +
            formatEffect(e.enEffect) +
            combinesIntoHtml +
            (e.s2Note ? '<div class="s2-note"><strong>vs. Season 2:</strong> ' + esc(e.s2Note) + '</div>' : '') +
          '</td>' +
          '<td class="body-cell" data-label="Upgraded Effect" style="min-width:260px">' + formatEffect(e.enUpgraded) + '</td>' +
        '</tr>';
      }).join('');
      el.innerHTML = '<div class="table-card"><div class="table-scroll"><table>' +
        '<thead><tr><th></th><th>Equipment</th><th>Base Effect</th><th>Upgraded Effect</th></tr></thead>' +
        '<tbody>' + rows + '</tbody></table></div></div>';
    }

    function updateVisibility() {
      const map = {
        community: document.getElementById('sec-community'),
        alliances: document.getElementById('sec-alliances'),
        strategies: document.getElementById('sec-strategies'),
        operators: document.getElementById('sec-operators'),
        equipment: document.getElementById('sec-equipment')
      };
      Object.keys(map).forEach(k => {
        map[k].style.display = (state.tab === 'all' || state.tab === k) ? 'block' : 'none';
      });
    }

    function renderAll() {
      renderPinnedBarAndPlanner();
      renderCommunity();
      renderAlliances();
      renderStrategies();
      renderOperators();
      renderEquipment();
      updateVisibility();
    }

    // Interactive helpers
    window.filterByAlliance = function(alName) {
      state.opAlliance = alName;
      opAllianceSelect.value = alName;
      renderOperators();
      document.getElementById('sec-operators').scrollIntoView({ behavior: 'smooth' });
    };

    window.jumpToOperator = function(opName) {
      const input = document.getElementById('globalSearch');
      input.value = opName;
      state.q = opName.toLowerCase();
      document.getElementById('clearSearch').style.display = 'inline-block';
      renderAll();
      document.getElementById('sec-operators').scrollIntoView({ behavior: 'smooth' });
    };

    window.jumpToEquipment = function(eqName) {
      state.equipTier = 'all';
      document.querySelectorAll('#equipTierFilters .chip').forEach(b => {
        b.classList.toggle('active', b.dataset.tier === 'all');
      });
      const input = document.getElementById('globalSearch');
      input.value = eqName;
      state.q = eqName.toLowerCase();
      document.getElementById('clearSearch').style.display = 'inline-block';
      renderAll();
      document.getElementById('sec-equipment').scrollIntoView({ behavior: 'smooth' });
    };

    // Event bindings
    const searchInput = document.getElementById('globalSearch');
    const clearBtn = document.getElementById('clearSearch');
    searchInput.addEventListener('input', e => {
      state.q = e.target.value.trim().toLowerCase();
      clearBtn.style.display = state.q ? 'inline-block' : 'none';
      renderAll();
    });
    clearBtn.addEventListener('click', () => {
      searchInput.value = '';
      state.q = '';
      clearBtn.style.display = 'none';
      renderAll();
    });

    document.getElementById('pinPickerSearch').addEventListener('input', e => {
      state.pinSearch = e.target.value.trim().toLowerCase();
      renderPinnedBarAndPlanner();
    });

    document.getElementById('btnClearPins').addEventListener('click', () => {
      state.pinnedOps.clear();
      savePins();
      renderAll();
    });

    document.getElementById('btnViewRecommendations').addEventListener('click', () => {
      state.communityAlliance = 'matched';
      document.querySelectorAll('#communityAllianceFilters .chip').forEach(b => {
        b.classList.toggle('active', b.dataset.alliance === 'matched');
      });
      renderCommunity();
      document.getElementById('sec-community').scrollIntoView({ behavior: 'smooth' });
    });

    document.getElementById('btnFilterPinnedOps').addEventListener('click', () => {
      state.opTier = 'pinned';
      document.querySelectorAll('#opTierFilters .chip').forEach(b => {
        b.classList.toggle('active', b.dataset.tier === 'pinned');
      });
      renderOperators();
      document.getElementById('sec-operators').scrollIntoView({ behavior: 'smooth' });
    });

    window.addEventListener('keydown', e => {
      if (e.key === '/' && document.activeElement !== searchInput && document.activeElement.tagName !== 'INPUT') {
        e.preventDefault();
        searchInput.focus();
      } else if (e.key === 'Escape' && document.activeElement === searchInput) {
        searchInput.blur();
      }
    });

    document.querySelectorAll('#mainTabs .tab-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('#mainTabs .tab-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.tab = btn.dataset.tab;
        updateVisibility();
      });
    });

    document.querySelectorAll('#communityAllianceFilters .chip').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('#communityAllianceFilters .chip').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.communityAlliance = btn.dataset.alliance;
        renderCommunity();
      });
    });

    document.querySelectorAll('#allianceFilters .chip').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('#allianceFilters .chip').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.allianceFilter = btn.dataset.filter;
        renderAlliances();
      });
    });

    document.querySelectorAll('#strategyFilters .chip').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('#strategyFilters .chip').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.strategyFilter = btn.dataset.filter;
        renderStrategies();
      });
    });

    document.querySelectorAll('#opTierFilters .chip').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('#opTierFilters .chip').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.opTier = btn.dataset.tier;
        renderOperators();
      });
    });

    opAllianceSelect.addEventListener('change', e => {
      state.opAlliance = e.target.value;
      renderOperators();
    });

    document.getElementById('opTypeSelect').addEventListener('change', e => {
      state.opType = e.target.value;
      renderOperators();
    });

    document.querySelectorAll('#equipTierFilters .chip').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('#equipTierFilters .chip').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.equipTier = btn.dataset.tier;
        renderEquipment();
      });
    });

    document.getElementById('toggleS2').addEventListener('click', function() {
      this.classList.toggle('active');
      document.body.classList.toggle('show-s2');
    });

    document.getElementById('toggleCN').addEventListener('click', function() {
      this.classList.toggle('active');
      document.body.classList.toggle('show-cn');
    });

    const btnTogglePin = document.getElementById('btnTogglePinDrawer');
    if (btnTogglePin) {
      btnTogglePin.addEventListener('click', function() {
        const bar = document.getElementById('pinnedBar');
        const collapsed = bar.classList.toggle('mobile-collapsed');
        this.innerHTML = collapsed ? 'Show &#9660;' : 'Hide &#9650;';
      });
    }

    const backToTopBtn = document.getElementById('backToTopBtn');
    window.addEventListener('scroll', () => {
      if (window.scrollY > 400) {
        backToTopBtn.classList.add('visible');
      } else {
        backToTopBtn.classList.remove('visible');
      }
    }, { passive: true });

    renderAll();
  </script>
</body>
</html>
"@

$outFile = Join-Path $outDir 'index.html'
$rootFile = Join-Path $root 'index.html'
[IO.File]::WriteAllText($outFile, $html, (New-Object Text.UTF8Encoding $false))
[IO.File]::WriteAllText($rootFile, $html, (New-Object Text.UTF8Encoding $false))
"Generated $outFile and $rootFile ($((Get-Item $outFile).Length) bytes)"
