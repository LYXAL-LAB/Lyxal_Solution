-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/cache_info.surql
-- Fonction : fn::utils_cache_info
--
-- Retourne les métadonnées d'une entrée de cache.
--
-- Paramètres
--   $entry : object
--   $now   : datetime
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_cache_info(
    $entry: object,
    $now: datetime
) -> object {
    RETURN {
        key:$entry.key,
        expired:fn::utils_cache_expired($entry,$now),
        hits:IF $entry.hits IS NONE{0}ELSE{$entry.hits},
        created_at:$entry.created_at,
        updated_at:$entry.updated_at,
        expires_at:$entry.expires_at,
        remaining:IF $entry.expires_at <= $now {
            0s
        } ELSE {
            $entry.expires_at-$now
        },
        hash:fn::utils_cache_hash($entry)
    };
}
COMMENT "Retourne les métadonnées d'une entrée de cache."
PERMISSIONS FULL;
