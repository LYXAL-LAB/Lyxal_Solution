-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_cache_select
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_cache_select(
    $entries: array<object>,
    $cache_key: string,
    $now: datetime
) -> option<object> {
    LET $matches = array::filter(
        $entries,
        |$entry| fn::validation_schema_cache_match(
            $entry,
            $cache_key,
            $now
        )
    );

    RETURN IF array::len($matches) = 0 {
        NONE
    } ELSE {
        $matches[0]
    };
}
COMMENT "
Sélectionne la première entrée de cache valide correspondant à une clé.
"
PERMISSIONS FULL;
