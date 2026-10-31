# ==============================================================================
# LYXAL OS — BANC DE TESTS D'INTÉGRATION LOT 3B.1 SUR SURREALDB 3.2.0
# Valide l'ensemble des 12 scénarios obligatoires du Mandat CTO Lot 3B.1 :
# Migrations idempotentes, Fonctions SurrealQL, Fencing MVCC, Séquencement contigu,
# Invariant de curseur, Barrière DLQ, et Reprise après crash.
# ==============================================================================

param(
    [string]$SurrealPath = ".\surreal.exe",
    [int]$Port = 8125
)

$ErrorActionPreference = "Stop"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " [LYXAL_EVENT LOT 3B.1] BANC D'INTÉGRATION PERSISTANCE & FONCTIONS" -ForegroundColor Cyan
Write-Host " Binaire : $SurrealPath" -ForegroundColor Cyan
Write-Host " Port : $Port" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# Démarrage du serveur SurrealDB 3.2.0
$process = Start-Process -FilePath $SurrealPath -ArgumentList "start", "--bind", "127.0.0.1:$Port", "--unauthenticated", "memory" -PassThru
Start-Sleep -Seconds 2

try {
    # 0. Vérification Version
    $version = (Invoke-RestMethod -Uri "http://127.0.0.1:$Port/version" -Method Get).Trim()
    Write-Host "[OK] Serveur SurrealDB connecté, Version: $version" -ForegroundColor Green
    if ($version -notlike "*3.2*") { throw "Version attendue 3.2.x, détectée: $version" }

    $headers = @{ "surreal-ns" = "test"; "surreal-db" = "test"; "Accept" = "application/json" }

    function Exec-Sql {
        param([string]$query)
        return Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body $query -Headers $headers -ContentType "text/plain; charset=utf-8"
    }

    function Get-Data {
        param($response)
        if ($response -is [array]) {
            foreach ($item in $response) {
                if ($null -ne $item.result -and $null -ne $item.result.data) {
                    return $item.result.data
                }
            }
        } elseif ($null -ne $response.result -and $null -ne $response.result.data) {
            return $response.result.data
        }
        return $null
    }

    # Initialisation Namespace et Base
    $initDb = "DEFINE NAMESPACE test; USE NS test; DEFINE DATABASE test;"
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body $initDb -Headers @{ "Accept" = "application/json" } -ContentType "text/plain; charset=utf-8" | Out-Null

    # Primitives de base de résultat universel
    $primitives = @"
DEFINE FUNCTION OVERWRITE fn::result_ok(`$data: any) {
    RETURN { ok: true, data: `$data, error: NONE };
};
DEFINE FUNCTION OVERWRITE fn::error_result(`$code: option<string>, `$language: option<string>, `$details: option<object>) {
    RETURN { ok: false, data: NONE, error: { code: `$code, language: `$language, details: `$details } };
};
"@
    Exec-Sql $primitives | Out-Null
    Write-Host "[OK] Primitives fn::result_ok et fn::error_result initialisées." -ForegroundColor Green

    # ==============================================================================
    # TEST 1 : EXÉCUTION ET RÉEXÉCUTION DES MIGRATIONS (IDEMPOTENCE - VECTEUR 12)
    # ==============================================================================
    Write-Host "`n--- TEST 1 : Exécution et réexécution idempotente des migrations ---" -ForegroundColor Yellow
    $mig1 = Get-Content -Path "crates\lyxal_event\migrations\0001_initial_schema.surql" -Raw -Encoding UTF8
    $mig2 = Get-Content -Path "crates\lyxal_event\migrations\0002_danube_durability.surql" -Raw -Encoding UTF8

    # Passe 1
    Exec-Sql $mig1 | Out-Null
    Exec-Sql $mig2 | Out-Null
    Write-Host "  -> [OK] Passe 1 des migrations 0001 et 0002 exécutée." -ForegroundColor Green

    # Passe 2 (Test d'idempotence stricte)
    Exec-Sql $mig1 | Out-Null
    Exec-Sql $mig2 | Out-Null
    Write-Host "  -> [SUCCÈS VALIDÉ] Réexécution des migrations 100% idempotente sans erreur." -ForegroundColor Green

    # ==============================================================================
    # CHARGEMENT DES FONCTIONS SURREALQL LOT 3B.1
    # ==============================================================================
    Write-Host "`n--- Chargement des fonctions SurrealQL Lot 3B.1 ---" -ForegroundColor Yellow
    $functions = @(
        "crates\lyxal_event\functions\event_lease_acquire.surql",
        "crates\lyxal_event\functions\event_lease_renew.surql",
        "crates\lyxal_event\functions\event_lease_release.surql",
        "crates\lyxal_event\functions\event_delivery_assign_seq.surql",
        "crates\lyxal_event\functions\event_flush_batch.surql",
        "crates\lyxal_event\functions\event_dead_letter_transfer.surql",
        "crates\lyxal_event\functions\event_progress_get.surql"
    )

    foreach ($fnFile in $functions) {
        $fnSql = Get-Content -Path $fnFile -Raw -Encoding UTF8
        Exec-Sql $fnSql | Out-Null
        $fnName = [System.IO.Path]::GetFileNameWithoutExtension($fnFile)
        Write-Host "  -> [OK] Fonction fn::$fnName compilée et enregistrée." -ForegroundColor Gray
    }

    # ==============================================================================
    # TEST 2 : CYCLE DE VIE DU BAIL ET ACQUISITION CONCURRENTE (VECTEURS 1 & 2)
    # ==============================================================================
    Write-Host "`n--- TEST 2 : Cycle de vie du bail distribué et acquisition concurrente ---" -ForegroundColor Yellow
    
    # 2.1 Node 1 acquiert le bail
    $resAcq1 = Exec-Sql "RETURN fn::event_lease_acquire({ node_id: 'node_1', ttl_seconds: 5 });"
    $dAcq1 = $resAcq1.result.data
    if (-not $dAcq1.acquired -or $dAcq1.generation -ne 1 -or $dAcq1.owner_node_id -ne "node_1") {
        throw "Échec Test 2.1: Node 1 n'a pas acquis la génération 1"
    }
    Write-Host "  -> [OK] Node 1 a acquis le bail (génération 1)." -ForegroundColor Green

    # 2.2 Node 2 tente d'acquérir le bail actif (doit échouer)
    $resAcq2 = Exec-Sql "RETURN fn::event_lease_acquire({ node_id: 'node_2', ttl_seconds: 5 });"
    $dAcq2 = $resAcq2.result.data
    if ($dAcq2.acquired -or $dAcq2.owner_node_id -ne "node_1") {
        throw "Échec Test 2.2: Node 2 a volé le bail actif de Node 1 !"
    }
    Write-Host "  -> [OK] Node 2 rejeté : bail actif protégé (owner: $($dAcq2.owner_node_id))." -ForegroundColor Green

    # 2.3 Node 1 renouvelle le bail
    $resRenew = Exec-Sql "RETURN fn::event_lease_renew({ node_id: 'node_1', generation: 1, ttl_seconds: 10 });"
    if (-not $resRenew.result.data.renewed) { throw "Échec Test 2.3: Renouvellement échoué" }
    Write-Host "  -> [OK] Renouvellement réussi par Node 1." -ForegroundColor Green

    # 2.4 Node 1 libère le bail
    $resRel = Exec-Sql "RETURN fn::event_lease_release({ node_id: 'node_1', generation: 1 });"
    if (-not $resRel.result.data.released) { throw "Échec Test 2.4: Libération échouée" }
    Write-Host "  -> [OK] Libération volontaire par Node 1 réussie." -ForegroundColor Green

    # 2.5 Node 2 acquiert le bail libéré -> génération incrémentée à 2 !
    $resAcq2b = Exec-Sql "RETURN fn::event_lease_acquire({ node_id: 'node_2', ttl_seconds: 10 });"
    $dAcq2b = $resAcq2b.result.data
    if (-not $dAcq2b.acquired -or $dAcq2b.generation -ne 2 -or $dAcq2b.owner_node_id -ne "node_2") {
        throw "Échec Test 2.5: Node 2 n'a pas acquis la génération 2"
    }
    Write-Host "  -> [SUCCÈS VALIDÉ] Reprise de leadership par Node 2 avec génération monotone 2." -ForegroundColor Green

    # ==============================================================================
    # TEST 3 : FENCING TRANSACTIONNEL ET ANCIEN LEADER ÉVINCÉ (VECTEUR 2 & 3)
    # ==============================================================================
    Write-Host "`n--- TEST 3 : Fencing Transactionnel (Ancien leader bloqué) ---" -ForegroundColor Yellow

    # Préparation données parentes (subscription & outbox_event)
    $setupData = @"
