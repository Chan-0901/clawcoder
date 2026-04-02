# code-review.ps1
# 代码审查工具 - 自动检测常见问题

param(
    [Parameter(Mandatory=$false)]
    [string]$Path,
    
    [Parameter(Mandatory=$false)]
    [string]$Content,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("fast", "full", "security", "performance", "style")]
    [string]$Level = "full",
    
    [Parameter(Mandatory=$false)]
    [string]$Checks = "security,performance,style,logic",
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowCode = $true
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  代码审查工具 v1.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 问题分类
$issues = @{
    High = @()
    Medium = @()
    Low = @()
}

function Add-Issue {
    param($Severity, $Category, $File, $Line, $Message, $Code, $Suggestion)
    
    $issue = [PSCustomObject]@{
        Severity = $Severity
        Category = $Category
        File = $File
        Line = $Line
        Message = $Message
        Code = $Code
        Suggestion = $Suggestion
    }
    
    switch ($Severity) {
        'High' { $script:issues.High += $issue }
        'Medium' { $script:issues.Medium += $issue }
        'Low' { $script:issues.Low += $issue }
    }
}

# 检查规则定义
$rules = @(
    # 安全规则
    @{ Pattern = '\+\s*[\'"](?:SELECT|INSERT|UPDATE|DELETE|DROP|UNION).*[\'"]'; Severity = 'High'; Category = 'security'; Message = '疑似SQL注入风险'; Suggestion = '使用参数化查询或ORM' },
    @{ Pattern = 'innerHTML\s*='; Severity = 'High'; Category = 'security'; Message = 'XSS风险：直接赋值innerHTML'; Suggestion = '使用textContent或DOMPurify转义' },
    @{ Pattern = 'eval\s*\('; Severity = 'High'; Category = 'security'; Message = '代码注入风险：使用eval' ; Suggestion = '避免使用eval，考虑JSON.parse替代' },
    @{ Pattern = 'password\s*=\s*[\'"][^\'"]{1,}[感\']'; Severity = 'High'; Category = 'security'; Message = '硬编码密码风险'; Suggestion = '使用环境变量或密钥管理服务' },
    @{ Pattern = 'exec\s*\(|system\s*\(|\shell_exec\s*\('; Severity = 'High'; Category = 'security'; Message = '命令注入风险'; Suggestion = '使用白名单或专用API' },
    @{ Pattern = 'api[_-]?key\s*=\s*[\'"][^\'"]+[\'"]'; Severity = 'Medium'; Category = 'security'; Message = '疑似硬编码API密钥'; Suggestion = '使用环境变量' },
    @{ Pattern = 'console\.(log|warn|error)\s*\([^)]*(?:password|secret|token|key)[^)]*\)'; Severity = 'Medium'; Category = 'security'; Message = '敏感信息可能被打印到日志'; Suggestion = '移除或脱敏日志输出' },
    
    # 性能规则
    @{ Pattern = 'for\s*\([^)]*\}\s*\{[^}]*(?:query|fetch|axios|ajax|http)'; Severity = 'High'; Category = 'performance'; Message = 'N+1查询问题：循环内发起网络请求'; Suggestion = '将请求移到循环外，批量处理' },
    @{ Pattern = 'while\s*\([^)]*\)\s*\{[^}]{500,}\}'; Severity = 'Medium'; Category = 'performance'; Message = '疑似死循环或长循环' ; Suggestion = '确保循环有终止条件' },
    @{ Pattern = 'JSON\.parse\s*\([^)]*\)\s*.*\.forEach|forEach.*JSON\.parse'; Severity = 'Medium'; Category = 'performance'; Message = '循环内重复解析JSON'; Suggestion = '将JSON.parse移到循环外' },
    @{ Pattern = 'document\.createElement\s*\([^)]*\).*innerHTML\s*=|innerHTML\s*=.*createElement'; Severity = 'Medium'; Category = 'performance'; Message = '重复创建和销毁DOM元素'; Suggestion = '使用文档片段或缓存元素' },
    
    # 代码规范
    @{ Pattern = 'if\s*\([^)]*\)\s*\{[^}]{300,}\}'; Severity = 'Low'; Category = 'style'; Message = '函数过长，建议拆分'; Suggestion = '单个函数控制在100行以内' },
    @{ Pattern = 'if\s*\([^)]*\)\s*\{[^}]*if\s*\([^)]*\)\s*\{[^}]*if\s*\([^)]*\)\s*\{[^}]*if\s*\([^)]*\)'; Severity = 'Low'; Category = 'style'; Message = '嵌套过深，建议重构'; Suggestion = '使用早期返回或策略模式' },
    @{ Pattern = '\d{4,}|[\'"][0-9a-f]{32,}[\'"]'; Severity = 'Low'; Category = 'style'; Message = '疑似魔法数字或字符串'; Suggestion = '使用命名常量替代' },
    @{ Pattern = 'catch\s*\(\s*\w+\s*\)\s*\{\s*\}'; Severity = 'Medium'; Category = 'logic'; Message = '空catch块，错误被忽略'; Suggestion = '至少记录错误日志' },
    @{ Pattern = 'return\s+null\s*;?\s*(?:if|for|while)'; Severity = 'Medium'; Category = 'logic'; Message = 'null后可能继续执行'; Suggestion = '检查null返回值的使用' },
    @{ Pattern = '==\s*(?!true|false|null|undefined|0)'; Severity = 'Low'; Category = 'style'; Message = '建议使用===而非==' ; Suggestion = '严格相等避免类型转换' }
)

