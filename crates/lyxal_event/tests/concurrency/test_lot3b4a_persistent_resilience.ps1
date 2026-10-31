# ============================================================================
# Harnais de Validation Résilience sur Stockage Persistant & Multi-Instance
# Lot 3B.4A - lyxal_event & lyxal_runtime
# Binaire officiel SurrealDB 3.2.0 avec backend surrealkv persistant sur disque
# ============================================================================

$ErrorActionPreference = "Stop"

$port = 8124
$dbPath = "surrealkv://./test_lot3b4a_data"
$dataDir = "test_lot3b4a_data"

if (Test-Path $dataDir) {
    Remove-Item -Recurse -Force $dataDir
}

function Start-SurrealServer {
    Write-Host "[SURREALDB] Démarrage du serveur 3.2.0 sur $dbPath (port $port)..." -ForegroundColor Cyan
    $p = Start-Process -FilePath ".\surreal.exe" `
        -ArgumentList "start", "--bind", "127.0.0.1:$port", "--user", "root", "--pass", "root", $dbPath `
        -PassThru -NoNewWindow
    
    $maxAttempts = 30
    $ready = $false
    for ($i = 0; $i -lt $maxAttempts; $i++) {
        Start-Sleep -Milliseconds 300
        try {
            $resp = Invoke-RestMethod -Uri "http://127.0.0.1:$port/health" -Method Get -TimeoutSec 1 -ErrorAction SilentlyContinue
            if ($null -ne $resp) {
                $ready = $true
                break
            }
        } catch {}
    }
    if (-not $ready) {
        throw "Le serveur SurrealDB n'a pas démarré sur le port $port"
    }
    Write-Host "[SURREALDB] Serveur opérationnel (PID=$($p.Id))" -ForegroundColor Green
    return $p
}

function Exec-Sql($query) {
    $headers = @{
        "Accept" = "application/json"
        "surreal-ns" = "test"
        "surreal-db" = "test"
        "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("root:root"))
    }
    $body = $query
    $resp = Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Headers $headers -Body $body -ContentType "text/plain; charset=utf-8"
    return $resp
}

function Get-Data($response) {
    if ($response -is [array]) {
        foreach ($item in $response) {
            if ($item.status -eq "ERR") {
                throw "SurrealDB Error: $($item.result)"
            }
            if ($null -ne $item.result -and $null -ne $item.result.data) {
                return $item.result.data
            }
        }
        $last = $response[-1]
        return $last.result
    } elseif ($null -ne $response.result -and $null -ne $response.result.data) {
        return $response.result.data
    }
    return $response.result
}

$process = $null

try {
    $process = Start-SurrealServer

    Write-Host "`n=== 1. APPLICATION DES MIGRATIONS ET FONCTIONS PERSISTANTES ===" -ForegroundColor Magenta
    $authHeader = @{
        "Accept" = "application/json"
        "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("root:root"))
    }
    Invoke-RestMethod -Uri "http://127.0.0.1:$port/sql" -Method Post -Body "DEFINE NAMESPACE test; USE NS test; DEFINE DATABASE test;" -Headers $authHeader -ContentType "text/plain; charset=utf-8" | Out-Null
    Exec-Sql @"
DEFINE FUNCTION OVERWRITE fn::result_ok(`$data: any) { RETURN { ok: true, data: `$data, error: NONE }; };
DEFINE FUNCTION OVERWRITE fn::error_result(`$code: option<string>, `$language: option<string>, `$details: option<object>) { RETURN { ok: false, data: NONE, error: { code: `$code, language: `$language, details: `$details } }; };
"@ | Out-Null

    $migrations = @(
        "migrations/0001_initial_schema.surql",
        "migrations/0002_danube_durability.surql",
        "migrations/0003_dead_letter_flexible.surql"
    )
    foreach ($m in $migrations) {
        $content = Get-Content "crates/lyxal_event/$m" -Raw -Encoding UTF8
        Exec-Sql $content | Out-Null
        Write-Host "  -> Migration appliquée : $m" -ForegroundColor Gray
    }

    $functions = @(
        "functions/event_lease_acquire.surql",
        "functions/event_lease_renew.surql",
        "functions/event_lease_release.surql",
        "functions/event_delivery_assign_seq.surql",
        "functions/event_flush_batch.surql",
        "functions/event_dead_letter_transfer.surql",
        "functions/event_progress_get.surql"
    )
    foreach ($fn in $functions) {
        $content = Get-Content "crates/lyxal_event/$fn" -Raw -Encoding UTF8
        Exec-Sql $content | Out-Null
    }
    Write-Host "[OK] Schémas et fonctions chargées sur le stockage persistant." -ForegroundColor Green

    # Initialisation Subscription et Outbox Events
    Exec-Sql @"
