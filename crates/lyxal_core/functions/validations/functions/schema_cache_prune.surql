-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_cache_prune
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_cache_prune(
    $entries: array<object>,
    $now: datetime
) -> array<object> {
    RETURN array::filter(
        $entries,
        |$entry| !fn::validation_schema_cache_is_expired(
            $entry,
            $now
        )
    );
}
COMMENT "
Retire d'un tableau toutes les entrées de cache expirées.
"
PERMISSIONS FULL;
