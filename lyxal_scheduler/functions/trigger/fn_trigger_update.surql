-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::trigger_update                                          │
-- │  Met à jour un déclencheur API (refuse les déclencheurs DSL).          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::trigger_update(
    $trigger_id: string,
    $cron_expression: option<string>,
    $timezone: option<string>,
    $calendar_id: option<string>,
    $window: option<string>,
    $not_before: option<datetime>,
    $not_after: option<datetime>,
    $enabled: bool
) {
    LET $t_id = type::record('scheduler_trigger', $trigger_id);
    LET $c_id = IF $calendar_id != NONE THEN type::record('scheduler_calendar', $calendar_id) ELSE NONE END;

    LET $updated = (
        UPDATE $t_id SET
            cron_expression = $cron_expression,
            timezone        = $timezone,
            calendar        = $c_id,
            window          = $window,
            not_before      = $not_before,
            not_after       = $not_after,
            enabled         = $enabled,
            updated_at      = time::now()
        WHERE managed_by = 'api'
        RETURN AFTER
    );

    RETURN array::len($updated) > 0;
};