CREATE type::record('event_subscription', 'sub_resilience') CONTENT { name: "sub_resilience" };
CREATE type::record('event_outbox', 'evt_res_1') CONTENT {
    event_id: rand::uuid::v7(),
    event_type: "invoice.generated",
    producer: "billing_service",
    payload: { invoice_id: "inv_101", total: 1200 },
    context: { instance_id: "inst_alpha", namespace: "test", database: "test" },
    correlation_id: rand::uuid::v7()
};
CREATE type::record('event_outbox', 'evt_res_2') CONTENT {
    event_id: rand::uuid::v7(),
    event_type: "invoice.generated",
    producer: "billing_service",
    payload: { invoice_id: "inv_102", total: 3400 },
    context: { instance_id: "inst_alpha", namespace: "test", database: "test" },
    correlation_id: rand::uuid::v7()
};
CREATE type::record('event_outbox', 'evt_res_3') CONTENT {
    event_id: rand::uuid::v7(),
    event_type: "invoice.generated",
    producer: "billing_service",
    payload: { invoice_id: "inv_103", total: 5600 },
    context: { instance_id: "inst_alpha", namespace: "test", database: "test" },
    correlation_id: rand::uuid::v7()
};
"@ | Out-Null

    # ------------------------------------------------------------------------
    # SCÉNARIO 1 : Multi-Instance & Exclusion de Leadership (Instance A vs B)
    # ------------------------------------------------------------------------
    Write-Host "`n--- SCÉNARIO 1 : Concurrence Multi-Instance & Exclusion de Leadership ---" -ForegroundColor Yellow
    $acqA = Exec-Sql "RETURN fn::event_lease_acquire({ node_id: 'instance_a', ttl_seconds: 4 });"
    $dataA = Get-Data $acqA
    if (-not $dataA.acquired -or $dataA.generation -ne 1) {
        throw "Instance A aurait dû acquérir le bail sous G=1"
    }
    Write-Host "  -> [SUCCÈS] Instance A a acquis le leadership (G=$($dataA.generation), TTL=4s)" -ForegroundColor Green

    # Concurrence : Instance B tente d'acquérir le bail pendant qu'il est actif
    $acqB = Exec-Sql "RETURN fn::event_lease_acquire({ node_id: 'instance_b', ttl_seconds: 4 });"
    $dataB = Get-Data $acqB
    if ($dataB.acquired) {
        throw "Violation d'exclusion mutuelle : Instance B n'aurait pas dû acquérir le bail actif !"
    }
    if ($dataB.owner_node_id -ne "instance_a") {
        throw "Le propriétaire déclaré doit être instance_a"
    }
    Write-Host "  -> [SUCCÈS] Tentative concurrente d'Instance B rejetée (détenu par $($dataB.owner_node_id))" -ForegroundColor Green

    # ------------------------------------------------------------------------
    # SCÉNARIO 2 : Assignation Séquentielle Contiguë sans Trou
    # ------------------------------------------------------------------------
    Write-Host "`n--- SCÉNARIO 2 : Attribution séquentielle contiguë par le Leader A ---" -ForegroundColor Yellow
    $del1Res = Exec-Sql @"
RETURN fn::event_delivery_assign_seq({
    outbox_event: 'event_outbox:evt_res_1',
    subscription: 'event_subscription:sub_resilience',
    target_module: 'accounting',
    node_id: 'instance_a',
    generation: 1,
    context: { instance_id: 'inst_alpha', namespace: 'test', database: 'test' }
});
"@
    $del1Data = Get-Data $del1Res
    if ($del1Data.delivery_seq -ne 1) { throw "Séquence 1 attendue pour livraison 1" }
    $del1Id = $del1Data.id
    Write-Host "  -> [SUCCÈS] Livraison 1 créée (id=$del1Id, seq=1)" -ForegroundColor Green

    $del2Res = Exec-Sql @"
