# ============================================================================
# SUITE OFFICIELLE DE VALIDATION PHASE 1 — LYXAL PIPELINE INGESTION V1
# Exécute l'audit complet des schémas SurrealDB v3.2.0, des index d'idempotence,
# du cloisonnement des 4 identités et de la machine à états de staging.
# ============================================================================

$ErrorActionPreference = "Stop"

$port = 8055
$workspaceRoot = "c:\Users\HP\Desktop\Lyxal_OS"
$ingestionRoot = "$workspaceRoot\crates\lyxal_pipeline_ingestion"
$catalogueRoot = "$workspaceRoot\crates\lyxal_catalogue"

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "DEMARRAGE DE LA SUITE DE TESTS SURREALDB PHASE 1 INGESTION" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

# 1. Génération cryptographique sécurisée de la clé JWT
if ($env:LYXAL_JWT_SECRET -and $env:LYXAL_JWT_SECRET.Length -ge 32) {
    $jwtSecret = $env:LYXAL_JWT_SECRET
    Write-Host "Cle JWT chargee depuis l'environnement (LYXAL_JWT_SECRET)." -ForegroundColor Green
} else {
    $bytes = New-Object byte[] 32
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $jwtSecret = [Convert]::ToBase64String($bytes)
    Write-Host "Cle JWT dynamique forte (256-bit CSPRNG) generee avec succes." -ForegroundColor Green
}

function New-JwtToken {
    param(
        [hashtable]$Payload,
        [string]$Secret
    )
    $header = @{ alg = "HS256"; typ = "JWT" } | ConvertTo-Json -Compress
    $payloadJson = $Payload | ConvertTo-Json -Compress

    $headerB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($header)).TrimEnd('=').Replace('+','-').Replace('/','_')
    $payloadB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($payloadJson)).TrimEnd('=').Replace('+','-').Replace('/','_')

    $toSign = "$headerB64.$payloadB64"
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [System.Text.Encoding]::UTF8.GetBytes($Secret)
    $sigBytes = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($toSign))
    $sigB64 = [Convert]::ToBase64String($sigBytes).TrimEnd('=').Replace('+','-').Replace('/','_')

    return "$headerB64.$payloadB64.$sigB64"
}

Write-Host "Demarrage du moteur SurrealDB v3.2.0 sur le port $port..."
$proc = Start-Process -FilePath "$workspaceRoot\surreal.exe" -ArgumentList "start --bind 127.0.0.1:$port --user root --pass root memory" -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 2

$results = [System.Collections.Generic.List[PSCustomObject]]::new()

