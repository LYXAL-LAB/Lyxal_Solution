param([int]$batchNum)
$mapping = Get-Content "services_mapping.json" | ConvertFrom-Json
$start = ($batchNum - 1) * 20
$end = [Math]::Min($start + 19, $mapping.Count - 1)
$services = $mapping[$start..$end]
Write-Host "Batch $batchNum : Services $($start+1) à $($end+1) ($($services.Count) services)"
# Fonction de normalisation
function Get-Slug($text) {
    $text.ToLower() -replace '[^a-z0-9]+','-' -replace '^-|-$',''
}
# Export pour debug
$services | Select-Object -First 5 | ForEach-Object {
    Write-Host "   $($_.Provider)/$($_.Service)  service:$(Get-Slug $_.Service)"
}
