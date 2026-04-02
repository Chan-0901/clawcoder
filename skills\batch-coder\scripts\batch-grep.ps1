# batch-grep.ps1
# Batch file search tool

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [Parameter(Mandatory=$true)]
    [string]$Pattern,
    
    [Parameter(Mandatory=$false)]
    [string]$Files = "*.*",
    
    [Parameter(Mandatory=$false)]
    [switch]$Recurse,
    
    [Parameter(Mandatory=$false)]
    [int]$ShowContext = 0,
    
    [Parameter(Mandatory=$false)]
    [switch]$CaseSensitive = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Regex = $false,
    
    [Parameter(Mandatory=$false)]
    [int]$MaxFiles = 100
)

$ErrorActionPreference = "Continue"
$Path = (Resolve-Path $Path).Path

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Batch File Search" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Directory: $Path"
Write-Host "Pattern: $Pattern"
Write-Host "Files: $Files"
Write-Host "Recurse: $Recurse"
Write-Host "Context: $ShowContext lines"
Write-Host ""

$getChildParams = @{
    Path = $Path
    File = $true
}

if ($Recurse) {
    $getChildParams['Recurse'] = $true
}

$files = Get-ChildItem @getChildParams | Where-Object { 
    $_.FullName -notmatch '\\node_modules\\' -and 
    $_.FullName -notmatch '\\.git\\' -and
    $_.FullName -notmatch '\\dist\\' 
} | Select-Object -First $MaxFiles

Write-Host "Searching $($files.Count) files..." -ForegroundColor Yellow
Write-Host ""

$results = @()
$totalMatches = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    
    $lineNum = 0
    $foundInFile = $false
    $fileMatches = @()
    
    foreach ($line in $content) {
        $lineNum++
        $match = $false
        
        if ($Regex) {
            if ($CaseSensitive) {
                $match = $line -cmatch $Pattern
            } else {
                $match = $line -match $Pattern
            }
        } else {
            $searchIn = if ($CaseSensitive) { $line } else { $line.ToLower() }
            $searchPattern = if ($CaseSensitive) { $Pattern } else { $Pattern.ToLower() }
            $match = $searchIn.Contains($searchPattern)
        }
        
        if ($match) {
            $totalMatches++
            $foundInFile = $true
            $fileMatches += [PSCustomObject]@{
                Line = $lineNum
                Content = $line.Trim()
            }
        }
    }
    
    if ($foundInFile) {
        $relPath = $file.FullName.Replace($Path, '').TrimStart('\')
        $results += [PSCustomObject]@{
            File = $relPath
            FullPath = $file.FullName
            Matches = $fileMatches
            MatchCount = $fileMatches.Count
        }
    }
}

# Output results
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Search Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Found $($results.Count) files, $totalMatches total matches" -ForegroundColor Green
Write-Host ""

foreach ($r in $results) {
    Write-Host "File: $($r.File) ($($r.MatchCount) matches)" -ForegroundColor Yellow
    
    if ($ShowContext -gt 0) {
        $content = Get-Content $r.FullPath -ErrorAction SilentlyContinue
        foreach ($m in $r.Matches) {
            $startLine = [Math]::Max(0, $m.Line - $ShowContext - 1)
            $endLine = [Math]::Min($content.Count, $m.Line + $ShowContext)
            
            for ($i = $startLine; $i -lt $endLine; $i++) {
                $prefix = if ($i + 1 -eq $m.Line) { "-> " } else { "   " }
                $color = if ($i + 1 -eq $m.Line) { "White" } else { "DarkGray" }
                Write-Host "   $prefix$($i+1): $($content[$i])" -ForegroundColor $color
            }
            Write-Host ""
        }
    } else {
        foreach ($m in $r.Matches | Select-Object -First 5) {
            $truncated = if ($m.Content.Length -gt 100) { $m.Content.Substring(0, 100) + "..." } else { $m.Content }
            Write-Host "   $($m.Line): $truncated" -ForegroundColor Gray
        }
        if ($r.MatchCount -gt 5) {
            Write-Host "   ... and $($r.MatchCount - 5) more" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
}

if ($results.Count -eq 0) {
    Write-Host "No matches found" -ForegroundColor Red
}