function Execute-TestQuery {
    param(
        [string]$TestId,
        [string]$Description,
        [string]$Namespace,
        [string]$Database,
        [string]$Token,
        [string]$BasicAuth,
        [string]$Query,
        [string]$ExpectedOutcome # "SUCCESS" or "ERROR"
    )

    $headers = @{}
    if ($Namespace) { $headers['surreal-ns'] = $Namespace }
    if ($Database)  { $headers['surreal-db'] = $Database }
    if ($Token)     { $headers['Authorization'] = "Bearer $Token" }
    elseif ($BasicAuth) { $headers['Authorization'] = "Basic $BasicAuth" }

    $status = "UNKNOWN"
    $detail = ""
    $rawResult = $null

    try {
        $res = Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers $headers -ContentType "text/plain; charset=utf-8" -Body $Query
        $rawResult = $res
        
        $hasInternalErr = $false
        $errMsg = ""
        $items = @($res)
        foreach ($r in $items) {
            if ($r.status -eq 'ERR') {
                $hasInternalErr = $true
                $errMsg = $r.result
                break
            }
        }

        $isDeniedByPermission = $false
        if ($items.Count -gt 0 -and ($null -eq $items[0].result -or ($items[0].result -is [array] -and $items[0].result.Count -eq 0)) -and ($Query.StartsWith("CREATE") -or $Query.StartsWith("DELETE") -or $Query.StartsWith("UPDATE") -or $Query.StartsWith("SELECT"))) {
            $isDeniedByPermission = $true
        }

        if ($hasInternalErr -or $isDeniedByPermission) {
            if ($ExpectedOutcome -eq "ERROR") {
                $status = "PASSED"
                $detail = if ($isDeniedByPermission) { "Bloque par Row-Level Security (0 affecte : RLS Deny)" } else { "Rejete avec succes : $errMsg" }
            } else {
                $status = "FAILED"
                $detail = "Erreur inattendue : $errMsg"
            }
        } else {
            if ($ExpectedOutcome -eq "SUCCESS") {
                $status = "PASSED"
                $detail = "Execute avec succes"
            } else {
                $status = "FAILED"
                $detail = "Requete autorisee alors qu'un echec etait attendu"
            }
        }
    } catch [System.Net.WebException] {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $errBody = $reader.ReadToEnd()
        
        if ($ExpectedOutcome -eq "ERROR") {
            $status = "PASSED"
            $detail = "Bloque au niveau HTTP/Auth (401/403) : $errBody"
        } else {
            $status = "FAILED"
            $detail = "Erreur HTTP inattendue : $errBody"
        }
    } catch {
        $status = "FAILED"
        $detail = $_.Exception.Message
    }

    $results.Add([PSCustomObject]@{
        Id = $TestId
        Description = $Description
        Status = $status
        Details = $detail
        Raw = ($rawResult | ConvertTo-Json -Compress)
    })

    $color = if ($status -eq "PASSED") { "Green" } else { "Red" }
    Write-Host ("[{0}] {1,-14} : {2}" -f $status, $TestId, $Description) -ForegroundColor $color
    if ($status -eq "FAILED") {
        Write-Host "   -> DETAILS: $detail" -ForegroundColor Red
        Write-Host "   -> RAW RES: " ($rawResult | ConvertTo-Json -Depth 3)
    }
}

function Invoke-SurrealQuery {
    param(
        [string]$Namespace = "lyxal_ingestion",
        [string]$Database = "staging_db",
        [string]$Token,
        [string]$Query
    )
    $headers = @{
        'surreal-ns' = $Namespace
        'surreal-db' = $Database
        'Authorization' = "Bearer $Token"
    }
    return Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers $headers -ContentType "text/plain; charset=utf-8" -Body $Query
}

try {
    # -------------------------------------------------------------------------
    # INITIALISATION : CRÉATION DE L'ESPACE STAGING & ACCÈS RECORD JWT
    # -------------------------------------------------------------------------
    Write-Host "`nInitialisation de la base staging et deploiement des schemas d'ingestion..."
    $rootAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('root:root'))

    $initSql = @"
DEFINE NAMESPACE IF NOT EXISTS lyxal_ingestion;
USE NS lyxal_ingestion;
DEFINE DATABASE IF NOT EXISTS staging_db;
USE DB staging_db;

DEFINE TABLE IF NOT EXISTS ingestion_session SCHEMALESS;

