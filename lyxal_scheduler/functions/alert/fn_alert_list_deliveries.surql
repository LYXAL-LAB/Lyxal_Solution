-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::alert_list_deliveries                                   │
-- │  Liste l'historique des livraisons d'alertes triées par date récente.   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::alert_list_deliveries(
    $job_key: option<string>,
    $limit: int
) {
    LET $j_id = IF $job_key != NONE THEN type::record('scheduler_job_definition', $job_key) ELSE NONE END;

    RETURN SELECT * FROM scheduler_alert_delivery
        WHERE $job_key == NONE OR job_key = $j_id
        ORDER BY fired_at DESC
        LIMIT $limit;
};
