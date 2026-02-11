# Script de génération automatique de tous les batches de services
# Génère: seeds + i18n_keys + i18n_translations pour les batches 2-21

param(
    [int]$startBatch = 2,
    [int]$endBatch = 21
)

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         GÉNÉRATION AUTOMATIQUE DES BATCHES SERVICE                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Charger le mapping
$mapping = Get-Content "services_mapping.json" | ConvertFrom-Json
Write-Host "✅ $($mapping.Count) services chargés`n" -ForegroundColor Green

# Fonction de normalisation pour slugs
function Get-Slug($text) {
    $slug = $text.ToLower() `
        -replace '\.','_' `
        -replace '[^a-z0-9_]+','_' `
        -replace '^_|_$','' `
        -replace '__+','_'
    return $slug
}

# Fonction pour déterminer le provider_id
function Get-ProviderId($provider) {
    $slug = Get-Slug $provider
    return "provider:$slug"
}

# Fonction pour obtenir la catégorie par défaut
function Get-Category($service) {
    $s = $service.ToLower()
    if ($s -match 'aws|cloud|lambda|s3') { return 'cloud' }
    if ($s -match 'mail|email|smtp') { return 'communication' }
    if ($s -match 'crm|sales|customer') { return 'crm' }
    if ($s -match 'sheet|table|database|sql') { return 'data-storage' }
    if ($s -match 'task|project|asana') { return 'project-management' }
    if ($s -match 'ai|ml|transform|comprehend') { return 'ai' }
    if ($s -match 'marketing|campaign') { return 'marketing' }
    if ($s -match 'github|gitlab|git') { return 'development' }
    return 'productivity'
}

# Fonction pour obtenir la couleur par défaut
function Get-Color($provider) {
    $colors = @{
        'aws' = '#FF9900'
        'google' = '#4285F4'
        'microsoft' = '#00A4EF'
        'slack' = '#4A154B'
        'github' = '#181717'
        'airtable' = '#FCBD24'
        'asana' = '#F06A6A'
        'default' = '#5C6AC4'
    }
    $p = $provider.ToLower()
    foreach ($key in $colors.Keys) {
        if ($p -match $key) { return $colors[$key] }
    }
    return $colors['default']
}

