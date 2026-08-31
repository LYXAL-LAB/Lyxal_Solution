-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_cache_is_expired
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_cache_is_expired(
    $entry: object,
    $now: datetime
) -> bool {
    IF $entry.expires_at IS NONE
        OR !type::is_datetime($entry.expires_at)
    {
        THROW "VALIDATION_INVALID_SCHEMA_CACHE_ENTRY";
    };

    RETURN $entry.expires_at <= $now;
}
COMMENT "
Indique si une entrée de cache de schéma est expirée.
"
PERMISSIONS FULL;
