# ==============================================================================
# LYXAL OS — HARNAIS DE VALIDATION TRANSACTIONNELLE LOT 3A SURREALDB 3.2.0
# Ce script exécute de manière automatisée et isolée les 4 axes de validation
# transactionnelle exigés par le CTO sur le binaire officiel SurrealDB 3.2.0.
# ==============================================================================

param(
    [string]$SurrealPath = ".\surreal.exe",
    [int]$Port = 8124
)

$ErrorActionPreference = "Stop"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " [LYXAL_EVENT LOT 3A] DÉMARRAGE DU BANC DE VALIDATION TRANSACTIONNELLE" -ForegroundColor Cyan
Write-Host " Binaire : $SurrealPath" -ForegroundColor Cyan
Write-Host " Port : $Port" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# 1. Démarrage de SurrealDB 3.2.0
$process = Start-Process -FilePath $SurrealPath -ArgumentList "start", "--bind", "127.0.0.1:$Port", "--unauthenticated", "memory" -PassThru
Start-Sleep -Seconds 2

try {
    # Vérification Version
    $version = (Invoke-RestMethod -Uri "http://127.0.0.1:$Port/version" -Method Get).Trim()
    Write-Host "[OK] Serveur SurrealDB connecté, Version: $version" -ForegroundColor Green
    if ($version -notlike "*3.2*") {
        throw "Version attendue 3.2.x, détectée: $version"
    }

    $headers = @{ "surreal-ns" = "test"; "surreal-db" = "test"; "Accept" = "application/json" }

    # Init Schéma
    $initSchema = @"
DEFINE NAMESPACE test; USE NS test; DEFINE DATABASE test; USE DB test;
DEFINE TABLE event_stream_lease SCHEMALESS;
DEFINE TABLE event_delivery SCHEMALESS;
DEFINE TABLE event_subscription_progress SCHEMALESS;
DEFINE TABLE event_dead_letter SCHEMALESS;
DEFINE TABLE test_sync SCHEMALESS;
DEFINE INDEX idx_del_event_sub ON TABLE event_delivery FIELDS outbox_event, subscription UNIQUE;
DEFINE INDEX idx_del_seq_sub ON TABLE event_delivery FIELDS subscription, delivery_seq UNIQUE;
"@
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body $initSchema -Headers @{ "Accept" = "application/json" } | Out-Null
    Write-Host "[OK] Schéma et tables initialisés avec succès" -ForegroundColor Green

    # ==============================================================================
    # AXE 1 : FENCING CONCURRENT (ANOMALIE READ-ONLY VS GARDE D'ÉCRITURE CONDITIONNELLE)
    # ==============================================================================
    Write-Host "`n--- AXE 1.A : Preuve de l'anomalie de lecture seule (Read-Only Lease Check) ---" -ForegroundColor Yellow
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body "DELETE event_stream_lease; DELETE event_delivery; CREATE event_stream_lease:outbox_leader CONTENT { generation: 1, owner_node_id: 'node_1', expires_at: time::now() + 10s };" -Headers $headers | Out-Null

    $job1A = Start-Job -ScriptBlock {
        param($p)
        $script = @"
BEGIN TRANSACTION;
LET `$lease = (SELECT * FROM event_stream_lease:outbox_leader WHERE generation = 1 AND owner_node_id = 'node_1');
IF array::is_empty(`$lease) THEN THROW "LEASE_LOST_INIT"; END;
sleep(3500ms);
CREATE event_delivery:del_1A CONTENT { status: 'delivered', written_by: 'node_1', generation: 1 };
COMMIT TRANSACTION;
"@
        $h = @{ "surreal-ns" = "test"; "surreal-db" = "test"; "Accept" = "application/json" }
        return Invoke-RestMethod -Uri "http://127.0.0.1:$p/sql" -Method Post -Body $script -Headers $h
    } -ArgumentList $Port

    # Attendre que le job démarre et entre dans son sleep transactionnel
    Start-Sleep -Milliseconds 1800
    # Leader 2 prend le leadership pendant le sleep de Leader 1
    $scriptTakeover = "BEGIN TRANSACTION; UPDATE event_stream_lease:outbox_leader SET generation = 2, owner_node_id = 'node_2'; COMMIT TRANSACTION;"
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body $scriptTakeover -Headers $headers | Out-Null

    $resJob1A = Receive-Job -Job $job1A -Wait
    $check1A = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body "SELECT * FROM event_delivery WHERE id = event_delivery:del_1A;" -Headers $headers
    $items1A = @($check1A.result)
    if ($items1A.Count -gt 0 -and $null -ne $items1A[0]) {
        Write-Host "  -> [DÉMONTRÉ] Anomaly Write Skew confirmée : la lecture seule a permis à Leader 1 (stale) de committer !" -ForegroundColor Magenta
    } else {
        throw "Échec du test de reproduction de l'anomalie 1.A. ResJob: $($resJob1A | ConvertTo-Json -Compress) Check: $($check1A | ConvertTo-Json -Compress)"
    }

    Write-Host "`n--- AXE 1.B : Preuve d'étanchéité absolue avec Garde d'Écriture Conditionnelle ---" -ForegroundColor Yellow
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body "DELETE event_stream_lease; DELETE event_delivery; CREATE event_stream_lease:outbox_leader CONTENT { generation: 1, owner_node_id: 'node_1', expires_at: time::now() + 10s };" -Headers $headers | Out-Null

    $job1B = Start-Job -ScriptBlock {
        param($p)
        $script = @"
BEGIN TRANSACTION;
LET `$guard = (
    UPDATE event_stream_lease:outbox_leader
    SET last_flushed_at = time::now()
    WHERE generation = 1 AND owner_node_id = 'node_1'
    RETURN AFTER
);
IF array::is_empty(`$guard) THEN THROW "FENCED"; END;
sleep(3500ms);
CREATE event_delivery:del_1B CONTENT { status: 'delivered', written_by: 'node_1', generation: 1 };
COMMIT TRANSACTION;
"@
        $h = @{ "surreal-ns" = "test"; "surreal-db" = "test"; "Accept" = "application/json" }
        return Invoke-RestMethod -Uri "http://127.0.0.1:$p/sql" -Method Post -Body $script -Headers $h
    } -ArgumentList $Port

    # Attendre que le job démarre et entre dans son sleep
    Start-Sleep -Milliseconds 1800
    # Leader 2 acquiert le bail
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body $scriptTakeover -Headers $headers | Out-Null

    $resJob1B = Receive-Job -Job $job1B -Wait
    $check1B = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body "SELECT * FROM event_delivery WHERE id = event_delivery:del_1B;" -Headers $headers
    $items1B = @($check1B.result)
    $hasNoDelivery = ($items1B.Count -eq 0 -or $null -eq $items1B[0])
    $conflictDetected = ($resJob1B | ConvertTo-Json -Compress).Contains("Transaction conflict: Write conflict")
    if ($hasNoDelivery -and $conflictDetected) {
        Write-Host "  -> [SUCCÈS VALIDÉ] Conflit d'écriture MVCC détecté sur le bail, transaction Leader 1 avortée, 0 zombie write !" -ForegroundColor Green
    } else {
        throw "Échec du test de garde d'écriture 1.B. ResJob: $($resJob1B | ConvertTo-Json -Compress) Items: $($items1B | ConvertTo-Json -Compress)"
    }

    # ==============================================================================
    # AXE 2 : ATTRIBUTION DE SÉQUENCE CONTIGUË SANS TROU ET ROLLBACK ATOMIQUE
    # ==============================================================================
    Write-Host "`n--- AXE 2 : Attribution de Séquence Contiguë et Rollback sur Crash ---" -ForegroundColor Yellow
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body "DELETE event_subscription_progress; DELETE event_delivery; CREATE event_subscription_progress:sub_1 CONTENT { last_assigned_seq: 100, last_persisted_cursor: 100 };" -Headers $headers | Out-Null

    # Injection d'erreur après incrément
    $errTx = @"