RETURN fn::event_delivery_assign_seq({
    outbox_event: 'event_outbox:evt_res_2',
    subscription: 'event_subscription:sub_resilience',
    target_module: 'accounting',
    node_id: 'instance_a',
    generation: 1,
    context: { instance_id: 'inst_alpha', namespace: 'test', database: 'test' }
});
"@
    $del2Data = Get-Data $del2Res
    if ($del2Data.delivery_seq -ne 2) { throw "Séquence 2 attendue pour livraison 2" }
    $del2Id = $del2Data.id
    Write-Host "  -> [SUCCÈS] Livraison 2 créée (id=$del2Id, seq=2)" -ForegroundColor Green

    # ------------------------------------------------------------------------
    # SCÉNARIO 3 : Crash Brutal Serveur SurrealDB (SIGKILL) et Reprise sur Disque
    # ------------------------------------------------------------------------
    Write-Host "`n--- SCÉNARIO 3 : Crash Brutal du Serveur (SIGKILL) et Redémarrage sur Disque ---" -ForegroundColor Yellow
    Write-Host "  -> Arrêt forcé immédiat du processus serveur PID=$($process.Id)..." -ForegroundColor Red
    Stop-Process -Id $process.Id -Force
    Start-Sleep -Seconds 1

    # Redémarrage du serveur sur les mêmes fichiers surrealkv
    $process = Start-SurrealServer

    # Vérification de la durabilité des données sur disque post-crash
    $verifyDel = Exec-Sql "SELECT id, delivery_seq, status FROM event_delivery WHERE subscription = type::record('event_subscription', 'sub_resilience') ORDER BY delivery_seq ASC;"
    $rows = $verifyDel[0].result
    if ($rows.Count -ne 2) {
        throw "Perte de données après crash : attendu 2 livraisons, obtenu $($rows.Count)"
    }
    if ($rows[0].delivery_seq -ne 1 -or $rows[1].delivery_seq -ne 2) {
        throw "Données corrompues post-crash dans event_delivery"
    }
    Write-Host "  -> [SUCCÈS] Durabilité vérifiée : les 2 livraisons et leurs séquences ont survécu au crash !" -ForegroundColor Green

    # ------------------------------------------------------------------------
    # SCÉNARIO 4 : Expiration de Bail & Bascule de Leadership (Failover Instance B)
    # ------------------------------------------------------------------------
    Write-Host "`n--- SCÉNARIO 4 : Expiration du Bail (TTL 4s) et Prise de Leadership par Instance B ---" -ForegroundColor Yellow
    Write-Host "  -> Attente de l'expiration du TTL (5 secondes)..." -ForegroundColor Gray
    Start-Sleep -Seconds 5

    $acqBFailover = Exec-Sql "RETURN fn::event_lease_acquire({ node_id: 'instance_b', ttl_seconds: 6 });"
    $dataBFailover = Get-Data $acqBFailover
    if (-not $dataBFailover.acquired) {
        throw "Instance B aurait dû acquérir le bail expiré !"
    }
    if ($dataBFailover.generation -ne 2) {
        throw "Numéro de génération monotone attendu G=2, obtenu G=$($dataBFailover.generation)"
    }
    Write-Host "  -> [SUCCÈS] Failover réussi : Instance B devient Leader avec G=$($dataBFailover.generation)" -ForegroundColor Green

    # Vérification que le nouveau leader relit la progression durable
    $progRes = Exec-Sql "RETURN fn::event_progress_get({ subscription: 'event_subscription:sub_resilience' });"
    $progData = Get-Data $progRes
    if ($progData.last_assigned_seq -ne 2 -or $progData.last_persisted_cursor -ne 0) {
        throw "Progression incohérente lue par le nouveau leader"
    }
    Write-Host "  -> [SUCCÈS] Nouveau leader a relu l'état exact : last_assigned_seq=2, last_persisted_cursor=0" -ForegroundColor Green

    # ------------------------------------------------------------------------
    # SCÉNARIO 5 : Réveil Zombie & Fencing Transactionnel Étanche (Instance A)
    # ------------------------------------------------------------------------
    Write-Host "`n--- SCÉNARIO 5 : Réveil Zombie d'Instance A & Fencing Transactionnel Rejeté ---" -ForegroundColor Yellow
    # L'ancien leader zombie A tente d'avancer le curseur sous G=1
    $zombieAttempt = Exec-Sql @"