DEFINE ACCESS ingestion_access ON DATABASE TYPE RECORD
    WITH JWT ALGORITHM HS256 KEY "$jwtSecret"
    AUTHENTICATE {
        IF `$token.iss != "lyxal-os" {
            THROW "INVALID_ISSUER: Le token JWT doit provenir de l'emetteur lyxal-os.";
        };
        IF `$token.aud != "lyxal-ingestion" AND `$token.aud != "lyxal-catalogue" {
            THROW "INVALID_AUDIENCE: Audience d'ingestion non autorisee.";
        };
        LET `$clean_id = string::replace(string::trim(`$token.sub), 'ingestion_session:', '');
        LET `$clean_id = string::replace(`$clean_id, 'service:', '');
        LET `$clean_id = string::replace(`$clean_id, 'user:', '');
        
        UPSERT type::record('ingestion_session', `$clean_id) SET
            role = `$token.role,
            agent_id = `$token.sub,
            scope = `$token.scope,
            updated_at = time::now();

        RETURN type::record('ingestion_session', `$clean_id);
    }
    DURATION FOR TOKEN 1h;
"@

    Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers @{'Authorization'="Basic $rootAuth"} -ContentType "text/plain; charset=utf-8" -Body $initSql | Out-Null

    # Déploiement des 6 schémas d'ingestion
    $schemaFiles = Get-ChildItem "$ingestionRoot\schema\*.surql" | Sort-Object Name
    foreach ($sf in $schemaFiles) {
        $content = Get-Content $sf.FullName -Raw -Encoding UTF8
        $deployRes = Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers @{'surreal-ns'='lyxal_ingestion'; 'surreal-db'='staging_db'; 'Authorization'="Basic $rootAuth"} -ContentType "text/plain; charset=utf-8" -Body $content
    }

    # Déploiement des définitions d'erreurs
    $errDefFile = "$ingestionRoot\error\ingestion\error_definitions.surql"
    if (Test-Path $errDefFile) {
        $errContent = "DEFINE TABLE IF NOT EXISTS error_definition SCHEMALESS;`n" + (Get-Content $errDefFile -Raw -Encoding UTF8)
        Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers @{'surreal-ns'='lyxal_ingestion'; 'surreal-db'='staging_db'; 'Authorization'="Basic $rootAuth"} -ContentType "text/plain; charset=utf-8" -Body $errContent | Out-Null
    }

    # Configuration de la base Master Catalogue pour tester le refus d'accès direct
    $masterSql = @"
DEFINE NAMESPACE IF NOT EXISTS lyxal_master;
USE NS lyxal_master;
DEFINE DATABASE IF NOT EXISTS master_catalogue;
USE DB master_catalogue;

DEFINE TABLE catalogue_item SCHEMAFULL
    PERMISSIONS
        FOR select WHERE true
        FOR create, update, delete WHERE `$token.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN `$token.scope;
DEFINE FIELD code ON catalogue_item TYPE string;
"@
    Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers @{'Authorization'="Basic $rootAuth"} -ContentType "text/plain; charset=utf-8" -Body $masterSql | Out-Null

    Write-Host "Schémas et bases initialisés avec succès.`n"

    # -------------------------------------------------------------------------
    # GÉNÉRATION DES 4 JETONS JWT DISTINCTS
    # -------------------------------------------------------------------------
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

    # 1. ingestion_agent (dédié à la réception et au chargement des flux bruts)
    $tokenIngestionAgent = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-ingestion"
        sub = "service:ingestion-worker-01"
        role = "ingestion_agent"
        scope = @("ingestion:batch:write")
        ns = "lyxal_ingestion"
        db = "staging_db"
        ac = "ingestion_access"
        iat = $now
        exp = $now + 3600
    } -Secret $jwtSecret

    # 2. qualification_agent (dédié à la normalisation, qualification et mise en quarantaine)
    $tokenQualificationAgent = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-ingestion"
        sub = "service:qualification-worker-01"
        role = "qualification_agent"
        scope = @("ingestion:staged:qualify")
        ns = "lyxal_ingestion"
        db = "staging_db"
        ac = "ingestion_access"
        iat = $now
        exp = $now + 3600
    } -Secret $jwtSecret

    # 3. steward_admin (Data Steward ayant autorité d'arbitrage et d'approbation)
    $tokenStewardAdmin = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-ingestion"
        sub = "user:data_steward_lead"
        role = "steward_admin"
        scope = @("ingestion:manifest:approve")
        ns = "lyxal_ingestion"
        db = "staging_db"
        ac = "ingestion_access"
        iat = $now
        exp = $now + 3600
    } -Secret $jwtSecret

    # 4. catalogue_sync_agent (Service habilité à publier vers le Master Catalogue)
    $tokenSyncAgent = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-ingestion"
        sub = "service:master-sync-worker"
        role = "catalogue_sync_agent"
        scope = @("catalogue:sync:write")
        ns = "lyxal_ingestion"
        db = "staging_db"
        ac = "ingestion_access"
        iat = $now
        exp = $now + 3600
    } -Secret $jwtSecret

    # =========================================================================
    # GROUPE 1 : TESTS D'ACCÈS, DROITS ET CLOISONNEMENT DES IDENTITÉS
    # =========================================================================

    # 1A. ingestion_agent crée un lot d'ingestion valide
    $batch1Hash = "a1b2c3d4e5f67890123456789012345678901234567890123456789012345678"
    $createBatchSql = @"
