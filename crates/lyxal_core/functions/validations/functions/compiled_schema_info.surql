-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_compiled_schema_info
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_compiled_schema_info(
    $compiled_schema: object
) -> object {
    RETURN {
        name: $compiled_schema.name,
        version: $compiled_schema.version,
        field_count: object::len($compiled_schema.fields),
        compiled_at: $compiled_schema.compiled_at
    };
}
COMMENT "Retourne les métadonnées d'un schéma compilé."
PERMISSIONS FULL;
