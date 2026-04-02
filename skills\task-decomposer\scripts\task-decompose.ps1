# task-decompose.ps1
# 任务分解工具 - 分析复杂任务，生成执行计划

param(
    [Parameter(Mandatory=$true)]
    [string]$Task,
    
    [Parameter(Mandatory=$false)]
    [int]$MaxParallel = 3
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  任务分解分析器" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "原始任务: $Task" -ForegroundColor White
Write-Host ""

# 分析任务复杂度
$analysis = @"

## 任务分析

### 任务类型识别
"@

# 关键词识别
$keywords = @{
    '分析' = @('审查', '检查', '评估', '调研')
    '生成' = @('创建', '生成', '制作', '编写')
    '处理' = @('处理', '转换', '导入', '导出')
    '搜索' = @('搜索', '查找', '搜集', '抓取')
    '优化' = @('优化', '改进', '重构', '修复')
}

$detected = @()
foreach ($category in $keywords.Keys) {
    foreach ($keyword in $keywords[$category]) {
        if ($Task.Contains($keyword)) {
            $detected += "$category -> $keyword"
        }
    }
}

if ($detected.Count -gt 0) {
    $analysis += "**检测到的操作类型:**`n"
    foreach ($d in $detected) {
        $analysis += "- $d`n"
    }
    $analysis += "`n"
}

# 识别可能包含的子任务数量（基于连接词）
$connectors = @('并且', '同时', '还要', '以及', '然后', '接下来', '最后', '首先', '第一', '第二', '第三')
$subTaskIndicators = 0
foreach ($connector in $connectors) {
    $subTaskIndicators += ([regex]::Matches($Task, $connector)).Count
}

$analysis += "### 复杂度评估`n"
$complexity = "低"
if ($subTaskIndicators -ge 3 -or $Task.Length -gt 100) {
    $complexity = "中"
}
if ($subTaskIndicators -ge 5 -or $Task.Length -gt 300) {
    $complexity = "高"
}

$analysis += "- 连接词数量: $subTaskIndicators`n"
$analysis += "- 任务长度: $($Task.Length) 字符`n"
$analysis += "- **复杂度评级: $complexity**`n"
$analysis += "`n"

# 生成子任务建议
$analysis += "### 建议的执行策略`n"

if ($complexity -eq "低") {
    $analysis += "**模式**: 单任务直接执行`n"
    $analysis += "- 任务较简单，可以直接执行`n"
    $analysis += "- 无需分解，一步到位`n"
} elseif ($complexity -eq "中") {
    $analysis += "**模式**: 分解为 2-3 个子任务`n"
    $analysis += "- 建议拆解为独立步骤`n"
    $analysis += "- 可串行或小并行执行`n"
} else {
    $analysis += "**模式**: 深度分解 + 并行执行`n"
    $analysis += "- 建议拆解为多个独立任务`n"
    $analysis += "- 利用 subagent 并行处理`n"
    $analysis += "- 最后汇总结果`n"
}

$analysis += "`n### 子任务分解建议`n"

# 根据任务类型给出建议
if ($Task -match '分析|审查|检查') {
    $analysis += "1. **[并行] 数据收集与预处理**`n"
    $analysis += "2. **[并行] 多维度分析**`n"
    $analysis += "3. **[顺序] 汇总与报告生成**`n"
} elseif ($Task -match '生成|创建|制作') {
    $analysis += "1. **[并行] 素材准备**`n"
    $analysis += "2. **[顺序] 核心内容生成**`n"
    $analysis += "3. **[顺序] 整合与优化**`n"
} elseif ($Task -match '处理|转换|导入|导出') {
    $analysis += "1. **[并行] 分批处理**`n"
    $analysis += "2. **[顺序] 结果汇总**`n"
    $analysis += "3. **[顺序] 验证与报告**`n"
} else {
    $analysis += "1. **[并行] 独立子任务A**`n"
    $analysis += "2. **[并行] 独立子任务B**`n"
    $analysis += "3. **[顺序] 结果整合**`n"
}

$analysis += "`n### 预估执行时间`n"
switch ($complexity) {
    '低' { $analysis += "- 预计耗时: 1-2 分钟`n" }
    '中' { $analysis += "- 预计耗时: 3-5 分钟`n" }
    '高' { $analysis += "- 预计耗时: 5-15 分钟`n" }
}

$analysis += "`n---\n"
$analysis += "**建议**: "

if ($complexity -eq "低") {
    $analysis += "直接开始执行任务。`n"
} else {
    $analysis += "是否需要我按上述分解方案执行？`n"
}

return $analysis