RETURN fn::event_flush_batch({
    subscription: 'event_subscription:sub_resilience',
    target_cursor: 1,
    node_id: 'instance_a',
    generation: 1,
    delivered_ids: ['$del1Id'],
    dead_letter_ids: [],
    dropped_ids: []
});
"@
    $zombieJson = ConvertTo-Json $zombieAttempt
    if ($zombieJson -notlike "*EVENT_STALE_LEADER_FENCED*") {
        throw "FAILLE DE SÉCURITÉ : La mutation zombie sous G=1 n'a pas été rejetée par le Fencing !"
    }
    Write-Host "  -> [SUCCÈS] Fencing transactionnel étanche : écriture zombie G=1 rejetée !" -ForegroundColor Green

    # Vérification que le curseur n'a pas bougé
    $progCheck = Exec-Sql "RETURN fn::event_progress_get({ subscription: 'event_subscription:sub_resilience' });"
    if ((Get-Data $progCheck).last_persisted_cursor -ne 0) {
        throw "Le curseur a été corrompu par la tentative zombie"
    }
    Write-Host "  -> [SUCCÈS] Intégrité préservée : le curseur durable est resté inchangé à 0" -ForegroundColor Green

    # ------------------------------------------------------------------------
    # SCÉNARIO 6 : Flush Unitaire ACK & Barrière DLQ sous Leader B
    # ------------------------------------------------------------------------
    Write-Host "`n--- SCÉNARIO 6 : Traitement ACK et Transfert Quarantaine DLQ sous Leader B ---" -ForegroundColor Yellow
    # 1. ACK seq 1
    $flush1Res = Exec-Sql @"
RETURN fn::event_flush_batch({
    subscription: 'event_subscription:sub_resilience',
    target_cursor: 1,
    node_id: 'instance_b',
    generation: 2,
    delivered_ids: ['$del1Id'],
    dead_letter_ids: [],
    dropped_ids: []
});
"@
    $flush1Data = Get-Data $flush1Res
    if ($flush1Data.persisted_cursor -ne 1) { throw "Curseur non avancé à 1" }
    Write-Host "  -> [SUCCÈS] Curseur avancé à 1 suite à l'ACK de livraison 1" -ForegroundColor Green

    # 2. Livraison 2 échoue de façon terminale -> Transfert DLQ
    $dlqRes = Exec-Sql @"
RETURN fn::event_dead_letter_transfer({
    delivery_id: '$del2Id',
    error: 'terminal: Invalid tax account configuration',
    node_id: 'instance_b',
    generation: 2
});
"@
    $dlqData = Get-Data $dlqRes
    if (-not $dlqData.dead_lettered) { throw "Échec du transfert en DLQ" }
    Write-Host "  -> [SUCCÈS] Livraison 2 transférée en DLQ (dlq_id=$($dlqData.dlq_id))" -ForegroundColor Green

    # 3. Flush débloquant la barrière jusqu'à seq 2
    $flush2Res = Exec-Sql @"
RETURN fn::event_flush_batch({
    subscription: 'event_subscription:sub_resilience',
    target_cursor: 2,
    node_id: 'instance_b',
    generation: 2,
    delivered_ids: [],
    dead_letter_ids: ['$del2Id'],
    dropped_ids: []
});
"@
    $flush2Data = Get-Data $flush2Res
    if ($flush2Data.persisted_cursor -ne 2) { throw "Curseur non avancé à 2 après résolution DLQ" }
    Write-Host "  -> [SUCCÈS] Curseur durable avancé à 2 après franchissement de la barrière DLQ" -ForegroundColor Green

    # ------------------------------------------------------------------------
    # SCÉNARIO 7 : Crash Brutal Serveur en cours de flux et Reprise Post-Crash
    # ------------------------------------------------------------------------
    Write-Host "`n--- SCÉNARIO 7 : Assignation seq=3, Crash Brutal et Reprise sur Disque ---" -ForegroundColor Yellow
    $del3Res = Exec-Sql @"
