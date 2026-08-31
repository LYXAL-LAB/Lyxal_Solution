-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_compiled_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_compiled_schema(
    $source: object,
    $compiled_fields: object
) -> object {
    RETURN {
        name: $source.name,
        version: $source.version,
        compiled_at: time::now(),
        source: $source.definition,
        fields: $compiled_fields
    };
}
COMMENT "Construit un schéma compilé."
PERMISSIONS FULL;
