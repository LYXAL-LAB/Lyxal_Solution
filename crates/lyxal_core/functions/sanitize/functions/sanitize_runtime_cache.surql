-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_runtime_cache
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_runtime_cache(
    $cache_entries: array<object>,
    $entry: object,
    $now: datetime
) -> array<object> {
    LET $active = array::filter(
        $cache_entries,
        |$item| $item.expires_at > $now AND $item.key != $entry.key
    );
    RETURN array::append($active,$entry);
}
COMMENT "Purge les entrées expirées et remplace la clé courante."
PERMISSIONS FULL;