RETURN fn::event_delivery_assign_seq({
    outbox_event: 'event_outbox:evt_res_3',
    subscription: 'event_subscription:sub_resilience',
    target_module: 'accounting',
    node_id: 'instance_b',
    generation: 2,
    context: { instance_id: 'inst_alpha', namespace: 'test', database: 'test' }
});
"@
    $del3Data = Get-Data $del3Res
    if ($del3Data.delivery_seq -ne 3) { throw "Séquence 3 attendue" }
    $del3Id = $del3Data.id
    Write-Host "  -> [SUCCÈS] Livraison 3 assignée (id=$del3Id, seq=3)" -ForegroundColor Green

    # Second crash forcé du serveur !
    Write-Host "  -> Crash forcé immédiat du serveur PID=$($process.Id)..." -ForegroundColor Red
    Stop-Process -Id $process.Id -Force
    Start-Sleep -Seconds 1

    # Redémarrage du serveur
    $process = Start-SurrealServer

    # Vérification post-crash : le curseur persistant est toujours à 2 et l'assignation est à 3
    $progPostCrash = Exec-Sql "RETURN fn::event_progress_get({ subscription: 'event_subscription:sub_resilience' });"
    $pData = Get-Data $progPostCrash
    if ($pData.last_persisted_cursor -ne 2 -or $pData.last_assigned_seq -ne 3) {
        throw "Incohérence de progression après le deuxième crash : cursor=$($pData.last_persisted_cursor), assigned=$($pData.last_assigned_seq)"
    }
    Write-Host "  -> [SUCCÈS] Post-crash intègre : curseur persistant=2, séquence allouée=3" -ForegroundColor Green

    # Renouvellement / réacquisition du bail par Instance B
    Exec-Sql "RETURN fn::event_lease_renew({ node_id: 'instance_b', generation: 2, ttl_seconds: 10 });" | Out-Null

    # Rétablissement et ACK de la livraison 3
    $flush3Res = Exec-Sql @"
RETURN fn::event_flush_batch({
    subscription: 'event_subscription:sub_resilience',
    target_cursor: 3,
    node_id: 'instance_b',
    generation: 2,
    delivered_ids: ['$del3Id'],
    dead_letter_ids: [],
    dropped_ids: []
});
"@
    $flush3Data = Get-Data $flush3Res
    if ($flush3Data.persisted_cursor -ne 3) { throw "Curseur non durci à 3" }
    Write-Host "  -> [SUCCÈS] Livraison 3 acquittée post-crash et curseur contigu durci à 3" -ForegroundColor Green

    # ------------------------------------------------------------------------
    # SCÉNARIO 8 : Arrêt Propre et Libération Formelle du Bail (Zero-Wait Handover)
    # ------------------------------------------------------------------------
    Write-Host "`n--- SCÉNARIO 8 : Arrêt Propre & Libération Formelle du Bail ---" -ForegroundColor Yellow
    $relRes = Exec-Sql "RETURN fn::event_lease_release({ node_id: 'instance_b', generation: 2 });"
    $relData = Get-Data $relRes
    if (-not $relData.released) { throw "Échec de libération propre du bail" }
    Write-Host "  -> [SUCCÈS] Instance B a formellement libéré le bail (is_released=true)" -ForegroundColor Green

    # Instance A peut immédiatement reprendre le leadership sans attendre le TTL !
    $acqAImmediate = Exec-Sql "RETURN fn::event_lease_acquire({ node_id: 'instance_a', ttl_seconds: 5 });"
    $dataAImmediate = Get-Data $acqAImmediate
    if (-not $dataAImmediate.acquired -or $dataAImmediate.generation -ne 3) {
        throw "Instance A aurait dû acquérir immédiatement le bail libéré sous G=3"
    }
    Write-Host "  -> [SUCCÈS] Reprise instantanée (Zero-Wait) par Instance A avec G=3" -ForegroundColor Green

    Write-Host "`n=================================================================" -ForegroundColor Cyan
    Write-Host " [BILAN LOT 3B.4A] 100% DES SCÉNARIOS VALIDÉS SUR STOCKAGE PERSISTANT" -ForegroundColor Green
    Write-Host " - Exclusion Multi-Instance : OUI" -ForegroundColor Green
    Write-Host " - Fencing Transactionnel Étanche : OUI" -ForegroundColor Green
    Write-Host " - Résilience Post-Crash Serveur : OUI" -ForegroundColor Green
    Write-Host " - Continuité du Curseur Danube : OUI" -ForegroundColor Green
    Write-Host " - Zéro Perte d'Événements : OUI" -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan
}
finally {
    if ($null -ne $process -and -not $process.HasExited) {
        Stop-Process -Id $process.Id -Force
        Write-Host "[OK] Serveur SurrealDB arrêté." -ForegroundColor Gray
    }
    # Nettoyage du répertoire de test
    if (Test-Path $dataDir) {
        Remove-Item -Recurse -Force $dataDir -ErrorAction SilentlyContinue
    }
}
