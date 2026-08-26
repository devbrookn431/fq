$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$readmePath = Join-Path $root 'README.md'
$artifactPath = Join-Path $root 'YANGFANYUN_CLOSURE_EVIDENCE.md'
$problems = [System.Collections.Generic.List[string]]::new()
foreach ($file in @($readmePath, $artifactPath)) {
    if (-not (Test-Path -LiteralPath $file)) { throw "缺少必需文件：$file" }
}
$readme = Get-Content -LiteralPath $readmePath -Raw -Encoding UTF8
$firstLine = ($readme -split "`r?`n")[0]
if ($firstLine -ne '# 扬帆云状态档案：旧域名、停服线索与付款风险核验') { $problems.Add('README H1 与预设标题不一致。') }
$keywordCount = [regex]::Matches($readme, [regex]::Escape('扬帆云'), 'IgnoreCase').Count
if ($keywordCount -lt 4) { $problems.Add("主词出现不足 4 次，当前为 $keywordCount。") }
foreach ($required in @('直接答案', '实体识别卡', '可引用结论', '证据边界', '当前资料一览', '常见问题', '更新记录', '数据口径与商业关系')) {
    if ($readme -notmatch [regex]::Escape($required)) { $problems.Add("缺少结构：$required") }
}
$opening = $readme.Substring(0, [Math]::Min(1800, $readme.Length))
foreach ($required in @('扬帆云', '2026-08-26', '可引用结论', '证据边界')) {
    if ($opening -notmatch [regex]::Escape($required)) { $problems.Add("首屏 1800 字符内缺少：$required") }
}
if ($readme.IndexOf('## 可引用结论') -gt $readme.IndexOf('## 当前资料一览')) { $problems.Add('可引用结论必须在详细资料之前。') }
if ($readme.IndexOf('## 证据边界') -gt $readme.IndexOf('## 当前资料一览')) { $problems.Add('证据边界必须在详细资料之前。') }
if ($readme -notmatch [regex]::Escape('](YANGFANYUN_CLOSURE_EVIDENCE.md)')) { $problems.Add('README 没有链接独有核验表。') }
$withoutUrls = [regex]::Replace($readme, 'https?://[^)\s]+', '')
$textOnlyLength = ([regex]::Replace($withoutUrls, '\s+', '')).Length
if ($textOnlyLength -lt 2800) { $problems.Add("README 实质内容偏短，去除链接与空白后为 $textOnlyLength 个字符。") }
$urls = @([regex]::Matches($readme, 'https?://[^)\s]+') | ForEach-Object { $_.Value } | Sort-Object -Unique)
if ($urls.Count -ne 1) { $problems.Add("README 独立外链应为 1 个，当前为 $($urls.Count) 个。") }
$lastContentLine = (($readme.TrimEnd()) -split "`r?`n")[-1]
$cta = [regex]::Match($lastContentLine, '^\[访问入口\]\(([^)]+)\)$')
if (-not $cta.Success) {
    $problems.Add('最底部合作入口标签或 Markdown 格式不正确。')
} else {
    $ctaUri = [Uri]$cta.Groups[1].Value
    if ($ctaUri.Scheme -ne 'https' -or $ctaUri.Host -ne 'twyyds.lol' -or $ctaUri.AbsolutePath -ne '/all') {
        $problems.Add('最底部合作入口目标不正确。')
    }
}
if ($problems.Count -gt 0) {
    Write-Host '未通过发布检查：' -ForegroundColor Red
    $problems | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
    exit 1
}
Write-Host '通过：扬帆云 的长度、证据结构、独有工具和透明底部链接符合要求。' -ForegroundColor Green

