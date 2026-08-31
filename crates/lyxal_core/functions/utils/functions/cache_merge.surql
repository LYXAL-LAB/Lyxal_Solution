-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_cache_merge
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_cache_merge(
    $entries: array<object>,
    $entry: object,
    $now: datetime
) -> array<object> {
    LET $active = array::filter(
        $entries,
        |$current|
            !fn::utils_cache_expired($current,$now)
            AND $current.key != $entry.key
    );

    RETURN array::append($active,$entry);
}
COMMENT "Purge les expirations et remplace une entrée par clé."
PERMISSIONS FULL;
