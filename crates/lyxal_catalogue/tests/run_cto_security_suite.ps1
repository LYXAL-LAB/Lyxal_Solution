# ============================================================================
# SUITE OFFICIELLE D'INTÉGRATION ET DE SÉCURITÉ CTO — LYXAL CATALOGUE V1.1
# FICHIER : crates/lyxal_catalogue/tests/run_cto_security_suite.ps1
# RÔLE    : Démonstration et validation par exécution réelle sur SurrealDB v3.2.0
#           Application stricte de la DIRECTIVE CTO — LYXAL CATALOGUE V1.1 :
#           1. Session avec $auth présent sans privilège sync -> Modification Master rejetée
#           2. Session tenant_user -> Modification directe et via fonction des champs maîtres rejetée
#           3. Service catalogue_sync_agent -> Modification officielle autorisée
#           4. JWT signé mais autre audience/scope/base -> Accès refusé
#           5. Synchronisation complète -> Conservation stricte des personnalisations locales
#           6. Écriture hors catalogue -> Accès refusé (Moindre Privilège)
#           7. Accès cross-tenant à une autre base -> Accès refusé
# ============================================================================

$workspaceRoot = "C:\Users\HP\Desktop\Lyxal_OS"
$catRoot = "$workspaceRoot\crates\lyxal_catalogue"
$errorRoot = "$workspaceRoot\crates\lyxal_error"
$baseRoot = "$workspaceRoot\crates\lyxal_base"

$port = 8180

# Injection sécurisée du secret JWT (variable d'environnement ou CSPRNG 256-bit cryptographiquement fort)
if ([string]::IsNullOrWhiteSpace($env:LYXAL_JWT_SECRET)) {
    $rngBytes = New-Object byte[] 32
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($rngBytes)
    $jwtSecret = [BitConverter]::ToString($rngBytes).Replace("-", "").ToLower()
} else {
    $jwtSecret = $env:LYXAL_JWT_SECRET
}
$wrongSecret = "attacker_fake_jwt_secret_key_1234567890"

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
            # Also check if a function returned an error result object { ok: false, error: ... }
            if ($r.result -and $r.result.ok -eq $false -and $r.result.error) {
                $hasInternalErr = $true
                $errMsg = "$($r.result.error.code): $($r.result.error.message)"
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
                $detail = "ECHEC SECURITE : L'operation aurait du etre bloquee mais a reussi !"
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
    Write-Host ("[{0}] {1,-10} : {2}" -f $status, $TestId, $Description) -ForegroundColor $color
    if ($status -eq "FAILED") {
        Write-Host "   -> DETAILS: $detail" -ForegroundColor Red
        Write-Host "   -> RAW RES: " ($rawResult | ConvertTo-Json -Depth 3)
    }
}

try {
    # -------------------------------------------------------------------------
    # ÉTAPE 1 : INITIALISATION DU MASTER, TENANT ALPHA ET TENANT BETA
    # DÉPLOIEMENT DIRECT DE TOUS LES FICHIERS DU DÉPÔT
    # -------------------------------------------------------------------------
    Write-Host "`nDeploiement des dependances, schemas et fonctions des modules..."
    $rootAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('root:root'))

    $prereqFiles = @(
        "$errorRoot\schema\error_definition.surql",
        "$errorRoot\functions\service\error_get.surql",
        "$errorRoot\functions\service\error_resolve.surql",
        "$errorRoot\functions\service\error_result.surql",
        "$errorRoot\functions\service\result_ok.surql",
        "$baseRoot\schema\base_unite_type.surql",
        "$baseRoot\schema\base_unite.surql",
        "$baseRoot\seeds\unite_type_initial.surql",
        "$baseRoot\seeds\unite_initial.surql"
    )
    $catSchemaFiles = Get-ChildItem "$catRoot\schema\*.surql" | Sort-Object Name | ForEach-Object { $_.FullName }
    $catSeedFiles = @(
        "$catRoot\seeds\error_definitions.surql",
        "$catRoot\seeds\catalogue_type_initial.surql",
        "$catRoot\seeds\catalogue_relation_type_initial.surql"
    )
    $catFunctionFiles = Get-ChildItem -Recurse "$catRoot\functions\*.surql" | Sort-Object FullName | ForEach-Object { $_.FullName }

    $deployScript = New-Object System.Text.StringBuilder
    foreach ($f in $prereqFiles) { [void]$deployScript.AppendLine((Get-Content $f -Raw -Encoding UTF8)); [void]$deployScript.AppendLine(';') }
    foreach ($f in $catSchemaFiles) { [void]$deployScript.AppendLine((Get-Content $f -Raw -Encoding UTF8)); [void]$deployScript.AppendLine(';') }
    foreach ($f in $catSeedFiles) { [void]$deployScript.AppendLine((Get-Content $f -Raw -Encoding UTF8)); [void]$deployScript.AppendLine(';') }
    foreach ($f in $catFunctionFiles) { [void]$deployScript.AppendLine((Get-Content $f -Raw -Encoding UTF8)); [void]$deployScript.AppendLine(';') }

    # Setup namespaces & databases
    $databases = @(
        @{ NS = "lyxal_master"; DB = "master_catalogue"; AC = "master_jwt_access" },
        @{ NS = "tenant_alpha"; DB = "client_db"; AC = "alpha_jwt_access" },
        @{ NS = "tenant_beta"; DB = "client_db"; AC = "beta_jwt_access" }
    )

    foreach ($db in $databases) {
        $setupSql = @"
DEFINE NAMESPACE IF NOT EXISTS $($db.NS);
USE NS $($db.NS);
DEFINE DATABASE IF NOT EXISTS $($db.DB);
USE DB $($db.DB);

DEFINE TABLE IF NOT EXISTS catalogue_session SCHEMALESS;

DEFINE ACCESS $($db.AC) ON DATABASE TYPE RECORD
    WITH JWT ALGORITHM HS256 KEY "$jwtSecret"
    AUTHENTICATE {
        IF `$token.iss != "lyxal-os" {
            THROW "INVALID_ISSUER: Le token JWT doit provenir de l'emetteur lyxal-os.";
        };
        IF `$token.aud != "lyxal-catalogue" {
            THROW "INVALID_AUDIENCE: Le token JWT n'est pas destine a lyxal-catalogue.";
        };
        LET `$clean_id = string::replace(`$token.sub, ":", "_");
        RETURN (UPSERT type::record('catalogue_session', `$clean_id) CONTENT {
            role: `$token.role,
            tenant_id: `$token.tenant_id,
            scope: `$token.scope
        });
    }
    DURATION FOR TOKEN 1h;