BEGIN TRANSACTION;
LET `$curr = (SELECT last_assigned_seq FROM ONLY event_subscription_progress:sub_1).last_assigned_seq;
LET `$next = `$curr + 1;
UPDATE event_subscription_progress:sub_1 SET last_assigned_seq = `$next;
CREATE event_delivery:d_abort CONTENT { subscription: 'sub_1', outbox_event: 'e_abort', delivery_seq: `$next, status: 'pending' };
THROW "CRASH_AFTER_INCREMENT";
COMMIT TRANSACTION;
"@
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body $errTx -Headers $headers | Out-Null

    $progCheck = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body "SELECT last_assigned_seq FROM ONLY event_subscription_progress:sub_1;" -Headers $headers
    if ($progCheck.result.last_assigned_seq -ne 100) {
        throw "Échec Rollback: sequence a augmenté malgré l'erreur !"
    }
    Write-Host "  -> [SUCCÈS VALIDÉ] Rollback parfait : last_assigned_seq est resté à 100 après crash !" -ForegroundColor Green

    # Retry immédiat réutilisant 101 sans trou
    $retryTx = @"
BEGIN TRANSACTION;
LET `$curr = (SELECT last_assigned_seq FROM ONLY event_subscription_progress:sub_1).last_assigned_seq;
LET `$next = `$curr + 1;
UPDATE event_subscription_progress:sub_1 SET last_assigned_seq = `$next;
CREATE event_delivery:d_ok CONTENT { subscription: 'sub_1', outbox_event: 'e_ok', delivery_seq: `$next, status: 'pending' };
COMMIT TRANSACTION;
"@
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body $retryTx -Headers $headers | Out-Null
    $progCheck2 = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body "SELECT last_assigned_seq FROM ONLY event_subscription_progress:sub_1;" -Headers $headers
    if ($progCheck2.result.last_assigned_seq -ne 101) {
        throw "Échec Attribution séquentielle"
    }
    Write-Host "  -> [SUCCÈS VALIDÉ] Retry a consommé exactement 101, zéro séquence brûlée, zéro trou !" -ForegroundColor Green

    # ==============================================================================
    # AXE 3 : INVARIANT DE CURSEUR DURABLE ET ÉTATS TERMINAUX
    # ==============================================================================
    Write-Host "`n--- AXE 3 : Invariant de Curseur Durable Contigu ---" -ForegroundColor Yellow
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body @"
DELETE event_subscription_progress; DELETE event_delivery;
CREATE event_subscription_progress:sub_1 CONTENT { last_assigned_seq: 5, last_persisted_cursor: 0 };
CREATE event_delivery:d1 CONTENT { subscription: 'sub_1', delivery_seq: 1, status: 'delivered' };
CREATE event_delivery:d2 CONTENT { subscription: 'sub_1', delivery_seq: 2, status: 'dead_letter' };
CREATE event_delivery:d3 CONTENT { subscription: 'sub_1', delivery_seq: 3, status: 'dropped' };
CREATE event_delivery:d4 CONTENT { subscription: 'sub_1', delivery_seq: 4, status: 'processing' };
CREATE event_delivery:d5 CONTENT { subscription: 'sub_1', delivery_seq: 5, status: 'delivered' };
"@ -Headers $headers | Out-Null

    # Tentative illégale d'avancer à 5 alors que 4 est processing
    $illegalAdvance = @"
