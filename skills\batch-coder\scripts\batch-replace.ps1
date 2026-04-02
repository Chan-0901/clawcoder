# batch-replace.ps1
# Batch text replacement tool

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [Parameter(Mandatory=$true)]
    [string]$Find,
    
    [Parameter(Mandatory=$true)]
    [string]$Replace,
    
    [Parameter(Mandatory=$false)]
    [string]$Pattern = "*.*",
    
    [Parameter(Mandatory=$false)]
    [switch]$Recurse,
    
    [Parameter(Mandatory=$false)]
    [switch]$Preview,
    
    [Parameter(Mandatory=$false)]
    [switch]$CaseSensitive = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Regex = $false
)

$ErrorActionPreference = "Continue"
$Path = (Resolve-Path $Path).Path

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Batch Text Replacement Tool" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Directory: $Path"
Write-Host "Find: $Find"
Write-Host "Replace: $Replace"
Write-Host "Pattern: $Pattern"
Write-Host "Recurse: $Recurse"
Write-Host "Regex: $Regex"
Write-Host ""

# Get file list
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
    $_.FullName -notmatch '\\dist\\' -and
    $_.FullName -notmatch '\\build\\'
}

Write-Host "Found $($files.Count) files" -ForegroundColor Yellow
Write-Host ""

if ($files.Count -eq 0) {
    Write-Host "No matching files found" -ForegroundColor Red
    exit 0
}

# Create backup directory
$backupDir = Join-Path $Path ".backup"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = Join-Path $backupDir "replace-$timestamp"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

# Statistics
$totalChanges = 0
$totalFiles = 0
$changes = @()

# Process each file
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    
    # Determine replacement method
    if ($Regex) {
        if ($CaseSensitive) {
            $newContent = $content -creplace $Find, $Replace
        } else {
            $newContent = $content -replace $Find, $Replace
        }
    } else {
        if ($CaseSensitive) {
            $newContent = $content -replace [regex]::Escape($Find), $Replace
        } else {
            $newContent = $content -ireplace [regex]::Escape($Find), $Replace
        }
    }
    
    if ($content -ne $newContent) {
        $matchCount = ([regex]::Matches($content, [regex]::Escape($Find), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
        $totalFiles++
        $totalChanges += $matchCount
        
        $relPath = $file.FullName.Replace($Path, '').TrimStart('\')
        $fileSize = [math]::Round($file.Length / 1024, 1)
        $changes += [PSCustomObject]@{
            File = $relPath
            Changes = $matchCount
            Size = $fileSize
        }
        
        # Preview mode
        if ($Preview) {
            Write-Host "[Preview] $relPath - $matchCount changes" -ForegroundColor Yellow
        }
        
        # Backup original file
        $backupPath = Join-Path $backupDir $relPath
        $backupFileDir = Split-Path $backupPath -Parent
        if (-not (Test-Path $backupFileDir)) {
            New-Item -ItemType Directory -Path $backupFileDir -Force | Out-Null
        }
        Copy-Item $file.FullName -Destination $backupPath -Force
        
        # Write new content
        if (-not $Preview) {
            Set-Content -Path $file.FullName -Value $newContent -NoNewline -Encoding UTF8
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files affected: $totalFiles" -ForegroundColor Green
Write-Host "Total changes: $totalChanges" -ForegroundColor Green
Write-Host "Backup directory: $backupDir" -ForegroundColor Gray
Write-Host ""

if ($Preview) {
    Write-Host "[Preview Mode] No actual changes made" -ForegroundColor Magenta
    Write-Host "Remove -Preview flag to execute changes" -ForegroundColor Magenta
} else {
    Write-Host "Changes completed!" -ForegroundColor Green
}

# Show changes list
if ($changes.Count -gt 0) {
    Write-Host ""
    Write-Host "Changed files:" -ForegroundColor White
    foreach ($c in $changes) {
        Write-Host "  $($c.File) ($($c.Changes) changes, $($c.Size) KB)" -ForegroundColor Gray
    }
}