CREATE ingestion_batch:batch_placo_01 CONTENT {
    source_type: "FAB_DIS",
    source_format_version: "FAB-DIS 3.0",
    fournisseur_id: "SAINT_GOBAIN_PLACO",
    nom_fichier: "catalogue_placo_2026.csv",
    file_hash_blake3: "$batch1Hash",
    taille_octets: 1048576,
    statut: "RECEIVED",
    chunk_size: 500,
    cursor_offset: 0
};
"@
    Execute-TestQuery -TestId "INGEST-TEST-01A" `
        -Description "ingestion_agent cree legitimement un nouveau lot d'ingestion : succes" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenIngestionAgent `
        -Query $createBatchSql `
        -ExpectedOutcome "SUCCESS"

    # 1B. ingestion_agent crée des lignes brutes
    $createRawSql = @"
CREATE ingestion_raw_record:batch_placo_01_line_1 CONTENT {
    batch: ingestion_batch:batch_placo_01,
    ligne_numero: 1,
    row_hash: "1111111111111111111111111111111111111111111111111111111111111111",
    payload_brut: { ean: "3456789012345", ref: "BA13-2500", label: "Placoplatre BA13 2500x1200" }
};
CREATE ingestion_raw_record:batch_placo_01_line_2 CONTENT {
    batch: ingestion_batch:batch_placo_01,
    ligne_numero: 2,
    row_hash: "2222222222222222222222222222222222222222222222222222222222222222",
    payload_brut: { ean: "INVALID_GTIN", ref: "BA13-3000", label: "Placoplatre BA13 3000x1200" }
};
"@
    Execute-TestQuery -TestId "INGEST-TEST-01B" `
        -Description "ingestion_agent cree des enregistrements bruts dans ingestion_raw_record : succes" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenIngestionAgent `
        -Query $createRawSql `
        -ExpectedOutcome "SUCCESS"

    # 1C. ingestion_agent tente d'écrire en staging (réservé à qualification_agent)
    $illegalStagedSql = @"
CREATE ingestion_staged_item CONTENT {
    batch: ingestion_batch:batch_placo_01,
    raw_record: ingestion_raw_record:batch_placo_01_line_1,
    ligne_numero: 1,
    fabricant: "PLACO",
    reference_fabricant: "BA13",
    libelle_commercial: "BA13",
    unite_reference: "PCE",
    conditionnement: {},
    canonical_fingerprint: "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
    qualification: "VERIFIED"
};
"@
    Execute-TestQuery -TestId "INGEST-TEST-01C" `
        -Description "ingestion_agent tente de creer un article en staging : refuse par RLS" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenIngestionAgent `
        -Query $illegalStagedSql `
        -ExpectedOutcome "ERROR"

    # 1D. ingestion_agent tente de créer un manifeste de publication
    Execute-TestQuery -TestId "INGEST-TEST-01D" `
        -Description "ingestion_agent tente de creer un manifeste de publication : refuse par RLS" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenIngestionAgent `
        -Query "CREATE ingestion_publication_manifest CONTENT { batch: ingestion_batch:batch_placo_01, manifest_ref: 'HACK', seal_hash: '123' };" `
        -ExpectedOutcome "ERROR"

    # 1E. Cloisonnement : ingestion_agent tente d'écrire directement dans le Master Catalogue
    Execute-TestQuery -TestId "INGEST-TEST-01E" `
        -Description "ingestion_agent tente d'ecrire directement dans le Master Catalogue : refuse par RLS Master" `
        -Namespace "lyxal_master" -Database "master_catalogue" `
        -Token $tokenIngestionAgent `
        -Query "CREATE catalogue_item CONTENT { code: 'DIRECT_POLLUTION' };" `
        -ExpectedOutcome "ERROR"

    # 1F. qualification_agent tente de créer un lot brut (réservé à ingestion_agent)
    Execute-TestQuery -TestId "INGEST-TEST-01F" `
        -Description "qualification_agent tente de creer un lot brut : refuse par RLS" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenQualificationAgent `
        -Query "CREATE ingestion_batch CONTENT { source_type: 'CSV', fournisseur_id: 'HACK', nom_fichier: 'h.csv', file_hash_blake3: '1111111111111111111111111111111111111111111111111111111111111111', taille_octets: 10 };" `
        -ExpectedOutcome "ERROR"

    # 1G. qualification_agent insère un article en staging et met une anomalie en quarantaine
    $stagedItem1Hash = "3333333333333333333333333333333333333333333333333333333333333333"
    $qualifySql = @"
