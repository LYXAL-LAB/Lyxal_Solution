-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_union_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_union_schema(
    $schemas: array<object>,
    $discriminator: option<string>
) -> object {
    IF array::len($schemas) < 2 { THROW "SANITIZE_UNION_REQUIRES_MULTIPLE_SCHEMAS"; };
    RETURN {
        schemas: $schemas,
        discriminator: IF $discriminator IS NONE { NONE } ELSE { string::trim($discriminator) }
    };
}
COMMENT "Construit une union de schémas."
PERMISSIONS FULL;
