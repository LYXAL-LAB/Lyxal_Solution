-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::dead_letter_remove_bulk                                 │
-- │  Supprime un lot de dead letters par leurs identifiants.                │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dead_letter_remove_bulk(
    $ids: array<string>
) {
    LET $dl_ids = (
        SELECT VALUE type::record('scheduler_dead_letter', $this) FROM $ids
    );

    LET $deleted = DELETE $dl_ids;
    RETURN array::len($deleted);
};
