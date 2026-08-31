-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::calendar_get                                            │
-- │  Récupère un calendrier par son identifiant.                            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::calendar_get(
    $calendar_id: string
) {
    LET $c_id = type::record('scheduler_calendar', $calendar_id);
    RETURN (SELECT * FROM $c_id)[0];
};
