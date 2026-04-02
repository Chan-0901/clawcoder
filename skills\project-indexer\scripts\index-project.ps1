# index-project.ps1
# Project Indexer - Scan project structure, extract code elements, build index

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectRoot,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = $null
)

$ErrorActionPreference = "Continue"

# Default output to memory directory
if (-not $OutputFile) {
    $memoryDir = "$env:USERPROFILE\.openclaw\workspace\memory\project-indexes"
    if (-not (Test-Path $memoryDir)) {
        New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null
    }
    $projectName = Split-Path $ProjectRoot -Leaf
    $OutputFile = "$memoryDir\$projectName-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
}

$ProjectRoot = (Resolve-Path $ProjectRoot).Path

Write-Host "Indexing project: $ProjectRoot"
Write-Host "Output file: $OutputFile"

$output = @()
$output += "# Project Index: $(Split-Path $ProjectRoot -Leaf)"
$output += "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$output += "Path: $ProjectRoot"
$output += ""

# 1. File structure
$output += "## File Structure"
$output += "```text"
$files = Get-ChildItem -Path $ProjectRoot -Recurse -File -Depth 10 | Where-Object { 
    $_.FullName -notmatch '\\node_modules\\' -and 
    $_.FullName -notmatch '\\.git\\' -and
    $_.FullName -notmatch '\\dist\\' -and
    $_.FullName -notmatch '\\build\\' -and
    $_.FullName -notmatch '\\target\\' -and
    $_.Name -notmatch '^\.'
} | Select-Object FullName, Extension, Length

foreach ($file in $files) {
    $relPath = $file.FullName.Replace($ProjectRoot, '').TrimStart('\')
    $size = [math]::Round($file.Length / 1024, 1)
    $output += "$relPath ($($file.Extension) $size KB)"
}
$output += "```"
$output += ""

# 2. Code elements extraction
$codeFiles = $files | Where-Object { $_.Extension -match '\.(py|js|ts|tsx|jsx|java|c|cpp|cs|go|rs|rb|php|swift|kt)$' }

$output += "## Code Elements"

$funcPattern = @{
    'py' = 'def\s+(\w+)\s*\('
    'js' = '(?:function\s+(\w+)|const\s+(\w+)\s*=|(\w+)\s*\([^)]*\)\s*\{)'
    'ts' = '(?:function\s+(\w+)|const\s+(\w+)\s*=|(\w+)\s*\([^)]*\)\s*\{|(\w+)\s*:\s*\([^)]*\)\s*=>)'
    'java' = '(?:public|private|protected)?\s*(?:static)?\s*\w+\s+(\w+)\s*\('
    'go' = 'func\s+(\w+)\s*\('
    'rs' = 'fn\s+(\w+)\s*\('
    'c' = '(?:void|int|char|float|double|struct\s+\w+)\s+(\w+)\s*\('
    'cpp' = '(?:void|int|char|float|double|\w+)\s+(\w+)\s*\([^)]*\)\s*\{'
}

$classPattern = @{
    'py' = 'class\s+(\w+)'
    'js' = 'class\s+(\w+)'
    'ts' = 'class\s+(\w+)'
    'java' = 'class\s+(\w+)'
    'go' = 'type\s+(\w+)\s+struct'
    'rs' = 'struct\s+(\w+)'
}

$output += "### Function Definitions"
$funcs = @()
foreach ($file in $codeFiles | Select-Object -First 50) {
    $ext = $file.Extension.TrimStart('.')
    if ($funcPattern[$ext]) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        $matches = [regex]::Matches($content, $funcPattern[$ext])
        foreach ($m in $matches) {
            $name = ($m.Groups | Where-Object { $_.Value -match '\w+' -and $_.Value -notmatch '^(?:function|const|var|let)$' } | Select-Object -First 1).Value
            if ($name) {
                $line = (Get-Content $file.FullName | Select-String -Pattern [regex]::Escape($m.Value) | Select-Object -First 1).LineNumber
                $relPath = $file.FullName.Replace($ProjectRoot, '').TrimStart('\')
                $funcs += "- $name - $relPath`:$line"
            }
        }
    }
}
if ($funcs.Count -gt 0) { $output += $funcs[0..[Math]::Min(99, $funcs.Count)] }
$output += ""

$output += "### Class Definitions"
$classes = @()
foreach ($file in $codeFiles | Select-Object -First 30) {
    $ext = $file.Extension.TrimStart('.')
    if ($classPattern[$ext]) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        $matches = [regex]::Matches($content, $classPattern[$ext])
        foreach ($m in $matches) {
            $name = $m.Groups[1].Value
            $line = (Get-Content $file.FullName | Select-String -Pattern [regex]::Escape($m.Value) | Select-Object -First 1).LineNumber
            $relPath = $file.FullName.Replace($ProjectRoot, '').TrimStart('\')
            $classes += "- $name - $relPath`:$line"
        }
    }
}
if ($classes.Count -gt 0) { $output += $classes[0..[Math]::Min(49, $classes.Count)] }

$output += ""

# 3. Statistics
$output += "## Statistics"
$extCounts = $files | Group-Object Extension | Sort-Object Count -Descending | ForEach-Object { "$($_.Name): $($_.Count) files" }
$output += $extCounts
$output += ""
$output += "Total: $($files.Count) files"

# Save
$output -join "`n" | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Indexing complete! Total $($files.Count) files"
Write-Host "Index file: $OutputFile"
