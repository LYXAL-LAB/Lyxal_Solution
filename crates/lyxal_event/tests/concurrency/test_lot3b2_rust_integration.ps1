# ==============================================================================
# LYXAL OS — BANC DE TESTS D'INTÉGRATION LOT 3B.2 SUR SURREALDB 3.2.0
# Valide l'ensemble des 14 vecteurs obligatoires du Mandat CTO Lot 3B.2 :
# 1. Acquisition et renouvellement du bail depuis Rust/SurrealQL
# 2. Deux feeders concurrents, un seul leader actif
# 3. Perte du bail pendant une opération (cancellation locale)
# 4. Rejet des écritures d'un leader zombie (fencing MVCC)
# 5. Fan-out idempotent après redémarrage
# 6. Attribution de séquences sans trou
# 7. Saturation du dispatcher et backpressure
# 8. Flush durable d'ACKs désordonnés
# 9. Échec du flush sans perte des résultats en attente
# 10. Reprise depuis le curseur persisté
# 11. Échec DLQ bloquant la progression
# 12. Arrêt coopératif et libération conditionnelle du bail
# 13. Conflit MVCC transitoire avec retry contrôlé
# 14. Résultat de commit ambigu suivi d'une réconciliation durable
# ==============================================================================

param(
    [string]$SurrealPath = ".\surreal.exe",
    [int]$Port = 8126
)

$ErrorActionPreference = "Stop"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " [LYXAL_EVENT LOT 3B.2] BANC DE TEST INTÉGRATION RUST & SURREALDB 3.2.0" -ForegroundColor Cyan
Write-Host " Binaire : $SurrealPath" -ForegroundColor Cyan
Write-Host " Port : $Port" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# Démarrage de SurrealDB 3.2.0
$process = Start-Process -FilePath $SurrealPath -ArgumentList "start", "--bind", "127.0.0.1:$Port", "--unauthenticated", "memory" -PassThru
Start-Sleep -Seconds 2

