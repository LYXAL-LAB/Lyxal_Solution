-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_cache_cleanup
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_cache_cleanup(
    $entries: array<object>,
    $now: datetime
) -> array<object> {
    RETURN array::filter(
        $entries,
        |$entry| !fn::utils_cache_expired($entry,$now)
    );
}
COMMENT "Supprime les entrées expirées d'un tableau de cache."
PERMISSIONS FULL;
