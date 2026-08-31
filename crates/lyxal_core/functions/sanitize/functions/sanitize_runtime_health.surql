-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_runtime_health
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_runtime_health(
    $registry: object,
    $cache_entries: array<object>,
    $now: datetime
) -> object {
    RETURN {
        healthy:true,
        schema_count:array::len($registry.entries),
        active_schema_count:array::len(
            array::filter($registry.entries, |$entry| $entry.status = "active")
        ),
        cache_count:array::len($cache_entries),
        expired_cache_count:array::len(
            array::filter($cache_entries, |$entry| $entry.expires_at <= $now)
        ),
        checked_at:$now
    };
}
COMMENT "Retourne l'état synthétique du runtime."
PERMISSIONS FULL;
