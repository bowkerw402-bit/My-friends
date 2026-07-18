param(
    [string]$Vault  = 'C:\Users\bowke\OneDrive\Documents\GitHub\My-friends',
    [string]$OutFile = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'Agent Transcripts.html'),
    [switch]$Open
)

# Builds one self contained, searchable HTML page of every Claude and Codex conversation,
# so the prompts and replies are readable without digging through folders.

Import-Module (Join-Path $PSScriptRoot 'OrchestratorLib.psm1') -Force -DisableNameChecking
Set-Utf8Console

function Esc([string]$s) {
    if ($null -eq $s) { return '' }
    return $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;')
}

$runsDir = Join-Path $Vault 'runs'
$runs = @()
if (Test-Path -LiteralPath $runsDir) {
    $runs = @(Get-ChildItem -LiteralPath $runsDir -Directory | Sort-Object Name -Descending)
}

$body = [System.Text.StringBuilder]::new()
$count = 0
foreach ($r in $runs) {
    $tPath = Join-Path $r.FullName 'transcript.md'
    if (-not (Test-Path -LiteralPath $tPath)) { $tPath = Join-Path $r.FullName '02-transcript.md' }   # pre lean-record runs
    if (-not (Test-Path -LiteralPath $tPath)) { continue }
    $txt = Read-Utf8 $tPath
    $mode = 'unknown'; $task = $r.Name
    $mPath = Join-Path $r.FullName 'manifest.json'
    if (Test-Path -LiteralPath $mPath) {
        try {
            $mf = (Read-Utf8 $mPath) | ConvertFrom-Json
            if ($mf.mode) { $mode = $mf.mode }
            if ($mf.task) { $task = ($mf.task -replace '\s+',' ') }
        } catch { }
    }
    if ($task.Length -gt 160) { $task = $task.Substring(0,160) + '...' }
    $when = $r.Name.Substring(0, [Math]::Min(17, $r.Name.Length)).Replace('--',' ')
    $badge = if ($mode -eq 'two-agent') { 'ok' } else { 'warn' }
    $count++

    [void]$body.Append('<section class="run"><header><span class="when">').Append((Esc $when))
    [void]$body.Append('</span><span class="badge ').Append($badge).Append('">').Append((Esc $mode)).Append('</span>')
    [void]$body.Append('<h2>').Append((Esc $task)).Append('</h2></header>')

    $pattern = '(?ms)^## (claude|codex) - round (\d+)\s+\(([^,]+), status: ([^\)]+)\)\r?\n(.*?)(?=^## |\z)'
    foreach ($m in [regex]::Matches($txt, $pattern)) {
        $agent = $m.Groups[1].Value
        $round = $m.Groups[2].Value
        $ts    = $m.Groups[3].Value
        $block = $m.Groups[5].Value
        $reply = $block
        $prompt = ''
        $di = $block.IndexOf('<details>')
        if ($di -ge 0) {
            $reply = $block.Substring(0, $di)
            $pm = [regex]::Match($block, '(?ms)~~~text\r?\n(.*?)\r?\n~~~')
            if ($pm.Success) { $prompt = $pm.Groups[1].Value }
        }
        $tShort = $ts
        if ($tShort -match 'T(\d{2}:\d{2})') { $tShort = $Matches[1] }

        [void]$body.Append('<div class="turn ').Append($agent).Append('">')
        [void]$body.Append('<div class="who"><b>').Append($agent).Append('</b> round ').Append($round).Append(' <span class="ts">').Append((Esc $tShort)).Append('</span></div>')
        [void]$body.Append('<div class="reply">').Append((Esc $reply.Trim())).Append('</div>')
        if ($prompt) {
            [void]$body.Append('<details><summary>the exact prompt it received</summary><pre>').Append((Esc $prompt.Trim())).Append('</pre></details>')
        }
        [void]$body.Append('</div>')
    }
    [void]$body.Append('</section>')
}

