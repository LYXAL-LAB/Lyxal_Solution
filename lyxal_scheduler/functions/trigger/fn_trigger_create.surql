-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::trigger_create                                          │
-- │  Crée un déclencheur (Cron, timezone, fenêtre, calendrier).             │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::trigger_create(
    $trigger_id: string,
    $job_key: string,
    $cron_expression: option<string>,
    $timezone: option<string>,
    $calendar_id: option<string>,
    $window: option<string>,
    $not_before: option<datetime>,
    $not_after: option<datetime>,
    $enabled: bool,
    $managed_by: string
) {
    LET $t_id = type::record('scheduler_trigger', $trigger_id);
    LET $j_id = type::record('scheduler_job_definition', $job_key);
    LET $c_id = IF $calendar_id != NONE THEN type::record('scheduler_calendar', $calendar_id) ELSE NONE END;

    RETURN (
        CREATE $t_id SET
            job_key         = $j_id,
            cron_expression = $cron_expression,
            timezone        = $timezone,
            calendar        = $c_id,
            window          = $window,
            not_before      = $not_before,
            not_after       = $not_after,
            enabled         = $enabled,
            managed_by      = $managed_by,
            created_at      = time::now(),
            updated_at      = time::now()
    )[0];
};