BEGIN TRANSACTION;
LET `$curr = (SELECT last_persisted_cursor FROM ONLY event_subscription_progress:sub_1).last_persisted_cursor;
LET `$target = 5;
LET `$unresolved = (
    SELECT VALUE delivery_seq FROM event_delivery
    WHERE subscription = 'sub_1' AND delivery_seq > `$curr AND delivery_seq <= `$target AND status NOT IN ['delivered', 'dead_letter', 'dropped']
);
IF array::len(`$unresolved) > 0 THEN THROW "UNRESOLVED_SEQUENCES"; END;
UPDATE event_subscription_progress:sub_1 SET last_persisted_cursor = `$target;
COMMIT TRANSACTION;
"@
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body $illegalAdvance -Headers $headers | Out-Null
    $cursorCheck = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body "SELECT last_persisted_cursor FROM ONLY event_subscription_progress:sub_1;" -Headers $headers
    if ($cursorCheck.result.last_persisted_cursor -ne 0) {
        throw "Le curseur a avancé malgré la séquence non résolue !"
    }
    Write-Host "  -> [SUCCÈS VALIDÉ] Avancement illégal bloqué par l'invariant, curseur protégé à 0 !" -ForegroundColor Green

    # Avancement légitime à 3 (1=delivered, 2=dead_letter, 3=dropped)
    $legitAdvance3 = @"
BEGIN TRANSACTION;
LET `$curr = (SELECT last_persisted_cursor FROM ONLY event_subscription_progress:sub_1).last_persisted_cursor;
LET `$target = 3;
LET `$unresolved = (
    SELECT VALUE delivery_seq FROM event_delivery
    WHERE subscription = 'sub_1' AND delivery_seq > `$curr AND delivery_seq <= `$target AND status NOT IN ['delivered', 'dead_letter', 'dropped']
);
IF array::len(`$unresolved) > 0 THEN THROW "UNRESOLVED_SEQUENCES"; END;
UPDATE event_subscription_progress:sub_1 SET last_persisted_cursor = `$target;
COMMIT TRANSACTION;
"@
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body $legitAdvance3 -Headers $headers | Out-Null
    $cursorCheck3 = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body "SELECT last_persisted_cursor FROM ONLY event_subscription_progress:sub_1;" -Headers $headers
    if ($cursorCheck3.result.last_persisted_cursor -ne 3) {
        throw "Échec de l'avancement légitime à 3"
    }
    Write-Host "  -> [SUCCÈS VALIDÉ] Curseur avancé avec succès à 3 sur séquence contiguë résolue !" -ForegroundColor Green

    # ==============================================================================
    # AXE 4 : BARRIÈRE DLQ ET PERSISTANCE IDEMPOTENTE
    # ==============================================================================
    Write-Host "`n--- AXE 4 : Barrière DLQ Atomique et Clé Déterministe Idempotente ---" -ForegroundColor Yellow
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body @"
DELETE event_dead_letter; DELETE event_delivery;
CREATE event_delivery:del_p1 CONTENT { outbox_event: 'evt_p1', subscription: 'sub_1', attempts: 5, status: 'failed' };
"@ -Headers $headers | Out-Null

    $dlqTx = @"
BEGIN TRANSACTION;
LET `$del = (SELECT * FROM ONLY event_delivery:del_p1);
UPSERT event_dead_letter:dlq_del_p1 CONTENT {
    delivery_id: `$del.id,
    outbox_event: `$del.outbox_event,
    subscription: `$del.subscription,
    attempts: `$del.attempts,
    last_error: "Poison error",
    dead_lettered_at: time::now()
};
UPDATE event_delivery:del_p1 SET status = 'dead_letter', dead_letter_ref = event_dead_letter:dlq_del_p1;
COMMIT TRANSACTION;
"@
    # Exécution 1
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body $dlqTx -Headers $headers | Out-Null
    # Exécution 2 (Idempotence)
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body $dlqTx -Headers $headers | Out-Null

    $dlqCount = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body "SELECT count() FROM event_dead_letter GROUP ALL;" -Headers $headers
    $delStatus = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body "SELECT status, dead_letter_ref FROM ONLY event_delivery:del_p1;" -Headers $headers

    if ($dlqCount.result[0].count -eq 1 -and $delStatus.result.status -eq "dead_letter" -and $delStatus.result.dead_letter_ref -eq "event_dead_letter:dlq_del_p1") {
        Write-Host "  -> [SUCCÈS VALIDÉ] Transition DLQ atomique et 100% idempotente (exactement 1 enregistrement conservé) !" -ForegroundColor Green
    } else {
        throw "Échec du test DLQ Barrier"
    }

    Write-Host "`n=================================================================" -ForegroundColor Cyan
    Write-Host " [BILAN GÉNÉRAL] TOUTES LES GARANTIES DU LOT 3A SONT VÉRIFIÉES À 100% SUR SURREALDB 3.2.0" -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan

} finally {
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Serveur de test arrêté." -ForegroundColor Gray
}