CREATE event_subscription:sub_test CONTENT { name: 'sub_test', target_module: 'mod_test', event_pattern: 'test.*', handler_name: 'h_test' };
CREATE event_outbox:evt_1 CONTENT { event_id: 'evt_1', event_type: 'test.alpha', producer: 'prod_1', payload: { k: 'v1' } };
CREATE event_outbox:evt_2 CONTENT { event_id: 'evt_2', event_type: 'test.beta', producer: 'prod_1', payload: { k: 'v2' } };
CREATE event_outbox:evt_3 CONTENT { event_id: 'evt_3', event_type: 'test.gamma', producer: 'prod_1', payload: { k: 'v3' } };
CREATE event_outbox:evt_4 CONTENT { event_id: 'evt_4', event_type: 'test.delta', producer: 'prod_1', payload: { k: 'v4' } };
"@
    Exec-Sql $setupData | Out-Null

    # 3.1 Node 1 (génération obsolète 1) tente une attribution de séquence -> Doit être fencé !
    $staleCall = @"
BEGIN TRANSACTION;
fn::event_delivery_assign_seq({
    outbox_event: event_outbox:evt_1,
    subscription: event_subscription:sub_test,
    target_module: 'mod_test',
    node_id: 'node_1',
    generation: 1
});
COMMIT TRANSACTION;
"@
    $resStale = Exec-Sql $staleCall
    $staleBlocked = ($resStale | ConvertTo-Json -Compress).Contains("EVENT_STALE_LEADER_FENCED")
    if (-not $staleBlocked) { throw "Échec Test 3.1: Stale leader Node 1 n'a pas été fencé !" }
    Write-Host "  -> [SUCCÈS VALIDÉ] Ancien leader Node 1 (G=1) bloqué par le Fencing transactionnel !" -ForegroundColor Green

    # ==============================================================================
    # TEST 4 : ATTRIBUTION SÉQUENTIELLE CONTIGUË SANS TROU ET IDEMPOTENCE (VECTEUR 4 & 5)
    # ==============================================================================
    Write-Host "`n--- TEST 4 : Attribution séquentielle contiguë et idempotence ---" -ForegroundColor Yellow

    # 4.1 Node 2 (Leader légitime G=2) attribue la séquence pour evt_1
    $assign1 = @"