"@

        Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers @{'Authorization'="Basic $rootAuth"} -ContentType "text/plain; charset=utf-8" -Body $setupSql | Out-Null
        $deployRes = Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers @{'surreal-ns'=$db.NS; 'surreal-db'=$db.DB; 'Authorization'="Basic $rootAuth"} -ContentType "text/plain; charset=utf-8" -Body $deployScript.ToString()
        $deployErrors = @($deployRes | Where-Object { $_.status -eq 'ERR' })
        Write-Host "DEPLOYED TO $($db.NS)/$($db.DB): $($deployRes.Count) statements, $($deployErrors.Count) errors."
        if ($deployErrors.Count -gt 0) {
            Write-Host "DEPLOYMENT ERRORS IN $($db.NS)/$($db.DB):" -ForegroundColor Red
            foreach ($de in $deployErrors) { Write-Host "ERR: $($de.result)" -ForegroundColor Red }
        }
    }

    # Configuration des tables privees hors catalogue pour tests d'isolation
    $extraAlpha = @"
DEFINE TABLE alpha_private_orders SCHEMAFULL
    PERMISSIONS FOR select, create, update, delete WHERE `$token.NS = "tenant_alpha" AND `$token.role = "tenant_user";
DEFINE FIELD order_ref ON alpha_private_orders TYPE string;
"@
    $extraBeta = @"
DEFINE TABLE beta_private_orders SCHEMAFULL
    PERMISSIONS FOR select, create, update, delete WHERE `$token.NS = "tenant_beta" AND `$token.role = "tenant_user";
DEFINE FIELD order_ref ON beta_private_orders TYPE string;
"@
    Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers @{'surreal-ns'='tenant_alpha'; 'surreal-db'='client_db'; 'Authorization'="Basic $rootAuth"} -ContentType "text/plain; charset=utf-8" -Body $extraAlpha | Out-Null
    Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers @{'surreal-ns'='tenant_beta'; 'surreal-db'='client_db'; 'Authorization'="Basic $rootAuth"} -ContentType "text/plain; charset=utf-8" -Body $extraBeta | Out-Null

    # Référentiels publics partagés en lecture seule (unités, erreurs, types)
    $extraPerms = @"
DEFINE TABLE OVERWRITE base_unite_type TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL, FOR create, update, delete NONE;
DEFINE TABLE OVERWRITE base_unite TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL, FOR create, update, delete NONE;
DEFINE TABLE OVERWRITE error_definition TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL, FOR create, update, delete NONE;
"@

    Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers @{'surreal-ns'='tenant_alpha'; 'surreal-db'='client_db'; 'Authorization'="Basic $rootAuth"} -ContentType "text/plain; charset=utf-8" -Body $extraPerms | Out-Null
    Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers @{'surreal-ns'='tenant_beta'; 'surreal-db'='client_db'; 'Authorization'="Basic $rootAuth"} -ContentType "text/plain; charset=utf-8" -Body $extraPerms | Out-Null
    Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers @{'surreal-ns'='lyxal_master'; 'surreal-db'='master_catalogue'; 'Authorization'="Basic $rootAuth"} -ContentType "text/plain; charset=utf-8" -Body $extraPerms | Out-Null

    Write-Host "Deploiement acheve avec succes."


    # -------------------------------------------------------------------------
    # ÉTAPE 2 : GÉNÉRATION DES VÉRITABLES JETONS JWT TYPÉS
    # -------------------------------------------------------------------------
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

    # Jeton Officiel catalogue_sync_agent pour Tenant Alpha
    $tokenSyncAlpha = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-catalogue"
        sub = "service:catalogue-sync-worker"
        role = "catalogue_sync_agent"
        scope = @("catalogue:sync:write")
        ns = "tenant_alpha"
        db = "client_db"
        ac = "alpha_jwt_access"
        iat = $now
        exp = $now + 3600
    } -Secret $jwtSecret

    # Jeton Locataire Client Alpha
    $tokenClientAlpha = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-catalogue"
        sub = "user:artisan_alpha"
        role = "tenant_user"
        tenant_id = "alpha"
        ns = "tenant_alpha"
        db = "client_db"
        ac = "alpha_jwt_access"
        iat = $now
        exp = $now + 3600
    } -Secret $jwtSecret

    # Jeton Locataire Client Beta
    $tokenClientBeta = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-catalogue"
        sub = "user:artisan_beta"
        role = "tenant_user"
        tenant_id = "beta"
        ns = "tenant_beta"
        db = "client_db"
        ac = "beta_jwt_access"
        iat = $now
        exp = $now + 3600
    } -Secret $jwtSecret

    # Jeton Locataire d'une autre entreprise (Beta) opérant dans le même namespace (test d'étanchéité multi-tenant RLS)
    $tokenOtherTenant = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-catalogue"
        sub = "user:other_tenant_user"
        role = "tenant_user"
        tenant_id = "beta"
        ns = "tenant_alpha"
        db = "client_db"
        ac = "alpha_jwt_access"
        iat = $now
        exp = $now + 3600
    } -Secret $jwtSecret

    # Jeton Authentifié SANS tenant_id (utilisateur ordinaire sans organisation rattachée)
    $tokenNoTenant = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-catalogue"
        sub = "user:anonymous_user"
        role = "tenant_user"
        ns = "tenant_alpha"
        db = "client_db"
        ac = "alpha_jwt_access"
        iat = $now
        exp = $now + 3600
    } -Secret $jwtSecret

    # Jeton Authentifié SANS rôle 'tenant_user' (ex: rôle 'guest')
    $tokenGuest = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-catalogue"
        sub = "user:guest_user"
        role = "guest"
        tenant_id = "alpha"
        ns = "tenant_alpha"
        db = "client_db"
        ac = "alpha_jwt_access"
        iat = $now
        exp = $now + 3600
    } -Secret $jwtSecret

    # Jeton avec mauvaise audience (ex: audience lyxal-billing au lieu de lyxal-catalogue)
    $tokenWrongAudience = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-billing"
        sub = "service:catalogue-sync-worker"
        role = "catalogue_sync_agent"
        scope = @("catalogue:sync:write")
        ns = "tenant_alpha"
        db = "client_db"
        ac = "alpha_jwt_access"
        iat = $now
        exp = $now + 3600
    } -Secret $jwtSecret

    # Jeton catalogue_sync_agent avec mauvais scope (ex: scope lecture seule)
    $tokenWrongScope = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-catalogue"
        sub = "service:catalogue-sync-worker"
        role = "catalogue_sync_agent"
        scope = @("catalogue:sync:read")
        ns = "tenant_alpha"
        db = "client_db"
        ac = "alpha_jwt_access"
        iat = $now
        exp = $now + 3600
    } -Secret $jwtSecret

    # Jeton falsifié (signé avec une clé pirate)
    $tokenForged = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-catalogue"
        sub = "hacker"
        role = "catalogue_sync_agent"
        scope = @("catalogue:sync:write")
        ns = "tenant_alpha"
        db = "client_db"
        ac = "alpha_jwt_access"
        iat = $now
        exp = $now + 3600
    } -Secret $wrongSecret

    # Jeton expiré
    $tokenExpired = New-JwtToken -Payload @{
        iss = "lyxal-os"
        aud = "lyxal-catalogue"
        sub = "service:catalogue-sync-worker"
        role = "catalogue_sync_agent"
        scope = @("catalogue:sync:write")
        ns = "tenant_alpha"
        db = "client_db"
        ac = "alpha_jwt_access"
        iat = $now - 7200
        exp = $now - 3600
    } -Secret $jwtSecret

    Write-Host "`n========================================================"
    Write-Host "EXÉCUTION DES TESTS DE SÉCURITÉ CONFORME À LA DIRECTIVE CTO"
    Write-Host "========================================================"

    # --- CRÉATION DE L'ARTICLE MAÎTRE INITIAL PAR catalogue_sync_agent ---
    $initMasterItem = @"