CREATE ingestion_staged_item:item_ba13 CONTENT {
    batch: ingestion_batch:batch_placo_01,
    raw_record: ingestion_raw_record:batch_placo_01_line_1,
    ligne_numero: 1,
    fabricant: "SAINT-GOBAIN PLACO",
    reference_fabricant: "BA13_2500",
    code_barre_gtin: "3456789012345",
    libelle_commercial: "Placoplatre BA13 2500x1200",
    unite_reference: "PCE",
    conditionnement: { quantite: 1.0, poids_kg: 28.5 },
    canonical_fingerprint: "$stagedItem1Hash",
    rules_version: "1.0.0",
    qualification: "VERIFIED",
    publication_action: "INSERT"
};
CREATE ingestion_quarantine_record CONTENT {
    batch: ingestion_batch:batch_placo_01,
    raw_record: ingestion_raw_record:batch_placo_01_line_2,
    ligne_numero: 2,
    code_erreur: "INGESTION_GTIN_INVALID",
    severite: "ERROR",
    champ_concerne: "code_barre_gtin",
    valeur_fautive: "INVALID_GTIN",
    cause_detaillee: "Longueur ou format GTIN invalide"
};
"@
    Execute-TestQuery -TestId "INGEST-TEST-01G" `
        -Description "qualification_agent cree un staged_item VERIFIED et log une anomalie en quarantaine : succes" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenQualificationAgent `
        -Query $qualifySql `
        -ExpectedOutcome "SUCCESS"

    # 1H. Interdiction d'auto-approbation : qualification_agent tente de s'approuver lui-même
    Execute-TestQuery -TestId "INGEST-TEST-01H" `
        -Description "qualification_agent tente d'auto-approuver un article : refuse (steward_admin requis)" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenQualificationAgent `
        -Query "UPDATE ingestion_staged_item:item_ba13 SET is_approved = true, approved_by = 'qualification_agent', approver_role = 'qualification_agent';" `
        -ExpectedOutcome "ERROR"

    # 1I. steward_admin approuve formellement un article VERIFIED
    $approveItemSql = @"
UPDATE ingestion_staged_item:item_ba13 SET 
    is_approved = true, 
    approved_by = 'user:data_steward_lead', 
    approver_role = 'steward_admin',
    approved_at = time::now();
"@
    Execute-TestQuery -TestId "INGEST-TEST-01I" `
        -Description "steward_admin approuve formellement l'article VERIFIED pour publication : succes" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenStewardAdmin `
        -Query $approveItemSql `
        -ExpectedOutcome "SUCCESS"

    # 1J. steward_admin tente d'approuver un article REJECTED : refus par le verrou moteur
    $createRejectedSql = @"
CREATE ingestion_staged_item:item_rejected CONTENT {
    batch: ingestion_batch:batch_placo_01,
    raw_record: ingestion_raw_record:batch_placo_01_line_2,
    ligne_numero: 2,
    fabricant: "SAINT-GOBAIN PLACO",
    reference_fabricant: "BA13_CORRUPTED",
    libelle_commercial: "Plaque corrompue",
    unite_reference: "PCE",
    conditionnement: {},
    canonical_fingerprint: "4444444444444444444444444444444444444444444444444444444444444444",
    qualification: "REJECTED"
};
"@
    $null = Invoke-SurrealQuery -Namespace "lyxal_ingestion" -Database "staging_db" -Token $tokenQualificationAgent -Query $createRejectedSql

    $illegalApproveRejectedSql = "UPDATE ingestion_staged_item:item_rejected SET is_approved = true, approved_by = 'user:data_steward_lead', approver_role = 'steward_admin';"
    Execute-TestQuery -TestId "INGEST-TEST-01J" `
        -Description "steward_admin tente d'approuver un article REJECTED : refuse par le verrou moteur evt_staged_guard" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenStewardAdmin `
        -Query $illegalApproveRejectedSql `
        -ExpectedOutcome "ERROR"

    # 1K. steward_admin crée et scelle un manifeste de publication
    $manifestSealHash = "5555555555555555555555555555555555555555555555555555555555555555"
    $createManifestSql = @"
