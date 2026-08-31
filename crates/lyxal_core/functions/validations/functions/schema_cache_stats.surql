-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_cache_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_cache_stats(
    $entries: array<object>,
    $now: datetime
) -> object {
    LET $expired = array::filter(
        $entries,
        |$entry| fn::validation_schema_cache_is_expired(
            $entry,
            $now
        )
    );

    RETURN {
        total: array::len($entries),
        expired: array::len($expired),
        active: array::len($entries) - array::len($expired)
    };
}
COMMENT "
Calcule des statistiques simples sur un ensemble d'entrées de cache.
"
PERMISSIONS FULL;
