-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_cache_touch
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_cache_touch(
    $entry: object,
    $ttl: duration,
    $now: datetime
) -> object {
    IF $ttl <= 0s {
        THROW "VALIDATION_INVALID_SCHEMA_CACHE_TTL";
    };

    RETURN object::extend(
        $entry,
        {
            touched_at: $now,
            expires_at: $now + $ttl,
            ttl: $ttl
        }
    );
}
COMMENT "
Prolonge la durée de vie d'une entrée de cache.
"
PERMISSIONS FULL;