$css = @'
:root{--tx:#1f2328;--mut:#59636e;--line:#d0d7de;--bg:#ffffff;--card:#f6f8fa;
      --claude:#3457d5;--codex:#8250df;--ok:#137a3f;--okbg:#e8f5ec;--warn:#b45309;--warnbg:#fdf2e3;}
@media (prefers-color-scheme:dark){:root{--tx:#e6edf3;--mut:#9aa5b1;--line:#30363d;--bg:#0d1117;--card:#161b22;
      --claude:#8aa2f2;--codex:#c69bf5;--ok:#4ac47e;--okbg:#122a1c;--warn:#e0a558;--warnbg:#2a2113;}}
*{box-sizing:border-box}
body{margin:0;padding:28px 20px 60px;background:var(--bg);color:var(--tx);
     font:15px/1.5 ui-sans-serif,system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;}
.wrap{max-width:900px;margin:0 auto}
h1{font-size:22px;margin:0 0 4px}
.sub{color:var(--mut);font-size:13px;margin-bottom:18px}
#q{width:100%;padding:10px 12px;font-size:14px;border:1px solid var(--line);border-radius:9px;
   background:var(--card);color:var(--tx);margin-bottom:20px}
.run{border:1px solid var(--line);border-radius:12px;padding:14px 16px;margin:0 0 16px}
.run header{margin-bottom:10px}
.when{font-size:12px;color:var(--mut)}
.badge{font-size:11px;font-weight:650;padding:2px 9px;border-radius:20px;margin-left:8px}
.badge.ok{background:var(--okbg);color:var(--ok)} .badge.warn{background:var(--warnbg);color:var(--warn)}
.run h2{font-size:14px;font-weight:600;margin:7px 0 0}
.turn{border-left:3px solid var(--line);padding:8px 0 8px 12px;margin:12px 0}
.turn.claude{border-left-color:var(--claude)} .turn.codex{border-left-color:var(--codex)}
.who{font-size:12px;color:var(--mut);margin-bottom:5px}
.turn.claude .who b{color:var(--claude)} .turn.codex .who b{color:var(--codex)}
.ts{margin-left:6px}
.reply{white-space:pre-wrap;font-size:14px}
details{margin-top:8px}
summary{cursor:pointer;font-size:12px;color:var(--mut)}
pre{white-space:pre-wrap;background:var(--card);border:1px solid var(--line);border-radius:8px;
    padding:10px;font-size:12px;color:var(--mut);overflow-x:auto;margin:8px 0 0}
.hidden{display:none}
'@

$js = @'
const q=document.getElementById('q');
q.addEventListener('input',()=>{const v=q.value.toLowerCase();
document.querySelectorAll('.run').forEach(r=>{r.classList.toggle('hidden', v && !r.innerText.toLowerCase().includes(v));});});
'@

$html = [System.Text.StringBuilder]::new()
[void]$html.Append("<!doctype html><html><head><meta charset='utf-8'><title>Agent Transcripts</title>")
[void]$html.Append("<meta name='viewport' content='width=device-width,initial-scale=1'><style>").Append($css).Append("</style></head><body><div class='wrap'>")
[void]$html.Append("<h1>Agent transcripts</h1><div class='sub'>")
[void]$html.Append($count).Append(" runs. Every Claude and Codex exchange, newest first. Open a fold to see the exact prompt an agent received. Rebuilt ")
[void]$html.Append((Get-Date).ToString('yyyy-MM-dd HH:mm')).Append(".</div>")
[void]$html.Append("<input id='q' placeholder='Search everything, for example: codex, netlify, deliverability'>")
[void]$html.Append($body.ToString())
[void]$html.Append("</div><script>").Append($js).Append("</script></body></html>")

Write-Utf8NoBom $OutFile $html.ToString()
Write-Host ("Wrote " + $OutFile + "  (" + $count + " runs)") -ForegroundColor Green
if ($Open) { try { Invoke-Item -LiteralPath $OutFile } catch { } }
