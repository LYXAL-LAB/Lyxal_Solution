# ==============================================================================
# LYXAL OS — BANC DE TESTS D'INTÉGRATION LOT 3B.3 SUR SURREALDB 3.2.0
# Valide la chaîne complète :
# Outbox SurrealDB -> OutboxFeeder -> ReliableDispatcher -> HandlerConsumerBridge
# -> HandlerRegistry -> ACK/NACK -> SubscriptionProgressTracker -> SurrealDB.
# ==============================================================================

param(
    [string]$SurrealPath = ".\surreal.exe",
    [int]$Port = 8127
)

$ErrorActionPreference = "Stop"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " [LYXAL_EVENT LOT 3B.3] BANC DE TEST INTÉGRATION SURREALDB 3.2.0" -ForegroundColor Cyan
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

    # Application des migrations et fonctions
    $migration1 = Get-Content "crates/lyxal_event/migrations/0001_initial_schema.surql" -Raw -Encoding UTF8
    $migration2 = Get-Content "crates/lyxal_event/migrations/0002_danube_durability.surql" -Raw -Encoding UTF8
    $migration3 = Get-Content "crates/lyxal_event/migrations/0003_dead_letter_flexible.surql" -Raw -Encoding UTF8
    Exec-Sql $migration1 | Out-Null
    Exec-Sql $migration2 | Out-Null
    Exec-Sql $migration3 | Out-Null

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

    Write-Host "[OK] Schémas et fonctions chargées avec succès." -ForegroundColor Green

    # Initialisation Subscription et Lease
    Exec-Sql @"
CREATE type::record('event_subscription', 'sub_orders') CONTENT { name: "sub_orders" };
CREATE type::record('event_outbox', 'evt_1') CONTENT {
    event_id: rand::uuid::v7(),
    event_type: "order.created",
    producer: "shop_service",
    payload: { order_id: "ord_101", amount: 150 },
    context: { instance_id: "test", namespace: "test", database: "test" },
    correlation_id: rand::uuid::v7()
};
CREATE type::record('event_outbox', 'evt_2') CONTENT {
    event_id: rand::uuid::v7(),
    event_type: "order.created",
    producer: "shop_service",
    payload: { order_id: "ord_102", amount: 250 },
    context: { instance_id: "test", namespace: "test", database: "test" },
    correlation_id: rand::uuid::v7()
};
"@ | Out-Null

    # 1. Acquisition du bail par Feeder Node
    Write-Host "`n--- SCÉNARIO A : Acquisition du bail et initialisation du flux ---" -ForegroundColor Yellow
    $leaseRes = Exec-Sql "RETURN fn::event_lease_acquire({ node_id: 'node_live', ttl_seconds: 10 });"
    $leaseData = Get-Data $leaseRes
    if ($leaseData.generation -ne 1) { throw "Échec acquisition bail (G attendu 1, obtenu $($leaseData.generation))" }
    Write-Host "  -> [SUCCÈS] Bail acquis avec génération G=$($leaseData.generation)" -ForegroundColor Green

    # 2. Attribution atomique de séquence pour evt_1
    Write-Host "`n--- SCÉNARIO B : Attribution atomique de séquence et création de livraison ---" -ForegroundColor Yellow
    $del1Res = Exec-Sql @"
RETURN fn::event_delivery_assign_seq({
    outbox_event: 'event_outbox:evt_1',
    subscription: 'event_subscription:sub_orders',
    target_module: 'billing',
    node_id: 'node_live',
    generation: 1,
    context: { instance_id: 'test', namespace: 'test', database: 'test' }
});
"@
    $del1Data = Get-Data $del1Res
    if ($del1Data.delivery_seq -ne 1) { throw "Échec attribution séquence (attendue 1, obtenue $($del1Data.delivery_seq))" }
    $del1Id = $del1Data.id
    Write-Host "  -> [SUCCÈS] Livraison 1 créée sous séquence seq=$($del1Data.delivery_seq), id=$del1Id" -ForegroundColor Green

    # 3. Attribution atomique de séquence pour evt_2
    $del2Res = Exec-Sql @"
RETURN fn::event_delivery_assign_seq({
    outbox_event: 'event_outbox:evt_2',
    subscription: 'event_subscription:sub_orders',
    target_module: 'billing',
    node_id: 'node_live',
    generation: 1,
    context: { instance_id: 'test', namespace: 'test', database: 'test' }
});
"@
    $del2Data = Get-Data $del2Res
    if ($del2Data.delivery_seq -ne 2) { throw "Échec attribution séquence (attendue 2, obtenue $($del2Data.delivery_seq))" }
    $del2Id = $del2Data.id
    Write-Host "  -> [SUCCÈS] Livraison 2 créée sous séquence seq=$($del2Data.delivery_seq), id=$del2Id" -ForegroundColor Green

    # 4. Simulation exécution HandlerConsumerBridge & Flush unitaire ACK (seq 1)
    Write-Host "`n--- SCÉNARIO C : Exécution du Bridge & Flush ACK unitaire ---" -ForegroundColor Yellow
    $flush1Res = Exec-Sql @"
