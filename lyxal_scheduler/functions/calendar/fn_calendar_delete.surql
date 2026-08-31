-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::calendar_delete                                         │
-- │  Supprime un calendrier métier.                                         │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::calendar_delete(
    $calendar_id: string
) {
    LET $c_id = type::record('scheduler_calendar', $calendar_id);
    RETURN DELETE $c_id;
};
