-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/cache_merge.surql
-- Fonction : fn::utils_cache_merge
--
-- Purge les expirations et remplace une entrée par clé.
--
-- Paramètres
--   $entries : array<object>
--   $entry   : object
--   $now     : datetime
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