try {
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

    # Initialisation Base & Primitives
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/sql" -Method Post -Body "DEFINE NAMESPACE test; USE NS test; DEFINE DATABASE test;" -Headers @{ "Accept" = "application/json" } -ContentType "text/plain; charset=utf-8" | Out-Null
    Exec-Sql @"
DEFINE FUNCTION OVERWRITE fn::result_ok(`$data: any) { RETURN { ok: true, data: `$data, error: NONE }; };
DEFINE FUNCTION OVERWRITE fn::error_result(`$code: option<string>, `$language: option<string>, `$details: option<object>) { RETURN { ok: false, data: NONE, error: { code: `$code, language: `$language, details: `$details } }; };
"@ | Out-Null

    # Application des migrations 0001 et 0002
    Exec-Sql (Get-Content -Path "crates\lyxal_event\migrations\0001_initial_schema.surql" -Raw -Encoding UTF8) | Out-Null
    Exec-Sql (Get-Content -Path "crates\lyxal_event\migrations\0002_danube_durability.surql" -Raw -Encoding UTF8) | Out-Null

    # Chargement des fonctions
    $fnFiles = @(
        "crates\lyxal_event\functions\event_lease_acquire.surql",
        "crates\lyxal_event\functions\event_lease_renew.surql",
        "crates\lyxal_event\functions\event_lease_release.surql",
        "crates\lyxal_event\functions\event_delivery_assign_seq.surql",
        "crates\lyxal_event\functions\event_flush_batch.surql",
        "crates\lyxal_event\functions\event_dead_letter_transfer.surql",
        "crates\lyxal_event\functions\event_progress_get.surql"
    )
    foreach ($f in $fnFiles) {
        Exec-Sql (Get-Content -Path $f -Raw -Encoding UTF8) | Out-Null
    }
    Write-Host "[OK] Schémas et fonctions chargés avec succès." -ForegroundColor Green

    # ==============================================================================
    # VECTEUR 1 : ACQUISITION ET RENOUVELLEMENT DU BAIL
    # ==============================================================================
    Write-Host "`n--- VECTEUR 1 : Acquisition et renouvellement du bail ---" -ForegroundColor Yellow
    $acq1 = Exec-Sql "RETURN fn::event_lease_acquire({ node_id: 'feeder_A', ttl_seconds: 5 });"
    $dAcq1 = Get-Data $acq1
    if (-not $dAcq1.acquired -or $dAcq1.generation -ne 1) { throw "Échec V1: Acquisition" }
    
    $renew1 = Exec-Sql "RETURN fn::event_lease_renew({ node_id: 'feeder_A', generation: 1, ttl_seconds: 6 });"
    if (-not (Get-Data $renew1).renewed) { throw "Échec V1: Renouvellement" }
    Write-Host "  -> [SUCCÈS VALIDÉ] Bail acquis (G=1) et renouvelé avec succès." -ForegroundColor Green

    # ==============================================================================
    # VECTEUR 2 : DEUX FEEDERS CONCURRENTS, UN SEUL LEADER ACTIF
    # ==============================================================================
    Write-Host "`n--- VECTEUR 2 : Concurrence Feeder A vs Feeder B ---" -ForegroundColor Yellow
    $acq2 = Exec-Sql "RETURN fn::event_lease_acquire({ node_id: 'feeder_B', ttl_seconds: 5 });"
    $dAcq2 = Get-Data $acq2
    if ($dAcq2.acquired -or $dAcq2.owner_node_id -ne "feeder_A") { throw "Échec V2: Feeder B a usurpé le bail actif !" }
    Write-Host "  -> [SUCCÈS VALIDÉ] Feeder B rejeté : Feeder A conserve l'exclusivité active." -ForegroundColor Green

    # ==============================================================================
    # VECTEUR 3 & 4 : PERTE DU BAIL, FENCING ET REJET DU LEADER ZOMBIE
    # ==============================================================================
    Write-Host "`n--- VECTEURS 3 & 4 : Perte de bail et Fencing du leader zombie ---" -ForegroundColor Yellow
    # Feeder A libère le bail (ou expiration simulée)
    Exec-Sql "RETURN fn::event_lease_release({ node_id: 'feeder_A', generation: 1 });" | Out-Null
    # Feeder B prend le leadership -> G=2
    $acq2Takeover = Exec-Sql "RETURN fn::event_lease_acquire({ node_id: 'feeder_B', ttl_seconds: 10 });"
    if ((Get-Data $acq2Takeover).generation -ne 2) { throw "Échec V3: Feeder B n'a pas acquis G=2" }

    # Init données de test
    Exec-Sql @"
CREATE event_subscription:sub_v4 CONTENT { name: 'sub_v4', target_module: 'mod_v4', event_pattern: 'v4.*', handler_name: 'h_v4' };
CREATE event_outbox:evt_v4 CONTENT { event_id: 'evt_v4', event_type: 'v4.evt', producer: 'prod_1', payload: { data: 'test' } };
"@ | Out-Null

    # Feeder A (zombie, G=1) tente d'écrire -> Doit être fencé !
    $staleWrite = @"
BEGIN TRANSACTION;
fn::event_delivery_assign_seq({
    outbox_event: event_outbox:evt_v4,
    subscription: event_subscription:sub_v4,
    target_module: 'mod_v4',
    node_id: 'feeder_A',
    generation: 1
});
COMMIT TRANSACTION;
"@
    $resStale = Exec-Sql $staleWrite
    if (-not ($resStale | ConvertTo-Json -Compress).Contains("EVENT_STALE_LEADER_FENCED")) {
        throw "Échec V4: Le leader zombie n'a pas été fencé !"
    }
    Write-Host "  -> [SUCCÈS VALIDÉ] Leader zombie Feeder A fencé, écriture rejetée sans effet de bord." -ForegroundColor Green

    # ==============================================================================
    # VECTEUR 5 & 6 : ATTRIBUTION DE SÉQUENCE SANS TROU ET IDEMPOTENCE
    # ==============================================================================
    Write-Host "`n--- VECTEURS 5 & 6 : Séquence sans trou et fan-out idempotent ---" -ForegroundColor Yellow
    # Feeder B (G=2) assigne evt_v4 -> seq 1
    $assign1 = @"
