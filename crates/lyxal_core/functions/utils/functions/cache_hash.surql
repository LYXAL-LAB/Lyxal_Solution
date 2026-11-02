-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/cache_hash.surql
-- Fonction : fn::utils_cache_hash
--
-- Calcule l'empreinte d'une entrée de cache.
--
-- Paramètres
--   $entry : object
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_cache_hash(
    $entry: object
) -> string {
    RETURN crypto::sha256(
        encoding::json::encode({
            key:$entry.key,
            value:$entry.value,
            expires_at:$entry.expires_at
        })
    );
}
COMMENT "Calcule l'empreinte d'une entrée de cache."
PERMISSIONS FULL;
