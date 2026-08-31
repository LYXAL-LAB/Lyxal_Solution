-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::alert_record_delivery                                   │
-- │  Enregistre une tentative de livraison d'alerte.                        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::alert_record_delivery(
    $delivery_id: string,
    $rule_name: string,
    $channel_name: string,
    $job_key: string,
    $execution_id: option<string>,
    $state: string,
    $error: option<string>,
    $fired_at: datetime,
    $delivered_at: option<datetime>
) {
    LET $d_id = type::record('scheduler_alert_delivery', $delivery_id);
    LET $j_id = type::record('scheduler_job_definition', $job_key);
    LET $e_id = IF $execution_id != NONE THEN type::record('scheduler_execution', $execution_id) ELSE NONE END;

    RETURN (
        CREATE $d_id SET
            rule_name    = $rule_name,
            channel_name = $channel_name,
            job_key      = $j_id,
            execution_id = $e_id,
            state        = $state,
            error        = $error,
            fired_at     = $fired_at,
            delivered_at = $delivered_at
    )[0];
};