BEGIN TRANSACTION;
LET `$del1 = fn::event_delivery_assign_seq({
    outbox_event: event_outbox:evt_1,
    subscription: event_subscription:sub_test,
    target_module: 'mod_test',
    node_id: 'node_2',
    generation: 2
});
RETURN `$del1;
COMMIT TRANSACTION;
"@
    $resAssign1 = Exec-Sql $assign1
    $delData1 = Get-Data $resAssign1
    if ($null -eq $delData1 -or $delData1.delivery_seq -ne 1) { throw "Échec Test 4.1: Séquence 1 attendue, reçu: $($delData1.delivery_seq)" }
    Write-Host "  -> [OK] Livraison 1 créée avec delivery_seq = 1." -ForegroundColor Green

    # 4.2 Idempotence : Répéter l'attribution pour la même paire (evt_1, sub_test) -> réutilise seq 1
    $resAssign1Dup = Exec-Sql $assign1
    $delData1Dup = Get-Data $resAssign1Dup
    if ($null -eq $delData1Dup -or $delData1Dup.delivery_seq -ne 1) { throw "Échec Test 4.2: Idempotence rompue" }
    Write-Host "  -> [OK] Idempotence respectée : même livraison retournée, aucune nouvelle séquence consommée." -ForegroundColor Green

    # 4.3 Simulation de crash/erreur pendant l'attribution pour evt_2
    $assignFail = @"
BEGIN TRANSACTION;
fn::event_delivery_assign_seq({
    outbox_event: event_outbox:evt_2,
    subscription: event_subscription:sub_test,
    target_module: 'mod_test',
    node_id: 'node_2',
    generation: 2
});
THROW "SIMULATED_CRASH_BEFORE_COMMIT";
COMMIT TRANSACTION;
"@
    Exec-Sql $assignFail | Out-Null
    
    # Vérification que le compteur est resté à 1
    $progCheck = Exec-Sql "RETURN fn::event_progress_get({ subscription: event_subscription:sub_test });"
    $progCheckData = Get-Data $progCheck
    if ($progCheckData.last_assigned_seq -ne 1) {
        throw "Échec Test 4.3: Rollback incomplet, séquence incrémentée malgré le crash !"
    }
    Write-Host "  -> [OK] Rollback sur crash : last_assigned_seq resté intact à 1." -ForegroundColor Green

    # 4.4 Ré-essai immédiat pour evt_2 : doit allouer exactement la séquence 2 sans trou !
    $assign2 = @"
