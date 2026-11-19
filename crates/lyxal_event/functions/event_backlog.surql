-- ============================================================================
-- Function   : fn::event_backlog
-- Module     : lyxal_event
-- Description: Livraisons non soldées par hôte, avec l'état du chef des événements de chaque
--              hôte : sert la sonde de santé (un hôte arrêté laisse ses livraisons en attente).
-- Contrat    : Retourne fn::result_ok([{ host, pending, waiting, oldest, leader_alive, leader_node }])
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_backlog(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            older_than: { pipeline: [{ rule: "duration", options: { min_value: 1s, max_value: 30d } }], default: 5m },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;

    -- Échéances à l'heure de la base, jamais à l'horloge d'un nœud
    LET $now = time::now();
    LET $limit = $now - $p.older_than;
    LET $hosts = (
        SELECT
            host,
            count() AS pending,
            count(created_at < $limit) AS waiting,
            time::min(created_at) AS oldest
        FROM event_delivery
        WHERE ["pending", "processing", "failed"] CONTAINS status
        GROUP BY host
        ORDER BY host ASC
    );

    RETURN fn::result_ok(array::map($hosts, |$row| {
        LET $lease = (SELECT owner_node_id, is_released, expires_at FROM ONLY type::record("event_stream_lease", $row.host));
        LET $alive = $lease != NONE AND $lease.is_released == false AND $lease.expires_at >= $now;
        RETURN {
            host: $row.host,
            pending: $row.pending,
            waiting: $row.waiting,
            oldest: $row.oldest,
            leader_alive: $alive,
            leader_node: IF $alive { $lease.owner_node_id } ELSE { NONE }
        };
    }));
} COMMENT "Livraisons non soldées (pending, processing, failed) par hôte ({ older_than : 5 min par défaut, de 1 s à 30 j }), triées par hôte : { host, pending : nombre, waiting : nombre créées avant older_than, oldest : création de la plus ancienne, leader_alive : bail du chef de l'hôte vivant à l'heure de la base, leader_node : son nœud }. Un hôte sans livraison non soldée n'apparaît pas."
PERMISSIONS FULL;
