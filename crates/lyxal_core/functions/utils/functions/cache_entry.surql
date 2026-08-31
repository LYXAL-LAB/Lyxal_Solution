-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_cache_entry
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_cache_entry(
    $key: string,
    $value: any,
    $ttl: duration,
    $created_at: datetime,
    $metadata: option<object>
) -> object {
    IF $ttl <= 0s {
        THROW "UTILS_INVALID_CACHE_TTL";
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
