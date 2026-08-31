-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_cache_replace
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_cache_replace(
    $entries: array<object>,
    $entry: object
) -> array<object> {
    IF $entry.cache_key IS NONE {
        THROW "VALIDATION_INVALID_SCHEMA_CACHE_ENTRY";
    };

    LET $without_existing = array::filter(
        $entries,
        |$item| $item.cache_key != $entry.cache_key
    );

    RETURN array::append($without_existing, $entry);
}
COMMENT "
Remplace ou ajoute une entrée dans une représentation en tableau du cache.
"
PERMISSIONS FULL;
