-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/cache_expired.surql
-- Fonction : fn::utils_cache_expired
--
-- Indique si une entrée de cache est expirée.
--
-- Paramètres
--   $entry : object
--   $now   : datetime
--
-- Valeur renvoyée : bool (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_cache_expired(
    $entry: object,
    $now: datetime
) -> bool {
    RETURN $entry.expires_at <= $now;
}
COMMENT "Indique si une entrée de cache est expirée."
PERMISSIONS FULL;