CREATE catalogue_item:PLACO_BA13 CONTENT {
    code: "PLACO_BA13",
    type: catalogue_type:PRODUIT,
    libelle: "Placoplatre BA13 2500x1200",
    description: "Descriptif technique standard Master",
    unite_reference: base_unite:M2,
    nature_reference: "COMMERCIALE",
    fabricant: "SAINT-GOBAIN PLACO",
    marque: "PLACO",
    reference_fabricant: "12345678",
    code_barre: "3456789012340",
    statut_commercial: "ACTIF",
    master_id: "catalogue_item:PLACO_BA13",
    is_custom: false
};
"@
    Execute-TestQuery -TestId "SETUP-01  " `
        -Description "Injection legitime par catalogue_sync_agent de l'article maitre dans Alpha" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $initMasterItem `
        -ExpectedOutcome "SUCCESS"

    # --- POINT 1 : SESSION AUTHENTIFIÉE AVEC $auth PRÉSENT ET $token ABSENT ---
    # Une session authentifiée ordinaire sans rôle catalogue_sync_agent explicite tente de modifier un champ maître
    Execute-TestQuery -TestId "CTO-TEST-1" `
        -Description "Session ordinaire avec `$auth present sans role sync : modification Master interdite" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -BasicAuth $rootAuth `
        -Query "UPDATE catalogue_item:PLACO_BA13 SET fabricant = 'PIRATE AUTH SESSION';" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-1B" `
        -Description "Session ordinaire avec `$auth present sans role sync via fn::catalogue_item_update : interdite" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -BasicAuth $rootAuth `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PLACO_BA13, fabricant: 'PIRATE AUTH' });" `
        -ExpectedOutcome "ERROR"

    # --- POINT 2 : SESSION tenant_user : MODIFICATION DIRECTE ET VIA FONCTION DES CHAMPS MAÎTRES INTERDITE ---
    Execute-TestQuery -TestId "CTO-TEST-2A" `
        -Description "Session tenant_user : modification DIRECTE champ maitre fabricant interdite" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "UPDATE catalogue_item:PLACO_BA13 SET fabricant = 'PIRATE CORP';" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-2B" `
        -Description "Session tenant_user : modification DIRECTE champ maitre description interdite" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "UPDATE catalogue_item:PLACO_BA13 SET description = 'Description modifiee par locataire';" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-2C" `
        -Description "Session tenant_user : modification DIRECTE champ maitre statut_commercial interdite" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "UPDATE catalogue_item:PLACO_BA13 SET statut_commercial = 'OBSOLETE';" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-2D" `
        -Description "Session tenant_user : modification VIA FONCTION champ maitre fabricant interdite" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PLACO_BA13, fabricant: 'PIRATE CORP' });" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-2E" `
        -Description "Session tenant_user : modification VIA FONCTION champ maitre description interdite" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PLACO_BA13, description: 'Descriptif pirate' });" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-2F" `
        -Description "Session tenant_user : modification VIA FONCTION champ maitre statut_commercial interdite" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PLACO_BA13, statut_commercial: 'OBSOLETE' });" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-2G" `
        -Description "Session tenant_user : personnalisation legitime champs locaux (code_interne & libelle_personnalise)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "UPDATE catalogue_item:PLACO_BA13 MERGE { code_interne_client: 'MON-BA13-ALPHA', libelle_personnalise: 'Plaque Placo BA13 Chantier Alpha' };" `
        -ExpectedOutcome "SUCCESS"

    Execute-TestQuery -TestId "CTO-TEST-2H" `
        -Description "Session tenant_user : modification DIRECTE champ local enabled autorisee (desactivation)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "UPDATE catalogue_item:PLACO_BA13 SET enabled = false;" `
        -ExpectedOutcome "SUCCESS"

    Execute-TestQuery -TestId "CTO-TEST-2I" `
        -Description "Session tenant_user : modification VIA FONCTION champ local enabled autorisee (reactivation)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PLACO_BA13, enabled: true });" `
        -ExpectedOutcome "SUCCESS"

    Execute-TestQuery -TestId "CTO-TEST-2L" `
        -Description "Session tenant_user : desactivation locale persistee de l'article pour test Master Sync" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PLACO_BA13, enabled: false });" `
        -ExpectedOutcome "SUCCESS"

    Execute-TestQuery -TestId "CTO-TEST-2J" `
        -Description "Session tenant_user : modification VIA FONCTION code structurel interdite" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PLACO_BA13, code: 'NEW_CODE' });" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-2K" `
        -Description "Session tenant_user : modification VIA FONCTION nature_reference interdite" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PLACO_BA13, nature_reference: 'GENERIQUE' });" `
        -ExpectedOutcome "ERROR"

    # --- POINT 3 : SERVICE catalogue_sync_agent : MODIFICATION OFFICIELLE AUTORISÉE ---
    $syncUpdateQuery = @"
