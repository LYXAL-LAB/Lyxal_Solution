-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_cache_stats
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_cache_stats(
    $entries: array<object>,
    $now: datetime
) -> object {
    LET $expired = array::filter(
        $entries,
        |$entry| fn::utils_cache_expired($entry,$now)
    );

    LET $active = array::filter(
        $entries,
        |$entry| !fn::utils_cache_expired($entry,$now)
    );

    RETURN {
        total:array::len($entries),
        active:array::len($active),
        expired:array::len($expired),
        total_hits:array::fold(
            $entries,
            0,
            |$hits,$entry|$hits+IF $entry.hits IS NONE{0}ELSE{$entry.hits}
        )
    };
}
COMMENT "Calcule les statistiques d'un cache."
PERMISSIONS FULL;
