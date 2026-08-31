-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::alert_override_upsert                                   │
-- │  Pose ou met à jour une surcharge de règle d'alerte (snooze, pause).    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::alert_override_upsert(
    $rule_name: string,
    $enabled: option<bool>,
    $snooze_until: option<datetime>,
    $throttle_secs: option<int>,
    $note: string,
    $set_by: string,
    $expires_at: option<datetime>
) {
    LET $o_id = type::record('scheduler_alert_override', $rule_name);

    RETURN (
        UPSERT $o_id SET
            enabled       = $enabled,
            snooze_until  = $snooze_until,
            throttle_secs = $throttle_secs,
            note          = $note,
            set_by        = $set_by,
            set_at        = time::now(),
            expires_at    = $expires_at
    )[0];
};
