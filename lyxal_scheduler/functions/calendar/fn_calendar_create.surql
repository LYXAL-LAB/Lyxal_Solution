-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::calendar_create                                         │
-- │  Crée ou met à jour un calendrier métier.                              │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::calendar_create(
    $calendar_id: string,
    $name: string,
    $timezone: option<string>,
    $rules: array<string>,
    $managed_by: string
) {
    LET $c_id = type::record('scheduler_calendar', $calendar_id);

    RETURN (
        UPSERT $c_id SET
            name       = $name,
            timezone   = $timezone,
            rules      = $rules,
            managed_by = $managed_by,
            updated_at = time::now()
    )[0];
};