# Génération des batches
for ($batch = $startBatch; $batch -le $endBatch; $batch++) {
    $start = ($batch - 1) * 20
    $end = [Math]::Min($start + 19, $mapping.Count - 1)
    $batchServices = $mapping[$start..$end]
    $count = $batchServices.Count
    
    Write-Host "📦 Batch $batch : Services $($start+1) à $($end+1) ($count services)" -ForegroundColor Yellow
    
    # ============================================================
    # FICHIER 1: Seeds
    # ============================================================
    $seedsContent = @"
-- =============================================================================================
-- |
-- | Fichier : service_batch${batch}_seeds.surql
-- | Module : integrations > reference > service
-- | Description : Seeds pour les services (Batch $batch : $count services)
-- |
-- | Source : n8n-master (génération automatique)
-- | Total : $count services
-- |
-- =============================================================================================

"@
    
    $serviceNum = $start + 1
    foreach ($svc in $batchServices) {
        $slug = Get-Slug $svc.Service
        $serviceId = "service:$slug"
        $providerId = Get-ProviderId $svc.Provider
        $category = Get-Category $svc.Service
        $color = Get-Color $svc.Provider
        $displayName = $svc.Service -replace '([a-z])([A-Z])','$1 $2'
        
        $seedsContent += @"
-- Service $serviceNum : $displayName
CREATE $serviceId SET
    identity = {
        name: "$($svc.Service)",
        slug: "$slug",
        display_name_i18n: i18n_key:service_${slug}_name,
        description_i18n: i18n_key:service_${slug}_desc,
        aliases: ["$($svc.Service)"]
    },
    presentation = {
        icon: NONE,
        color: "$color",
        display_order: 0,
        category_slug: "$category",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["$category"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: { n8n_version: "1.0", source: "n8n-master", auto_generated: true }
    },
    provider_id: $providerId,
    category_id: NONE,
    is_active: true;

"@
        $serviceNum++
    }
    
    $seedsContent | Out-File "service_batch${batch}_seeds.surql" -Encoding UTF8
    Write-Host "   ✓ Seeds créé" -ForegroundColor Green
    
    # ============================================================
    # FICHIER 2: i18n_keys
    # ============================================================
    $keysContent = @"
-- =============================================================================================
-- |
-- | Fichier : service_batch${batch}_i18n_keys.surql
-- | Module : integrations > reference > service
-- | Description : Clés i18n pour les services (Batch $batch)
-- |
-- | Total : $($count * 2) clés ($count services × 2 clés: name + desc)
-- |
-- =============================================================================================

"@
    
    foreach ($svc in $batchServices) {
        $slug = Get-Slug $svc.Service
        $keysContent += @"
-- Service: $($svc.Service)
CREATE i18n_key:service_${slug}_name SET description = "Nom du service $($svc.Service)";
CREATE i18n_key:service_${slug}_desc SET description = "Description du service $($svc.Service)";

"@
    }
    
    $keysContent | Out-File "service_batch${batch}_i18n_keys.surql" -Encoding UTF8
    Write-Host "   ✓ i18n_keys créé" -ForegroundColor Green
    
    # ============================================================
    # FICHIER 3: i18n_translations
    # ============================================================
    $transContent = @"
-- =============================================================================================
-- |
-- | Fichier : service_batch${batch}_i18n_translations.surql
-- | Module : integrations > reference > service
-- | Description : Traductions i18n pour les services (Batch $batch)
-- |
-- | Langues : FR, EN, IT, DE, ES
-- | Total : $($count * 2 * 5) traductions ($count services × 2 clés × 5 langues)
-- |
-- =============================================================================================

"@
    
    foreach ($svc in $batchServices) {
        $slug = Get-Slug $svc.Service
        $displayName = $svc.Service -replace '([a-z])([A-Z])','$1 $2'
        
        # Nom (identique dans toutes les langues)
        $transContent += @"
-- $displayName
RELATE i18n_key:service_${slug}_name->translation->language:fr SET text = "$displayName";
RELATE i18n_key:service_${slug}_name->translation->language:en SET text = "$displayName";
RELATE i18n_key:service_${slug}_name->translation->language:it SET text = "$displayName";
RELATE i18n_key:service_${slug}_name->translation->language:de SET text = "$displayName";
RELATE i18n_key:service_${slug}_name->translation->language:es SET text = "$displayName";
RELATE i18n_key:service_${slug}_desc->translation->language:fr SET text = "Service $displayName pour automatisation";
RELATE i18n_key:service_${slug}_desc->translation->language:en SET text = "$displayName service for automation";
RELATE i18n_key:service_${slug}_desc->translation->language:it SET text = "Servizio $displayName per automazione";
RELATE i18n_key:service_${slug}_desc->translation->language:de SET text = "$displayName-Dienst für Automatisierung";
RELATE i18n_key:service_${slug}_desc->translation->language:es SET text = "Servicio $displayName para automatización";

"@
    }
    
    $transContent | Out-File "service_batch${batch}_i18n_translations.surql" -Encoding UTF8
    Write-Host "   ✓ i18n_translations créé`n" -ForegroundColor Green
}

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         GÉNÉRATION TERMINÉE ✅                                         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "📊 RÉSUMÉ:`n" -ForegroundColor Yellow
$totalBatches = $endBatch - $startBatch + 1
$totalFiles = $totalBatches * 3
Write-Host "   • Batches créés: $totalBatches" -ForegroundColor White
Write-Host "   • Fichiers générés: $totalFiles" -ForegroundColor White
Write-Host "   • Services traités: $(($endBatch * 20) - (($startBatch - 1) * 20))" -ForegroundColor White
Write-Host ""