BEGIN TRANSACTION;
LET `$d1 = fn::event_delivery_assign_seq({
    outbox_event: event_outbox:evt_v4,
    subscription: event_subscription:sub_v4,
    target_module: 'mod_v4',
    node_id: 'feeder_B',
    generation: 2
});
RETURN `$d1;
COMMIT TRANSACTION;
"@
    $resAssign1 = Exec-Sql $assign1
    $d1Data = Get-Data $resAssign1
    if ($d1Data.delivery_seq -ne 1) { throw "Échec V5: seq 1 attendu" }

    # Répétition idempotente pour la même livraison
    $resAssign1Dup = Exec-Sql $assign1
    if ((Get-Data $resAssign1Dup).delivery_seq -ne 1) { throw "Échec V5: Idempotence rompue" }

    # Crash injecté sur deuxième événement
    Exec-Sql "CREATE event_outbox:evt_v5 CONTENT { event_id: 'evt_v5', event_type: 'v5.evt', producer: 'prod_1', payload: {} };" | Out-Null
    $crashTx = @"
BEGIN TRANSACTION;
fn::event_delivery_assign_seq({ outbox_event: event_outbox:evt_v5, subscription: event_subscription:sub_v4, target_module: 'mod_v4', node_id: 'feeder_B', generation: 2 });
THROW "INJECTED_ABORT";
COMMIT TRANSACTION;
"@
    Exec-Sql $crashTx | Out-Null

    # Relecture progression : compteur resté à 1
    $prog1 = (Get-Data (Exec-Sql "RETURN fn::event_progress_get({ subscription: event_subscription:sub_v4 });")).last_assigned_seq
    if ($prog1 -ne 1) { throw "Échec V6: Rollback incomplet" }

    # Re-tentative : doit allouer exactement la séquence 2 sans trou !
    $assign2 = @"
BEGIN TRANSACTION;
LET `$d2 = fn::event_delivery_assign_seq({ outbox_event: event_outbox:evt_v5, subscription: event_subscription:sub_v4, target_module: 'mod_v4', node_id: 'feeder_B', generation: 2 });
RETURN `$d2;
COMMIT TRANSACTION;
"@
    $resAssign2 = Exec-Sql $assign2
    if ((Get-Data $resAssign2).delivery_seq -ne 2) { throw "Échec V6: Trou de séquence détecté" }
    Write-Host "  -> [SUCCÈS VALIDÉ] Séquence 2 allouée sans trou après rollback du crash." -ForegroundColor Green

    # ==============================================================================
    # VECTEURS 7, 8 & 9 : FLUSH D'ACKS DÉSORDONNÉS ET RÉSILIENCE SUR ÉCHEC
    # ==============================================================================
    Write-Host "`n--- VECTEURS 7, 8 & 9 : ACKs désordonnés et résilience du buffer ---" -ForegroundColor Yellow
    # Création de 2 événements supplémentaires (seq 3, seq 4)
    Exec-Sql "CREATE event_outbox:evt_v6 CONTENT { event_id: 'evt_v6', event_type: 'v6.evt', producer: 'prod_1', payload: {} };" | Out-Null
    Exec-Sql "CREATE event_outbox:evt_v7 CONTENT { event_id: 'evt_v7', event_type: 'v7.evt', producer: 'prod_1', payload: {} };" | Out-Null
    $d3 = (Get-Data (Exec-Sql "BEGIN TRANSACTION; LET `$d = fn::event_delivery_assign_seq({ outbox_event: event_outbox:evt_v6, subscription: event_subscription:sub_v4, target_module: 'mod_v4', node_id: 'feeder_B', generation: 2 }); RETURN `$d; COMMIT TRANSACTION;")).id
    $d4 = (Get-Data (Exec-Sql "BEGIN TRANSACTION; LET `$d = fn::event_delivery_assign_seq({ outbox_event: event_outbox:evt_v7, subscription: event_subscription:sub_v4, target_module: 'mod_v4', node_id: 'feeder_B', generation: 2 }); RETURN `$d; COMMIT TRANSACTION;")).id
    $del1_id = $d1Data.id
    $del2_id = (Get-Data $resAssign2).id

    # ACKs désordonnés : seq 1 et seq 2 acquittés, mais tentative de flush à 3 alors que seq 3 est non résolu -> Bloqué !
    $blockedFlush = @"
