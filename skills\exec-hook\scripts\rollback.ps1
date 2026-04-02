# rollback.ps1
# 回滚脚本 - 从备份恢复文件

param(
    [Parameter(Mandatory=$false)]
    [string]$BackupDir = ".backup",
    
    [Parameter(Mandatory=$false)]
    [int]$Last = 1
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  文件回滚工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $BackupDir)) {
    Write-Host "[错误] 备份目录不存在: $BackupDir" -ForegroundColor Red
    Write-Host "没有找到任何备份" -ForegroundColor Yellow
    exit 1
}

# 获取所有备份文件
$backups = Get-ChildItem -Path $BackupDir -Recurse -File | Where-Object { $_.Extension -eq ".bak" } | Sort-Object LastWriteTime -Descending

if ($backups.Count -eq 0) {
    Write-Host "[信息] 没有找到备份文件" -ForegroundColor Yellow
    exit 0
}

Write-Host "找到 $($backups.Count) 个备份文件" -ForegroundColor Green
Write-Host ""

# 显示最近的备份
Write-Host "最近的备份:" -ForegroundColor White
Write-Host ""

$grouped = $backups | Group-Object { $_.Name -replace '\.\d{8}-\d{6}\.bak$', '' } | Select-Object -First 10

$groupNum = 1
foreach ($group in $grouped) {
    Write-Host "$groupNum. $($group.Name)" -ForegroundColor Yellow
    $group.Group | Select-Object -First 3 | ForEach-Object {
        $relPath = $_.FullName.Replace((Resolve-Path $BackupDir).Path, '').TrimStart('\')
        Write-Host "   - $($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')) - $relPath" -ForegroundColor Gray
    }
    if ($group.Group.Count -gt 3) {
        Write-Host "   ... 还有 $($group.Group.Count - 3) 个版本" -ForegroundColor DarkGray
    }
    Write-Host ""
    $groupNum++
}

Write-Host "----------------------------------------" -ForegroundColor Cyan

# 交互式回滚
if ($Last -gt 0) {
    $latest = $backups | Select-Object -First $Last
    foreach ($bak in $latest) {
        $originalName = $bak.Name -replace '\.\d{8}-\d{6}\.bak$', ''
        $originalDir = Split-Path $bak.FullName -Parent
        $relativePath = $bak.FullName.Replace($originalDir, '').Replace('\').Replace($bak.Name, '')
        
        # 尝试找到原始文件位置
        $possiblePaths = @(
            (Join-Path (Get-Location) "$relativePath\$originalName"),
            (Join-Path (Get-Location) $originalName),
            $originalName
        )
        
        $targetPath = $null
        foreach ($p in $possiblePaths) {
            if (Test-Path $p) {
                $targetPath = $p
                break
            }
        }
        
        if (-not $targetPath) {
            $targetPath = Join-Path (Get-Location) $originalName
        }
        
        Write-Host ""
        Write-Host "回滚: $($bak.Name)" -ForegroundColor Yellow
        Write-Host "  备份: $($bak.FullName)" -ForegroundColor Gray
        Write-Host "  目标: $targetPath" -ForegroundColor Gray
        
        try {
            Copy-Item $bak.FullName -Destination $targetPath -Force
            Write-Host "  ✓ 成功恢复到: $targetPath" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ 回滚失败: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "回滚完成!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "用法示例:" -ForegroundColor White
    Write-Host "  .\rollback.ps1 -Last 1    # 回滚最后一个备份" -ForegroundColor Gray
    Write-Host "  .\rollback.ps1 -Last 3    # 回滚最后3个备份" -ForegroundColor Gray
}
