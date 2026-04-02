# batch-generate.ps1
# 从模板批量生成文件

param(
    [Parameter(Mandatory=$true)]
    [string]$Template,
    
    [Parameter(Mandatory=$true)]
    [string]$Data,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputDir,
    
    [Parameter(Mandatory=$false)]
    [string]$FileNamePattern = "{{name}}",
    
    [Parameter(Mandatory=$false)]
    [string]$Delimiter = ","
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  批量模板生成工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查模板文件
if (-not (Test-Path $Template)) {
    Write-Host "[错误] 模板文件不存在: $Template" -ForegroundColor Red
    exit 1
}

# 检查数据文件
if (-not (Test-Path $Data)) {
    Write-Host "[错误] 数据文件不存在: $Data" -ForegroundColor Red
    exit 1
}

# 创建输出目录
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# 读取模板
$templateContent = Get-Content $Template -Raw

# 读取数据
$dataExt = [System.IO.Path]::GetExtension($Data).ToLower()
$items = @()

if ($dataExt -eq ".csv") {
    # CSV格式
    $csvData = Import-Csv -Path $Data -Delimiter $Delimiter
    $headers = ($csvData[0].PSObject.Properties | ForEach-Object { $_.Name })
    
    foreach ($row in $csvData) {
        $item = @{}
        foreach ($header in $headers) {
            $item[$header] = $row.$header
        }
        $items += [PSCustomObject]$item
    }
} elseif ($dataExt -eq ".json") {
    # JSON格式
    $jsonData = Get-Content $Data -Raw | ConvertFrom-Json
    if ($jsonData -is [System.Array]) {
        $items = $jsonData
    } else {
        $items = @($jsonData)
    }
} else {
    Write-Host "[错误] 不支持的数据格式: $dataExt" -ForegroundColor Red
    Write-Host "支持的格式: .csv, .json" -ForegroundColor Gray
    exit 1
}

Write-Host "模板: $Template"
Write-Host "数据: $Data ($($items.Count) 条记录)"
Write-Host "输出: $OutputDir"
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  正在生成文件..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$generated = 0
$errors = 0

# 获取模板中的所有变量
$templateVars = [regex]::Matches($templateContent, '\{\{(\w+)\}\}') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique

foreach ($item in $items) {
    try {
        # 生成文件名
        $fileName = $FileNamePattern
        foreach ($var in $templateVars) {
            $value = if ($item.PSObject.Properties[$var]) { $item.$var } else { "{{$var}}" }
            $fileName = $fileName -replace "\{\{$var\}\}", $value
        }
        
        # 清理文件名中的非法字符
        $fileName = $fileName -replace '[\\/:*?"<>|]', '_'
        
        # 替换模板内容
        $content = $templateContent
        foreach ($var in $templateVars) {
            $value = if ($item.PSObject.Properties[$var]) { $item.$var } else { "" }
            $content = $content -replace "\{\{$var\}\}", $value
        }
        
        # 写入文件
        $outputPath = Join-Path $OutputDir $fileName
        Set-Content -Path $outputPath -Value $content -Encoding UTF8
        
        Write-Host "✓ $fileName" -ForegroundColor Green
        $generated++
    } catch {
        Write-Host "✗ $($item.name): $($_.Exception.Message)" -ForegroundColor Red
        $errors++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  生成完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "成功: $generated 个文件" -ForegroundColor Green
if ($errors -gt 0) {
    Write-Host "失败: $errors 个文件" -ForegroundColor Red
}