# 分析内容
function Analyze-Code {
    param($Content, $FileName = "stdin")
    
    $lines = $Content -split "`n"
    
    foreach ($rule in $rules) {
        $checkName = $rule.Category
        if ($Checks -notmatch $checkName) { continue }
        
        $matches = [regex]::Matches($Content, $rule.Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        
        foreach ($m in $matches) {
            $lineNum = 1
            $pos = 0
            while ($pos -lt $m.Index -and $pos -lt $Content.Length) {
                if ($Content[$pos] -eq "`n") { $lineNum++ }
                $pos++
            }
            
            # 获取上下文代码
            $code = ""
            if ($ShowCode -and $lineNum -le $lines.Count) {
                $startLine = [Math]::Max(0, $lineNum - 2)
                $endLine = [Math]::Min($lines.Count - 1, $lineNum + 1)
                $code = ($lines[$startLine..$endLine] -join "`n")
                if ($code.Length -gt 200) { $code = $code.Substring(0, 200) + "..." }
            }
            
            Add-Issue -Severity $rule.Severity -Category $rule.Category -File $FileName -Line $lineNum -Message $rule.Message -Code $code -Suggestion $rule.Suggestion
        }
    }
}

# 处理输入
if ($Path) {
    $Path = (Resolve-Path $Path -ErrorAction SilentlyContinue).Path
    if (-not $Path) {
        Write-Host "[错误] 路径不存在: $Path" -ForegroundColor Red
        exit 1
    }
    
    $files = Get-ChildItem -Path $Path -Recurse -File | Where-Object { 
        $_.Extension -match '\.(py|js|ts|tsx|jsx|java|c|cpp|cs|go|rs|rb|php|swift|kt)$' -and
        $_.FullName -notmatch '\\node_modules\\' -and
        $_.FullName -notmatch '\\\.git\\'
    }
    
    Write-Host "审查 $($files.Count) 个代码文件..." -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            Analyze-Code -Content $content -FileName $file.FullName
        }
    }
} elseif ($Content) {
    Analyze-Code -Content $Content -FileName "input"
} else {
    Write-Host "[错误] 请提供 -Path 或 -Content 参数" -ForegroundColor Red
    exit 1
}

# 输出报告
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  审查结果" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalIssues = $issues.High.Count + $issues.Medium.Count + $issues.Low.Count
Write-Host "📊 问题总数: $totalIssues" -ForegroundColor White
Write-Host "  🔴 高危: $($issues.High.Count)" -ForegroundColor Red
Write-Host "  🟡 中危: $($issues.Medium.Count)" -ForegroundColor Yellow
Write-Host "  🟢 低危: $($issues.Low.Count)" -ForegroundColor Green
Write-Host ""

if ($issues.High.Count -gt 0) {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  🔴 高危问题 (需要立即修复)" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    
    $i = 1
    foreach ($issue in $issues.High) {
        Write-Host "$i. [$($issue.Category)] $($issue.Message)" -ForegroundColor Red
        Write-Host "   位置: $($issue.File):$($issue.Line)" -ForegroundColor Gray
        if ($issue.Code -and $ShowCode) {
            Write-Host "   代码:" -ForegroundColor Gray
            foreach ($line in ($issue.Code -split "`n")) {
                Write-Host "      $line" -ForegroundColor DarkGray
            }
        }
        Write-Host "   建议: $($issue.Suggestion)" -ForegroundColor Cyan
        Write-Host ""
        $i++
    }
}

if ($issues.Medium.Count -gt 0) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  🟡 中危问题 (建议修复)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    
    $i = 1
    foreach ($issue in $issues.Medium | Select-Object -First 10) {
        Write-Host "$i. [$($issue.Category)] $($issue.Message)" -ForegroundColor Yellow
        Write-Host "   位置: $($issue.File):$($issue.Line)" -ForegroundColor Gray
        Write-Host "   建议: $($issue.Suggestion)" -ForegroundColor Cyan
        Write-Host ""
        $i++
    }
    
    if ($issues.Medium.Count -gt 10) {
        Write-Host "  ... 还有 $($issues.Medium.Count - 10) 个中危问题" -ForegroundColor Gray
        Write-Host ""
    }
}

if ($issues.Low.Count -gt 0) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  🟢 低危问题 / 改进建议" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    $i = 1
    foreach ($issue in $issues.Low | Select-Object -First 5) {
        Write-Host "$i. [$($issue.Category)] $($issue.Message)" -ForegroundColor Green
        Write-Host "   位置: $($issue.File):$($issue.Line)" -ForegroundColor Gray
        Write-Host "   建议: $($issue.Suggestion)" -ForegroundColor Cyan
        Write-Host ""
        $i++
    }
    
    if ($issues.Low.Count -gt 5) {
        Write-Host "  ... 还有 $($issues.Low.Count - 5) 个低危问题" -ForegroundColor Gray
        Write-Host ""
    }
}

if ($totalIssues -eq 0) {
    Write-Host "✅ 太棒了！没有发现问题" -ForegroundColor Green
    Write-Host ""
}

# 总结
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  审查完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
