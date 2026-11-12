# Look up English names of strategy leaders not covered by Closure via PRTS operator pages.
$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
$g = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'data\glossary.auto.json') | ConvertFrom-Json
$S = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'data\cn\strategies.json') | ConvertFrom-Json
$ua = 'StrongholdProtocolWikiTranslator/1.0 (personal translation project)'
$res = [ordered]@{}
foreach ($s in $S) {
    $l = $s.leader
    if ($g.leaders.$l) { continue }
    if ($g.operators.$l) { $res[$l] = "$($g.operators.$l) [pool]"; continue }
    $url = 'https://prts.wiki/api.php?action=parse&format=json&prop=wikitext&redirects=1&page=' + [uri]::EscapeDataString($l)
    $json = & curl.exe -s -A $ua $url
    $txt = ''
    try { $txt = ($json | Out-String | ConvertFrom-Json).parse.wikitext.'*' } catch {}
    $m = [regex]::Match($txt, '\|\s*干员外文名\s*=\s*([^\n|]+)')
    if (-not $m.Success) { $m = [regex]::Match($txt, '\|\s*英文名\s*=\s*([^\n|]+)') }
    $res[$l] = $(if ($m.Success) { $m.Groups[1].Value.Trim() + ' [prts]' } else { '?' })
    Start-Sleep -Milliseconds 400
}
$res.GetEnumerator() | ForEach-Object { "$($_.Key) => $($_.Value)" }
