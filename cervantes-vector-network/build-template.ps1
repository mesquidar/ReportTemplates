$ErrorActionPreference = 'Stop'

$packageRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$partsRoot = Join-Path $packageRoot 'parts'
$manifest = Get-Content -LiteralPath (Join-Path $packageRoot 'template.json') -Raw | ConvertFrom-Json

function Read-Part([string]$relativePath) {
    return (Get-Content -LiteralPath (Join-Path $packageRoot $relativePath) -Raw).Trim()
}

$headerPart = $manifest.parts | Where-Object type -eq 'Header' | Sort-Object order
$coverPart = $manifest.parts | Where-Object type -eq 'Cover' | Sort-Object order
$bodyParts = $manifest.parts | Where-Object type -eq 'Body' | Sort-Object order
$footerPart = $manifest.parts | Where-Object type -eq 'Footer' | Sort-Object order

$html = [System.Text.StringBuilder]::new()
[void]$html.AppendLine('<!DOCTYPE html>')
[void]$html.AppendLine('<html lang="en" xmlns="http://www.w3.org/1999/xhtml">')
[void]$html.AppendLine('<head>')
[void]$html.AppendLine('    <meta charset="utf-8"/>')
[void]$html.AppendLine('    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>')
[void]$html.AppendLine('    <meta name="description" content="Cervantes Vector Network penetration testing report"/>')
[void]$html.AppendLine('    <title>{{ProjectName}} — Vector Network Report</title>')
[void]$html.AppendLine('</head>')
[void]$html.AppendLine('<body>')

[void]$html.AppendLine('    <header>')
[void]$html.AppendLine('        <!-- report-zone:header:start -->')
foreach ($part in $headerPart) {
    [void]$html.AppendLine("        <!-- gallery-part:$($part.key):start -->")
    [void]$html.AppendLine((Read-Part $part.html))
    [void]$html.AppendLine("        <!-- gallery-part:$($part.key):end -->")
}
[void]$html.AppendLine('        <!-- report-zone:header:end -->')
[void]$html.AppendLine('    </header>')

[void]$html.AppendLine('    <cover>')
[void]$html.AppendLine('        <!-- report-zone:cover:start -->')
foreach ($part in $coverPart) {
    [void]$html.AppendLine("        <!-- gallery-part:$($part.key):start -->")
    [void]$html.AppendLine((Read-Part $part.html))
    [void]$html.AppendLine("        <!-- gallery-part:$($part.key):end -->")
}
[void]$html.AppendLine('        <!-- report-zone:cover:end -->')
[void]$html.AppendLine('    </cover>')

[void]$html.AppendLine('    <main>')
[void]$html.AppendLine('        <!-- report-zone:body:start -->')
foreach ($part in $bodyParts) {
    [void]$html.AppendLine("        <!-- gallery-part:$($part.key):start -->")
    [void]$html.AppendLine((Read-Part $part.html))
    [void]$html.AppendLine("        <!-- gallery-part:$($part.key):end -->")
}
[void]$html.AppendLine('        <!-- report-zone:body:end -->')
[void]$html.AppendLine('    </main>')

[void]$html.AppendLine('    <footer>')
[void]$html.AppendLine('        <!-- report-zone:footer:start -->')
foreach ($part in $footerPart) {
    [void]$html.AppendLine("        <!-- gallery-part:$($part.key):start -->")
    [void]$html.AppendLine((Read-Part $part.html))
    [void]$html.AppendLine("        <!-- gallery-part:$($part.key):end -->")
}
[void]$html.AppendLine('        <!-- report-zone:footer:end -->')
[void]$html.AppendLine('    </footer>')
[void]$html.AppendLine('</body>')
[void]$html.AppendLine('</html>')

$css = [System.Text.StringBuilder]::new()
[void]$css.AppendLine((Get-Content -LiteralPath (Join-Path $partsRoot 'base.css') -Raw).Trim())
[void]$css.AppendLine()
foreach ($part in $manifest.parts) {
    [void]$css.AppendLine("/* gallery-part:$($part.key):start */")
    [void]$css.AppendLine((Read-Part $part.css))
    [void]$css.AppendLine("/* gallery-part:$($part.key):end */")
    [void]$css.AppendLine()
}

[System.IO.File]::WriteAllText((Join-Path $packageRoot 'template.html'), $html.ToString(), [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $packageRoot 'template.css'), $css.ToString(), [System.Text.UTF8Encoding]::new($false))