UPDATE catalogue_item:PLACO_BA13 MERGE {
    description: "Descriptif technique officiel Master enrichi 2026",
    statut_commercial: "ACTIF"
};
"@
    Execute-TestQuery -TestId "CTO-TEST-3 " `
        -Description "Service catalogue_sync_agent : modification officielle description/statut_commercial autorisee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $syncUpdateQuery `
        -ExpectedOutcome "SUCCESS"

    Execute-TestQuery -TestId "CTO-TEST-3B" `
        -Description "Service catalogue_sync_agent : tentative de reactiver un article localement desactive interdite" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query "UPDATE catalogue_item:PLACO_BA13 SET enabled = true;" `
        -ExpectedOutcome "ERROR"

    # --- POINT 4 : JWT SIGNÉ DESTINÉ À UNE AUTRE AUDIENCE, SCOPE OU BASE : ACCÈS REFUSÉ ---
    Execute-TestQuery -TestId "CTO-TEST-4A" `
        -Description "JWT signe mais mauvaise audience (lyxal-billing au lieu de lyxal-catalogue) : rejet" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenWrongAudience `
        -Query "SELECT * FROM catalogue_item;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-4B" `
        -Description "JWT catalogue_sync_agent sans scope 'catalogue:sync:write' (scope lecture) : modification rejetee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenWrongScope `
        -Query "UPDATE catalogue_item:PLACO_BA13 SET description = 'Hacked';" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-4C" `
        -Description "JWT signe avec fausse signature (cle pirate) : rejet immediat 401" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenForged `
        -Query "SELECT * FROM catalogue_item;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-4D" `
        -Description "JWT expire (exp < now) : rejet immediat 401" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenExpired `
        -Query "SELECT * FROM catalogue_item;" `
        -ExpectedOutcome "ERROR"

    # --- POINT 5 : SYNCHRONISATION COMPLÈTE & CONSERVATION STRICTE DES PERSONNALISATIONS LOCALES ---
    Execute-TestQuery -TestId "CTO-TEST-5A" `
        -Description "Tentative du flux Master d'ecraser un champ local du client : bloquee par verrou moteur" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query "UPDATE catalogue_item:PLACO_BA13 MERGE { libelle_personnalise: 'Ecrasement Master' };" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-5B" `
        -Description "Tentative du flux Master via fn::catalogue_item_update d'ecraser un champ local : bloquee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PLACO_BA13, libelle_personnalise: 'Ecrasement Master' });" `
        -ExpectedOutcome "ERROR"

    # --- POINT 6 : TENTATIVE D'ÉCRITURE HORS CATALOGUE (MOINDRE PRIVILÈGE) ---
    Execute-TestQuery -TestId "CTO-TEST-6 " `
        -Description "catalogue_sync_agent tente d'ecrire sur table privee hors catalogue : refuse par RLS" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query "CREATE alpha_private_orders CONTENT { order_ref: 'HACK-ORDER' };" `
        -ExpectedOutcome "ERROR"

    # --- POINT 7 : TENTATIVE D'ACCÈS À UNE AUTRE BASE CLIENTE (ÉTANCHÉITÉ MULTI-TENANT) ---
    Execute-TestQuery -TestId "CTO-TEST-7 " `
        -Description "Client Alpha tente d'acceder aux donnees de la base Client Beta : refuse" `
        -Namespace "tenant_beta" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "SELECT * FROM beta_private_orders;" `
        -ExpectedOutcome "ERROR"

    # --- POINT 8 : ARTICLES PRIVÉS & RESTRICTION DES PERMISSIONS $auth ---
    $createPrivItemAlpha = @"
CREATE catalogue_item:PORT_SUR_MESURE CONTENT {
    code: "SM-ALPHA-01",
    type: catalogue_type:PRODUIT,
    libelle: "Porte sur mesure Atelier Alpha",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "MENUISERIE ALPHA",
    is_custom: true,
    tenant_id: "alpha"
};
"@
    Execute-TestQuery -TestId "CTO-TEST-8A" `
        -Description "Client Alpha cree legitimement son article prive avec tenant_id = 'alpha'" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query $createPrivItemAlpha `
        -ExpectedOutcome "SUCCESS"

    Execute-TestQuery -TestId "CTO-TEST-8B" `
        -Description "Client Alpha lit et modifie son propre article prive : autorise" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "UPDATE catalogue_item:PORT_SUR_MESURE MERGE { libelle: 'Porte sur mesure Alpha V2' };" `
        -ExpectedOutcome "SUCCESS"

    Execute-TestQuery -TestId "CTO-TEST-8C" `
        -Description "Client Beta tente de modifier l'article prive de Client Alpha : bloque par RLS tenant_id" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientBeta `
        -Query "UPDATE catalogue_item:PORT_SUR_MESURE SET libelle = 'Hacked by Beta';" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-8D" `
        -Description "Client Beta via fn::catalogue_item_update tente de modifier l'article prive d'Alpha : bloque" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientBeta `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PORT_SUR_MESURE, libelle: 'Hacked by Beta' });" `
        -ExpectedOutcome "ERROR"

    # =========================================================================
    # POINT 9 : TESTS COMPLÉMENTAIRES CTO V1.1 — VERROUILLAGE FINAL DES ARTICLES PRIVÉS
    # =========================================================================

    # --- 1. Création d'un article privé sans tenant_id : refus ---
    $createNoTenantDirect = @"
CREATE catalogue_item CONTENT {
    code: "PRIV_NO_TENANT_DIR",
    type: catalogue_type:PRODUIT,
    libelle: "Article sans tenant direct",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "MENUISERIE TEST",
    is_custom: true
};
"@
    Execute-TestQuery -TestId "CTO-TEST-9A1" `
        -Description "Creation DIRECTE article prive par identite sans tenant_id : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenNoTenant `
        -Query $createNoTenantDirect `
        -ExpectedOutcome "ERROR"

    $createNoTenantFn = @"
fn::catalogue_item_create({
    code: "PRIV_NO_TENANT_FN",
    type: catalogue_type:PRODUIT,
    libelle: "Article sans tenant fn",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "MENUISERIE TEST",
    is_custom: true
});
"@
    Execute-TestQuery -TestId "CTO-TEST-9A2" `
        -Description "Creation VIA FONCTION article prive par identite sans tenant_id : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenNoTenant `
        -Query $createNoTenantFn `
        -ExpectedOutcome "ERROR"

    # --- 2. Création avec un tenant_id appartenant à une autre entreprise : refus ---
    $createSpoofTenantDirect = @"
CREATE catalogue_item CONTENT {
    code: "PRIV_SPOOF_BETA_DIR",
    type: catalogue_type:PRODUIT,
    libelle: "Usurpation Beta direct",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "MENUISERIE ALPHA",
    is_custom: true,
    tenant_id: "beta"
};
"@
    Execute-TestQuery -TestId "CTO-TEST-9B1" `
        -Description "Client Alpha tente creation DIRECTE avec tenant_id = 'beta' : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query $createSpoofTenantDirect `
        -ExpectedOutcome "ERROR"

    $createSpoofTenantFn = @"
