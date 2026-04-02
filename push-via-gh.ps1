# Upload files to GitHub via API
$BasePath = "C:\Users\Administrator\Documents\xiamo-skills"
$Owner = "Chan-0901"
$Repo = "xiamo-skills"

$files = Get-ChildItem -Path $BasePath -Recurse -File | Where-Object { 
    $_.FullName -notmatch '\.git' -and 
    $_.Name -ne "push-via-gh.ps1" -and
    $_.Name -ne "push-via-api.ps1"
}

$success = 0
$failed = 0

foreach ($file in $files) {
    $relativePath = $file.FullName.Replace("$BasePath\", "").Replace("$BasePath/", "")
    $content = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($file.FullName))
    
    # Check if file exists
    $checkUrl = "https://api.github.com/repos/$Owner/$Repo/contents/$relativePath"
    $sha = $null
    try {
        $existing = Invoke-RestMethod -Uri $checkUrl -Headers @{ "Authorization" = "token $((gh auth token).Trim())" } -ErrorAction SilentlyContinue
        if ($existing) {
            $sha = $existing.sha
            Write-Host "File exists, will update: $relativePath"
        }
    } catch {
        Write-Host "New file: $relativePath"
    }
    
    # Create/Update file
    $body = @{
        message = "Add $relativePath"
        content = $content
    }
    if ($sha) {
        $body.sha = $sha
    }
    
    try {
        $result = gh api repos/$Owner/$Repo/contents/$relativePath -f content=$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($content))) -f message="Add $relativePath" --method PUT 2>&1
        Write-Host "OK: $relativePath" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "FAIL: $relativePath - $_" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "Done! Success: $success, Failed: $failed"