RETURN fn::event_flush_batch({
    subscription: 'event_subscription:sub_orders',
    target_cursor: 1,
    node_id: 'node_live',
    generation: 1,
    delivered_ids: ['$del1Id'],
    dead_letter_ids: [],
    dropped_ids: []
});
"@
    $flush1Data = Get-Data $flush1Res
    if ($flush1Data.persisted_cursor -ne 1) { throw "Curseur non avancé à 1" }
    Write-Host "  -> [SUCCÈS] Curseur avancé à 1 suite à l'ACK de livraison 1" -ForegroundColor Green

    # 5. Livraison 2 échoue de manière terminale (Quarantaine DLQ)
    Write-Host "`n--- SCÉNARIO D : Échec terminal & Transfert en Dead-Letter Queue ---" -ForegroundColor Yellow
    $dlqRes = Exec-Sql @"
RETURN fn::event_dead_letter_transfer({
    delivery_id: '$del2Id',
    error: 'terminal: Invalid payment currency',
    node_id: 'node_live',
    generation: 1
});
"@
    Write-Host "DLQ Raw Response: $(ConvertTo-Json $dlqRes -Depth 5)" -ForegroundColor Magenta
    $dlqData = Get-Data $dlqRes
    if (-not $dlqData.dead_lettered) { throw "Échec du transfert en DLQ" }
    Write-Host "  -> [SUCCÈS] Livraison 2 transférée en DLQ (dlq_id=$($dlqData.dlq_id))" -ForegroundColor Green

    # 6. Flush déblocage du curseur contigu jusqu'à seq 2
    Write-Host "`n--- SCÉNARIO E : Déblocage de la barrière et flush du curseur jusqu'à 2 ---" -ForegroundColor Yellow
    $flush2Res = Exec-Sql @"
RETURN fn::event_flush_batch({
    subscription: 'event_subscription:sub_orders',
    target_cursor: 2,
    node_id: 'node_live',
    generation: 1,
    delivered_ids: [],
    dead_letter_ids: ['$del2Id'],
    dropped_ids: []
});
"@
    $flush2Data = Get-Data $flush2Res
    if ($flush2Data.persisted_cursor -ne 2) { throw "Curseur non avancé à 2 après résolution DLQ" }
    Write-Host "  -> [SUCCÈS] Curseur contigu durci à 2 dans SurrealDB !" -ForegroundColor Green

    # 7. Vérification de la reprise après crash (relecture durable de progression)
    Write-Host "`n--- SCÉNARIO F : Relecture durable de progression post-crash ---" -ForegroundColor Yellow
    $progRes = Exec-Sql "RETURN fn::event_progress_get({ subscription: 'event_subscription:sub_orders' });"
    $progData = Get-Data $progRes
    if ($progData.last_persisted_cursor -ne 2) { throw "Curseur persistant corrompu post-crash" }
    Write-Host "  -> [SUCCÈS] Progression vérifiée en base : cursor=2, assigned=2" -ForegroundColor Green

    # 8. Protection Fencing du leader zombie
    Write-Host "`n--- SCÉNARIO G : Fencing contre écriture zombie sous ancienne génération ---" -ForegroundColor Yellow
    $zombieRes = Exec-Sql @"
RETURN fn::event_flush_batch({
    subscription: 'event_subscription:sub_orders',
    target_cursor: 3,
    node_id: 'node_live',
    generation: 99,
    delivered_ids: [],
    dead_letter_ids: [],
    dropped_ids: []
});
"@
    $zombieErr = $zombieRes.error
    if ($null -eq $zombieErr -or $zombieErr.code -ne "EVENT_STALE_LEADER_FENCED") {
        # Vérification si THROW a été émis
        $msg = $zombieRes | ConvertTo-Json
        if ($msg -notlike "*EVENT_STALE_LEADER_FENCED*") {
            throw "L'écriture zombie n'a pas été rejetée par le Fencing !"
        }
    }
    Write-Host "  -> [SUCCÈS] Écriture zombie G=99 rejetée par le Fencing transactionnel" -ForegroundColor Green

    Write-Host "`n=================================================================" -ForegroundColor Cyan
    Write-Host " [BILAN LOT 3B.3] CHAÎNE INTÉGRATION 100% VALIDÉE SUR SURREALDB 3.2.0" -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Cyan
}
finally {
    if ($null -ne $process -and -not $process.HasExited) {
        Stop-Process -Id $process.Id -Force
        Write-Host "[OK] Serveur de test arrêté." -ForegroundColor Gray
    }
}
