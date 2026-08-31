-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_cache_entry
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_cache_entry(
    $cache_key: string,
    $compiled_schema: object,
    $ttl: duration,
    $created_at: datetime
) -> object {
    IF string::trim($cache_key) = "" {
        THROW "VALIDATION_INVALID_SCHEMA_CACHE_KEY";
    };

    IF $ttl <= 0s {
        THROW "VALIDATION_INVALID_SCHEMA_CACHE_TTL";
    };

    RETURN {
        cache_key: string::trim($cache_key),
        compiled_schema: $compiled_schema,
        created_at: $created_at,
        expires_at: $created_at + $ttl,
        ttl: $ttl
    };
}
COMMENT "
Construit une entrée de cache de schéma compilé.
"
PERMISSIONS FULL;
