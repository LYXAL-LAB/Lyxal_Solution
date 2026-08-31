-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_occurrence_purge_before                                      │
-- │  Purge technique des anciennes occurrences antérieures à une date       │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_occurrence_purge_before(
    $before_date: option<datetime>
) {
    IF $before_date == NONE {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "before_date" });
    };

    -- Purge des occurrences sans mot-clé SQL FROM
    DELETE error_occurrence WHERE occurred_at < $before_date;

    RETURN fn::result_ok({ purged: true, before: $before_date });
} COMMENT "Purge les anciennes occurrences d'erreurs antérieures à une date donnée (rétention technique)";
