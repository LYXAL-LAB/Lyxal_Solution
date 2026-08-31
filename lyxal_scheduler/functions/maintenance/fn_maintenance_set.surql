-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::maintenance_set                                         │
-- │  Active ou désactive le mode maintenance global.                        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::maintenance_set(
    $manual_active: bool,
    $window_start: option<datetime>,
    $window_end: option<datetime>,
    $note: option<string>,
    $updated_by: option<string>
) {
    RETURN (
        UPSERT scheduler_maintenance:global SET
            manual_active = $manual_active,
            window_start  = $window_start,
            window_end    = $window_end,
            note          = $note,
            updated_by    = $updated_by,
            updated_at    = time::now()
    )[0];
};