fn::catalogue_item_create({
    code: "PRIV_SPOOF_BETA_FN",
    type: catalogue_type:PRODUIT,
    libelle: "Usurpation Beta fn",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "MENUISERIE ALPHA",
    is_custom: true,
    tenant_id: "beta"
});
"@
    Execute-TestQuery -TestId "CTO-TEST-9B2" `
        -Description "Client Alpha tente creation VIA FONCTION avec tenant_id = 'beta' : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query $createSpoofTenantFn `
        -ExpectedOutcome "ERROR"

    # --- 3. Modification du propriétaire après création : refus ---
    Execute-TestQuery -TestId "CTO-TEST-9C1" `
        -Description "Client Alpha tente modification DIRECTE du proprietaire tenant_id : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "UPDATE catalogue_item:PORT_SUR_MESURE SET tenant_id = 'beta';" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9C2" `
        -Description "Client Alpha tente modification VIA FONCTION du proprietaire tenant_id : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PORT_SUR_MESURE, tenant_id: 'beta' });" `
        -ExpectedOutcome "ERROR"

    # --- 4. Lecture, modification et suppression par une autre entreprise : refus ---
    Execute-TestQuery -TestId "CTO-TEST-9D1" `
        -Description "Autre entreprise (Beta) tente lecture DIRECTE article prive de Client Alpha : refusee (RLS)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenOtherTenant `
        -Query "SELECT * FROM catalogue_item WHERE id = catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9D2" `
        -Description "Autre entreprise (Beta) tente modification DIRECTE article prive de Client Alpha : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenOtherTenant `
        -Query "UPDATE catalogue_item:PORT_SUR_MESURE SET libelle = 'Hacked by Other Tenant';" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9D3" `
        -Description "Autre entreprise (Beta) tente modification VIA FONCTION article prive de Client Alpha : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenOtherTenant `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PORT_SUR_MESURE, libelle: 'Hacked by Other Tenant' });" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9D4" `
        -Description "Autre entreprise (Beta) tente suppression DIRECTE article prive de Client Alpha : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenOtherTenant `
        -Query "DELETE catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9D5" `
        -Description "Autre entreprise (Beta) tente suppression VIA FONCTION article prive de Client Alpha : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenOtherTenant `
        -Query "fn::catalogue_item_delete({ id: catalogue_item:PORT_SUR_MESURE });" `
        -ExpectedOutcome "ERROR"

    # --- 5. Accès à un article privé par une identité sans tenant_id : refus ---
    Execute-TestQuery -TestId "CTO-TEST-9E1" `
        -Description "Identite sans tenant_id tente lecture DIRECTE article prive : refusee (RLS)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenNoTenant `
        -Query "SELECT * FROM catalogue_item WHERE id = catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9E2" `
        -Description "Identite sans tenant_id tente modification DIRECTE article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenNoTenant `
        -Query "UPDATE catalogue_item:PORT_SUR_MESURE SET libelle = 'Hacked by Anon';" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9E3" `
        -Description "Identite sans tenant_id tente modification VIA FONCTION article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenNoTenant `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PORT_SUR_MESURE, libelle: 'Hacked by Anon' });" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9E4" `
        -Description "Identite sans tenant_id tente suppression DIRECTE article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenNoTenant `
        -Query "DELETE catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9E5" `
        -Description "Identite sans tenant_id tente suppression VIA FONCTION article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenNoTenant `
        -Query "fn::catalogue_item_delete({ id: catalogue_item:PORT_SUR_MESURE });" `
        -ExpectedOutcome "ERROR"

    # --- 6. Lecture d'un article privé par catalogue_sync_agent : refus ---
    Execute-TestQuery -TestId "CTO-TEST-9F1" `
        -Description "catalogue_sync_agent tente lecture DIRECTE article prive : refusee (RLS)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query "SELECT * FROM catalogue_item WHERE id = catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9F2" `
        -Description "catalogue_sync_agent tente modification DIRECTE article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query "UPDATE catalogue_item:PORT_SUR_MESURE SET libelle = 'Sync altered';" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9F3" `
        -Description "catalogue_sync_agent tente modification VIA FONCTION article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PORT_SUR_MESURE, libelle: 'Sync fn altered' });" `
        -ExpectedOutcome "ERROR"


    Execute-TestQuery -TestId "CTO-TEST-9F4" `
        -Description "catalogue_sync_agent tente suppression DIRECTE article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query "DELETE catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9F5" `
        -Description "catalogue_sync_agent tente suppression VIA FONCTION article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query "fn::catalogue_item_delete({ id: catalogue_item:PORT_SUR_MESURE });" `
        -ExpectedOutcome "ERROR"

    # --- 7. Opérations légitimes du propriétaire : succès ---
    $createLegitAlpha = @"
fn::catalogue_item_create({
    code: "ALPHA-LEGIT-01",
    type: catalogue_type:PRODUIT,
    libelle: "Article Alpha Legitime",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "MENUISERIE ALPHA",
    is_custom: true
});
"@
    Execute-TestQuery -TestId "CTO-TEST-9G1" `
        -Description "Client Alpha cree legitimement son article prive via fn::catalogue_item_create : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query $createLegitAlpha `
        -ExpectedOutcome "SUCCESS"

    Execute-TestQuery -TestId "CTO-TEST-9G2" `
        -Description "Client Alpha lit legitimement son article prive recemment cree : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "SELECT * FROM catalogue_item WHERE code = 'ALPHA-LEGIT-01';" `
        -ExpectedOutcome "SUCCESS"

    $updateLegitAlpha = @"
LET `$item_rec = (SELECT VALUE id FROM ONLY catalogue_item WHERE code = 'ALPHA-LEGIT-01');
fn::catalogue_item_update({
    id: `$item_rec,
    libelle: "Article Alpha Legitime V2",
    description: "Mise a jour legitime par le proprietaire"
});
"@
    Execute-TestQuery -TestId "CTO-TEST-9G3" `
        -Description "Client Alpha met a jour son article prive via fn::catalogue_item_update : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query $updateLegitAlpha `
        -ExpectedOutcome "SUCCESS"

    $deleteLegitAlpha = @"
LET `$item_rec = (SELECT VALUE id FROM ONLY catalogue_item WHERE code = 'ALPHA-LEGIT-01');
fn::catalogue_item_delete({
    id: `$item_rec
});
"@
    Execute-TestQuery -TestId "CTO-TEST-9G4" `
        -Description "Client Alpha supprime legitimement son article prive via fn::catalogue_item_delete : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query $deleteLegitAlpha `
        -ExpectedOutcome "SUCCESS"

    # --- 8. Refus d'un utilisateur sans rôle tenant_user (ex: rôle guest) ---
    $createGuestDirect = @"
