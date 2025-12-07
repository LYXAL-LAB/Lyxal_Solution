# --- Configuration ---
$User = "root"
$Pass = "root"
$LogLevel = "trace"  # Mode trace pour plus de détails
$Bind = "127.0.0.1:8000"
$SurrealPath = "D:\Users\DUBREUCQ\Downloads\surreal-v3.0.0-alpha.16.windows-amd64.exe"
$Storage = "surreal.db"

# Dossier modules
$ModulesPath = "D:\Users\DUBREUCQ\Downloads\surrealdb-3.0.0-alpha.16\modules"

# Activation
$AllowAll = $true
$AllowGuests = $false
$AllowNet = @("0.0.0.0/0")

# CRITIQUE: L'ORDRE EST IMPORTANT - files AVANT surrealism !
$ExperimentalFeatures = "files,surrealism,graphql,define_api"

# --- Lancement ---
Write-Host "Demarrage de SurrealDB avec Surrealism..."
Write-Host "Executable       : $SurrealPath"
Write-Host "Modules          : $ModulesPath"
Write-Host "Experimental     : $ExperimentalFeatures"
Write-Host "-----------------------------------------------------------"

# Créer le dossier modules
if (-not (Test-Path $ModulesPath)) {
    New-Item -ItemType Directory -Path $ModulesPath -Force | Out-Null
    Write-Host "Dossier modules cree"
}

# Construction stockage
if ($Storage -eq "memory") {
    $StoragePath = "memory"
} else {
    $StoragePath = "rocksdb://$Storage"
}

# TRES IMPORTANT: Variables environnement
$env:SURREAL_CAPS_ALLOW_EXPERIMENTAL = $ExperimentalFeatures
$env:SURREAL_BUCKET_FOLDER_ALLOWLIST = $ModulesPath

# Arguments
$Arguments = @(
    "start"
    "--log", $LogLevel
    "--user", $User
    "--pass", $Pass
    "--bind", $Bind
    $StoragePath
)

if ($AllowAll) {
    $Arguments += "--allow-all"
}

if ($AllowGuests) {
    $Arguments += "--allow-guests"
}

if ($AllowNet) {
    foreach ($target in $AllowNet) {
        $Arguments += "--allow-net"
        $Arguments += $target
    }
}

# Lancement
Write-Host ""
Write-Host "Variables:"
Write-Host "  SURREAL_CAPS_ALLOW_EXPERIMENTAL=$ExperimentalFeatures"
Write-Host "  SURREAL_BUCKET_FOLDER_ALLOWLIST=$ModulesPath"
Write-Host ""
Write-Host "Commande: $SurrealPath $($Arguments -join ' ')"
Write-Host ""
& $SurrealPath @Arguments