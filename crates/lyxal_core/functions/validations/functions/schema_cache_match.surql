-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_cache_match
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_cache_match(
    $entry: object,
    $cache_key: string,
    $now: datetime
) -> bool {
    IF $entry.cache_key IS NONE
        OR !type::is_string($entry.cache_key)
    {
        THROW "VALIDATION_INVALID_SCHEMA_CACHE_ENTRY";
    };

    RETURN $entry.cache_key = string::trim($cache_key)
        AND !fn::validation_schema_cache_is_expired(
            $entry,
            $now
        );
}
COMMENT "
Vérifie qu'une entrée correspond à la clé demandée et n'est pas expirée.
"
PERMISSIONS FULL;