CREATE catalogue_item CONTENT {
    code: "PRIV_GUEST_DIR",
    type: catalogue_type:PRODUIT,
    libelle: "Article guest direct",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "MENUISERIE ALPHA",
    is_custom: true,
    tenant_id: "alpha"
};
"@
    Execute-TestQuery -TestId "CTO-TEST-9H1" `
        -Description "Utilisateur sans role tenant_user tente creation DIRECTE article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenGuest `
        -Query $createGuestDirect `
        -ExpectedOutcome "ERROR"

    $createGuestFn = @"
fn::catalogue_item_create({
    code: "PRIV_GUEST_FN",
    type: catalogue_type:PRODUIT,
    libelle: "Article guest fn",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "MENUISERIE ALPHA",
    is_custom: true
});
"@
    Execute-TestQuery -TestId "CTO-TEST-9H2" `
        -Description "Utilisateur sans role tenant_user tente creation VIA FONCTION article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenGuest `
        -Query $createGuestFn `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9H3" `
        -Description "Utilisateur sans role tenant_user tente lecture DIRECTE article prive : refusee (RLS)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenGuest `
        -Query "SELECT * FROM catalogue_item WHERE id = catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9H4" `
        -Description "Utilisateur sans role tenant_user tente modification DIRECTE article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenGuest `
        -Query "UPDATE catalogue_item:PORT_SUR_MESURE MERGE { libelle: 'Hacked by Guest' };" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9H5" `
        -Description "Utilisateur sans role tenant_user tente modification VIA FONCTION article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenGuest `
        -Query "fn::catalogue_item_update({ id: catalogue_item:PORT_SUR_MESURE, libelle: 'Hacked by Guest fn' });" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9H6" `
        -Description "Utilisateur sans role tenant_user tente suppression DIRECTE article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenGuest `
        -Query "DELETE catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-9H7" `
        -Description "Utilisateur sans role tenant_user tente suppression VIA FONCTION article prive : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenGuest `
        -Query "fn::catalogue_item_delete({ id: catalogue_item:PORT_SUR_MESURE });" `
        -ExpectedOutcome "ERROR"

    # =========================================================================
    # POINT 9C : AUDIT TRANSVERSAL DE SÉCURITÉ & PERMISSIONS (DIRECTIVE CTO V1.1)
    # =========================================================================

    # 1. Attaques directes sur la table catalogue_session
    Execute-TestQuery -TestId "CTO-TEST-10A" `
        -Description "Attaque Session 1: Client Alpha tente de modifier son propre role dans catalogue_session : refuse" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "UPDATE catalogue_session:user_artisan_alpha SET role = 'catalogue_sync_agent';" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-10B" `
        -Description "Attaque Session 2: Client Alpha tente de modifier son tenant_id ou ses scopes : refuse" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "UPDATE catalogue_session:user_artisan_alpha SET tenant_id = 'beta', scope = ['catalogue:sync:write'];" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-10C" `
        -Description "Attaque Session 3: Client Alpha tente de modifier la session d'un autre utilisateur : refuse" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "UPDATE catalogue_session:user_artisan_beta SET role = 'hacked';" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-10D" `
        -Description "Attaque Session 4: Client Alpha tente de creer directement une fausse session sync : refuse" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query "CREATE catalogue_session:fake_sync CONTENT { role: 'catalogue_sync_agent', scope: ['catalogue:sync:write'] };" `
        -ExpectedOutcome "ERROR"

    # 2. Cloisonnement multi-tenant des Compositions & Lignes privées
    $setupAlphaPrivateComp = @"
LET `$c = (CREATE catalogue_composition CONTENT {
    parent_item: catalogue_item:PORT_SUR_MESURE,
    libelle: "Recette Cloison Porte Alpha",
    version: 1,
    statut: "DRAFT"
});
CREATE catalogue_composition_ligne CONTENT {
    composition: `$c[0].id,
    composant_item: catalogue_item:PLACO_BA13,
    quantite: 1.5,
    unite: base_unite:U
};
"@
    Execute-TestQuery -TestId "CTO-TEST-10E1" `
        -Description "Client Alpha cree legitimement une composition et ligne sur son article prive : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query $setupAlphaPrivateComp `
        -ExpectedOutcome "SUCCESS"

    Execute-TestQuery -TestId "CTO-TEST-10E2" `
        -Description "Client Beta tente lecture DIRECTE d'une composition privee de Client Alpha : refusee (RLS)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenOtherTenant `
        -Query "SELECT * FROM catalogue_composition WHERE parent_item = catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-10E3" `
        -Description "catalogue_sync_agent tente lecture d'une composition privee de Client Alpha : refusee (RLS)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query "SELECT * FROM catalogue_composition WHERE parent_item = catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-10F1" `
        -Description "Client Beta tente lecture DIRECTE des lignes de composition de Client Alpha : refusee (RLS)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenOtherTenant `
        -Query "SELECT * FROM catalogue_composition_ligne WHERE composition.parent_item = catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-10F2" `
        -Description "Client Beta tente modification DIRECTE d'une ligne de composition de Client Alpha : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenOtherTenant `
        -Query "UPDATE catalogue_composition_ligne SET quantite = 99.0 WHERE composition.parent_item = catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    # 3. Cloisonnement multi-tenant des Relations privées
    $setupAlphaPrivateRel = @"
CREATE catalogue_relation CONTENT {
    source: catalogue_item:PORT_SUR_MESURE,
    cible: catalogue_item:PLACO_BA13,
    relation_type: catalogue_relation_type:ACCESSOIRE,
    commentaire: "Liaison privee Alpha"
};
"@
    Execute-TestQuery -TestId "CTO-TEST-10G1" `
        -Description "Client Alpha cree legitimement une relation impliquant son article prive : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query $setupAlphaPrivateRel `
        -ExpectedOutcome "SUCCESS"

    Execute-TestQuery -TestId "CTO-TEST-10G2" `
        -Description "Client Beta tente lecture DIRECTE de la relation privee de Client Alpha : refusee (RLS)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenOtherTenant `
        -Query "SELECT * FROM catalogue_relation WHERE source = catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-10G3" `
        -Description "Client Beta tente modification DIRECTE de la relation privee de Client Alpha : refusee" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenOtherTenant `
        -Query "UPDATE catalogue_relation SET commentaire = 'Hacked by Beta' WHERE source = catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    Execute-TestQuery -TestId "CTO-TEST-10G4" `
        -Description "catalogue_sync_agent tente lecture de la relation privee de Client Alpha : refusee (RLS)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query "SELECT * FROM catalogue_relation WHERE source = catalogue_item:PORT_SUR_MESURE;" `
        -ExpectedOutcome "ERROR"

    # Action 1 CTO : Création d'une relation privée appartenant à Beta
    $setupBetaPrivateRel = @"
LET `$item_beta = (CREATE catalogue_item:BETA_FENETRE CONTENT {
    code: "BETA-FEN-01",
    type: catalogue_type:PRODUIT,
    libelle: "Fenetre PVC Beta",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "MENUISERIE BETA",
    is_custom: true,
    tenant_id: "beta"
});
CREATE catalogue_relation:rel_beta_privee CONTENT {
    source: catalogue_item:BETA_FENETRE,
    cible: catalogue_item:PLACO_BA13,
    relation_type: catalogue_relation_type:ACCESSOIRE,
    commentaire: "Relation privee appartenant a Beta"
};
"@
    Execute-TestQuery -TestId "CTO-TEST-10G5" `
        -Description "Client Beta cree legitimement sa relation privee : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenOtherTenant `
        -Query $setupBetaPrivateRel `
        -ExpectedOutcome "SUCCESS"

    # Action 1 CTO : Client Alpha tente de modifier la relation privée de Beta en remplaçant source et cible par des articles accessibles à Alpha
    $attackAlphaOnBetaRel = @"
UPDATE catalogue_relation:rel_beta_privee SET 
    source = catalogue_item:PORT_SUR_MESURE, 
    cible = catalogue_item:PLACO_BA13, 
    commentaire = "Detournement par Alpha avec extremites Alpha";
"@
    Execute-TestQuery -TestId "CTO-TEST-10G6" `
        -Description "Client Alpha tente modification relation de Beta avec source/cible Alpha : refusee (anciennes extremites non autorisees)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query $attackAlphaOnBetaRel `
        -ExpectedOutcome "ERROR"

    # Action 1 CTO : Client Alpha tente d'associer un article cible prive appartenant a Beta dans sa propre relation
    $attackAlphaTargetBeta = @"
UPDATE catalogue_relation SET cible = catalogue_item:BETA_FENETRE WHERE source = catalogue_item:PORT_SUR_MESURE;
"@
    Execute-TestQuery -TestId "CTO-TEST-10G7" `
        -Description "Client Alpha tente de lier sa relation a un article de Beta : refusee (nouvelle extremite non autorisee)" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query $attackAlphaTargetBeta `
        -ExpectedOutcome "ERROR"

    # 4. Opérations légitimes du propriétaire
    $updateAlphaPrivate = @"
UPDATE catalogue_composition SET libelle = 'Recette Cloison Alpha V2' WHERE parent_item = catalogue_item:PORT_SUR_MESURE;
UPDATE catalogue_relation SET commentaire = 'Liaison privee validee V2' WHERE source = catalogue_item:PORT_SUR_MESURE;
"@
    Execute-TestQuery -TestId "CTO-TEST-10H" `
        -Description "Client Alpha lit et met a jour sa propre composition et sa propre relation : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenClientAlpha `
        -Query $updateAlphaPrivate `
        -ExpectedOutcome "SUCCESS"

    # 5. Fonctionnement normal du service Master Sync
    $syncReadRefs = @"
SELECT * FROM catalogue_type;
SELECT * FROM catalogue_categorie;
SELECT * FROM catalogue_attribut;
SELECT * FROM catalogue_relation_type;
"@
    Execute-TestQuery -TestId "CTO-TEST-10I" `
        -Description "catalogue_sync_agent consulte et manipule legitimement les referentiels de reference : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $syncReadRefs `
        -ExpectedOutcome "SUCCESS"

    # =========================================================================
    # POINT 10 : SUITE DE NON-RÉGRESSION DES RÈGLES MÉTIER MASTER CATALOGUE V1
    # =========================================================================

    # --- Test 2 : Collision master_id ---
    $createSync1 = @"
fn::catalogue_item_create({
    code: "TEST_SYNC_ITEM_01",
    type: catalogue_type:PRODUIT,
    libelle: "Article synchronise 1",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "FABRICANT EXT",
    is_custom: false,
    master_id: "catalogue_item:EXT_SHARED_001"
});
"@
    Execute-TestQuery -TestId "V1-TEST-02A" `
        -Description "Creation reference locale avec master_id par catalogue_sync_agent : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $createSync1 `
        -ExpectedOutcome "SUCCESS"

    $createSync2Collision = @"
fn::catalogue_item_create({
    code: "TEST_SYNC_ITEM_02",
    type: catalogue_type:PRODUIT,
    libelle: "Article tentant de reutiliser le meme master_id",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "FABRICANT EXT",
    is_custom: false,
    master_id: "catalogue_item:EXT_SHARED_001"
});
"@
    Execute-TestQuery -TestId "V1-TEST-02B" `
        -Description "Collision d'un second article avec le meme master_id : bloque" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $createSync2Collision `
        -ExpectedOutcome "ERROR"

    # --- Test 3 : GTIN Modulo 10 ---
    $badGtin = @"
fn::catalogue_item_create({
    code: "TEST_BAD_GTIN_ITEM",
    type: catalogue_type:PRODUIT,
    libelle: "Produit avec GTIN-13 errone",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "TEST LAB",
    code_barre: "4006381333932",
    is_custom: false
});
"@
    Execute-TestQuery -TestId "V1-TEST-03A" `
        -Description "Produit avec GTIN-13 ayant mauvaise cle Modulo 10 : bloque" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $badGtin `
        -ExpectedOutcome "ERROR"

    $goodGtin = @"
fn::catalogue_item_create({
    code: "TEST_GOOD_GTIN_ITEM",
    type: catalogue_type:PRODUIT,
    libelle: "Produit avec GTIN-13 officiel valide",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "TEST LAB",
    code_barre: "4006381333931",
    is_custom: false
});
"@
    Execute-TestQuery -TestId "V1-TEST-03B" `
        -Description "Produit avec GTIN-13 officiel valide (cle 1) : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $goodGtin `
        -ExpectedOutcome "SUCCESS"


    # --- Test 4 : Référence fabricant dupliquée chez le même fabricant ---
    $fabRef1 = @"
fn::catalogue_item_create({
    code: "TEST_FAB_REF_01",
    type: catalogue_type:PRODUIT,
    libelle: "Article Fabricant Ref Unique",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "BOSCH OUTILLAGE",
    reference_fabricant: "PRO-BOSCH-2026",
    is_custom: false
});
"@
    Execute-TestQuery -TestId "V1-TEST-04A" `
        -Description "Creation reference fabricant initiale chez Bosch : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $fabRef1 `
        -ExpectedOutcome "SUCCESS"

    $fabRef2Collision = @"
fn::catalogue_item_create({
    code: "TEST_FAB_REF_02",
    type: catalogue_type:PRODUIT,
    libelle: "Tentative doublon reference fabricant chez Bosch",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "BOSCH OUTILLAGE",
    reference_fabricant: "PRO-BOSCH-2026",
    is_custom: false
});
"@
    Execute-TestQuery -TestId "V1-TEST-04B" `
        -Description "Doublon de reference fabricant chez le meme fabricant : bloque" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $fabRef2Collision `
        -ExpectedOutcome "ERROR"

    $fabRefMakita = @"
fn::catalogue_item_create({
    code: "TEST_FAB_REF_MAKITA",
    type: catalogue_type:PRODUIT,
    libelle: "Meme reference mais chez Makita",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "MAKITA FRANCE",
    reference_fabricant: "PRO-BOSCH-2026",
    is_custom: false
});
"@
    Execute-TestQuery -TestId "V1-TEST-04C" `
        -Description "Meme reference fabricant chez un fabricant distinct (Makita) : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $fabRefMakita `
        -ExpectedOutcome "SUCCESS"

    # --- Test 6 : Modification d'une référence commerciale liée à un générique ---
    $relCommerce = @"
LET `$gen_item = fn::catalogue_item_create({
    code: "TEST_GEN_SUPPORT",
    type: catalogue_type:PRODUIT,
    libelle: "Support metallique generique",
    unite_reference: base_unite:U,
    nature_reference: "GENERIQUE",
    is_custom: false
});
LET `$com_item = fn::catalogue_item_create({
    code: "TEST_COM_SUPPORT_SPIT",
    type: catalogue_type:PRODUIT,
    libelle: "Support metallique Spit Pro",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "SPIT PASLODE",
    marque: "SPIT",
    reference_fabricant: "SPIT-SUP-01",
    is_custom: false
});
LET `$rel_spec = fn::catalogue_relation_create({
    source: `$com_item.data.id,
    cible: `$gen_item.data.id,
    relation_type: catalogue_relation_type:COMMERCIAL_SPECIFICATION,
    commentaire: "Specification Spit pour support generique"
});
fn::catalogue_item_update({
    id: `$com_item.data.id,
    statut_commercial: "FIN_DE_SERIE",
    description: "Fin de serie - remplace par V2"
});
"@
    Execute-TestQuery -TestId "V1-TEST-06 " `
        -Description "Mise a jour commerciale liee a un generique (statut FIN_DE_SERIE) : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $relCommerce `
        -ExpectedOutcome "SUCCESS"

    # --- Test 7 : Cycle de remplacement A -> B -> C -> A ---
    $antiCycle = @"
