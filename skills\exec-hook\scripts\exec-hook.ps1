# exec-hook.ps1
# 执行钩子核心脚本 - 操作拦截、日志记录、备份管理

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("before_exec", "before_write", "before_delete", "after_exec", "check_danger")]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$Path,
    
    [Parameter(Mandatory=$false)]
    [string]$Content,
    
    [Parameter(Mandatory=$false)]
    [string]$Command,
    
    [Parameter(Mandatory=$false)]
    [string]$BackupDir = ".backup",
    
    [Parameter(Mandatory=$false)]
    [string]$LogFile = $null
)

$ErrorActionPreference = "Continue"

# 默认日志位置
if (-not $LogFile) {
    $logDir = "$env:USERPROFILE\.openclaw\workspace\memory\exec-hooks"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    $LogFile = Join-Path $logDir "exec.log"
}

# 危险命令模式
$dangerousCommands = @(
    'rm\s+-rf',
    'del\s+/[fq]\s',
    'format\s+',
    'mkfs',
    'dd\s+if=',
    '>\/dev\/null',
    'drop\s+table',
    'delete\s+from\s+\w+\s*;',
    'truncate\s+',
    'shutdown',
    'reboot',
    'init\s+0|init\s+6'
)

$dangerousPaths = @(
    'C:\\Windows\\System32',
    '/etc/passwd',
    '/etc/shadow',
    '/bin/bash',
    '/usr/bin/'
)

function Write-Log {
    param($Message, $Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8
    
    switch ($Level) {
        "WARN" { Write-Host $logEntry -ForegroundColor Yellow }
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        default { Write-Host $logEntry -ForegroundColor Gray }
    }
}

function Backup-File {
    param($FilePath)
    
    if (-not (Test-Path $FilePath)) { return $null }
    
    $dir = Split-Path $FilePath -Parent
    $name = Split-Path $FilePath -Leaf
    
    # 创建备份目录
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }
    
    # 生成带时间戳的备份文件名
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = Join-Path $BackupDir "$name.$timestamp.bak"
    
    Copy-Item $FilePath -Destination $backupPath -Force
    
    # 只保留最近10个备份
    $oldBackups = Get-ChildItem -Path $BackupDir -Filter "$name.*.bak" | Sort-Object LastWriteTime -Descending | Select-Object -Skip 10
    foreach ($old in $oldBackups) {
        Remove-Item $old.FullName -Force
    }
    
    Write-Log "已备份: $FilePath -> $backupPath" "INFO"
    return $backupPath
}

function Test-DangerousPath {
    param($Path)
    
    foreach ($pattern in $dangerousPaths) {
        if ($Path -match [regex]::Escape($pattern)) {
            return $true
        }
    }
    return $false
}

function Test-DangerousCommand {
    param($Command)
    
    foreach ($pattern in $dangerousCommands) {
        if ($Command -match $pattern) {
            return $true
        }
    }
    return $false
}

# 执行对应的钩子动作
switch ($Action) {
    "check_danger" {
        $result = @{
            IsDangerous = $false
            Reason = $null
            RequiresConfirm = $false
        }
        
        if ($Command) {
            if (Test-DangerousCommand -Command $Command) {
                $result.IsDangerous = $true
                $result.Reason = "检测到危险命令"
                $result.RequiresConfirm = $true
            }
        }
        
        if ($Path) {
            if (Test-DangerousPath -Path $Path) {
                $result.IsDangerous = $true
                $result.Reason = "目标路径涉及系统关键目录"
                $result.RequiresConfirm = $true
            }
        }
        
        return $result | ConvertTo-Json
    }
    
    "before_exec" {
        Write-Log "准备执行命令: $Command" "INFO"
        
        if (Test-DangerousCommand -Command $Command) {
            Write-Log "警告: 命令可能危险 - $Command" "WARN"
            return @{ ConfirmRequired = $true; Message = "检测到危险命令，是否继续？" } | ConvertTo-Json
        }
        
        return @{ ConfirmRequired = $false } | ConvertTo-Json
    }
    
    "before_write" {
        Write-Log "准备写入文件: $Path" "INFO"
        
        $backupPath = $null
        if (Test-Path $Path) {
            $backupPath = Backup-File -FilePath $Path
        }
        
        return @{ BackupPath = $backupPath; Confirmed = $true } | ConvertTo-Json
    }
    
    "before_delete" {
        Write-Log "准备删除: $Path" "WARN"
        
        if (-not (Test-Path $Path)) {
            Write-Log "文件不存在: $Path" "ERROR"
            return @{ Confirmed = $false; Message = "文件不存在" } | ConvertTo-Json
        }
        
        # 尝试移动到回收站而非直接删除
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.Namespace(0).ParseName($Path)
        
        return @{ 
            Confirmed = $true; 
            Message = "建议移至回收站而非永久删除";
            MoveToTrash = $true 
        } | ConvertTo-Json
    }
    
    "after_exec" {
        param(
            [Parameter(Mandatory=$false)]
            [int]$ExitCode = 0,
            
            [Parameter(Mandatory=$false)]
            [string]$Output = ""
        )
        
        Write-Log "命令执行完成，退出码: $ExitCode" "INFO"
        
        if ($ExitCode -ne 0) {
            Write-Log "命令执行异常" "ERROR"
        }
        
        # 生成输出摘要
        $summary = if ($Output.Length -gt 500) { $Output.Substring(0, 500) + "..." } else { $Output }
        
        return @{
            ExitCode = $ExitCode
            Summary = $summary
            Success = ($ExitCode -eq 0)
        } | ConvertTo-Json
    }
}

Write-Log "未知动作: $Action" "ERROR"
