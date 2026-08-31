-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::dead_letter_remove                                      │
-- │  Supprime une dead letter de la file.                                   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dead_letter_remove(
    $id: string
) {
    LET $dl_id = type::record('scheduler_dead_letter', $id);
    RETURN DELETE $dl_id;
};