CREATE ingestion_publication_manifest:manifest_placo_v1 CONTENT {
    batch: ingestion_batch:batch_placo_01,
    manifest_ref: "MANIF-2026-PLACO-001",
    manifest_version: 1,
    seal_hash: "$manifestSealHash",
    is_sealed: true,
    statut: "SEALED",
    nb_articles_insert: 1,
    nb_articles_update: 0
};
UPDATE ingestion_publication_manifest:manifest_placo_v1 SET 
    statut = "APPROVED",
    approved_by = "user:data_steward_lead",
    approver_role = "steward_admin",
    approved_at = time::now();
"@
    Execute-TestQuery -TestId "INGEST-TEST-01K" `
        -Description "steward_admin cree, scelle et approuve formellement le manifeste : succes" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenStewardAdmin `
        -Query $createManifestSql `
        -ExpectedOutcome "SUCCESS"

    # 1L. steward_admin tente d'exécuter lui-même la publication vers le Master (réservé à catalogue_sync_agent)
    Execute-TestQuery -TestId "INGEST-TEST-01L" `
        -Description "steward_admin tente de passer le manifeste a EXECUTING : refuse (catalogue_sync_agent requis)" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenStewardAdmin `
        -Query "UPDATE ingestion_publication_manifest:manifest_placo_v1 SET statut = 'EXECUTING';" `
        -ExpectedOutcome "ERROR"

    # 1M. catalogue_sync_agent lit le manifeste approuvé et prend en charge l'exécution
    Execute-TestQuery -TestId "INGEST-TEST-01M" `
        -Description "catalogue_sync_agent prend legitimement en charge le manifeste approuve : succes" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenSyncAgent `
        -Query "UPDATE ingestion_publication_manifest:manifest_placo_v1 SET statut = 'EXECUTING';" `
        -ExpectedOutcome "SUCCESS"


    # =========================================================================
    # GROUPE 2 : TESTS D'INDEX D'IDEMPOTENCE ET D'UNICITÉ
    # =========================================================================

    # 2A. Collision de lot : même source_type et même hash BLAKE3
    Execute-TestQuery -TestId "INGEST-TEST-02A" `
        -Description "Collision de lot avec meme source_type et meme file_hash_blake3 : bloque par index unique" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenIngestionAgent `
        -Query "CREATE ingestion_batch:dup_batch CONTENT { source_type: 'FAB_DIS', fournisseur_id: 'AUTRE', nom_fichier: 'dup.csv', file_hash_blake3: '$batch1Hash', taille_octets: 100 };" `
        -ExpectedOutcome "ERROR"

    # 2B. Collision de ligne brute dans le même lot
    Execute-TestQuery -TestId "INGEST-TEST-02B" `
        -Description "Collision de numero de ligne brute au sein du meme lot : bloque par index unique" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenIngestionAgent `
        -Query "CREATE ingestion_raw_record CONTENT { batch: ingestion_batch:batch_placo_01, ligne_numero: 1, row_hash: '9999999999999999999999999999999999999999999999999999999999999999', payload_brut: {} };" `
        -ExpectedOutcome "ERROR"

    # 2C. Collision métier en staging : même fabricant + même référence usine dans le même lot
    $dupBusinessSql = @"
CREATE ingestion_staged_item CONTENT {
    batch: ingestion_batch:batch_placo_01,
    raw_record: ingestion_raw_record:batch_placo_01_line_1,
    ligne_numero: 3,
    fabricant: "SAINT-GOBAIN PLACO",
    reference_fabricant: "BA13_2500",
    libelle_commercial: "Doublon BA13",
    unite_reference: "PCE",
    conditionnement: {},
    canonical_fingerprint: "6666666666666666666666666666666666666666666666666666666666666666",
    qualification: "VERIFIED"
};
"@
    Execute-TestQuery -TestId "INGEST-TEST-02C" `
        -Description "Collision metier staged_item (meme fabricant et reference usine dans le lot) : bloque par index unique" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenQualificationAgent `
        -Query $dupBusinessSql `
        -ExpectedOutcome "ERROR"

    # 2D. Collision de version de manifeste sur le même lot
    Execute-TestQuery -TestId "INGEST-TEST-02D" `
        -Description "Collision de version de manifeste sur le meme lot : bloque par index unique" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenStewardAdmin `
        -Query "CREATE ingestion_publication_manifest CONTENT { batch: ingestion_batch:batch_placo_01, manifest_ref: 'MANIF-DUP', manifest_version: 1, seal_hash: '7777777777777777777777777777777777777777777777777777777777777777' };" `
        -ExpectedOutcome "ERROR"


    # =========================================================================
    # GROUPE 3 : TESTS DE MACHINE À ÉTATS & GARDIENS ÉVÉNEMENTIELS
    # =========================================================================

    # 3A. Transition de lot légale : RECEIVED -> PARSING -> VALIDATING -> STAGED
    $batchCycleSql = @"
UPDATE ingestion_batch:batch_placo_01 SET statut = 'PARSING';
UPDATE ingestion_batch:batch_placo_01 SET statut = 'VALIDATING';
UPDATE ingestion_batch:batch_placo_01 SET statut = 'STAGED';
"@
    Execute-TestQuery -TestId "INGEST-TEST-03A" `
        -Description "Transitions de cycle de lot conformes a BatchStateMachine : succes" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenQualificationAgent `
        -Query $batchCycleSql `
        -ExpectedOutcome "SUCCESS"

    # 3B. Transition de lot illégale : tentative de sauter directement de RECEIVED à PUBLISHED
    $batch2Hash = "b2c3d4e5f6789012345678901234567890123456789012345678901234567890"
    $illegalBatchTransSql = @"