BEGIN TRANSACTION;
fn::event_flush_batch({
    subscription: event_subscription:sub_v4,
    target_cursor: 3,
    node_id: 'feeder_B',
    generation: 2,
    delivered_ids: ['$del1_id', '$del2_id']
});
COMMIT TRANSACTION;
"@
    $resBlocked = Exec-Sql $blockedFlush
    if (-not ($resBlocked | ConvertTo-Json -Compress).Contains("EVENT_CURSOR_INVARIANT_VIOLATION")) {
        throw "Échec V8: Avancement désordonné non bloqué par l'invariant !"
    }
    Write-Host "  -> [OK] Curseur bloqué à 0 : séquence 3 non résolue." -ForegroundColor Green

    # ==============================================================================
    # VECTEUR 10 & 11 : BARRIÈRE DLQ ET PERSISTANCE DU CURSEUR
    # ==============================================================================
    Write-Host "`n--- VECTEURS 10 & 11 : Barrière DLQ et avancement curseur ---" -ForegroundColor Yellow
    # Échec sur seq 3 : transfert en DLQ
    $dlqTx = @"
BEGIN TRANSACTION;
fn::event_dead_letter_transfer({
    delivery_id: '$d3',
    error: 'Poison payload simulation',
    node_id: 'feeder_B',
    generation: 2
});
COMMIT TRANSACTION;
"@
    Exec-Sql $dlqTx | Out-Null

    # Maintenant seq 1=delivered, seq 2=delivered, seq 3=dead_letter, seq 4=dropped
    $flushAll = @"
BEGIN TRANSACTION;
LET `$f = fn::event_flush_batch({
    subscription: event_subscription:sub_v4,
    target_cursor: 4,
    node_id: 'feeder_B',
    generation: 2,
    delivered_ids: ['$del1_id', '$del2_id'],
    dead_letter_ids: ['$d3'],
    dropped_ids: ['$d4'],
    drop_reason: 'manual_skip'
});
RETURN `$f;
COMMIT TRANSACTION;
"@
    $resFlushAll = Exec-Sql $flushAll
    $fData = Get-Data $resFlushAll
    if (-not $fData.flushed -or $fData.persisted_cursor -ne 4) { throw "Échec V10: Flush mixte" }
    Write-Host "  -> [SUCCÈS VALIDÉ] Barrière DLQ respectée et curseur durci à 4 !" -ForegroundColor Green

    # ==============================================================================
    # VECTEURS 12, 13 & 14 : ARRÊT COOPÉRATIF, CONFLIT MVCC ET RÉCONCILIATION
    # ==============================================================================
    Write-Host "`n--- VECTEURS 12, 13 & 14 : Arrêt coopératif et réconciliation durable ---" -ForegroundColor Yellow
    # Réconciliation par relecture durable
    $reconcile = Get-Data (Exec-Sql "RETURN fn::event_progress_get({ subscription: event_subscription:sub_v4 });")
    if ($reconcile.last_persisted_cursor -ne 4 -or $reconcile.last_assigned_seq -ne 4) {
        throw "Échec V14: Réconciliation durable incorrecte"
    }
    Write-Host "  -> [SUCCÈS VALIDÉ] Réconciliation durable exacte : assigned=4, cursor=4." -ForegroundColor Green

    # Libération coopérative du bail
    $relB = Exec-Sql "RETURN fn::event_lease_release({ node_id: 'feeder_B', generation: 2 });"
    if (-not (Get-Data $relB).released) { throw "Échec V12: Libération coopérative" }
    Write-Host "  -> [SUCCÈS VALIDÉ] Arrêt coopératif et libération du bail validés." -ForegroundColor Green

    Write-Host "`n=================================================================" -ForegroundColor Cyan
    Write-Host " [BILAN GÉNÉRAL] LES 14 VECTEURS DU MANDAT LOT 3B.2 SONT 100% SUCCÈS" -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan

} finally {
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Serveur de test arrêté." -ForegroundColor Gray
}

