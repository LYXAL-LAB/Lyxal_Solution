-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/cache_stats.surql
-- Fonction : fn::utils_cache_stats
--
-- Calcule les statistiques d'un cache.
--
-- Paramètres
--   $entries : array<object>
--   $now     : datetime
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
