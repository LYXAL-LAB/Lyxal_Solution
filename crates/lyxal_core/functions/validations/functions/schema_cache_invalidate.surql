-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_cache_invalidate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_cache_invalidate(
    $entries: array<object>,
    $schema_name: string
) -> array<object> {
    LET $prefix = string::concat(
        string::lowercase(string::trim($schema_name)),
        "@"
    );

    RETURN array::filter(
        $entries,
        |$entry|
            !string::starts_with(
                string::lowercase($entry.cache_key),
                $prefix
            )
    );
}
COMMENT "
Invalide toutes les versions en cache d'un schéma donné.
"
PERMISSIONS FULL;