LET `$item_remp_a = fn::catalogue_item_create({
    code: "TEST_REMP_A",
    type: catalogue_type:PRODUIT,
    libelle: "Generation 1 (A)",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "TECH CORP",
    is_custom: false
});
LET `$item_remp_b = fn::catalogue_item_create({
    code: "TEST_REMP_B",
    type: catalogue_type:PRODUIT,
    libelle: "Generation 2 (B)",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "TECH CORP",
    is_custom: false
});
LET `$item_remp_c = fn::catalogue_item_create({
    code: "TEST_REMP_C",
    type: catalogue_type:PRODUIT,
    libelle: "Generation 3 (C)",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    fabricant: "TECH CORP",
    is_custom: false
});
fn::catalogue_relation_create({
    source: `$item_remp_a.data.id,
    cible: `$item_remp_b.data.id,
    relation_type: catalogue_relation_type:REMPLACEMENT
});
fn::catalogue_relation_create({
    source: `$item_remp_b.data.id,
    cible: `$item_remp_c.data.id,
    relation_type: catalogue_relation_type:REMPLACEMENT
});
fn::catalogue_relation_create({
    source: `$item_remp_c.data.id,
    cible: `$item_remp_a.data.id,
    relation_type: catalogue_relation_type:REMPLACEMENT
});
"@
    Execute-TestQuery -TestId "V1-TEST-07 " `
        -Description "Cycle de remplacement ferme A -> B -> C -> A : rejete par anti-cycle" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $antiCycle `
        -ExpectedOutcome "ERROR"

    # --- Test 8 : Composition BTP avec pertes isolées et conditionnement ---
    $btpComp = @"
LET `$btp_composant = fn::catalogue_item_create({
    code: "TEST_COMPOSANT_M2",
    type: catalogue_type:PRODUIT,
    libelle: "Plaque technique brute",
    unite_reference: base_unite:M2,
    nature_reference: "GENERIQUE",
    is_custom: false,
    conditionnement: {
        type_unite: base_unite:PCE,
        quantite: 3.0,
        poids_kg: 27.5
    }
});
LET `$btp_ouvrage = fn::catalogue_item_create({
    code: "TEST_OUVRAGE_CLOISON",
    type: catalogue_type:OUVRAGE,
    libelle: "Ouvrage de cloison test",
    unite_reference: base_unite:M2,
    nature_reference: "GENERIQUE",
    is_custom: false,
    is_composite: true
});
LET `$btp_comp = fn::catalogue_composition_create({
    parent_item: `$btp_ouvrage.data.id,
    libelle: "Recette test sans double perte"
});
fn::catalogue_composition_add_line({
    composition_id: `$btp_comp.data.id,
    composant_item: `$btp_composant.data.id,
    quantite: 2.00,
    unite: base_unite:M2,
    coefficient_perte: 1.025
});
"@
    Execute-TestQuery -TestId "V1-TEST-08 " `
        -Description "Composition BTP avec pertes isolees (coef 1.025) et conditionnement : succes" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $btpComp `
        -ExpectedOutcome "SUCCESS"

    # --- Test 9 : Nature générique vs commerciale ---
    $badGeneric = @"
fn::catalogue_item_create({
    code: "TEST_BAD_GENERIC",
    type: catalogue_type:PRODUIT,
    libelle: "Faux generique avec marque",
    unite_reference: base_unite:U,
    nature_reference: "GENERIQUE",
    fabricant: "PLACOPLATRE",
    is_custom: false
});
"@
    Execute-TestQuery -TestId "V1-TEST-09A" `
        -Description "Generique tentant de declarer un fabricant/marque : bloque" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $badGeneric `
        -ExpectedOutcome "ERROR"

    $badCommercial = @"
fn::catalogue_item_create({
    code: "TEST_BAD_COMMERCIAL",
    type: catalogue_type:PRODUIT,
    libelle: "Faux commercial sans marque ni fabricant",
    unite_reference: base_unite:U,
    nature_reference: "COMMERCIALE",
    is_custom: false
});
"@
    Execute-TestQuery -TestId "V1-TEST-09B" `
        -Description "Commercial sans marque ni fabricant : bloque" `
        -Namespace "tenant_alpha" -Database "client_db" `
        -Token $tokenSyncAlpha `
        -Query $badCommercial `
        -ExpectedOutcome "ERROR"



    # -------------------------------------------------------------------------
    # VÉRIFICATION DE L'ÉTAT FINAL DE L'ARTICLE DANS TENANT ALPHA
    # -------------------------------------------------------------------------
    Write-Host "`nVerification de l'etat final de l'article dans Alpha..."
    $verifyHeaders = @{
        'surreal-ns' = 'tenant_alpha'
        'surreal-db' = 'client_db'
        'Authorization' = "Bearer $tokenClientAlpha"
    }
    $finalState = Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers $verifyHeaders -ContentType "text/plain; charset=utf-8" -Body "SELECT code, libelle, fabricant, description, statut_commercial, enabled, code_interne_client, libelle_personnalise FROM catalogue_item:PLACO_BA13;"
    Write-Host "Article apres tous les tests :" ($finalState | ConvertTo-Json -Depth 5)

} finally {
    Write-Host "`nArret du processus SurrealDB."
    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
}

Write-Host "`n========================================================"
Write-Host "RÉSUMÉ FINAL DES TESTS CTO"
Write-Host "========================================================"
$passedCount = ($results | Where-Object { $_.Status -eq "PASSED" }).Count
$failedCount = ($results | Where-Object { $_.Status -eq "FAILED" }).Count
Write-Host "Total tests : $($results.Count) | PASSED : $passedCount | FAILED : $failedCount"

if ($failedCount -gt 0) {
    exit 1
} else {
    exit 0
}
