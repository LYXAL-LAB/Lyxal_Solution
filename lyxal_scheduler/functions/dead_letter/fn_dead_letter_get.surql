-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::dead_letter_get                                         │
-- │  Récupère une dead letter par son identifiant.                          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dead_letter_get(
    $id: string
) {
    LET $dl_id = type::record('scheduler_dead_letter', $id);
    RETURN (SELECT * FROM $dl_id)[0];
};
