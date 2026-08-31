-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_schema_cache
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_schema_cache(
    $compiled_schema: object,
    $ttl: duration,
    $created_at: datetime
) -> object {
    IF $ttl <= 0s { THROW "SANITIZE_INVALID_SCHEMA_CACHE_TTL"; };
    RETURN {
        key: string::concat($compiled_schema.name,"@",$compiled_schema.version),
        compiled_schema: $compiled_schema,
        created_at: $created_at,
        expires_at: $created_at + $ttl
    };
}
COMMENT "Construit une entrée de cache de schéma compilé."
PERMISSIONS FULL;
