-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/cache_cleanup.surql
-- Fonction : fn::utils_cache_cleanup
--
-- Supprime les entrées expirées d'un tableau de cache.
--
-- Paramètres
--   $entries : array<object>
--   $now     : datetime
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