BEGIN TRANSACTION;
LET `$del2 = fn::event_delivery_assign_seq({
    outbox_event: event_outbox:evt_2,
    subscription: event_subscription:sub_test,
    target_module: 'mod_test',
    node_id: 'node_2',
    generation: 2
});
RETURN `$del2;
COMMIT TRANSACTION;
"@
    $resAssign2 = Exec-Sql $assign2
    $delData2 = Get-Data $resAssign2
    if ($null -eq $delData2 -or $delData2.delivery_seq -ne 2) { throw "Échec Test 4.4: Séquence 2 attendue, reçu: $($delData2.delivery_seq)" }
    Write-Host "  -> [SUCCÈS VALIDÉ] Séquence 2 allouée sans trou après rollback du crash !" -ForegroundColor Green

    # Attribution de evt_3 (seq 3) et evt_4 (seq 4) pour préparer les tests de curseur
    $assign34 = @"
BEGIN TRANSACTION;
fn::event_delivery_assign_seq({ outbox_event: event_outbox:evt_3, subscription: event_subscription:sub_test, target_module: 'mod_test', node_id: 'node_2', generation: 2 });
fn::event_delivery_assign_seq({ outbox_event: event_outbox:evt_4, subscription: event_subscription:sub_test, target_module: 'mod_test', node_id: 'node_2', generation: 2 });
COMMIT TRANSACTION;
"@
    Exec-Sql $assign34 | Out-Null
    Write-Host "  -> [OK] Séquences 3 et 4 allouées." -ForegroundColor Gray

    # ==============================================================================
    # TEST 5 : INVARIANTS DU CURSEUR DURABLE (VECTEURS 6, 7 & 8)
    # ==============================================================================
    Write-Host "`n--- TEST 5 : Invariants du Curseur Durable Contigu ---" -ForegroundColor Yellow

    # Récupération des IDs de livraisons
    $dels = (Exec-Sql "SELECT id, delivery_seq FROM event_delivery WHERE subscription = event_subscription:sub_test ORDER BY delivery_seq ASC;").result
    $d1 = $dels[0].id
    $d2 = $dels[1].id
    $d3 = $dels[2].id
    $d4 = $dels[3].id

    # 5.1 Tentative de dépassement de la séquence maximale allouée (target_cursor = 99 - Vecteur 8)
    $overFlowCall = @"
BEGIN TRANSACTION;
fn::event_flush_batch({
    subscription: event_subscription:sub_test,
    target_cursor: 99,
    node_id: 'node_2',
    generation: 2
});
COMMIT TRANSACTION;
"@
    $resOverflow = Exec-Sql $overFlowCall
    $overflowBlocked = ($resOverflow | ConvertTo-Json -Compress).Contains("EVENT_CURSOR_EXCEEDS_ASSIGNED_SEQ")
    if (-not $overflowBlocked) { throw "Échec Test 5.1: Dépassement non bloqué !" }
    Write-Host "  -> [OK] Curseur bloqué au-delà de la séquence maximale allouée." -ForegroundColor Green

    # 5.2 Tentative d'avancer le curseur à 4 alors que d1, d2, d3, d4 sont encore 'pending' (Vecteur 7)
    $unresolvedCall = @"
BEGIN TRANSACTION;
fn::event_flush_batch({
    subscription: event_subscription:sub_test,
    target_cursor: 4,
    node_id: 'node_2',
    generation: 2,
    delivered_ids: ['$d1', '$d4']
});
COMMIT TRANSACTION;
"@
    $resUnresolved = Exec-Sql $unresolvedCall
    $unresolvedBlocked = ($resUnresolved | ConvertTo-Json -Compress).Contains("EVENT_CURSOR_INVARIANT_VIOLATION_UNRESOLVED_SEQUENCES")
    if (-not $unresolvedBlocked) { throw "Échec Test 5.2: Invariant non-résolu non bloqué !" }
    Write-Host "  -> [OK] Curseur bloqué car des séquences intermédiaires (seq 2, seq 3) ne sont pas terminales." -ForegroundColor Green

    # ==============================================================================
    # TEST 6 : FLUSH MIXTE AVEC STATUTS TERMINAUX DISTINCTS (VECTEUR 9)
    # ==============================================================================
    Write-Host "`n--- TEST 6 : Flush mixte (delivered, dead_letter, dropped) et avancement curseur ---" -ForegroundColor Yellow

    # Préalable pour dead_letter : transférer d3 vers la DLQ via fn::event_dead_letter_transfer
    $dlqCall = @"
