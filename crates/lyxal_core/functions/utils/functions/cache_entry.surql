-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/cache_entry.surql
-- Fonction : fn::utils_cache_entry
--
-- Construit une entrée de cache.
--
-- Paramètres
--   $key        : string
--   $value      : any
--   $ttl        : duration
--   $created_at : datetime
--   $metadata   : option<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $ttl <= 0s
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_cache_entry(
    $key: string,
    $value: any,
    $ttl: duration,
    $created_at: datetime,
    $metadata: option<object>
) -> object {
    IF $ttl <= 0s {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN {
        key:string::trim($key),
        value:$value,
        created_at:$created_at,
        updated_at:$created_at,
        expires_at:$created_at+$ttl,
        hits:0,
        metadata:IF $metadata IS NONE{{}}ELSE{$metadata}
    };
}
COMMENT "Construit une entrée de cache."
PERMISSIONS FULL;