CREATE ingestion_batch:batch_test_illegal CONTENT {
    source_type: "CSV",
    source_format_version: "RFC4180",
    fournisseur_id: "KNAUF",
    nom_fichier: "knauf.csv",
    file_hash_blake3: "$batch2Hash",
    taille_octets: 500,
    statut: "RECEIVED"
};
UPDATE ingestion_batch:batch_test_illegal SET statut = 'PUBLISHED';
"@
    Execute-TestQuery -TestId "INGEST-TEST-03B" `
        -Description "Transition de lot illegale (RECEIVED -> PUBLISHED direct) : rejetee par evt_batch_guard" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenIngestionAgent `
        -Query $illegalBatchTransSql `
        -ExpectedOutcome "ERROR"

    # 3C. Transition de qualification légale : TO_CONFIRM -> VERIFIED par steward_admin
    $createToConfirmSql = @"
CREATE ingestion_staged_item:item_to_confirm CONTENT {
    batch: ingestion_batch:batch_placo_01,
    raw_record: ingestion_raw_record:batch_placo_01_line_1,
    ligne_numero: 10,
    fabricant: "SEMIN",
    reference_fabricant: "ENDUIT_CE78",
    libelle_commercial: "Enduit joint Semin CE78",
    unite_reference: "KG",
    conditionnement: { quantite: 25.0 },
    canonical_fingerprint: "8888888888888888888888888888888888888888888888888888888888888888",
    qualification: "TO_CONFIRM"
};
"@
    $null = Invoke-SurrealQuery -Namespace "lyxal_ingestion" -Database "staging_db" -Token $tokenQualificationAgent -Query $createToConfirmSql

    $itemArbitrateSql = "UPDATE ingestion_staged_item:item_to_confirm SET qualification = 'VERIFIED';"
    Execute-TestQuery -TestId "INGEST-TEST-03C" `
        -Description "Arbitrage et transition de qualification legale (TO_CONFIRM -> VERIFIED) : succes" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenStewardAdmin `
        -Query $itemArbitrateSql `
        -ExpectedOutcome "SUCCESS"

    # 3D. Transition de qualification illégale (statut fantaisiste)
    Execute-TestQuery -TestId "INGEST-TEST-03D" `
        -Description "Transition de qualification avec valeur illegale : rejetee par assert de schema" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenStewardAdmin `
        -Query "UPDATE ingestion_staged_item:item_to_confirm SET qualification = 'AUTO_MAGIC';" `
        -ExpectedOutcome "ERROR"

    # 3E. Transition de manifeste illégale : DRAFT -> APPROVED direct sans scellement préalable
    $illegalManifestSql = @"
CREATE ingestion_publication_manifest:manifest_draft_direct CONTENT {
    batch: ingestion_batch:batch_placo_01,
    manifest_ref: "MANIF-DRAFT-DIRECT",
    manifest_version: 2,
    seal_hash: "9999999999999999999999999999999999999999999999999999999999999999",
    statut: "DRAFT"
};
UPDATE ingestion_publication_manifest:manifest_draft_direct SET statut = 'APPROVED', approved_by = 'user:data_steward_lead', approver_role = 'steward_admin';
"@
    Execute-TestQuery -TestId "INGEST-TEST-03E" `
        -Description "Transition de manifeste illegale (DRAFT -> APPROVED sans SEALED) : rejetee par evt_manifest_guard" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenStewardAdmin `
        -Query $illegalManifestSql `
        -ExpectedOutcome "ERROR"

    # 3F. Immuabilité absolue des enregistrements bruts : tentative d'altération
    Execute-TestQuery -TestId "INGEST-TEST-03F" `
        -Description "Tentative de modification d'un enregistrement brut (ingestion_raw_record) : refusee par PERMISSIONS NONE" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenIngestionAgent `
        -Query "UPDATE ingestion_raw_record:batch_placo_01_line_1 SET payload_brut = { altered: true };" `
        -ExpectedOutcome "ERROR"

    # 3G. Immuabilité absolue de la quarantaine : tentative de suppression
    Execute-TestQuery -TestId "INGEST-TEST-03G" `
        -Description "Tentative de suppression dans la zone de quarantaine : refusee par PERMISSIONS NONE" `
        -Namespace "lyxal_ingestion" -Database "staging_db" `
        -Token $tokenQualificationAgent `
        -Query "DELETE ingestion_quarantine_record;" `
        -ExpectedOutcome "ERROR"

} finally {
    Write-Host "`nArret du processus SurrealDB..."
    Stop-Process -Id $proc.Id -Force
}

# -----------------------------------------------------------------------------
# RÉCAPITULATIF FINAL
# -----------------------------------------------------------------------------
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "RESUME FINAL DES TESTS PHASE 1 INGESTION" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
$passedCount = ($results | Where-Object { $_.Status -eq "PASSED" }).Count
$failedCount = ($results | Where-Object { $_.Status -eq "FAILED" }).Count
$totalCount = $results.Count

Write-Host "Total tests : $totalCount | PASSED : $passedCount | FAILED : $failedCount" -ForegroundColor $(if ($failedCount -eq 0) { "Green" } else { "Red" })

if ($failedCount -gt 0) {
    Write-Host "`nLISTE DES ECHECS :" -ForegroundColor Red
    $results | Where-Object { $_.Status -eq "FAILED" } | ForEach-Object {
        Write-Host " - [$($_.Id)] $($_.Description) -> $($_.Details)" -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host "`nTOUS LES TESTS DE PHASE 1 SONT PASSES AVEC SUCCES." -ForegroundColor Green
    exit 0
}