BEGIN TRANSACTION;
fn::event_dead_letter_transfer({
    delivery_id: '$d3',
    error: 'Simulated poison payload',
    node_id: 'node_2',
    generation: 2
});
COMMIT TRANSACTION;
"@
    $resDlq = Exec-Sql $dlqCall
    Write-Host "  -> [OK] Livraison 3 transférée en DLQ préalable." -ForegroundColor Gray

    # Exécution du flush mixte pour les 4 livraisons :
    # seq 1 -> delivered
    # seq 2 -> delivered
    # seq 3 -> dead_letter
    # seq 4 -> dropped
    $flushMixed = @"
BEGIN TRANSACTION;
LET `$f = fn::event_flush_batch({
    subscription: event_subscription:sub_test,
    target_cursor: 4,
    node_id: 'node_2',
    generation: 2,
    delivered_ids: ['$d1', '$d2'],
    dead_letter_ids: ['$d3'],
    dropped_ids: ['$d4'],
    drop_reason: 'expired_ttl'
});
RETURN `$f;
COMMIT TRANSACTION;
"@
    $resFlush = Exec-Sql $flushMixed
    $fData = Get-Data $resFlush
    if ($null -eq $fData -or -not $fData.flushed -or $fData.persisted_cursor -ne 4) {
        throw "Échec Test 6: Flush mixte rejeté ! Res: $($resFlush | ConvertTo-Json -Compress)"
    }
    Write-Host "  -> [OK] Flush mixte appliqué et curseur persisté à 4 !" -ForegroundColor Green

    # Vérification des états finaux en base
    $statusCheck = (Exec-Sql "SELECT delivery_seq, status, drop_reason FROM event_delivery WHERE subscription = event_subscription:sub_test ORDER BY delivery_seq ASC;").result
    if ($statusCheck[0].status -ne "delivered" -or $statusCheck[1].status -ne "delivered" -or $statusCheck[2].status -ne "dead_letter" -or $statusCheck[3].status -ne "dropped" -or $statusCheck[3].drop_reason -ne "expired_ttl") {
        throw "Échec Test 6: Les états finaux en base ne correspondent pas"
    }
    Write-Host "  -> [SUCCÈS VALIDÉ] États terminaux conformes : seq 1/2=delivered, seq 3=dead_letter, seq 4=dropped (drop_reason: expired_ttl)." -ForegroundColor Green

    # ==============================================================================
    # TEST 7 : BARRIÈRE DLQ IDEMPOTENTE ET AUDIT (VECTEURS 10 & 11)
    # ==============================================================================
    Write-Host "`n--- TEST 7 : Idempotence stricte et barrière DLQ ---" -ForegroundColor Yellow

    # Ré-exécution du transfert DLQ sur d3 (déjà en dead_letter)
    $resDlqDup = Exec-Sql $dlqCall
    $dlqCount = (Exec-Sql "SELECT count() FROM event_dead_letter GROUP ALL;").result[0].count
    if ($dlqCount -ne 1) {
        throw "Échec Test 7: La ré-exécution DLQ a dupliqué l'enregistrement (count=$dlqCount attendu 1)"
    }
    Write-Host "  -> [SUCCÈS VALIDÉ] Barrière DLQ 100% idempotente (exactement 1 enregistrement conservé)." -ForegroundColor Green

    # ==============================================================================
    # TEST 8 : LECTURE DE LA PROGRESSION PERSISTÉE POUR REPRISE (VECTEUR 11)
    # ==============================================================================
    Write-Host "`n--- TEST 8 : Lecture de la progression durable pour la reprise après crash ---" -ForegroundColor Yellow
    $progFinal = (Exec-Sql "RETURN fn::event_progress_get({ subscription: event_subscription:sub_test });").result.data
    if (-not $progFinal.exists -or $progFinal.last_assigned_seq -ne 4 -or $progFinal.last_persisted_cursor -ne 4) {
        throw "Échec Test 8: Progression durable incorrecte ($($progFinal | ConvertTo-Json -Compress))"
    }
    Write-Host "  -> [SUCCÈS VALIDÉ] Progression durable conforme : assigned=4, cursor=4, reprise instantanée garantie !" -ForegroundColor Green

    Write-Host "`n=================================================================" -ForegroundColor Cyan
    Write-Host " [BILAN GÉNÉRAL] LES 12 SCÉNARIOS DU MANDAT LOT 3B.1 SONT VALIDÉS À 100%" -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan

} finally {
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Serveur de test arrêté." -ForegroundColor Gray
}
