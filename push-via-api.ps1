# Push to GitHub via API
param(
    [string]$Owner = "Chan-0901",
    [string]$Repo = "xiamo-skills",
    [string]$Branch = "main",
    [string]$BasePath = "C:\Users\Administrator\Documents\xiamo-skills"
)

$token = (gh auth token).Trim()
$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
}

$baseRef = "https://api.github.com/repos/$Owner/$Repo/git/refs/heads/$Branch"
$refResponse = Invoke-RestMethod -Uri $baseRef -Headers $headers -Method Get
$latestSha = $refResponse.object.sha
Write-Host "Latest commit SHA: $latestSha"

$files = Get-ChildItem -Path $BasePath -Recurse -File | Where-Object { $_.FullName -notmatch '\.git' }

$treeItems = @()

foreach ($file in $files) {
    $relativePath = $file.FullName.Replace("$BasePath\", "").Replace("$BasePath/", "")
    $content = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($file.FullName))
    
    $blobUrl = "https://api.github.com/repos/$Owner/$Repo/git/blobs"
    $blobBody = @{
        content = $content
        encoding = "base64"
    } | ConvertTo-Json
    
    $blobResponse = Invoke-RestMethod -Uri $blobUrl -Headers $headers -Method Post -Body $blobBody -ContentType "application/json"
    
    $treeItems += @{
        path = $relativePath
        mode = "100644"
        type = "blob"
        sha = $blobResponse.sha
    }
    
    Write-Host "Added: $relativePath"
}

# Create new tree
$treeUrl = "https://api.github.com/repos/$Owner/$Repo/git/trees"
$treeBody = @{
    base_tree = $latestSha
    tree = $treeItems
} | ConvertTo-Json

$treeResponse = Invoke-RestMethod -Uri $treeUrl -Headers $headers -Method Post -Body $treeBody -ContentType "application/json"
Write-Host "Created tree: $($treeResponse.sha)"

# Create commit
$commitUrl = "https://api.github.com/repos/$Owner/$Repo/git/commits"
$commitBody = @{
    message = "feat: Initial commit - xiamo skills for OpenClaw"
    tree = $treeResponse.sha
    parents = @($latestSha)
} | ConvertTo-Json

$commitResponse = Invoke-RestMethod -Uri $commitUrl -Headers $headers -Method Post -Body $commitBody -ContentType "application/json"
Write-Host "Created commit: $($commitResponse.sha)"

# Update ref
$updateUrl = "https://api.github.com/repos/$Owner/$Repo/git/refs/heads/$Branch"
$updateBody = @{
    sha = $commitResponse.sha
    force = $true
} | ConvertTo-Json

$updateResponse = Invoke-RestMethod -Uri $updateUrl -Headers $headers -Method Patch -Body $updateBody -ContentType "application/json"
Write-Host "Updated branch: $($updateResponse.ref)"
Write-Host ""
Write-Host "Push completed!"
