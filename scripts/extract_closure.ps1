# Extract table rows from Closure Wiki HTML pages into JSON (icon id + cell texts),
# used to build the CN<->EN glossary by joining rows on shared icon ids.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$raw = Join-Path $root 'data\raw'

function HtmlText([string]$s) {
    $s = [regex]::Replace($s, '<br\s*/?>', "`n")
    $s = [regex]::Replace($s, '<[^>]+>', '')
    $s = [System.Net.WebUtility]::HtmlDecode($s)
    return $s.Trim()
}

function Extract([string]$file) {
    $h = [IO.File]::ReadAllText((Join-Path $raw $file), [Text.Encoding]::UTF8)
    $h = [regex]::Replace($h, '<script[\s\S]*?</script>', '')
    # Collect headings with positions
    $heads = [regex]::Matches($h, '<h([23])[^>]*>([\s\S]*?)</h\1>') | ForEach-Object { [pscustomobject]@{ Pos = $_.Index; Level = [int]$_.Groups[1].Value; Text = (HtmlText $_.Groups[2].Value) } }
    $rows = @()
    foreach ($m in [regex]::Matches($h, '<tr[^>]*>([\s\S]*?)</tr>')) {
        $tr = $m.Groups[1].Value
        if ($tr -match '<th') { continue }
        $cells = @([regex]::Matches($tr, '<td[^>]*>([\s\S]*?)</td>') | ForEach-Object { $_.Groups[1].Value })
        if ($cells.Count -eq 0) { continue }
        $icon = ''
        $im = [regex]::Match($tr, '<img src="[^"]*/([^/"]+)\.(?:webp|png)"(?:[^>]*alt="([^"]*)")?')
        if ($im.Success) { $icon = $im.Groups[1].Value }
        $h2 = ''; $h3 = ''
        foreach ($x in $heads) { if ($x.Pos -lt $m.Index) { if ($x.Level -eq 2) { $h2 = $x.Text; $h3 = '' } else { $h3 = $x.Text } } }
        # operator links inside the row (slug + display name)
        $links = @([regex]::Matches($tr, '<a href="[^"]*/operators/([^"]+)" title="([^"]*)"[^>]*>\s*<img src="[^"]*/([^/"]+)\.webp"') | ForEach-Object { [ordered]@{ slug = $_.Groups[1].Value; name = [System.Net.WebUtility]::HtmlDecode($_.Groups[2].Value); char = $_.Groups[3].Value } })
        $rows += [ordered]@{ h2 = $h2; h3 = $h3; icon = $icon; cells = @($cells | ForEach-Object { HtmlText $_ }); links = $links }
    }
    return $rows
}

foreach ($f in 'closure_s2.html', 'closure_s3.html', 'closure_s3_zh.html') {
    $rows = Extract $f
    $out = Join-Path $raw ($f -replace '\.html$', '.rows.json')
    [IO.File]::WriteAllText($out, (ConvertTo-Json -InputObject @($rows) -Depth 6), (New-Object Text.UTF8Encoding $false))
    "$f -> $($rows.Count) rows"
}
